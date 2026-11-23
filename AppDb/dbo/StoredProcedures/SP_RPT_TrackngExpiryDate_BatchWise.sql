
-- [dbo].[SP_RPT_TrackngExpiryDate_BatchWise] '2025-03-01','2026-10-01',5485,-999,-999

CREATE PROCEDURE [dbo].[SP_RPT_TrackngExpiryDate_BatchWise]
(
@DateFrom DATE='2020/08/01', 
@DateTo DATE='2020/12/01', 
@UserID INT =1, 
@PropertyID INT = -999,
@LocationID INT = -999,
@StockItemID INT = -999
)

AS
BEGIN
	SELECT DISTINCT SE.stockitemid, C.Name AS CategoryName,U.Name AS Size, SIH.StockItemCode,SIH.Name, L.Name AS LocationName
	,SE.BatchNo,CONVERT(DATE,SE.EXPDate) EXPDate
	,[dbo].[FN_GetBatchBalanceQty](SE.StockItemID,SE.LocationID,SE.BatchNo,SE.EXPDate,@DateTo) BalanceQty
	,ISNULL(SE.SellingPrice,0) SellingPrice
	FROM  [dbo].[StockItemWiseEXPDateIns] SE
	INNER JOIN StockTransactionHeaders SH ON SH.Id = SE.TransactionID OR SE.TransactionID = -999 
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SE.StockItemID
	INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND SH.LocationID = SID.LocationID
	INNER JOIN Categories C ON C.Id = SIH.CategoryID 
	INNER JOIN Units U ON U.Id = SE.MasterUnitID
	INNER JOIN Locations L On L.Id = SE.LocationID 
	WHERE SE.PropertyID =CASE WHEN  @PropertyID = -999 THEN   SE.PropertyID ELSE  @PropertyID END 
	AND SE.EXPDate BETWEEN @DateFrom AND @DateTo 
	AND SE.LocationID = CASE WHEN @LocationID = -999 THEN SE.LocationID ELSE @LocationID END
	AND SE.StockItemID = CASE WHEN @StockItemID = -999 THEN SE.StockItemID ELSE @StockItemID END
	and [dbo].[FN_GetBatchBalanceQty](SE.StockItemID,SE.LocationID,SE.BatchNo,SE.EXPDate,@DateTo) >0
	GROUP BY SE.stockitemid, C.Name ,U.Name , SIH.StockItemCode,SIH.Name, L.Name,SE.BatchNo,SE.EXPDate,SE.LocationID,SE.SellingPrice
	ORDER BY LocationName,StockItemCode,EXPDate ASC



END

GO

