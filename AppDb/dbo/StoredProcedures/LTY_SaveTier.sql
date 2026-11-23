-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Save Tier (Insert or Update)
--
--              2026-08-17: IsTierAutoUpgrade added. MaxiumPoint is conditional on it -
--              the form disables the box and sends 0 when the flag is off, and 0 would
--              read as a ceiling of zero points, so it is stored as NULL instead.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_SaveTier]
	@TierId INT = NULL,          -- pass NULL/0 for insert, existing Id for update
	@TierName NVARCHAR(200),
	@PropertyId INT,
	@MiniumPoint DECIMAL(18,4) = NULL,
	@MaxiumPoint DECIMAL(18,4) = NULL,
	@RuleId INT = NULL,
	@SortOrder INT = NULL,
	@IsActive BIT = 1,
	@IsTierAutoUpgrade BIT = 0,
	@CreateBy INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	SET @IsTierAutoUpgrade = ISNULL(@IsTierAutoUpgrade, 0);

	-- No auto upgrade means no ceiling, whatever the form sent.
	IF (@IsTierAutoUpgrade = 0)
	BEGIN
		SET @MaxiumPoint = NULL;
	END

	BEGIN TRY

		BEGIN TRANSACTION;

		IF (@IsTierAutoUpgrade = 1
			AND @MaxiumPoint IS NOT NULL
			AND @MiniumPoint IS NOT NULL
			AND @MaxiumPoint < @MiniumPoint)
		BEGIN
			RAISERROR('MaxiumPoint cannot be less than MiniumPoint.', 16, 1);
		END

		IF (@TierId IS NULL OR @TierId = 0)
		BEGIN
			-- INSERT
			INSERT INTO [dbo].[LTY_Tier]
			(
				TierName,
				PropertyId,
				MiniumPoint,
				MaxiumPoint,
				RuleId,
				SortOrder,
				IsActive,
				IsTierAutoUpgrade,
				CreatedBy,
				CreatedDate
			)
			VALUES
			(
				@TierName,
				@PropertyId,
				@MiniumPoint,
				@MaxiumPoint,
				@RuleId,
				@SortOrder,
				@IsActive,
				@IsTierAutoUpgrade,
				@CreateBy,
				GETDATE()
			);

			SET @TierId = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
			-- UPDATE
			UPDATE [dbo].[LTY_Tier]
			SET
				TierName          = @TierName,
				PropertyId        = @PropertyId,
				MiniumPoint       = @MiniumPoint,
				MaxiumPoint       = @MaxiumPoint,
				RuleId            = @RuleId,
				SortOrder         = @SortOrder,
				IsActive          = @IsActive,
				IsTierAutoUpgrade = @IsTierAutoUpgrade,
				ModifyId          = @CreateBy,
				ModifyDate        = GETDATE()
			WHERE TierId = @TierId;
		END

		COMMIT TRANSACTION;

		SELECT @TierId AS TierId;

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

