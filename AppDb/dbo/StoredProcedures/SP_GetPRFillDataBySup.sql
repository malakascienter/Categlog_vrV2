
--[SP_GetPRFillDataBySup] 1,1,9,425 

CREATE PROCEDURE [dbo].[SP_GetPRFillDataBySup] --1,1,2
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
    @Categoryid INT ,
	@Supplierid INT 
    WITH RECOMPILE
AS
    BEGIN

        DECLARE @Locationid2 INT= @Locationid ,
            @Propertyid2 INT= @Propertyid ,
            @Categoryid2 INT = @Categoryid

        DECLARE @ISGross BIT
         
        SELECT  @ISGross = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid2		
		  

        SELECT  dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name ,
                dbo.StockItemDetails.AveragePrice AS CostPrice ,
                dbo.StockItemDetails.MasterUnitID ,
                ( CASE WHEN @ISGross = 0
                       THEN dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
                                                            dbo.StockItemHeaders.TaxGroupID)
                       ELSE dbo.StockItemDetails.SellingPrice
                  END ) SellingPrice ,
                StockItemHeaders.IsPriceEditable ,
                StockItemHeaders.StockItemCode ,
                dbo.StockItemHeaders.Barcode ,
                dbo.StockItemDetails.SellingPrice AS TaxInclusivePrice ,
                StockItemHeaders.MaintainPriceHistory
        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN dbo.SupplierWiseItemDetails SD ON sd.StockItemID=dbo.StockItemHeaders.Id and sd.LocationId=@Locationid2
        WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
                AND ( dbo.StockItemHeaders.CategoryID = @Categoryid2 ) AND dbo.StockItemDetails.IsActive=1
				AND SD.SupplierID=@Supplierid
    END

GO

