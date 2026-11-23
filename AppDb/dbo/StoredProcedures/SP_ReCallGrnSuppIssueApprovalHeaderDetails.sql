

CREATE PROCEDURE [dbo].[SP_ReCallGrnSuppIssueApprovalHeaderDetails] (@headerID int)
AS
BEGIN
--exec  [dbo].[SP_ReCallGrnSuppIssueApprovalHeaderDetails]  1
		DECLARE @XMLDetails XML,@iDocID INT,@LocationId INT

		SELECT @XMLDetails = CONVERT(XML,XMLDetails),@LocationId = LocationId
		FROM  GRNApprovalLog 
		WHERE Id = @headerID

		
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		
  		SELECT * INTO #tempItemDetails FROM 
		OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2) 
		WITH (StockItemID INT, Quantity DECIMAL(18,6),UnitPrice DECIMAL(18,6),TxnUnitID INT, Remarks VARCHAR(MAX))

		SELECT TD.StockItemID, TD.Quantity AS RequestedQuantity,TD.UnitPrice, U.Name AS UnitName, SH.Name ItemName,  TD.Quantity AS ApprovedQuantity,
		(SELECT QuantityInHand FROM  StockItemDetails WHERE StockItemHeaderID = TD.StockItemID AND LocationID = @LocationId) AS QuantityInHand
		FROM #tempItemDetails TD
		INNER JOIN Units U ON U.Id = TD.TxnUnitId
		INNER JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID

END

GO

