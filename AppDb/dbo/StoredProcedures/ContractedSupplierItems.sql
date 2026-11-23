-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-09-03
-- Description:	Loading active /expired contract supplier details
--	[dbo].[ContractedSupplierItems] 1,-999,-999,-999,-999,3

-- =============================================
create PROCEDURE [dbo].[ContractedSupplierItems]
@PropertyID INT,
@LocationID INT,
@StockItemID INT,
@CategoryId INT,
@SubCatId INT,
@selectedOptionID INT
AS
BEGIN
	SET NOCOUNT ON;


	IF(@selectedOptionID =3)
	BEGIN

	SELECT DISTINCT SW.StockItemID,SW.LocationId
	INTO #TempContracted
	FROM SupplierWiseItemDetails SW
	INNER JOIN StockItemHeaders H ON H.ID = SW.StockItemID
	 INNER JOIN StockItemDetails D ON H.Id = D.StockItemHeaderID AND SW.LocationId = D.LocationID
	 WHERE SW.IsContractedSupplier = 1
	 AND CONVERT(DATE,GETDATE()) BETWEEN SW.Validfrom AND ValidTo
	 AND SW.LocationID = CASE WHEN @LocationID = -999 THEN SW.LocationId ELSE @LocationID END
	 AND H.CompanyId = CASE WHEN @PropertyID =  -999 THEN H.CompanyId ELSE @PropertyID END
	  AND H.ID = CASE WHEN @StockItemID = -999 THEN H.Id ELSE @StockItemID END
	  AND H.CategoryID = CASE WHEN @CategoryId = -999 THEN H.CategoryID ELSE @CategoryId END
	  AND H.SubCategoryID = CASE WHEN @SubCatId = -999 THEN H.SubCategoryID ELSE @SubCatId END

	SELECT DISTINCT H.StockItemCode,H.Name,C.Name AS Category, SC.Name AS SubCategory,SC2.Description AS SubCategory2, 
	 (SELECT [dbo].[FN_GetTopMasterUnit](H.Id)) AS MasterUnit
		FROM StockItemHeaders H
	  INNER JOIN StockItemDetails D ON H.Id = D.StockItemHeaderID
	  INNER JOIN Categories C ON C.Id = H.CategoryID
	  INNER JOIN SubCategories SC ON SC.Id = H.SubCategoryID
	  INNER JOIN SubCategories02 SC2 ON SC2.Id = H.SubCategory2ID  
	  WHERE H.CompanyId = CASE WHEN @PropertyID =  -999 THEN H.CompanyId ELSE @PropertyID END
	  AND D.LocationID = CASE WHEN @LocationID = -999 THEN D.LocationId ELSE @LocationID END
	  AND H.ID = CASE WHEN @StockItemID = -999 THEN H.Id ELSE @StockItemID END
	  AND H.CategoryID = CASE WHEN @CategoryId = -999 THEN H.CategoryID ELSE @CategoryId END
	  AND H.SubCategoryID = CASE WHEN @SubCatId = -999 THEN H.SubCategoryID ELSE @SubCatId END
	  AND H.ID NOT IN (SELECT StockItemID FROM #TempContracted)



		--SELECT S.Name AS Supplier,SH.StockItemCode, SH.Name AS Item,U.Name AS PurchasingUnit, T.Name AS Tax,L.Name AS Location, SD.CostPrice as Price
		--,SD.Validfrom,ValidTo
		--FROM SupplierWiseItemDetails SD 
		--INNER JOIN Suppliers s ON S.Id = SD.SupplierID
		--INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
		--INNER JOIN Units U ON U.Id = SD.PurchaseUnitID
		--INNER JOIN TaxGroups T ON T.TaxGroupId = SD.TaxGroupID
		--INNER JOIN Locations L ON L.id = SD.LocationId
		--WHERE ISNULL(SD.IsContractedSupplier,0)=0
		--AND SD.LocationId = CASE WHEN @LocationID = -999 THEN SD.LocationId ELSE @LocationID END
		--AND SH.CompanyId = CASE WHEN @PropertyID =  -999 THEN SH.CompanyId ELSE @PropertyID END
		--AND SH.ID = CASE WHEN @StockItemID = -999 THEN SH.Id ELSE @StockItemID END
		--AND SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
		--AND SH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SH.SubCategoryID ELSE @SubCatId END
		
	END
	ELSE
	BEGIN
		SELECT S.Name AS Supplier,SH.StockItemCode, SH.Name AS Item,U.Name AS PurchasingUnit, T.Name AS Tax,L.Name AS Location, SD.CostPrice as Price
		,SD.Validfrom,ValidTo
		FROM SupplierWiseItemDetails SD 
		INNER JOIN Suppliers s ON S.Id = SD.SupplierID
		INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemID
		INNER JOIN Units U ON U.Id = SD.PurchaseUnitID
		INNER JOIN TaxGroups T ON T.TaxGroupId = SD.TaxGroupID
		INNER JOIN Locations L ON L.id = SD.LocationId
		WHERE SD.IsContractedSupplier=1
		AND SD.LocationId = CASE WHEN @LocationID = -999 THEN SD.LocationId ELSE @LocationID END
		AND SH.CompanyId = CASE WHEN @PropertyID =  -999 THEN SH.CompanyId ELSE @PropertyID END
		AND SH.ID = CASE WHEN @StockItemID = -999 THEN SH.Id ELSE @StockItemID END
		AND SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
		AND SH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SH.SubCategoryID ELSE @SubCatId END
		AND ((@selectedOptionID = 1 AND SD.ValidTo >= GETDATE()) OR
		(@selectedOptionID = 2 AND SD.ValidTo < GETDATE()) OR
		(@selectedOptionID NOT IN (1,2)) );
	END



    
END

GO

