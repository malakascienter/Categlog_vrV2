-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Delete a coupon.
--
--              A hard delete, unlike the soft deletes elsewhere in this module:
--              LTY_CouponMaster has no IsActive or IsDeleted column to set. Add
--              one if coupons need to survive deletion for reporting.
--
--              A coupon already spent is refused - the order it was used on
--              would otherwise point at a row that no longer exists. Deactivate
--              by setting the expiry into the past instead.
--
--              The DocumentNo it consumed is not given back;
--              LTY_TransactionTypeWiseNextNumbers only ever moves forward.
-- =============================================
-- EXEC [dbo].[LTY_DeleteCoupon] @CouponId = 1, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_DeleteCoupon]
	@CouponId INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponMaster]
					   WHERE Id = @CouponId AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('This coupon no longer exists.', 16, 1);
		END

		IF EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage]
				   WHERE CouponId = @CouponId AND PropertyId = @PropertyId AND IsUse = 1)
		BEGIN
			RAISERROR('This coupon has already been used and cannot be deleted. Expire it instead.', 16, 1);
		END

		-- Nothing should be left here once the guard above passes, but a usage
		-- row with IsUse = 0 would still orphan itself against the coupon.
		DELETE FROM [dbo].[LTY_CouponUsage]
		WHERE CouponId = @CouponId AND PropertyId = @PropertyId;

		DELETE FROM [dbo].[LTY_CouponMaster]
		WHERE Id = @CouponId AND PropertyId = @PropertyId;

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

