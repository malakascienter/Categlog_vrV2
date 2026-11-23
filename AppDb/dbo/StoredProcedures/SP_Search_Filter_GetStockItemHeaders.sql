

-- [dbo].[SP_Search_Filter_GetStockItemHeaders] 172
CREATE   PROCEDURE [dbo].[SP_Search_Filter_GetStockItemHeaders] --9460
	@value INT
	AS 
	BEGIN
		DECLARE @DisableExpDate BIT = 0;
		SELECT LocationId, QuantityInHand INTO #TempStockDetals FROM StockItemDetails WHERE StockItemHeaderID = @value

		IF( SELECT COUNT(*) FROM #TempStockDetals WHERE QuantityInHand > 0) > 0
			SET @DisableExpDate = 1
		ELSE 
			SET @DisableExpDate = 0

		--SELECT H.Id,H.StockItemCode,H.PLUCode,D.IsActive,H.Name,H.ImageUrl,H.TaxGroupID,H.IsExpiryDateApplicable,D.SIH,D.MinimumQuantity,
		--D.MaximumQuantity,D.ReOrderLevel,D.ReOrderQuantity,D.CostPrice,D.AveragePrice,H.supplierID,H.LocationID 
		--FROM dbo.StockItemHeaders AS H INNER JOIN dbo.StockItemDetails AS D ON D.StockItemHeaderID = H.Id 
  --                               INNER JOIN dbo.Categories AS C ON H.CategoryID = C.Id INNER JOIN dbo.SubCategories AS S ON H.SubCategoryID = S.Id 
                                 --WHERE H.id = @value

								 SELECT H.Id,H.StockItemCode,H.PLUCode,H.Name,H.NameOnInvoice,H.ImageUrl,H.TaxGroupID ,t.Name AS TaxGroupName,
								 H.IsExpiryDateApplicable,H.Isbundle as Isbundle,H.MaintainPriceHistory,H.Remarks,H.IsPriceEditable,H.supplierID,
								 H.LocationID,
								 C.Name AS CategoryName, H.CategoryID, S.Name AS SubCatergoryName, H.SubCategoryID,ISNULL((SELECT TOP(1) SH.IsActive FROM dbo.StockItemDetails AS SH WHERE StockItemHeaderID=@value AND IsActive=1),0) AS IsActive,
								 (SELECT TOP(1) SH.MasterUnitID FROM dbo.StockItemDetails AS SH INNER JOIN locations lo on sh.locationid=lo.id WHERE StockItemHeaderID=@value and lo.ismainstore=1) AS MasterUnitID,H.SubCategory2ID,S2.Description AS SubCatergory2Name, H.BrandedItem, H.GenericItemCode,
								 @DisableExpDate AS DisableExpDate,
								 H.IsMultiplePrices,H.IsMultipleBarcode,H.IsAllowDiscount,H.IsFractionItem,H.IsSerialNo,H.IsAllowReturnItem, H.IsOpenPrice, --Added By Nivesh 2024-02-27
								 H.IsSellingItem
								 ,H.ChargeHeaderID ChargeHeaderID, CG.Name ChargeGroupName,IM.ItemImage,H.ERPReferenceCode
								 ,ISNULL(H.IsProductionItem,0) IsProductionItem --Added by Nivesh 2024-08-23
								 ,H.ReportUnitID, RU.Name AS ReportUnitName --Added by Tharuka 2026-09-17
		--,D.MaximumQuantity,D.ReOrderLevel,D.ReOrderQuantity,D.CostPrice,D.AveragePrice,D.IsActive,D.SIH,D.MinimumQuantity
		FROM dbo.StockItemHeaders AS H 
	
		--INNER JOIN dbo.StockItemDetails AS D ON D.StockItemHeaderID = H.Id 
        left JOIN dbo.Categories AS C ON H.CategoryID = C.Id left JOIN dbo.SubCategories AS S ON H.SubCategoryID = S.Id 
		left JOIN dbo.SubCategories02 AS S2 ON S2.Id=H.SubCategory2ID
		left JOIN TaxGroups t ON H.TaxGroupID = t.TaxGroupId
		left join Gen_ChargeGroupHeader CG ON CG.ChargeHeaderID = H.ChargeHeaderID
		left join [StockItemWiseImage] IM ON H.Id = IM.StockItemId
		left join Units RU ON RU.Id = H.ReportUnitID
		WHERE H.Id= @value
	END 

	--SELECT * FROM StockItemHeaders
	--SELECT * FROM TaxGroups

GO

