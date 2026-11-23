
create PROCEDURE [dbo].[SP_GetGRNWiseItemDetails](@TxnId INT)

AS
BEGIN
	SELECT DISTINCT SIH.Id AS ItemId,SIH.Name AS ItemName, SIH.StockItemCode AS ItemCode, PD.UnitPrice AS POPrice,
	SD.Quantity AS GRNQty, SD.UnitPrice AS GRNUnitPrice,TMD.InvQty, TMD.InvUnitPrice
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	LEFT JOIN ThreeWayMatchingHeader TMH ON TMH.GRNTxnId = SH.Id
	LEFT JOIN ThreeWayMatchingDetails TMD ON TMD.HeaderId = TMH.Id AND TMD.ItemId = SD.StockItemID
	LEFT JOIN PoHeaders PH ON PH.Id = SH.ReferenceID
	LEFT JOIN PoDetails PD ON PH.Id = PD.PoHeaderID
	WHERE SH.Id = @TxnId
END

GO

