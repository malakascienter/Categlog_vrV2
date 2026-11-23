/*  Record that a run issued a coupon, so the exit lookup is a seek.

    Guarded the same way as LTYJ_Step_Begin: a replayed ISSUE_VOUCHER collides on
    (RunId, VoucherRef) and the existing CouponId is returned instead of a second
    registration.                                                                 */
CREATE PROCEDURE dbo.LTYJ_RunVoucher_Register
    @RunId      bigint,
    @JourneyId  int,
    @MemberId   int,
    @PropertyId int,
    @CouponId   int,
    @VoucherRef varchar(50),
    @NodeKey    varchar(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.LTYJ_RunVoucher (RunId, JourneyId, MemberId, PropertyId, CouponId, VoucherRef, NodeKey)
        VALUES (@RunId, @JourneyId, @MemberId, @PropertyId, @CouponId, @VoucherRef, @NodeKey);

        SELECT CAST(SCOPE_IDENTITY() AS bigint) AS RunVoucherId, @CouponId AS CouponId, 1 AS IsNew;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2627, 2601) THROW;

        SELECT RunVoucherId, CouponId, 0 AS IsNew
        FROM   dbo.LTYJ_RunVoucher
        WHERE  RunId = @RunId AND VoucherRef = @VoucherRef;
    END CATCH
END

GO

