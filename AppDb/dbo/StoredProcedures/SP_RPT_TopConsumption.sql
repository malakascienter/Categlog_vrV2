
-- [dbo].[SP_RPT_TopConsumption] '2024/07/01','2024/07/22',-999,2,9217,-999,1,'H'

CREATE PROCEDURE  [dbo].[SP_RPT_TopConsumption] 
(
@DateFrom DATE='2020/08/01', 
@DateTo DATE='2020/12/01', 
@CategoryID INT= -999, 
@LocationID INT=-999,
@UserID INT =1, 
@DepartmentID INT =-999,
@PropertyID INT = 1,
@SortedBy CHAR(1) = 'H' 
)

AS
BEGIN


		SELECT SH.StockItemCode, SH.Name,U.Name AS UnitName,L.Name AS LocationName,
		SUM( STD.Quantity ) AS Quantity,
		--STD.NewAveragePrice UnitCost,
		AVG(STD.NewAveragePrice) UnitCost,
		SUM(STD.Quantity) * AVG(STD.NewAveragePrice)  AS TotalCost,STH.TransactionType  INTO #TempDataIssue
		FROM StockTransactionHeaders STH 
		INNER JOIN  StockTransactionDetails STD ON STH.Id = STD.StockTransactionHeaderID
		INNER JOIN StockItemHeaders SH ON SH.Id = STD.StockItemID
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.Id
		AND SD.LocationID = CASE WHEN @LocationID  = -999 THEN STH.LocationID  ELSE @LocationID END
		INNER JOIN Units U ON U.Id = SD.MasterUnitID  
		INNER JOIN Locations L ON L.Id = STH.LocationID 
		WHERE STH.TransactionType IN ( 'IN','IF','IR') AND STH.PropertyID = CASE WHEN @PropertyID = -999 THEN STH.PropertyID ELSE @PropertyID END 
		AND STH.LocationID = CASE WHEN @LocationID  = -999 THEN STH.LocationID  ELSE @LocationID END
		AND STH.DepartmentID = CASE WHEN @DepartmentID = -999 THEN  STH.DepartmentID ELSE @DepartmentID END
		AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN  SH.CategoryID  ELSE @CategoryID END
		AND STH.TransactionDate BETWEEN @DateFrom AND @DateTo
		GROUP BY SH.StockItemCode, SH.Name,U.Name--,STD.NewAveragePrice
		,STH.TransactionType,L.Name

IF(@SortedBy = 'H')
BEGIN
	SELECT  I.StockItemCode, I.Name, I.UnitName, SUM(CASE WHEN I.TransactionType IN ('IN','IF') THEN I.Quantity ELSE - I.Quantity END )
	AS Quantity, I.UnitCost,I.LocationName,
	SUM(CASE WHEN I.TransactionType IN ('IN','IF') THEN I.Quantity ELSE - I.Quantity END )* I.UnitCost AS TotalCost
	FROM #TempDataIssue I
	GROUP BY I.StockItemCode, I.Name, I.UnitName,I.UnitCost,I.LocationName
	ORDER BY SUM(CASE WHEN I.TransactionType IN ('IN','IF') THEN I.Quantity ELSE - I.Quantity END )* I.UnitCost DESC
END
ELSE
BEGIN
	SELECT I.StockItemCode, I.Name, I.UnitName, SUM(CASE WHEN I.TransactionType IN ('IN','IF') THEN I.Quantity ELSE - I.Quantity END )
	AS Quantity, I.UnitCost,I.LocationName,
	SUM(CASE WHEN I.TransactionType IN ('IN','IF') THEN I.Quantity ELSE - I.Quantity END )* I.UnitCost AS TotalCost
	FROM #TempDataIssue I
	GROUP BY I.StockItemCode, I.Name, I.UnitName,I.UnitCost,I.LocationName
	ORDER BY SUM(CASE WHEN I.TransactionType = 'IN' THEN I.Quantity ELSE - I.Quantity END )* I.UnitCost ASC
END

	
END

GO

