CREATE PROCEDURE [dbo].[Dayend_SP_CheckInventoryRecipeIssuesAccountMapping] 
	@PropertyId INT,
	@HotelDate DATE
AS
BEGIN
	
		--DECLARE @BlockCode VARCHAR(5) = 'KTI' --dont change block code
		--DECLARE @BlockCode2 VARCHAR(5) = 'GRN' --dont change block code
		--DECLARE @GLCompCode VARCHAR(5)
		--SELECT @GLCompCode = GLCOMPCODE FROM Companies WHERE CompanyID = @PropertyId

		--SELECT CASE WHEN GLM.AccCode IS NULL THEN 'Not Account Map' ELSE 'Account Map' END AS AccMapStatus,
		--L.Name as Location,
		--DD.Name DepartMentName,
		--C.Name AS CategoryName,
		--SC1.Name AS SubCategory1,
		--SC2.Description AS SubCategory2,
		--'KTI' AS  BlockCode
		--FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
		--		INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
		--		INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
		--		INNER JOIN PrinterType AS LR ON BT.Outlet = LR.OutletID --AND LR.PropertyId = BT.PropertyId 
		--		INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
		--		INNER JOIN StockItemHeaders SH ON SD.StockItemHeaderID = SH.Id
		--		INNER JOIN Categories C ON SH.CategoryID = C.Id
		--		INNER JOIN SubCategories SC1 ON SH.SubCategoryID =  SC1.Id
		--		INNER JOIN SubCategories02 SC2 ON SH.SubCategory2ID = SC2.Id
		--		INNER JOIN Departments DD ON DD.Id = LR.DepartmentID
		--		INNER JOIN Locations L ON L.Id = StockLocationID
		--		LEFT JOIN eFinancials_Accounting..Destinity_GLIntegrationAccountMapping GLM 
		--		ON GLM.Level1 = DD.Code AND GLM.Level2 = C.Code and GLM.Level3 = SC1.Code and GLM.Level4 = SC2.Code AND GLM.BlockCode = @BlockCode and GLM.GLCompCode = @GLCompCode
		--WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@HotelDate) 
		--GROUP BY L.Id ,L.Code ,L.Name ,
		--DD.Id ,DD.Code ,  DD.Name ,
		--C.Id ,C.Code , C.Name ,
		--SC1.Id ,SC1.Code , SC1.Name ,
		--SC2.Id ,SC2.Code ,  SC2.Description 
		--,GLM.AccCode

		--UNION ALL

		--SELECT CASE WHEN GLM.AccCode IS NULL THEN 'Not Account Map' ELSE 'Account Map' END AS AccMapStatus,
		--L.Name as Location,
		--'' AS DepartMentName,
		--C.Name AS CategoryName,
		--'' AS SubCategory1,
		--'' AS SubCategory2,
		--'GRN' AS  BlockCode
		--FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
		--		INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
		--		INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
		--		INNER JOIN PrinterType AS LR ON BT.Outlet = LR.OutletID --AND LR.PropertyId = BT.PropertyId 
		--		INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
		--		INNER JOIN StockItemHeaders SH ON SD.StockItemHeaderID = SH.Id
		--		INNER JOIN Categories C ON SH.CategoryID = C.Id
		--		INNER JOIN SubCategories SC1 ON SH.SubCategoryID =  SC1.Id
		--		INNER JOIN SubCategories02 SC2 ON SH.SubCategory2ID = SC2.Id
		--		INNER JOIN Departments DD ON DD.Id = LR.DepartmentID
		--		INNER JOIN Locations L ON L.Id = StockLocationID
		--		LEFT JOIN eFinancials_Accounting..Destinity_GLIntegrationAccountMapping GLM 
		--		ON GLM.Level1 = L.Code AND GLM.Level2 = C.Code AND GLM.BlockCode = @BlockCode2 and GLM.GLCompCode = @GLCompCode
		--WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@HotelDate) 
		--GROUP BY L.Id ,L.Code ,L.Name ,
		--C.Id ,C.Code , C.Name 
		--,GLM.AccCode


		print 1

END

GO

