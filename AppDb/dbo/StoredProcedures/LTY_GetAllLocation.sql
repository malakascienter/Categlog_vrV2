-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get Active Locations by PropertyId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllLocation]
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT
			Code,
			Description
		FROM [dbo].[Location_Ref]
		WHERE Active     = 1
		  AND PropertyId = @PropertyId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

