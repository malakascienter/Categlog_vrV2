CREATE PROCEDURE [dbo].[SP_GetALLPRFillDataByItem] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@Itemid INT 
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
                dbo.StockItemDetails.AveragePrice AS CostPrice,
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
        WHERE   ( dbo.StockItemDetails.LocationID = CASE WHEN @Locationid1 = -999 THEN  dbo.StockItemDetails.LocationID ELSE @Locationid1 END)
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 )  AND   dbo.StockItemHeaders.Id=@Itemid
    END

GO

