-- Author		: Nivesh
-- Created by	: 2025-09-23
-- Description	: Generate report for executive , Production Profitability
--NEW
CREATE PROCEDURE [dbo].[Report_ExecutiveProductionProfitabilityReport](        
 @Date	DATE,
 @LocationID INT,
 @PropertyId INT
)        
AS        
BEGIN         


	IF OBJECT_ID(N'tempdb..#TempItemCost') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemCost
	END


		SELECT        SUM(Quantity * AveragePrice) AS CostPrice,MenuCode,OKS.PropertyID,OKS.OutletCode
		INTO #TempItemCost
		FROM            OutletKitchenIssues OKS
		 WHERE  OKS.TxnDate >= CONVERT(DATETIME,@Date,103) 
				AND OKS.TxnDate <= CONVERT(DATETIME,@Date,103) 
				 AND OKS.PropertyId=@PropertyId   
		GROUP BY OKS.MenuCode,OKS.PropertyID,OKS.OutletCode



	 SELECT MM.Description,L.description AS Outlet,SUM(BT.Qty) AS SalesQty,BT.Rate AS SalesPrice,SUM(BT.Qty)*BT.Rate AS NetSales,TIC.CostPrice/ case when SUM(BT.Qty) = 0 then 1 else SUM(BT.Qty) end AS CostPrice,TIC.CostPrice AS CostValue,(SUM(BT.Qty)*BT.Rate)-(TIC.CostPrice) AS ProfitAtCost,
	 ((SUM(BT.Qty)*BT.Rate)-(TIC.CostPrice))/ (case when (SUM(BT.Qty)*BT.Rate) = 0 then 1 else (SUM(BT.Qty)*BT.Rate) end) *100 AS GP
	 INTO #TempProductionProfitability
	 FROM OutletKitchenIssues OK
	 INNER JOIN MainMenu MM ON OK.MenuCode = MM.ItemCode AND OK.PropertyID = MM.PropertyId
	 INNER JOIN Location_Ref L ON OK.OutletCode = L.code AND OK.PropertyID = L.PropertyId
	 INNER JOIN BillTrans BT ON OK.TxnDate = BT.OrderDate AND OK.OutletCode = BT.Outlet AND OK.PropertyID = BT.PropertyId AND OK.MenuCode = BT.MainMenuCode 
	 INNER JOIN #TempItemCost TIC ON TIC.MenuCode = OK.MenuCode AND TIC.PropertyID = OK.PropertyID AND TIC.OutletCode = OK.OutletCode
	 WHERE  OK.TxnDate >= CONVERT(DATETIME,@Date,103) 
			AND OK.TxnDate <= CONVERT(DATETIME,@Date,103) 
			AND OK.PropertyId=@PropertyId   AND BT.Qty > 0 AND BT.Rate > 0 
	GROUP BY MM.Description,L.description ,BT.Rate,TIC.CostPrice


	select * from #TempProductionProfitability where ProfitAtCost > 0


	IF OBJECT_ID(N'tempdb..#TempItemCost') IS NOT NULL
	BEGIN
	DROP TABLE #TempItemCost
	END


END;

GO

