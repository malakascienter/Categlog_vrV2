-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Save Rule (Insert or Update)
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_SaveRule]
	@RuleId INT = NULL,        
	@RuleName NVARCHAR(200),
	@Description NVARCHAR(500) = NULL,
	@PropertyId INT,
	@RuleTypeId INT,
	@Rate DECIMAL(18,4) = NULL,
	@BaseValueId INT = NULL,
	@Multiplier DECIMAL(18,4) = NULL,
	@ExpireDayCount INT = NULL,
	@IsActive BIT = 1,
	@CreateBy INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF (@RuleId IS NULL OR @RuleId = 0)
		BEGIN
			-- INSERT
			INSERT INTO [dbo].[LTY_PointEarningRule]
			(
				RuleName,
				Description,
				PropertyId,
				RuleTypeId,
				Rate,
				BaseValueId,
				Multiplier,
				IsActive,
				CreateBy,
				CreatedDate,
				ExpireDayCount  
			)
			VALUES
			(
				@RuleName,
				@Description,
				@PropertyId,
				@RuleTypeId,
				@Rate,
				@BaseValueId,
				@Multiplier,
				@IsActive,
				@CreateBy,
				GETDATE(),
				@ExpireDayCount
			);

			SET @RuleId = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
			-- UPDATE
			UPDATE [dbo].[LTY_PointEarningRule]
			SET
				RuleName    = @RuleName,
				Description = @Description,
				PropertyId  = @PropertyId,
				RuleTypeId  = @RuleTypeId,
				Rate        = @Rate,
				BaseValueId = @BaseValueId,
				Multiplier  = @Multiplier,
				IsActive    = @IsActive,
				ModifyBy    = @CreateBy,
				ModifyDate  = GETDATE(),
				ExpireDayCount  = @ExpireDayCount
			WHERE RuleId = @RuleId;
		END

		COMMIT TRANSACTION;

		SELECT @RuleId AS RuleId;

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

