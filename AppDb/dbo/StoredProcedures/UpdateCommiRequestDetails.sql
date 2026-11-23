-- [dbo].[UpdateCommiRequestDetails] '[{"ID":47,"HeaderID":29,"StockItemID":null,"StockItemCode":null,"StockItemName":"Test 3 15 b","UnitID":null,"Remarks":null,"RequestLocation":"BEVERAGES","ProductLocation":"KITCHEN","RequestedQTY":2.0,"RequestedDate":"2024-08-06T00:00:00","DeliveryScheduleID":null,"AdjustedQty":null,"ApprovedQTY":2.0,"Status":null},{"ID":48,"HeaderID":29,"StockItemID":null,"StockItemCode":null,"StockItemName":"TEST 3 13 A","UnitID":null,"Remarks":null,"RequestLocation":"BEVERAGES","ProductLocation":"KITCHEN","RequestedQTY":2.0,"RequestedDate":"2024-08-06T00:00:00","DeliveryScheduleID":null,"AdjustedQty":null,"ApprovedQTY":2.0,"Status":null},{"ID":52,"HeaderID":31,"StockItemID":null,"StockItemCode":null,"StockItemName":"8mm Size 1 1/2'' Length Black Screw","UnitID":null,"Remarks":null,"RequestLocation":"MAIN KITCHEN","ProductLocation":"BEVERAGES","RequestedQTY":2.0,"RequestedDate":"2024-08-30T00:00:00","DeliveryScheduleID":null,"AdjustedQty":null,"ApprovedQTY":2.0,"Status":null}]'
create PROCEDURE [dbo].[UpdateCommiRequestDetails]
 @List VARCHAR(MAX)
AS
BEGIN
	DECLARE @ID INT,@HeaderID INT,@ApproveQty Money;
	create table #temp(Id INT,HeaderID INT,ApprovedQTY MONEY);

	Insert INTO #temp(Id,HeaderID,ApprovedQTY) 
	SELECT ID,HeaderID,ApprovedQTY
	  FROM OPENJSON(@List)
		WITH (
			ID int,
			HeaderID INT,
			ApprovedQTY MONEY
		);

	SELECT DISTINCT HeaderID INTO #temp2 from #temp

	WHILE EXISTS(SELECT TOP 1 * from #temp)
	BEGIN
		SELECT TOP 1 @ID = Id,@HeaderID = HeaderID, @ApproveQty = ApprovedQTY FROM #temp
		UPDATE CommiRequestDetails SET ApprovedQTY=@ApproveQty, Status='A' where ID=@ID;

		UPDATE CommiRequestHeader SET Status = 'C'
		WHERE Id = @HeaderID
		 AND NOT EXISTS (
			SELECT 1 
			FROM CommiRequestDetails 
			WHERE HeaderID = @HeaderID AND Status <> 'A'
		);
		
		DELETE TOP(1) FROM #temp
	END

	WHILE EXISTS (SELECT DISTINCT HeaderID FROM #temp2)
	BEGIN
		SELECT DISTINCT TOP 1 @HeaderID = HeaderID 
		FROM #temp2;
    
		EXEC [dbo].[InsertProductionRequest] @HeaderID;
		EXEC [dbo].[InsertCommiTransfer] @HeaderID
    
		DELETE FROM #temp2 WHERE HeaderID = @HeaderID;
	END
END

GO

