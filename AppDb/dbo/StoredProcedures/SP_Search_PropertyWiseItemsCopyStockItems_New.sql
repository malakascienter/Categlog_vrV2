 --[SP_Search_PropertyWiseItemsCopyStockItems_New] 1,10,'',0,0,0,-999,-999,-999,1
 --[SP_Search_PropertyWiseItemsCopyStockItems_New] 1,10,'',0,0,0,-999,-999,-999,2
 --[SP_Search_PropertyWiseItemsCopyStockItems_New] '',-999,-999,-999,1,8
 --[SP_Search_PropertyWiseItemsCopyStockItems_New] '',-999,-999,-999,2
 --go
CREATE PROCEDURE [dbo].[SP_Search_PropertyWiseItemsCopyStockItems_New] 
	(@search VARCHAR(20),
	@CatergoryID INT,
	@SubcatergoryID INT,
	@SubCategory2ID INT,
	@CompanyId INT,
	@LocationId INT)
AS 
BEGIN
SET NOCOUNT ON;

SET @search = LTRIM(RTRIM(@search))

		IF(@search IS NULL OR @search = '')
		BEGIN 
			SELECT DISTINCT
					H.Name, 
					H.Id,
					H.StockItemCode,
					U.Name as FromUnitName,
					U.Name as ToUnitName,
					U.Id as FromUnitId,
					U.Id as ToUnitId,
					H.CompanyId,
					0 AS IsHave,
					0 AS disable,
					0 AS IsChecked ,
					  (
					SELECT UnitConvertion.UnitID, UnitConvertion.Unitname, UnitConvertion.Value
					FROM (
					SELECT ToUnitID AS UnitID, ToUnitName AS Unitname, convert(int ,Value) as Value FROM dbo.UnitConversions WHERE FromUnitID = U.Id
					UNION ALL
					SELECT FromUnitID AS UnitID, FromUnitName AS Unitname, convert(int ,Value) as Value FROM dbo.UnitConversions WHERE ToUnitID = U.Id
					UNION
					SELECT Id, Name, 1 AS Value FROM dbo.Units WHERE Id = U.Id
					) AS UnitConvertion
					FOR JSON PATH
					) AS UnitConvertion

					INTO #TempCompanyItems

			FROM StockItemHeaders AS H 	
			inner join StockItemDetails sd on h.Id=sd.StockItemHeaderID
			inner join Units U on u.Id = sd.MasterUnitID
			WHERE H.CategoryID = (CASE WHEN (@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END) 
				AND H.SubCategoryID = (CASE WHEN (@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
				AND H.SubCategory2ID = (CASE WHEN (@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
				AND H.CompanyId = @CompanyId and sd.LocationID=@LocationId AND sd.IsActive =1


			SELECT 
				Name,
				Id,
				StockItemCode,
				FromUnitName,
				ToUnitName,
				FromUnitId,
				ToUnitId,
				CompanyId,
				IsHave,
				disable,
				IsChecked,
				UnitConvertion
			FROM #TempCompanyItems
			ORDER BY StockItemCode ASC;

			DROP TABLE #TempCompanyItems;

		END
	ELSE
		BEGIN
			
				SELECT DISTINCT H.Name,
						H.Id,
						H.StockItemCode,
						U.Name as FromUnitName,
						U.Name as ToUnitName,
						U.Id as FromUnitId,
						U.Id as ToUnitId,
						H.CompanyId,
						0 AS IsHave,
						0 AS disable,
						0 AS IsChecked,
						(
					SELECT UnitConvertion.UnitID, UnitConvertion.Unitname, UnitConvertion.Value
					FROM (
					SELECT ToUnitID AS UnitID, ToUnitName AS Unitname, convert(int ,Value) as Value FROM dbo.UnitConversions WHERE FromUnitID = U.Id
					UNION ALL
					SELECT FromUnitID AS UnitID, FromUnitName AS Unitname, convert(int ,Value) as Value FROM dbo.UnitConversions WHERE ToUnitID = U.Id
					UNION
					SELECT Id, Name, 1 AS Value FROM dbo.Units WHERE Id = U.Id
					) AS UnitConvertion
					FOR JSON PATH
					) AS UnitConvertion

						INTO #TempCompanyItems2
				FROM StockItemHeaders AS H 	
				inner join StockItemDetails sd on h.Id=sd.StockItemHeaderID
				inner join Units U on u.Id = sd.MasterUnitID
				WHERE ((H.Name + H.StockItemCode LIKE 
					(CASE WHEN @Search IS NULL THEN H.Name + H.StockItemCode ELSE '%'+ @search +'%' END)
				) )  	AND
				H.CategoryID = (CASE WHEN (@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END) 
					AND H.SubCategoryID = (CASE WHEN (@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
					AND H.SubCategory2ID = (CASE WHEN (@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
					AND H.CompanyId = @CompanyId and sd.LocationID=@LocationId AND sd.IsActive =1

				SELECT 
					Name,
					Id,
					StockItemCode,
					FromUnitName,
					ToUnitName,
					FromUnitId,
					ToUnitId,
					CompanyId
					IsHave,
					disable,
					IsChecked,
					UnitConvertion
				FROM #TempCompanyItems2
				ORDER BY StockItemCode ASC;

				DROP TABLE #TempCompanyItems2;
			--end--
		END
END

GO

