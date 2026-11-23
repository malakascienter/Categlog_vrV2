-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-24
-- Description:	Update Document Number
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_UpdateDocumentNumber] 
	@PropertyID INT,
	@LocationID VARCHAR(5),
	@TransactionType CHAR(4)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRY 
	BEGIN TRAN
		
		UPDATE SPO_TransactionTypeWiseNextNumbers
		SET NextNumber = NextNumber + 1
		WHERE LocationID = @LocationID
		AND PropertyID = @PropertyID
		AND TransactionType =  @TransactionType;

	COMMIT TRAN
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
	END CATCH;
END

GO

