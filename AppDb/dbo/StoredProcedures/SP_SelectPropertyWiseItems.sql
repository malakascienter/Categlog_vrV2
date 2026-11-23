
-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <04/03/2022> 
---- =============================================
--[dbo].[SP_SelectPropertyWiseItems] -999,-999,-999,53,'1'
--go
CREATE PROCEDURE [dbo].[SP_SelectPropertyWiseItems](@CatergoryID INT,@SubcatergoryID INT,@SubCategory2ID INT,@CompanyId INT,@Search VARCHAR(1000))
AS
BEGIN
	  
	DECLARE @AllItemDetails TABLE (NAME VARCHAR(1000), StockItemCode VARCHAR(300),IsHave BIT)

	 SELECT DISTINCT  H.Name, H.StockItemCode,1 AS IsHave INTO #TempCompanyItems
	 FROM StockItemHeaders AS H 	
	 WHERE H.CategoryID = (CASE WHEN(@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END)  AND 
	 H.SubCategoryID = (CASE WHEN(@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
	 AND H.SubCategory2ID = (CASE WHEN(@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)
	 AND H.CompanyId = @CompanyId
 
	 SELECT DISTINCT  H.Name, H.StockItemCode,0 AS IsHave INTO #TempAllItems  
	 FROM StockItemHeaders AS H 	
	 WHERE H.CategoryID = (CASE WHEN(@catergoryID = -999) THEN H.CategoryID ELSE @catergoryID END)  AND 
	 H.SubCategoryID = (CASE WHEN(@subcatergoryID = -999) THEN H.SubCategoryID ELSE @subcatergoryID END) 
	 AND H.SubCategory2ID = (CASE WHEN(@SubCategory2ID = -999) THEN H.SubCategory2ID ELSE @SubCategory2ID END)

	 INSERT INTO @AllItemDetails
	 SELECT * FROM #TempCompanyItems
	 UNION
	 SELECT * FROM #TempAllItems WHERE StockItemCode NOT IN (SELECT StockItemCode FROM  #TempCompanyItems)

	 SELECT * FROM @AllItemDetails WHERE Name LIKE '%' + ISNULL(@Search,'') + '%'  OR   StockItemCode LIKE '%' + ISNULL(@Search,'') + '%' 
 
END

GO

