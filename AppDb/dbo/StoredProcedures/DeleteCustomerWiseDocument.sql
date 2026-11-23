
create PROCEDURE [dbo].[DeleteCustomerWiseDocument] @cusId INt, @docId INT
AS
BEGIN TRY
BEGIN TRANSACTION
	DELETE FROM CustomerWiseDocuments WHERE CustomerID = @cusId AND DocumentID = @docId
	DELETE FROM Documents WHERE PartnerTypeId = @cusId AND DocTyprId = @docId
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	if @@TRANCOUNT>0
		ROLLBACK TRANSACTION

		INSERT INTO dbo.Error_List (OccuredDateTime,ErrorNo,ErrorLine,Error,ErrorProcedure) VALUES (SYSDATETIME(),ERROR_NUMBER(),ERROR_LINE(),ERROR_MESSAGE(),ERROR_PROCEDURE()); 		
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
	 @ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH

GO

