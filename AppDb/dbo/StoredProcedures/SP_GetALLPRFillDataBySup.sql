--SP_GetALLPRFillDataBySup 1,1,197
CREATE PROCEDURE [dbo].[SP_GetALLPRFillDataBySup] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@Supplierid INT 
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid ,
            @ISGross BIT
         
        SELECT  @ISGross = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid

        SELECT 
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name ,
                SD.CostPrice ,
                dbo.StockItemDetails.MasterUnitID ,
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
                MaintainPriceHistory AS MaintainPriceHistory
        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN dbo.SupplierWiseItemDetails SD ON sd.StockItemID=dbo.StockItemHeaders.Id  and sd.locationid=@Locationid1
        WHERE   ( dbo.StockItemDetails.LocationID = @Locationid1 )
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 ) AND SD.SupplierID=@Supplierid
    END

GO

