

CREATE PROCEDURE [dbo].[SP_ReCallTransactionHeaderDetails] (@headerID int)
AS
BEGIN


		SELECT TD.StockItemID, TD.Quantity AS RequestedQuantity,TD.UnitPrice, U.Name AS UnitName, SH.Name ItemName,  TD.Quantity AS ApprovedQuantity,
		(SELECT QuantityInHand FROM  StockItemDetails WHERE StockItemHeaderID = TD.StockItemID AND LocationID = TH.LocationID) AS QuantityInHand
		FROM StockTransactionHeaders TH
		INNER JOIN StockTransactionDetails TD ON TH.Id = TD.StockTransactionHeaderID
		INNER JOIN Units U ON U.Id = TD.TxnUnitId
		INNER JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		WHERE TH.Id = @headerID

END

GO

