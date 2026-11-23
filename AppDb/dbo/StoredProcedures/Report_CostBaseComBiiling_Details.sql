

CREATE PROCEDURE [dbo].[Report_CostBaseComBiiling_Details]
	@FromDate VARCHAR(20),
	@ToDate VARCHAR(20),
	@PropertyId INT,
	@Outlet VARCHAR(MAX)
AS
BEGIN
		SET NOCOUNT ON;


		SELECT	
			CM.ComplimentaryType AS ComplimentaryType,
			BillHeader.OrderNo,
			Location_Ref.description AS Outlet,
			BillHeader.OrderDate,
			BillHeader.OrderTime,
			Category.Description as CatName,
			ItemCategory.Name AS ItemCategory,
			MainMenu.Description AS ItemName,
			BillTrans.Qty,
			(ABS((SUM((RD.Qty * IB.Qty * BillTrans.Qty) * (OutletKitchenIssues.AveragePrice *   Categlog_vrV2.[dbo].[FN_GetUnitConvertionRate](BillTrans.PropertyId,RD.Unit, SD.MasterUnitID)))  ))) Cost,
			Waiter.Name AS WaiterName
		FROM	   Categlog_vrV2.dbo.BillHeader
		INNER JOIN Categlog_vrV2.dbo.Location_Ref ON BillHeader.Outlet = Location_Ref.code AND BillHeader.PropertyId = Location_Ref.PropertyId
		INNER JOIN Categlog_vrV2.dbo.BillTrans  ON BillTrans.OrderNo = BillHeader.OrderNo AND BillTrans.Outlet = BillHeader.Outlet AND BillTrans.OrderDate = BillHeader.OrderDate AND BillTrans.Propertyid = BillHeader.propertyid
		INNER JOIN Categlog_vrV2.dbo.ItemBreakDown AS IB ON IB.MainMenuCode = BillTrans.MainMenuCode AND BillTrans.PropertyId = IB.PropertyId 
		INNER JOIN Categlog_vrV2.dbo.RecipeHeader AS RH ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
		INNER JOIN Categlog_vrV2.dbo.RecipeDetails AS RD ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
		INNER JOIN Categlog_vrV2.dbo.StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BillTrans.PropertyId AND SD.LocationID = Location_Ref.StockLocationID
		INNER JOIN  Categlog_vrV2.dbo.MainMenu  ON MainMenu.ItemCode = BillTrans.MainMenuCode AND MainMenu.PropertyId = BillTrans.PropertyId
		INNER JOIN Categlog_vrV2.dbo.ItemCategory ON MainMenu.ItemCategory = ItemCategory.Id AND MainMenu.PropertyId = ItemCategory.PropertyId 	
		INNER JOIN Category ON MainMenu.Category = Category.Code AND Category.PropertyId = MainMenu.PropertyId
		LEFT JOIN Categlog_vrV2.dbo.Waiter  ON Waiter.Code = BillHeader.Waiter AND Waiter.PropertyId = BillHeader.PropertyId
		LEFT JOIN POS_ComplimentaryTypes CM ON BillHeader.ComplimentaryID = CM.ID
		INNER JOIN Categlog_vrV2.dbo.OutletKitchenIssues  ON OutletKitchenIssues.PropertyID = BillHeader.PropertyId AND OutletKitchenIssues.OutletCode = BillHeader.Outlet AND OutletKitchenIssues.LocationID = Location_Ref.StockLocationID
		AND OutletKitchenIssues.TxnDate = BillHeader.OrderDate AND OutletKitchenIssues.MenuCode = MainMenu.ItemCode AND OutletKitchenIssues.StockItemID = SD.StockItemHeaderID AND OutletKitchenIssues.DepartmentID = Location_Ref.DepartmentID
		AND OutletKitchenIssues.TxnUnitID = RD.Unit
		WHERe (BillHeader.OrderDate BETWEEN   @FromDate AND @ToDate ) 
		AND BillHeader.Id IN 
		(
			SELECT	BHH.Id 
			FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
			INNER JOIN Categlog_vrV2.dbo.BillHeader BHH  ON PayTrans.OrderNo = BHH.OrderNo AND PayTrans.Outlet = BHH.Outlet AND PayTrans.OrderDate = BHH.OrderDate AND PayTrans.Propertyid = BHH.propertyid
			WHERE	(PaymentTypes.NoValue = 1 AND PayTrans.OrderDate  BETWEEN   @FromDate AND @ToDate ) 
					AND PayTrans.PayCode <> 'BR' 
					AND PayTrans.PropertyId = @PropertyID
					AND PayTrans.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		)
		AND BillHeader.PropertyId = @PropertyID
		AND Location_Ref.IsGLEnabled = 1
		AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		GROUP BY CM.ComplimentaryType,BillHeader.OrderNo,Location_Ref.description,BillHeader.OrderDate,BillHeader.OrderTime,Category.Description,ItemCategory.Name,MainMenu.Description,BillTrans.Qty,Waiter.Name
		         
		HAVING (SUM((RD.Qty * IB.Qty * BillTrans.Qty) * (OutletKitchenIssues.AveragePrice *   Categlog_vrV2.[dbo].[FN_GetUnitConvertionRate](BillTrans.PropertyId,RD.Unit, SD.MasterUnitID)))  ) > 0

END

GO

