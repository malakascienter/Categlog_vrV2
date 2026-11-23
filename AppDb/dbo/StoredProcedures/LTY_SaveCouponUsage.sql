-- =============================================
-- Author:      Ravindu
-- Create date: 2026-08-17
-- Modified:    2026-08-18 - three defects fixed. See script 186's header; the
--              reversal change alters behaviour and needs POS sign-off.
-- Description: Put a coupon on an order, or take it back off.
--
--              @IsUse = 1  inserts the usage row, so LTY_GetCoupon stops offering
--                          the coupon.
--              @IsUse = 0  deletes THAT COUPON's row again, so it is offered once
--                          more. Other coupons on the same order are untouched.
--
--              Applying a coupon that is already on this order is not an error -
--              the row is left as it is rather than duplicated, so a repeated
--              call from the till changes nothing. That is what the original
--              comment promised and what this version actually does.
-- =============================================
-- EXEC [dbo].[LTY_SaveCouponUsage] @PropertyId=1, @Outlet='300', @OrderNo='ORD-00020',
--                                  @TxnDate='2026-08-17 13:00:00', @CouponId=1, @IsUse=1
CREATE PROCEDURE [dbo].[LTY_SaveCouponUsage]
    @PropertyId INT,
    @Outlet     VARCHAR(20),
    @OrderNo    VARCHAR(50),
    @TxnDate    DATETIME,
    @CouponId   INT,
    @IsUse      BIT = 1
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        IF (NULLIF(LTRIM(RTRIM(@OrderNo)), '') IS NULL)
        BEGIN
            RAISERROR('An order number is required.', 16, 1);
        END

        IF (ISNULL(@IsUse, 1) = 1)
        BEGIN

            IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponMaster]
                           WHERE Id = @CouponId AND PropertyId = @PropertyId)
            BEGIN
                RAISERROR('This coupon does not exist.', 16, 1);
            END

            /*  Spent on some OTHER order, so it is not available for this one.

                The exclusion of the current order is the fix for defect 1. Without
                it the second call for the same order - a till retry, a double-tap,
                a re-send after a timeout - failed with a message blaming an order
                that does not exist.

                Outlet and date are part of the order key here because that is how
                the reversal branch has always identified a row; matching on
                OrderNo alone would treat the same order number at two outlets as
                one order.                                                        */
            IF EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage]
                       WHERE CouponId   = @CouponId
                         AND PropertyId = @PropertyId
                         AND IsUse      = 1
                         AND NOT (OrderNo = @OrderNo
                                  AND Outlet = @Outlet
                                  AND CONVERT(date, OrderDate) = CONVERT(date, @TxnDate)))
            BEGIN
                RAISERROR('This coupon has already been used on another order.', 16, 1);
            END

            IF EXISTS (SELECT 1 FROM [dbo].[LTY_CouponMaster]
                       WHERE Id = @CouponId
                         AND PropertyId = @PropertyId
                         AND ExpireDate < @TxnDate)
            BEGIN
                RAISERROR('This coupon has expired.', 16, 1);
            END

            /*  Withdrawn coupons cannot be applied. Guarded on <> 'ACTIVE' rather
                than = 'CANCELLED' so any future status is refused by default -
                a status this procedure has never heard of must not silently pass. */
            IF EXISTS (SELECT 1 FROM [dbo].[LTY_CouponMaster]
                       WHERE Id = @CouponId
                         AND PropertyId = @PropertyId
                         AND ISNULL(Status, 'ACTIVE') <> 'ACTIVE')
            BEGIN
                RAISERROR('This coupon is no longer valid.', 16, 1);
            END

            /*  Already on this order: leave it alone rather than add a second row.

                Defect 2 was that this tested only CouponId, so it could not tell
                this order from another - and could never be true anyway, because
                the guard above raised first for any IsUse = 1 row. It now matches
                the full order key and does what its comment always claimed.       */
            IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage]
                           WHERE CouponId   = @CouponId
                             AND PropertyId = @PropertyId
                             AND OrderNo    = @OrderNo
                             AND Outlet     = @Outlet
                             AND CONVERT(date, OrderDate) = CONVERT(date, @TxnDate))
            BEGIN
                INSERT INTO [dbo].[LTY_CouponUsage]
                    (PropertyId, Outlet, OrderNo, OrderDate, CouponId, IsUse)
                VALUES
                    (@PropertyId, @Outlet, @OrderNo, @TxnDate, @CouponId, 1);
            END

        END
        ELSE
        BEGIN

            /*  Taken off the order: THIS coupon's row goes, and it is offered again.

                Defect 3, and the one real behaviour change in this script. The
                CouponId predicate was commented out, so removing one coupon from
                an order removed every coupon on it. The caller names a coupon and
                the header says "deletes it again" - singular - so this is what
                both the signature and the documentation always described.

                A caller that relied on clearing a whole order in one call must now
                make one call per coupon.                                          */
            DELETE FROM [dbo].[LTY_CouponUsage]
            WHERE PropertyId = @PropertyId
              AND CouponId   = @CouponId
              AND OrderNo    = @OrderNo
              AND Outlet     = @Outlet
              AND CONVERT(date, OrderDate) = CONVERT(date, @TxnDate);

        END

        COMMIT TRANSACTION;

        SELECT @CouponId AS CouponId;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSev   INT            = ERROR_SEVERITY();
        DECLARE @ErrState INT            = ERROR_STATE();

        RAISERROR(@ErrMsg, @ErrSev, @ErrState);

    END CATCH
END

GO

