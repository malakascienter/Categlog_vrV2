-- =============================================
-- Author:		Nivesh
-- Create date: 2024-04-04
-- Description: Select Table Category
-- =============================================
--[SP_SelectTableCategory] 2
CREATE PROCEDURE [dbo].[SP_SelectTableCategory]
	@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;

BEGIN TRY 
	SELECT 
	 TableCategoryID
	 ,TableCategoryName
	 ,OutletID
	 ,IsActive
	 ,SequenceID
	 ,IsRevolving
	FROM POS_TableCategories  
	WHERE PropertyId=@PropertyId AND IsActive =1 
	ORDER BY SequenceID,TableCategoryID

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

