-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-11
-- Description:	Redeem points against a settled POS order.
--
--              2026-08-17: @TxnType added.
--
--                'S'  the existing redemption. Nothing about it changed.
--
--                'V'  void the order. Nothing already written is touched - the void
--                     only adds rows:
--
--                       a 'V' row carrying the negative of what the order earned,
--                       which cancels those points out
--
--                       a 'G' row carrying the positive of what the order redeemed,
--                       which hands the spent points back
--
--                     The rows being reversed are found by
--                     OrderNo + PropertyId + OutletCode + TxnDate. History stays as
--                     written, so the ledger shows the sale and the reversal side
--                     by side.
--
--              A void writes no 'R' row and does no balance check - it only reverses.
--
--              NOTE: the 'V' row is what removes the earned points, through its own
--              negative amount. FN_LTY_GetMemberPointBalance must therefore COUNT
--              'V' rows. Script 145, which excluded them, belongs to the earlier
--              update-in-place design and must not be left applied alongside this
--              one - see script 148.
-- =============================================
-- EXEC [dbo].[LTY_PointRedeem] @TelephoneNo='0702375050', @OutletCode='300',
--      @RedeemPointCount=0, @NetAmount=0, @OrderDate='2026-08-17 13:00',
--      @OrderNo='ORD-00020', @PropertyId=1, @UserId=4168, @TxnType='V'
CREATE   PROCEDURE [dbo].[LTY_PointRedeem]
	@TelephoneNo NVARCHAR(20),
	@OutletCode VARCHAR(50),
	@RedeemPointCount DECIMAL(18,2),
	@NetAmount DECIMAL(18,4),
	@OrderDate DATETIME,
	@OrderNo VARCHAR(MAX),
	@PropertyId INT,
	@UserId INT,
	@TxnType VARCHAR(10) = 'S'
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @TransactionType VARCHAR(10) = 'R';
	DECLARE @MemberId      INT;
	DECLARE @PointsBefore  DECIMAL(18,2);
	DECLARE @PointsBalance DECIMAL(18,2);
	DECLARE @TransactionId INT;
	DECLARE @NeverExpires  DATETIME = CONVERT(DATETIME, '9999-12-31');

	-- Void
	DECLARE @EarnPoints        DECIMAL(18,2);
	DECLARE @EarnBillValue     DECIMAL(18,4);
	DECLARE @GivebackPoints    DECIMAL(18,2);
	DECLARE @GivebackBillValue DECIMAL(18,4);
	DECLARE @VoidRowId         INT;
	DECLARE @ReturnRowId       INT;

	SET @TxnType = ISNULL(NULLIF(LTRIM(RTRIM(@TxnType)), ''), 'S');

	BEGIN TRY

		BEGIN TRANSACTION;

		IF (NULLIF(LTRIM(RTRIM(@TelephoneNo)), '') IS NULL)
		BEGIN
			RAISERROR('A telephone number is required to redeem points.', 16, 1);
		END

		---- Resolve the member from the telephone number ----
		SELECT @MemberId = MemberId
		FROM [dbo].[LTY_Member]
		WHERE PrimaryMobileNo = @TelephoneNo
		  AND PropertyId      = @PropertyId
		  AND IsActive        = 1;

		IF (@MemberId IS NULL)
		BEGIN
			RAISERROR('No active member is registered with this telephone number.', 16, 1);
		END

		IF (@TxnType = 'V')
		BEGIN

			---- Void ---------------------------------------------------------------

			-- The 'V' row written below is also the marker that says this order has
			-- been dealt with, so this is what stops a second void crediting again.
			IF EXISTS (SELECT 1 FROM [dbo].[LTY_MemberWisePointTransaction]
					   WHERE OrderNo         = @OrderNo
						 AND PropertyId      = @PropertyId
						 AND OutletCode      = @OutletCode
						 AND TxnDate         = @OrderDate
						 AND TransactionType = 'V')
			BEGIN
				RAISERROR('This order has already been voided.', 16, 1);
			END

			-- What the order earned. The row itself is left exactly as written.
			SELECT TOP (1)
				@EarnPoints    = t.NoPoints,
				@EarnBillValue = t.BillValue
			FROM [dbo].[LTY_MemberWisePointTransaction] AS t
			WHERE t.OrderNo         = @OrderNo
			  AND t.PropertyId      = @PropertyId
			  AND t.OutletCode      = @OutletCode
			  AND CONVERT(DATE,t.TxnDate)         =  CONVERT(DATE,@OrderDate)  
			  AND t.TransactionType = 'G'
			ORDER BY t.Id ASC;

			-- What the order redeemed. Also left as written.
			SELECT TOP (1)
				@GivebackPoints    = ABS(t.NoPoints),
				@GivebackBillValue = t.BillValue
			FROM [dbo].[LTY_MemberWisePointTransaction] AS t
			WHERE t.OrderNo         = @OrderNo
			  AND t.PropertyId      = @PropertyId
			  AND t.OutletCode      = @OutletCode
			  AND CONVERT(DATE,t.TxnDate)         =  CONVERT(DATE,@OrderDate)  
			  AND t.TransactionType = 'R'
			ORDER BY t.Id DESC;

			--IF (@EarnPoints IS NULL AND @GivebackPoints IS NULL)
			--BEGIN
			--	RAISERROR('No earn or redeem transaction was found for this order to void.', 16, 1);
			--END

			---- 1. Reverse the earn with a 'V' row carrying the negative. Written
			----    even when the order earned nothing, because this row is what
			----    marks the order voided.
			SET @PointsBefore  = [dbo].[FN_LTY_GetMemberPointBalance](@PropertyId, @TelephoneNo);
			SET @PointsBalance = @PointsBefore - ISNULL(@EarnPoints, 0);

		
			IF( ISNULL(@EarnPoints,0) > 0)
			BEGIN

				INSERT INTO [dbo].[LTY_MemberWisePointTransaction]
						(
							MemberId, NoPoints, OutletCode, PropertyId, BillValue,
							PointsBefore, PointsBalance, TransactionType, Remark, TxnDate,
							CreatedUserId, CreatedDateTime, OrderNo, ExpireDate
						)
						VALUES
						(
							@MemberId,
							-ISNULL(@EarnPoints, 0),
							@OutletCode,
							@PropertyId,
							ISNULL(@EarnBillValue, @NetAmount),
							@PointsBefore,
							@PointsBalance,
							'V',
							'Points reversed on void of order ' + @OrderNo,
							@OrderDate,
							@UserId,
							GETDATE(),
							@OrderNo,
							@NeverExpires
						);
 
					SET @VoidRowId = SCOPE_IDENTITY();

			END

			SET @VoidRowId = ISNULL(@VoidRowId,0)

			---- 2. Hand back what was redeemed, as a positive 'G'.
			IF (ISNULL(@GivebackPoints, 0) > 0)
			BEGIN

				SET @PointsBefore  = @PointsBalance;
				SET @PointsBalance = @PointsBefore + @GivebackPoints;

				INSERT INTO [dbo].[LTY_MemberWisePointTransaction]
				(
					MemberId, NoPoints, OutletCode, PropertyId, BillValue,
					PointsBefore, PointsBalance, TransactionType, Remark, TxnDate,
					CreatedUserId, CreatedDateTime, OrderNo, ExpireDate
				)
				VALUES
				(
					@MemberId,
					@GivebackPoints,
					@OutletCode,
					@PropertyId,
					ISNULL(@GivebackBillValue, @NetAmount),
					@PointsBefore,
					@PointsBalance,
					'G',
					'Points returned on void of order ' + @OrderNo,
					@OrderDate,
					@UserId,
					GETDATE(),
					@OrderNo,
					@NeverExpires
				);

				SET @ReturnRowId = SCOPE_IDENTITY();

			END

			COMMIT TRANSACTION;

			SELECT
				@VoidRowId                 AS TransactionId,
				@ReturnRowId               AS ReturnTransactionId,
				ISNULL(@EarnPoints, 0)     AS ReversedPoints,
				ISNULL(@GivebackPoints, 0) AS ReturnedPoints,
				@PointsBalance             AS PointsBalance;

			RETURN;

		END

		---- 'S' - the existing redemption, unchanged --------------------------------

		IF (ISNULL(@RedeemPointCount, 0) <= 0)
		BEGIN
			RAISERROR('The redeem point count must be greater than zero.', 16, 1);
		END

		IF EXISTS (SELECT 1 FROM [dbo].[LTY_MemberWisePointTransaction]
				   WHERE OrderNo         = @OrderNo
					 AND PropertyId      = @PropertyId
					 AND OutletCode      = @OutletCode
					 AND TransactionType = @TransactionType)
		BEGIN
			RAISERROR('Points have already been redeemed for this order.', 16, 1);
		END

		---- Current balance ----
		SET @PointsBefore = [dbo].[FN_LTY_GetMemberPointBalance](@PropertyId, @TelephoneNo);

		IF (@RedeemPointCount > @PointsBefore)
		BEGIN
			RAISERROR('The member does not have enough points for this redemption.', 16, 1);
		END

		SET @PointsBalance = @PointsBefore - @RedeemPointCount;

		INSERT INTO [dbo].[LTY_MemberWisePointTransaction]
		(
			MemberId, NoPoints, OutletCode, PropertyId, BillValue,
			PointsBefore, PointsBalance, TransactionType, Remark, TxnDate,
			CreatedUserId, CreatedDateTime, OrderNo, ExpireDate
		)
		VALUES
		(
			@MemberId,
			-@RedeemPointCount,
			@OutletCode,
			@PropertyId,
			@NetAmount,
			@PointsBefore,
			@PointsBalance,
			@TransactionType,
			'Points redeemed for order ' + @OrderNo,
			@OrderDate,
			@UserId,
			GETDATE(),
			@OrderNo,
			@NeverExpires
		);

		SET @TransactionId = SCOPE_IDENTITY();

		COMMIT TRANSACTION;

		SELECT
			@TransactionId    AS TransactionId,
			@RedeemPointCount AS RedeemedPoints,
			@PointsBefore     AS PointsBefore,
			@PointsBalance    AS PointsBalance;

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

