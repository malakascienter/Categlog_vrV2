
-- [dbo].[SP_RPT_TotalItemList] 1,-999,-999,-999

-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <14/03/2022> 
-- =============================================
 
CREATE PROCEDURE  [dbo].[SP_RPT_TotalItemList](@PropertyId INT,@CatId INT,@SubCatId INT,@SubCat2Id INT)--, @LocationID INT)
AS
BEGIN
	  SELECT DISTINCT H.StockItemCode,H.Name,C.Name AS Category, SC.Name AS SubCategory,SC2.Description AS SubCategory2, 
	 (SELECT [dbo].[FN_GetTopMasterUnit](H.Id)) AS MasterUnit
	  FROM StockItemHeaders H
	  INNER JOIN StockItemDetails D ON H.Id = D.StockItemHeaderID
	  INNER JOIN Categories C ON C.Id = H.CategoryID
	  INNER JOIN SubCategories SC ON SC.Id = H.SubCategoryID
	  INNER JOIN SubCategories02 SC2 ON SC2.Id = H.SubCategory2ID 
	  WHERE H.CategoryID = CASE WHEN @CatId = -999 THEN H.CategoryID  ELSE @CatId END
	  AND H.SubCategoryID =  CASE WHEN @SubCatId = -999 THEN H.SubCategoryID  ELSE @SubCatId END
	  AND H.SubCategory2ID =  CASE WHEN @SubCat2Id = -999 THEN H.SubCategory2ID  ELSE @SubCat2Id END
	  AND H.CompanyId = CASE WHEN @PropertyId = -999 THEN H.CompanyId  ELSE @PropertyId END   
	  --AND H.LocationId = CASE WHEN @LocationID = -999 THEN H.LocationId  ELSE @LocationID END
END

GO

