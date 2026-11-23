
-- [dbo].[SP_RPT_ItemMovement_AllItems] 1,'2025/05/01','2025/05/21',-999,1,0,-999,-999 
 
CREATE PROCEDURE [dbo].[SP_RPT_ItemMovement_AllItems] (@PropertyID INT, @DateFrom DATE='2018-08-10', @DateTo DATE='2018-09-30', @StockItemID INT=-999, @LocationID INT =1, 
@byValue BIT =0,@CategoryId INT = -999,@SubCatId INT = -999)
as

  set @byValue =0

CREATE TABLE #TempTable (StockItemID INT, StockItemCode VARCHAR(50), Name VARCHAR(100) , UnitName NVARCHAR(200) ,OpeingBalance  DECIMAL,	GRN	DECIMAL, TI	DECIMAL,
[TO]	DECIMAL,	[IN]	DECIMAL, [IF] DECIMAL,	[IR]	DECIMAL,	[DAM]	DECIMAL,	[SR]	DECIMAL,	ClosingBalance DECIMAL(18,2),ClosingBalanceValue DECIMAL(18,6) )

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
LEFT JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockTransactionDetails AS D2 ON D.Id = D2.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID=@LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = CASE @StockItemID WHEN -999 THEN IH.ID ELSE @StockItemID END 
AND H.LocationID = @LocationID AND H.TransactionDate BETWEEN   @DateFrom AND @dateTo
AND IH.CategoryID = CASE WHEN @CategoryId = -999 THEN IH.CategoryID ELSE @CategoryId END
AND IH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN IH.SubCategoryID ELSE @SubCatId END
AND H.PropertyID = @PropertyID
GROUP BY  IH.Id, IH.StockItemCode , IH.Name,U.Name


SELECT *
FROM (
SELECT StockItemID , StockItemCode , Name  , UnitName ,OpeingBalance  ,	GRN	, TI	,
[TO]	,	[IN]	, [IF] ,	[IR]	,	[DAM]	,	[SR]	,	ClosingBalance ,ClosingBalanceValue 
FROM #TempTable
UNION ALL
SELECT SH.Id AS StockItemID, SH.StockItemCode AS StockItemCode, SH.Name AS  Name,U.Name AS UnitName, 0 as OpeingBalance, 
0  GRN	,0 TI	, 0 [TO]	,0 [IN]	,0 [IF] ,0 IR	,0 DAM	,0 SR	,
	0 as ClosingBalance,  0 as ClosingBalanceVal
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	WHERE SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
	AND SD.LocationID = CASE WHEN @LocationID = -999 THEN SD.LocationID ELSE @LocationID END 
	AND SH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SH.SubCategoryID ELSE @SubCatId END
	AND SH.Id = CASE @StockItemID WHEN -999 THEN SH.ID ELSE @StockItemID END 
	AND SH.CompanyId =@PropertyID
	AND SH.Id NOT IN (SELECT StockItemID from #TempTable)
	
	) AS A
	ORDER BY ClosingBalance DESC,ClosingBalanceValue DESC,StockItemCode

GO

