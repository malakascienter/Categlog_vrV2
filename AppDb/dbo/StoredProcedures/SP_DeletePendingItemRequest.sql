
CREATE PROCEDURE [dbo].[SP_DeletePendingItemRequest] (@ReqItemHeaderId INT,@UserID INT=1)
AS 
BEGIN
BEGIN TRY 
	BEGIN TRANSACTION
	DECLARE @Name VARCHAR(500),  @Temp_Log_TeStItReWiLo int
	SELECT @Name = ItemDescription FROM TempStockItemRequest WHERE Id = @ReqItemHeaderId
	
	EXEC InsertMasterFileChangeLog 'Stock Item Request',@UserID,'D',@Name
	--------------------------Log TempStockItemRequest Delete--------------------------
	IF EXISTS (SELECT 1 FROM [dbo].[TempStockItemRequest] WHERE Id = @ReqItemHeaderId)
	BEGIN 
		EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequest', @ReqItemHeaderId, 'INV', 'TSIRD', 'D', @UserID,0, '', ''
	END
	-----------------------------------------------------------------------------------
	DELETE FROM [dbo].[TempStockItemRequest] WHERE Id = @ReqItemHeaderId

	--------------------------Log TempStockItemRequest Delete--------------------------
	IF EXISTS (SELECT 1 FROM [dbo].[TempStockItemRequestWiseLocations] WHERE StockItemRequestId = @ReqItemHeaderId)
	BEGIN 
		SELECT @Temp_Log_TeStItReWiLo = ID FROM [dbo].[TempStockItemRequestWiseLocations] WHERE StockItemRequestId = @ReqItemHeaderId
		EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequestWiseLocations', @Temp_Log_TeStItReWiLo, 'INV', 'TSIRWLD', 'D', @UserID,0, '', ''
	END
	-----------------------------------------------------------------------------------
	DELETE FROM [dbo].[TempStockItemRequestWiseLocations] WHERE StockItemRequestId = @ReqItemHeaderId
	COMMIT TRANSACTION
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
	ROLLBACK TRANSACTION 
END CATCH



END

GO

