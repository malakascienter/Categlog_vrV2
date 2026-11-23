-- [dbo].[SP_RPT_ItemMovement] '2026-11-02','2026-11-02',2,1,0,-999,-999
CREATE PROCEDURE [dbo].[SP_RPT_ItemMovement] ( @DateFrom DATE='2018-08-10', @DateTo DATE='2018-09-30', @StockItemID INT=-999, @LocationID INT =1, @byValue BIT =0,@CategoryId INT = -999,@SubCatId INT = -999)
as

  
CREATE TABLE #TempTable (StockItemID INT, StockItemCode VARCHAR(50), Name VARCHAR(100) , UnitName NVARCHAR(200) ,OpeingBalance  DECIMAL,	GRN	DECIMAL, TI	DECIMAL,
[TO]	DECIMAL,	[IN]	DECIMAL, [IF] DECIMAL(18,6),	[IR]	DECIMAL,	[DAM]	DECIMAL,	[SR]	DECIMAL,	ClosingBalance DECIMAL(18,2),ClosingBalanceValue DECIMAL(18,6) )

INSERT INTO #TempTable

SELECT IH.Id, IH.StockItemCode , IH.Name ,U.Name UnitName, dbo.getBalance(@DateFrom,IH.Id,@LocationID,1,@byValue), 
SUM(CASE h.TransactionType WHEN 'GR' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),  -- esle was 1 in GR changed to 0
SUM(CASE h.TransactionType WHEN 'TI' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'TO' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IN' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IF' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'IR' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'DN' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
SUM(CASE h.TransactionType WHEN 'SR' THEN d.Quantity * CASE WHEN @byValue = 1 THEN d.UnitPrice ELSE 1 END ELSE 0 END ),
dbo.getBalance(@DateTo,IH.Id,@LocationID,0,@byValue),
dbo.getBalance(@DateTo,IH.Id,@LocationID,0,1)
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID=@LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END 
AND H.LocationID = @LocationID AND H.TransactionDate BETWEEN   @DateFrom AND @dateTo
AND IH.CategoryID = CASE WHEN @CategoryId = -999 THEN IH.CategoryID ELSE @CategoryId END
AND IH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN IH.SubCategoryID ELSE @SubCatId END
GROUP BY  IH.Id, IH.StockItemCode , IH.Name,U.Name


SELECT * FROM #TempTable

GO

