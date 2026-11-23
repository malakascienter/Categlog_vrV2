-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <10/02/2022> 
-- =============================================
--   [dbo].[SP_RPT_StockLedgerSummary] '2022-08-28','2023-08-29',4521,7,0,-999,-999 
--go
CREATE PROCEDURE [dbo].[SP_RPT_StockLedgerSummary] ( @DateFrom DATE='2018-08-10', @DateTo DATE='2018-09-30', @StockItemID INT=-999, @LocationID INT =1, @byValue BIT =0,@CategoryId INT = -999,@SubCatId INT = -999)
as

  
CREATE TABLE #TempTable (StockItemID INT, StockItemCode VARCHAR(MAX), Name VARCHAR(MAX) , UnitName NVARCHAR(200) ,Category varchar(100), SubCategory varchar(100),OpeingBalance  DECIMAL(18,2),	GRN	DECIMAL, TI	DECIMAL(18,2),
[TO]	DECIMAL(18,2),	[IN]	DECIMAL(18,2), [IF] DECIMAL(18,2),	[IR]	DECIMAL(18,2),	[DAM]	DECIMAL(18,2),	[SR]	DECIMAL(18,2),Recon decimal(18,2),	ClosingBalance DECIMAL(18,2) , LastPurchasePrice 	DECIMAL(18,2) ,OpeingBalanceVal  DECIMAL(18,2),	GRNVal	DECIMAL(18,2), TIVal	DECIMAL(18,2),
[TOVal]	DECIMAL(18,2),	[INVal]	DECIMAL(18,2), [IFVal] DECIMAL(18,2),	[IRVal]	DECIMAL(18,2),	[DAMVal]	DECIMAL(18,2),	[SRVal]	DECIMAL(18,2), [ReconVal] decimal(18,2)	,ClosingBalanceVal DECIMAL(18,2), PurchaseBillValue 	DECIMAL(18,2))

INSERT INTO #TempTable

SELECT IH.Id, IH.StockItemCode , IH.Name ,U.Name UnitName,ct.name as category , sc.name as subCategory,
dbo.getBalance(@DateFrom,IH.Id,@LocationID,1,0), 
SUM(CASE h.TransactionType WHEN 'GR' THEN d.Quantity   ELSE 0 END ),   
SUM(CASE h.TransactionType WHEN 'TI' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'TO' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IN' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IF' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IR' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'DN' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'SR' THEN d.Quantity   ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'AA' THEN d.Quantity   ELSE 0 END ),
dbo.getBalance(@DateTo,IH.Id,@LocationID,0,0),
 (SELECT [dbo].[FN_GetLastGRNPriceByDate] (@LocationID,IH.Id,@DateTo)),
  dbo.getBalance(@DateFrom,IH.Id,@LocationID,1,1), 
SUM(CASE h.TransactionType WHEN 'GR' THEN d.Quantity * d.UnitPrice ELSE 0 END ),   
SUM(CASE h.TransactionType WHEN 'TI' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'TO' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IN' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IF' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IR' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'DN' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'SR' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'AA' THEN d.Quantity * d.UnitPrice ELSE 0 END ),
dbo.getBalance(@DateTo,IH.Id,@LocationID,0,1),
(SELECT [dbo].[FN_AllGRNValue](@LocationID,IH.Id,@DateFrom, @DateTo))
FROM dbo.StockTransactionDetails AS D
INNER JOIN dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = CASE WHEN @LocationID = -999 THEN ID.LocationID ELSE @LocationID END
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
Inner join Categories as ct ON IH.CategoryID = ct.Id 
INNER JOIN SubCategories as sc ON IH.SubCategoryID = sc.Id
WHERE IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END 
AND H.LocationID = CASE WHEN @LocationID = -999 THEN ID.LocationID ELSE @LocationID END AND H.TransactionDate BETWEEN @DateFrom AND @dateTo
AND IH.CategoryID = CASE WHEN @CategoryId = -999 THEN IH.CategoryID ELSE @CategoryId END
AND IH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN IH.SubCategoryID ELSE @SubCatId END
GROUP BY  IH.Id, IH.StockItemCode , IH.Name,U.Name, ct.name, sc.name 

SELECT * FROM #TempTable

GO

