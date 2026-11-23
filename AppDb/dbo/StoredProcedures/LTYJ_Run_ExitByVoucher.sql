/*  The global exit. Applied when a VOUCHER_USED event drains from the outbox.

    Finds every live run that issued this coupon and ends it. The lookup is a seek
    on IX_LTYJ_RunVoucher_Coupon rather than a JSON scan across live runs, which
    is the whole reason LTYJ_RunVoucher exists.

    A run mid-execution (LockedUntil in the future) is still exited here. That is
    deliberate: the owning worker re-reads status before acting on any side
    effect, so the worst case is a wasted step, not a wrong send. Letting the run
    continue because a worker happens to hold it would be the actual bug.

    Note this is one of TWO independent paths that enforce the exit. The other is
    a defensive re-check immediately before every action node. Either alone would
    do; both together mean a missed event still cannot produce a reminder for a
    voucher that has already been spent.                                          */
CREATE PROCEDURE dbo.LTYJ_Run_ExitByVoucher
    @CouponId   int,
    @PropertyId int,
    @ExitReason varchar(50) = 'VOUCHER_USED'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();

    UPDATE rv
    SET    rv.UsedAt = ISNULL(rv.UsedAt, @now)
    FROM   dbo.LTYJ_RunVoucher AS rv
    WHERE  rv.CouponId = @CouponId AND rv.PropertyId = @PropertyId;

    UPDATE r
    SET    r.Status      = 'EXITED',
           r.ExitReason  = @ExitReason,
           r.EndedAt     = @now,
           r.NextRunAt   = NULL,
           r.LockedBy    = NULL,
           r.LockedUntil = NULL
    OUTPUT inserted.RunId, inserted.JourneyId, inserted.MemberId
    FROM   dbo.LTYJ_Run AS r
    INNER JOIN dbo.LTYJ_RunVoucher AS rv
            ON rv.RunId = r.RunId
    WHERE  rv.CouponId  = @CouponId
      AND  rv.PropertyId = @PropertyId
      AND  r.Status IN ('ACTIVE','WAITING');
END

GO

