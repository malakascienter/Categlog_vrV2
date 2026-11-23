-- [dbo].[SP_GetSelectedItemDetailsBySup] 1,1,1,1

CREATE PROCEDURE [dbo].[SP_GetSelectedItemDetailsBySup] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@Supplierid INT,
	@Itemid INT 
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid ,
			@Supplierid1 INT = @Supplierid,
            @ISGross BIT,
			@IsDefault BIT
         
        SELECT  @ISGross = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid

		SELECT @IsDefault = CheckForDefaultSupplier  FROM CommonSettings

        SELECT 
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name ,
                dbo.SupplierWiseItemDetails.CostPrice AS CostPrice,
               -- dbo.StockItemDetails.MasterUnitID ,
			   SupplierWiseItemDetails.PurchaseUnitID MasterUnitID,
                ( CASE WHEN @ISGross = 0
                       THEN dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
                                                            dbo.StockItemHeaders.TaxGroupID)
                       ELSE dbo.StockItemDetails.SellingPrice
                  END ) SellingPrice ,
                dbo.StockItemHeaders.IsPriceEditable ,
                dbo.StockItemHeaders.StockItemCode ,
                dbo.StockItemHeaders.Barcode ,
                1 Quantity ,
                dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
                                                dbo.StockItemHeaders.TaxGroupID) Value ,
                dbo.StockItemDetails.SellingPrice AS TaxInclusivePrice ,
                MaintainPriceHistory AS MaintainPriceHistory,SupplierWiseItemDetails.IsDefaultSupplier,
				dbo.[FN_GetStockInHand_Reatils](@Propertyid,@Locationid,@Itemid) QtyInHand
				INTO #TemptemData
        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN dbo.SupplierWiseItemDetails ON dbo.SupplierWiseItemDetails.StockItemID = dbo.StockItemDetails.StockItemHeaderID
        WHERE   ( dbo.StockItemDetails.LocationID = @Locationid1 )
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 ) AND (dbo.SupplierWiseItemDetails.SupplierID= @Supplierid1) 
				 AND  (dbo.StockItemHeaders.Id=@Itemid AND dbo.SupplierWiseItemDetails.LocationId = @Locationid1)
				 	AND (SupplierWiseItemDetails.ValidTo >= GETDATE() OR SupplierWiseItemDetails.ValidTo IS NULL)
		
		IF @IsDefault = 0
			SELECT * FROM #TemptemData ORDER BY Name
		IF @IsDefault =1 
			SELECT * FROM #TemptemData WHERE IsDefaultSupplier = 1  ORDER BY Name


    END

GO

