-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-24
-- Description:	Insert Document number
-- =============================================
CREATE     PROCEDURE [dbo].[LTY_InsertDocumentNumber] 
	@PropertyID INT,
	@LocationCode VARCHAR(5),
	@TransactionType CHAR(4)
AS
BEGIN
	SET NOCOUNT ON;
	
	BEGIN TRY 
	BEGIN TRAN
		
		INSERT INTO LTY_TransactionTypeWiseNextNumbers
		(
			PropertyID,
			LocationCode,
			TransactionType,
			NextNumber,
			LengthOfFormatting
		)
		VALUES
		(@PropertyID, @LocationCode, @TransactionType, 1, 6);

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

