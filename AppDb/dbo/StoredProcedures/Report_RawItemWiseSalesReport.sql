-- =============================================
-- Author:		Isuru Pramodya
-- Create date:	2025-06-27
-- Description:	Report SP to get Item Wise Consumption
-- [dbo].[Report_RawItemWiseSalesReport] -999,-999,'2025-07-01','2025-07-01',1

-- =============================================
CREATE PROCEDURE [dbo].[Report_RawItemWiseSalesReport]
	@LocationID INT,
	@CategoryID INT,
	@FromDate DATE,
	@ToDate DATE,
	@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

		IF OBJECT_ID(N'tempdb..#TempItemCost') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemCost
	END

		SELECT  OKS.stockitemid,CONVERT(DATE,TxnDate) TxnDate, SUM(Quantity) Quantity ,MenuCode,OKS.PropertyID,OKS.OutletCode,I.LocationID,CA.Name CatName,SH.NAME ItemName,SH.StockItemCode
		,SH.CategoryID,UN.Name UnitName,OKS.DepartmentID,OKS.TxnUnitID,I.MasterUnitID,
		--,SUM(Quantity) * [dbo].[FN_GetUnitConvertionRate](OKS.PropertyId,OKS.TxnUnitID, I.MasterUnitID) MasterUnitQuantity,
		UN2.NAME MasterUnit
		INTO #TempItemCost
		FROM            OutletKitchenIssues OKS
		INNER JOIN StockItemdetails I ON OKS.StockItemID= I.StockItemHeaderID AND OKS.LocationID= I.LocationID
		INNER JOIN STOCKITEMHEADERS SH ON SH.ID = I.StockItemHeaderID
		INNER JOIN CATEGORIES CA ON CA.ID = SH.CategoryID
		INNER JOIN UNITS UN ON UN.ID = OKS.TxnUnitID
		INNER JOIN UNITS UN2 ON UN2.ID = I.MasterUnitID
		 WHERE  OKS.TxnDate BETWEEN @FromDate AND @ToDate  AND OKS.PropertyId=@PropertyID
		--AND OKS.stockitemid=378
		 AND I.LocationID = CASE WHEN @LocationID = -999 THEN I.LocationID ELSE @LocationID END
		 AND SH.CategoryID = CASE WHEN @CategoryID = -999 THEN SH.CategoryID ELSE @CategoryID END
		GROUP BY OKS.stockitemid,OKS.MenuCode,OKS.PropertyID,OKS.OutletCode,TxnDate,I.LocationID,CA.Name,SH.StockItemCode,SH.NAME,SH.CategoryID,UN.Name,OKS.DepartmentID
		,OKS.PropertyId,OKS.TxnUnitID, I.MasterUnitID,UN2.NAME,OKS.TxnUnitID
		
		--select *
		--from #TempItemCost
		--WHERE Quantity <>MasterUnitQuantity
		-- SELECT 
  --      SUM(Quantity) AS TotalQuantity,StockItemCode,LocationID ,MenuCode
		--FROM #TempItemCost   GROUP BY LocationID, StockItemCode,MenuCode


SELECT  MM.Description,  SUM(BT.Qty) AS SalesQty,OK.LocationID AS StockLocationID, OK.CatName,  LO.Name AS LocationName, OK.ItemName,OK.StockItemCode,OK.UnitName,OK.stockitemid, 
TQ.TotalQuantity AS TotalConsumption , TQ.MasterUnitQuantity as MasterUnitConsumption
,OK.MenuCode,OK.MasterUnit
FROM #TempItemCost OK
INNER JOIN MainMenu MM  ON OK.MenuCode = MM.ItemCode   AND OK.PropertyID = MM.PropertyId
INNER JOIN BillTrans BT    ON OK.TxnDate = BT.OrderDate     AND OK.OutletCode = BT.Outlet     AND OK.PropertyID = BT.PropertyId    AND OK.MenuCode = BT.MainMenuCode 
INNER JOIN LOCATIONS LO     ON LO.ID = OK.LocationID
LEFT JOIN (    SELECT 
        SUM(Quantity) AS TotalQuantity,StockItemCode,LocationID ,MenuCode,
		  SUM(Quantity) * [dbo].[FN_GetUnitConvertionRate](PropertyID,TxnUnitID, MasterUnitID) MasterUnitQuantity
		FROM #TempItemCost   GROUP BY LocationID, StockItemCode,MenuCode,PropertyID,TxnUnitID, MasterUnitID) TQ 
    ON TQ.StockItemCode = OK.StockItemCode 
    AND TQ.LocationID = OK.LocationID
	AND TQ.MenuCode= OK.MenuCode

WHERE  
    OK.TxnDate BETWEEN @FromDate AND @ToDate
    AND OK.PropertyId = @PropertyID
    AND OK.LocationID = CASE WHEN @LocationID = -999 THEN OK.LocationID ELSE @LocationID END
GROUP BY MM.Description,OK.LocationID,OK.CatName,LO.Name,OK.ItemName,OK.StockItemCode,OK.UnitName,TQ.TotalQuantity ,TQ.MasterUnitQuantity
,OK.stockitemid,OK.MenuCode,OK.DepartmentID,OK.MasterUnit 
ORDER BY OK.ItemName,OK.StockItemCode,LO.Name

END

GO

