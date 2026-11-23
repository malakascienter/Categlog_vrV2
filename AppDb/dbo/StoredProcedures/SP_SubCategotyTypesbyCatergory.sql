CREATE PROCEDURE [dbo].[SP_SubCategotyTypesbyCatergory] 
	@catergoryID INT,
	@companyID INT
AS
BEGIN
	SELECT DISTINCT SC.Id AS id,SC.Name AS text 
	FROM dbo.SubCategories SC
	INNER JOIN dbo.StockItemHeaders SI ON SI.SubCategoryID = SC.Id
	--WHERE SI.CategoryID = CASE WHEN @catergoryID = -999 THEN SI.CategoryID ELSE @catergoryID END  AND SC.CompanyId = @companyID
	WHERE SI.CategoryID = CASE WHEN @catergoryID = -999 THEN SI.CategoryID ELSE @catergoryID END  
END

GO

