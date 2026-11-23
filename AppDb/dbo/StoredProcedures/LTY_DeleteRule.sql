-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Delete Rule by PropertyId and RuleId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_DeleteRule]
	@PropertyId INT,
	@RuleId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		-- Validation: block delete if this Rule is mapped to any Tier
		IF EXISTS (
			SELECT 1
			FROM [dbo].[LTY_Tier]
			WHERE RuleId     = @RuleId
			  AND PropertyId = @PropertyId
		)
		BEGIN
			RAISERROR('This Rule is mapped to a Tier and cannot be deleted.', 16, 1);
		END

		DELETE FROM [dbo].[LTY_PointEarningRule]
		WHERE PropertyId = @PropertyId
		  AND RuleId     = @RuleId;

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

