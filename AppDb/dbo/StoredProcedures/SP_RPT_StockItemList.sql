-- [dbo].[SP_RPT_StockItemList] 1,-999,-999,-999, '3598,15,14,16,3597,7,12,1,8,2604,13,21,19,20', -999

-- =============================================
-- Author:		Nivesh
-- Create date: 2026-06-01
-- =============================================
 
CREATE     PROCEDURE  [dbo].[SP_RPT_StockItemList](
	@PropertyID INT,
	@CategoryId INT,
	@SubCatId INT,
	@SubCat2Id INT,
	@MultipleLocationID VARCHAR(MAX),
	@selectedOptionID INT
)--, @LocationID INT)
AS
BEGIN
	DECLARE @LocationListTable TABLE(
		Id INT,
		LocationName VARCHAR(100)
	)

	INSERT INTO @LocationListTable 
 	SELECT Id, Name LocationName 
	FROM Locations
	WHERE Id IN (SELECT * FROM string_split(@MultipleLocationID,N','))

	SELECT DISTINCT 
		H.StockItemCode,
		H.Name,
		C.Name AS Category, 
		SC.Name AS SubCategory,
		L.Name AS LacationName,
		SC2.Description AS SubCategory2, 
		(SELECT [dbo].[FN_GetTopMasterUnit](H.Id)) AS MasterUnit,
		D.QuantityInHand,
		D.AveragePrice,
		H.NameOnInvoice,
		TableBarCode.Barcode,
		D.IsActive
	FROM StockItemHeaders H
	INNER JOIN StockItemDetails D ON H.Id = D.StockItemHeaderID
	INNER JOIN Categories C ON C.Id = H.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = H.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.Id = H.SubCategory2ID 
	INNER JOIN Locations L ON D.LocationID = L.Id
	OUTER APPLY (
		SELECT STRING_AGG(PB.Barcode,',') AS Barcode
		FROM POS_ItemBarCode PB 
		WHERE PB.ItemID = H.Id AND PB.CompanyID = H.CompanyId
	) AS TableBarCode
	WHERE H.CategoryID = CASE WHEN @CategoryId = -999 THEN H.CategoryID  ELSE @CategoryId END
	AND H.SubCategoryID =  CASE WHEN @SubCatId = -999 THEN H.SubCategoryID  ELSE @SubCatId END
	AND H.SubCategory2ID =  CASE WHEN @SubCat2Id = -999 THEN H.SubCategory2ID  ELSE @SubCat2Id END
	AND H.CompanyId = CASE WHEN @PropertyId = -999 THEN H.CompanyId  ELSE @PropertyId END
	AND (D.IsActive = @selectedOptionID OR @selectedOptionID = -999)
	AND D.LocationId IN ( SELECT Id FROM @LocationListTable)
END

GO

