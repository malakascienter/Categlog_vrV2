-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-14
-- Description:	Manual points adjustment for one or more members.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_PointAdjust]
	@MemberIdsJson NVARCHAR(MAX),
	@Points DECIMAL(18,2),
	@IsAddPoint BIT,
	@IsExpire BIT = 0,          -- accepted for compatibility; the date decides
	@ExpiryDate DATE = NULL,
	@PropertyId INT,
	@CreateBy INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @TransactionType VARCHAR(10) =
		CASE WHEN @IsAddPoint = 1 THEN 'G' ELSE 'E' END;
	DECLARE @NeverExpires DATETIME = CONVERT(DATETIME, '9999-12-31');
	DECLARE @ExpireDate   DATETIME;
	DECLARE @Remark       VARCHAR(MAX);
	DECLARE @Now          DATETIME = GETDATE();
	DECLARE @BatchRef     VARCHAR(50);
	DECLARE @Affected     INT;

	CREATE TABLE #Member (MemberId INT NOT NULL PRIMARY KEY);

	INSERT INTO #Member (MemberId)
	SELECT DISTINCT CONVERT(INT, [value])
	FROM OPENJSON(@MemberIdsJson)
	WHERE NULLIF(LTRIM(RTRIM([value])), '') IS NOT NULL;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM #Member)
		BEGIN
			RAISERROR('At least one member must be selected.', 16, 1);
		END

		IF (@IsAddPoint = 1 AND ISNULL(@Points, 0) <= 0)
		BEGIN
			RAISERROR('The point value must be greater than zero.', 16, 1);
		END

		-- Points expiring in the past would be granted and immediately unusable,
		-- with nothing on screen to say why. Delete these three lines if a
		-- back-dated expiry is legitimate.
		IF (@IsAddPoint = 1 AND @ExpiryDate IS NOT NULL AND @ExpiryDate < CAST(@Now AS DATE))
		BEGIN
			RAISERROR('The expiry date cannot be in the past.', 16, 1);
		END

		IF EXISTS (SELECT 1 FROM #Member AS x
				   WHERE NOT EXISTS (SELECT 1 FROM [dbo].[LTY_Member] AS m
									 WHERE m.MemberId   = x.MemberId
									   AND m.PropertyId = @PropertyId
									   AND m.IsActive   = 1))
		BEGIN
			RAISERROR('One or more selected members do not exist or are inactive.', 16, 1);
		END

		-- The supplied date wins whenever there is one; no date means never expires.
		SET @ExpireDate = CASE WHEN @IsAddPoint = 1 AND @ExpiryDate IS NOT NULL
							   THEN CONVERT(DATETIME, @ExpiryDate)
							   ELSE @NeverExpires END;
		SET @BatchRef   = CONCAT('ADJ-', FORMAT(@Now, 'yyyyMMddHHmmssfff'));
		SET @Remark     = CASE WHEN @IsAddPoint = 1
							   THEN CONCAT('Points added by adjustment ', @BatchRef)
							   ELSE CONCAT('Points expired by adjustment ', @BatchRef) END;

		---- Each member's balance before the adjustment ----
		SELECT
			x.MemberId,
			ISNULL(b.PointsBalance, 0) AS PointsBefore
		INTO #Balance
		FROM #Member AS x
		OUTER APPLY
		(
			SELECT TOP (1) t.PointsBalance
			FROM [dbo].[LTY_MemberWisePointTransaction] AS t
			WHERE t.MemberId   = x.MemberId
			  AND t.PropertyId = @PropertyId
			ORDER BY t.Id DESC
		) AS b;

		INSERT INTO [dbo].[LTY_MemberWisePointTransaction]
		(
			MemberId, NoPoints, OutletCode, PropertyId, BillValue,
			PointsBefore, PointsBalance, TransactionType, Remark, TxnDate,
			CreatedUserId, CreatedDateTime, OrderNo, ExpireDate
		)
		SELECT
			b.MemberId,
			-- Expiring writes the balance back as a negative, so the row lands on zero.
			CASE WHEN @IsAddPoint = 1 THEN @Points ELSE -b.PointsBefore END,
			'-999',                      -- no outlet: the column is NOT NULL
			@PropertyId,
			0,                           -- no bill behind an adjustment
			b.PointsBefore,
			CASE WHEN @IsAddPoint = 1 THEN b.PointsBefore + @Points ELSE 0 END,
			@TransactionType,
			@Remark,
			@Now,
			@CreateBy,
			@Now,
			@BatchRef,
			@ExpireDate
		FROM #Balance AS b
		-- Nothing to expire for a member already on zero or below.
		WHERE @IsAddPoint = 1 OR b.PointsBefore > 0;

		SET @Affected = @@ROWCOUNT;

		COMMIT TRANSACTION;

		SELECT
			@Affected        AS MembersAdjusted,
			@TransactionType AS TransactionType,
			@ExpireDate      AS ExpireDate,
			@BatchRef        AS BatchReference;

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

