-- =============================================
-- Author:		Nivesh
-- Create date: 2024-09-25
-- Description:	Get Currency Type
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetCurrencyType]
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		SELECT * FROM CurrencyType;
	END TRY
	BEGIN CATCH
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH;
END

GO

