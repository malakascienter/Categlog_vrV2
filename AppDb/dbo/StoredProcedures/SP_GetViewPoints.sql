-- =============================================
-- Author:		Nivesh
-- Create date: 2024-05-29
-- Description:	Get Lotus View Points
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetViewPoints] 
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
		SELECT ID,ViewName,Angel,additionalRadius,fontColor,fontSize,fontWidth FROM ViewPoints
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT>0
		ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000);  
			DECLARE @ErrorSeverity INT;  
			DECLARE @ErrorState INT;  

			SELECT   
			@ErrorMessage = ERROR_MESSAGE(),  
			@ErrorSeverity = ERROR_SEVERITY(),  
			@ErrorState = ERROR_STATE(); 
			RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
			--Insert Error log
			INSERT INTO OnlineTableReservation_ErrorTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
			VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())
	END CATCH;

END

GO

