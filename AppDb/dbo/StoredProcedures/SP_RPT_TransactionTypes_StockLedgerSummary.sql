-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 23 JUNE 2023
-- Description:	Loading Transaction Types for Stock Ledger Summary Report

--[dbo].[SP_RPT_TransactionTypes_StockLedgerSummary] '2025-09-09','2025-09-09',-999,1,0,-999,-999 

-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_TransactionTypes_StockLedgerSummary] 
( @DateFrom DATE='2018-08-10', @DateTo DATE='2018-09-30', 
@StockItemID INT=-999, 
@LocationID INT =1, @byValue BIT =0,
@CategoryId INT = -999,
@SubCatId INT = -999)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT IH.Id StockItemID, IH.StockItemCode StockItemCode, IH.Name ,U.Name UnitName, dbo.getBalance(@DateFrom,IH.Id,@LocationID,1,0) as OpeingBalance, 
	dbo.getBalance(@DateTo,IH.Id,@LocationID,0,0) as ClosingBalance,
 
  dbo.getBalance(@DateFrom,IH.Id,@LocationID,1,1) as OpeingBalanceVal, dbo.getBalance(@DateTo,IH.Id,@LocationID,0,1) as ClosingBalanceVal,

TR.Name as TransactionType,SUM(d.Quantity) as Qty 
--,d.UnitPrice
,ISNULL(SUM(d.Quantity * d.UnitPrice),0) / NULLIF(SUM(d.Quantity),0) UnitPrice
,SUM(d.Quantity *d.UnitPrice) as Value
,TR.SortID
INTO #TempTable
	FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
	INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK) ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH WITH (NOLOCK) ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockTransactionDetails AS D2 WITH (NOLOCK) ON D.Id = D2.Id
	INNER JOIN dbo.StockItemDetails AS ID WITH (NOLOCK) ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = CASE WHEN @LocationID = -999 THEN ID.LocationID ELSE @LocationID END
	INNER JOIN dbo.Units AS U WITH (NOLOCK) ON ID.MasterUnitID = U.Id
	INNER JOIN TransactionTypes TR WITH (NOLOCK) ON TR.Code = H.TransactionType
	WHERE IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END 
	AND H.LocationID = CASE WHEN @LocationID = -999 THEN ID.LocationID ELSE @LocationID END AND H.TransactionDate BETWEEN @DateFrom AND @dateTo
	AND IH.CategoryID = CASE WHEN @CategoryId = -999 THEN IH.CategoryID ELSE @CategoryId END
	AND IH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN IH.SubCategoryID ELSE @SubCatId END
	GROUP BY  IH.Id, IH.StockItemCode , IH.Name,U.Name,TR.Name,d.UnitPrice,TR.SortID
	Order BY IH.StockItemCode

	--SELECT *
	--FROM #TempTable

	SELECT *
FROM (
SELECT StockItemID , StockItemCode , Name  , UnitName ,OpeingBalance  ,	ClosingBalance ,OpeingBalanceVal,ClosingBalanceVal ,TransactionType,
Qty,UnitPrice,Value,SortID
FROM #TempTable
UNION ALL
SELECT SH.Id AS StockItemID, SH.StockItemCode AS StockItemCode, SH.Name AS  Name,U.Name AS UnitName
, 0 as OpeingBalance, 0 ClosingBalance 
 , dbo.getBalance(@DateFrom,SH.Id,@LocationID,1,1) as OpeingBalanceVal, dbo.getBalance(@DateTo,SH.Id,@LocationID,0,1) as ClosingBalanceVal,
'NULL' TransactionType,
0 Qty,0 UnitPrice,0 Value,1 SortID
	FROM StockItemHeaders SH WITH (NOLOCK)
	INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Units U WITH (NOLOCK) ON U.Id = SD.MasterUnitID
	WHERE SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
	AND SD.LocationID = CASE WHEN @LocationID = -999 THEN SD.LocationID ELSE @LocationID END 
	AND SH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SH.SubCategoryID ELSE @SubCatId END
	AND SH.Id = CASE @StockItemID WHEN -999 THEN SH.ID ELSE @StockItemID END 
	AND SH.Id NOT IN (SELECT StockItemID from #TempTable)
	
	) AS A
	ORDER BY ClosingBalance DESC,ClosingBalanceVal DESC,StockItemCode
END

GO

