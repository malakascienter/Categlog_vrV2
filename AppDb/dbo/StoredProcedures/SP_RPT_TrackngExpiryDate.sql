
CREATE PROCEDURE [dbo].[SP_RPT_TrackngExpiryDate]
(
@DateFrom DATE='2020/08/01', 
@DateTo DATE='2020/12/01', 
@UserID INT =1, 
@PropertyID INT = -999,
@SupplierID INT = -999
)

AS
BEGIN
	SELECT DISTINCT SE.stockitemid, C.Name AS CategoryName,U.Name AS Size, SIH.StockItemCode,SIH.Name,  SE.BalanceQuantity, SE.EXPDate, L.Name AS LocationName
	FROM  [dbo].[StockItemWiseEXPDateIns] SE
	INNER JOIN StockTransactionHeaders SH ON SH.Id = SE.TransactionID OR SE.TransactionID = -999 
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SE.StockItemID
	INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND SH.LocationID = SID.LocationID
	INNER JOIN Categories C ON C.Id = SIH.CategoryID 
	INNER JOIN Units U ON U.Id = SID.MasterUnitID
	INNER JOIN Locations L On L.Id = SE.LocationID 
	WHERE SE.PropertyID =CASE WHEN  @PropertyID = -999 THEN   SE.PropertyID ELSE  @PropertyID END 
	AND SE.EXPDate BETWEEN @DateFrom AND @DateTo 
	AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN  SH.SupplierID ELSE @SupplierID END
	AND SE.BalanceQuantity > 0
	ORDER BY LocationName,StockItemCode,EXPDate ASC
END

GO

