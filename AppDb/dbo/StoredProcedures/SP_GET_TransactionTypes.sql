CREATE PROCEDURE [dbo].[SP_GET_TransactionTypes]
AS
BEGIN
-------------------------------------------------------------------------------
BEGIN TRY 
SELECT Id,CONCAT(Code,'/',Name) AS TransactionType FROM dbo.TransactionTypes WHERE  IsActive = 1
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
-------------------------------------------------------------------------------
END

GO

