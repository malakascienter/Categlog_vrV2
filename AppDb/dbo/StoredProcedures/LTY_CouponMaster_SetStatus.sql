/*  Withdraw or reinstate a coupon.

    Refuses to withdraw one that has already been spent. The redemption has
    happened, the discount was given, and marking the coupon cancelled afterwards
    would misdescribe what took place - the correction for that is a refund on the
    order, not an edit here.                                                      */
CREATE PROCEDURE dbo.LTY_CouponMaster_SetStatus
    @CouponId   int,
    @PropertyId int,
    @Status     varchar(20),
    @Reason     nvarchar(300) = NULL,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (@Status NOT IN ('ACTIVE','CANCELLED','EXPIRED'))
        THROW 50430, 'Status must be ACTIVE, CANCELLED or EXPIRED.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTY_CouponMaster WHERE Id = @CouponId AND PropertyId = @PropertyId)
        THROW 50431, 'This coupon does not exist.', 1;

    IF (@Status <> 'ACTIVE'
        AND EXISTS (SELECT 1 FROM dbo.LTY_CouponUsage
                    WHERE CouponId = @CouponId AND PropertyId = @PropertyId AND IsUse = 1))
        THROW 50432, 'This coupon has already been used and cannot be withdrawn.', 1;

    UPDATE dbo.LTY_CouponMaster
    SET    Status       = @Status,
           StatusReason = @Reason,
           ModifyBy     = @ActionBy,
           ModifyDate   = GETDATE()
    WHERE  Id = @CouponId AND PropertyId = @PropertyId;

    SELECT CouponId = @CouponId, Status = @Status;
END

GO

