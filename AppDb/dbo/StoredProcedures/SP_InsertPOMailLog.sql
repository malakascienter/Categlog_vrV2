-- =============================================
-- Author:		Nivesh
-- Create date: 2025-07-21
-- Description:	Insert PO mail status
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertPOMailLog] 
	@PurchaseOrderID INT,
	@ErrorMessage VARCHAR(500),
	@IsSend BIT,
	@PropertyID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY 
BEGIN TRANSACTION
	
INSERT INTO [dbo].[POSendMailLog]
           ([POHeaderID]
           ,[Message]
           ,[IsSendMail],
		   [PropertyID])
     VALUES
           (@PurchaseOrderID
           ,@ErrorMessage
           ,@IsSend
		   ,@PropertyID)

		   select '' SupplierName

COMMIT TRANSACTION

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		select '' SupplierName
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;

END

GO

