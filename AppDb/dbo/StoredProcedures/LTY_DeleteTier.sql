-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Delete Tier by PropertyId and TierId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_DeleteTier]
	@PropertyId INT,
	@TierId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF EXISTS (
			SELECT 1
			FROM [dbo].[LTY_Member]
			WHERE TierId     = @TierId
			  AND PropertyId = @PropertyId
		)
		BEGIN
			RAISERROR('This Tier is mapped to a Member and cannot be deleted.', 16, 1);
		END

		DELETE FROM [dbo].[LTY_Tier]
		WHERE PropertyId = @PropertyId
		  AND TierId     = @TierId;

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

