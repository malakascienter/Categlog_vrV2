/*  Has the voucher this run issued been spent?

    Backs the CONDITION node. Reads LTY_CouponUsage directly rather than trusting
    LTYJ_RunVoucher.UsedAt, because that column is only stamped when an outbox
    event is processed - and this check is the defensive one that has to hold even
    if an event was missed.

    Expiry counts as "not used": an expired voucher was never redeemed, and the
    journey's own exit rules decide what to do about it.                          */
CREATE PROCEDURE dbo.LTYJ_RunVoucher_IsUsed
    @RunId      bigint,
    @VoucherRef varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT rv.CouponId,
           cm.ExpireDate,
           CASE WHEN EXISTS (SELECT 1 FROM dbo.LTY_CouponUsage cu
                             WHERE cu.CouponId   = rv.CouponId
                               AND cu.PropertyId = rv.PropertyId
                               AND cu.IsUse      = 1)
                THEN 1 ELSE 0 END AS IsUsed,
           CASE WHEN cm.ExpireDate < SYSDATETIME() THEN 1 ELSE 0 END AS IsExpired
    FROM   dbo.LTYJ_RunVoucher AS rv
    LEFT JOIN dbo.LTY_CouponMaster AS cm ON cm.Id = rv.CouponId
    WHERE  rv.RunId = @RunId AND rv.VoucherRef = @VoucherRef;
END

GO

