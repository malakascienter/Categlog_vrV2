-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Save a coupon (insert or update), from the admin portal.
--
--              Insert numbers the coupon from the outlet's own counter under
--              TransactionType 'COU', the same way LTY_PointEarn numbers the
--              coupons it issues. Update never touches DocumentNo - the number
--              is the coupon's identity once it has been handed out.
--
--              A coupon already spent (an LTY_CouponUsage row with IsUse = 1)
--              cannot be edited; the value the customer was given has to stay
--              what it was.
--
--              LTY_CouponMaster has no ModifyBy / ModifyDate, so an update
--              leaves no audit trail. Add those columns if that matters.
--
--              The client sends @ExpireDayCount, not a date. The date is worked
--              out here:
--                insert - CreatedDate (now) + n
--                update - the ORIGINAL CreatedDate + n
--              Counting an edit from the original creation date is what makes
--              the value stable: LTY_GetCouponById hands the count back as
--              DATEDIFF(CreatedDate, ExpireDate), so opening a coupon and
--              saving it unchanged leaves the expiry exactly where it was.
--              Counting from GETDATE() would quietly extend it every time.
-- =============================================
-- EXEC [dbo].[LTY_SaveCoupon] @PropertyId=1, @MemberId=1, @Outlet='300',
--      @IsPerecentage=1, @Value=25, @ExpireDayCount=90, @CreateBy=4168
CREATE   PROCEDURE [dbo].[LTY_SaveCoupon]
	@CouponId INT = NULL,            -- NULL/0 to insert, existing Id to update
	@PropertyId INT,
	@MemberId INT = NULL,
	@Outlet VARCHAR(20),
	@IsPerecentage BIT = 0,
	@Value DECIMAL(18,4),
	@ExpireDayCount INT,
	@CreateBy INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @CouponTxnType CHAR(4) = 'COU';
	DECLARE @DocNo NVARCHAR(300);
	DECLARE @CreatedDate DATETIME;
	DECLARE @ExpireDate DATETIME;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF (NULLIF(LTRIM(RTRIM(@Outlet)), '') IS NULL)
		BEGIN
			RAISERROR('An outlet is required.', 16, 1);
		END

		IF (ISNULL(@Value, 0) <= 0)
		BEGIN
			RAISERROR('The coupon value must be greater than zero.', 16, 1);
		END

		IF (@IsPerecentage = 1 AND @Value > 100)
		BEGIN
			RAISERROR('A percentage coupon cannot be worth more than 100.', 16, 1);
		END

		IF (ISNULL(@ExpireDayCount, 0) <= 0)
		BEGIN
			RAISERROR('The expire day count must be greater than zero.', 16, 1);
		END

		IF (@MemberId IS NOT NULL
			AND NOT EXISTS (SELECT 1 FROM [dbo].[LTY_Member]
							WHERE MemberId = @MemberId AND PropertyId = @PropertyId AND IsActive = 1))
		BEGIN
			RAISERROR('No active member holds this member id.', 16, 1);
		END

		IF (@CouponId IS NULL OR @CouponId = 0)
		BEGIN

			-- A new coupon starts counting from now.
			SET @CreatedDate = GETDATE();
			SET @ExpireDate  = DATEADD(DAY, @ExpireDayCount, @CreatedDate);

			---- Get Doc No ----
			SELECT @DocNo = [dbo].[FN_LTY_GetNextDocumentNumber](@PropertyId, @Outlet, @CouponTxnType);
			IF (@DocNo IS NULL)
			BEGIN
				EXEC [dbo].[LTY_InsertDocumentNumber] @PropertyId, @Outlet, @CouponTxnType;
				SELECT @DocNo = [dbo].[FN_LTY_GetNextDocumentNumber](@PropertyId, @Outlet, @CouponTxnType);
			END

			INSERT INTO [dbo].[LTY_CouponMaster]
			(
				DocumentNo, PropertyId, MemberId, Outlet,
				IsPerecentage, Value, ExpireDate, CreateBy, CreatedDate
			)
			VALUES
			(
				CONCAT(TRIM(@CouponTxnType), '/', @Outlet, '/', @DocNo),
				@PropertyId, @MemberId, @Outlet,
				@IsPerecentage, @Value, @ExpireDate, @CreateBy, @CreatedDate
			);

			SET @CouponId = SCOPE_IDENTITY();

			UPDATE [dbo].[LTY_TransactionTypeWiseNextNumbers]
			SET NextNumber = NextNumber + 1
			WHERE PropertyID      = @PropertyId
			  AND LocationCode    = @Outlet
			  AND TransactionType = @CouponTxnType;

		END
		ELSE
		BEGIN

			IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_CouponMaster]
						   WHERE Id = @CouponId AND PropertyId = @PropertyId)
			BEGIN
				RAISERROR('This coupon no longer exists.', 16, 1);
			END

			IF EXISTS (SELECT 1 FROM [dbo].[LTY_CouponUsage]
					   WHERE CouponId = @CouponId AND PropertyId = @PropertyId AND IsUse = 1)
			BEGIN
				RAISERROR('This coupon has already been used and cannot be changed.', 16, 1);
			END

			-- Re-count from the original creation date, not from today, so an
			-- unchanged save does not move the expiry.
			SELECT @CreatedDate = CreatedDate
			FROM [dbo].[LTY_CouponMaster]
			WHERE Id = @CouponId AND PropertyId = @PropertyId;

			SET @ExpireDate = DATEADD(DAY, @ExpireDayCount, @CreatedDate);

			UPDATE [dbo].[LTY_CouponMaster]
			SET
				MemberId      = @MemberId,
				Outlet        = @Outlet,
				IsPerecentage = @IsPerecentage,
				Value         = @Value,
				ExpireDate    = @ExpireDate
			WHERE Id = @CouponId
			  AND PropertyId = @PropertyId;

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

