-- =============================================
-- Author:		Vinuki
-- Modified by : Nivesh
-- Modified Date: 2024-08-01
-- Create date: Get Data for Document Download
-- Description:	
-- =============================================
--SP_GetDataForFilteration 1,4168,1,-999,-999,1,0

CREATE PROCEDURE [dbo].[SP_GetDataForFilteration]
( @SupplierID Int , @UserID Int, @PropertyID int , @CategoryID int , @SubCategoryID int , @LocationID int, @IsSupplierWise bit =1)

AS
BEGIN
	
		IF(@IsSupplierWise =1)
		BEGIN
			SELECT DISTINCT
				S.Name,
				L.Code as LocationCode ,
				sh.StockItemCode,L.Name as LocationName,
				C.Name as CategoryName,
				SC.Name as SubCategoryName,
				sh.Name as ItemName,
				CONVERT(decimal(10,2), sw.CostPrice) as CostPrice,
				g.Name as TaxName,
				sw.IsDefaultSupplier, 
				SW.CompanyId,
				g.TaxGroupId,
				U.Name as PurchaseUnitName
			FROM dbo.SupplierWiseItemDetails AS SW
			INNER JOIN dbo.Suppliers AS S ON S.ID = SW.SupplierID 
			INNER JOIN dbo.Units AS U ON U.Id =SW.PurchaseUnitID
			INNER JOIN dbo.Locations L ON L.Id=SW.LocationId
			INNER JOIN TaxGroups g on sw.TaxGroupID = g.TaxGroupId
			INNER JOIN StockItemHeaders sh on sw.StockItemID = sh.Id
			--INNER JOIN StockItemDetails sd ON sd.StockItemHeaderID = sh.Id
			LEFT JOIN Categories C on c.Id = sh.CategoryID
			LEFT JOIN SubCategories SC on SC.Id = sh.SubCategoryID
			WHERE SW.SupplierID = @SupplierID 
				AND SW.CompanyId = @PropertyID  
				AND (sh.CategoryID = CASE WHEN  @CategoryID = -999 THEN sh.CategoryID ELSE @CategoryID END)  
				AND (sh.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN sh.SubCategoryID ELSE @SubCategoryID END) 
				--AND sd.IsActive = 1
				AND L.Id = @locationid
		END
		ELSE IF(@IsSupplierWise =0)
		BEGIN
			SELECT DISTINCT
				'' Name,
				L.Code as LocationCode ,
				sh.StockItemCode,L.Name as LocationName,
				C.Name as CategoryName,
				SC.Name as SubCategoryName,
				sh.Name as ItemName,
				CONVERT(decimal(10,2), 0) as CostPrice,
				ISNULL(g.Name,'VAT 0') as TaxName,
				0 IsDefaultSupplier,
				sh.CompanyId,
				ISNULL(g.TaxGroupId,1) TaxGroupId,
				U.Name as PurchaseUnitName
			FROM dbo.StockItemHeaders AS sh
			INNER JOIN StockItemDetails sd on sd.StockItemID = sh.Id
			INNER JOIN dbo.Units AS U ON U.Id =sd.MasterUnitID
			INNER JOIN dbo.Locations L ON L.Id=SD.LocationId
			LEFT JOIN TaxGroups g on sh.TaxGroupID = g.TaxGroupId					 
			LEFT JOIN Categories C on c.Id = sh.CategoryID
			LEFT JOIN SubCategories SC on SC.Id = sh.SubCategoryID
			WHERE  sh.CompanyId = @PropertyID  
				AND (sh.CategoryID = CASE WHEN  @CategoryID = -999 THEN sh.CategoryID ELSE @CategoryID END)  
				AND (sh.SubCategoryID = CASE WHEN @SubCategoryID = -999 THEN sh.SubCategoryID ELSE @SubCategoryID END) 
				AND sd.IsActive = 1
				AND L.Id = @locationid
		END
END

GO

