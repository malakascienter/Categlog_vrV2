
--SP_GetALLPRFillData -999,1,15

CREATE PROCEDURE [dbo].[SP_GetALLPRFillData] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
    @ModuleID INT =-999
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid ,
            @ISGross BIT,@IsRecipeLocationMaintain BIT,@DefaultLocationID INT
         
        SELECT  @ISGross = IsTaxOrSellPrice,@IsRecipeLocationMaintain = IsRecipeLocationMaintain
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid


        SELECT TOP (1) @DefaultLocationID = ID
        FROM Locations
        WHERE DefaultLocation=1
        AND CompanyID = @Propertyid
        


        IF(@ModuleID = 15)
        BEGIN
            IF(@IsRecipeLocationMaintain =1)
            BEGIN
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
                    WHERE   ( dbo.StockItemDetails.LocationID = @Locationid1 )
                            AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 )
		    		        ORDER BY dbo.StockItemHeaders.name ASC
            END
            ELSE
            BEGIN
                SELECT DISTINCT
                            dbo.StockItemHeaders.Id ,
                            dbo.StockItemHeaders.Name ,
                            dbo.[FN_GetLastAveragePrice](@DefaultLocationID,dbo.StockItemHeaders.Id)  AS CostPrice ,
                            [dbo].[FN_GetMasterUnitID](@propertyId, @DefaultLocationID,dbo.StockItemHeaders.Id) MasterUnitID,
                            0  SellingPrice ,
                            dbo.StockItemHeaders.IsPriceEditable ,
                            dbo.StockItemHeaders.StockItemCode ,
                            dbo.StockItemHeaders.Barcode ,
                            1 Quantity 
                    FROM    dbo.StockItemDetails WITH (NOLOCK)
                            INNER JOIN dbo.StockItemHeaders  WITH (NOLOCK) ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
                    WHERE   ( dbo.StockItemDetails.LocationID = CASE WHEN @Locationid1 = -999 THEN dbo.StockItemDetails.LocationID ELSE @Locationid1 END  )
                            AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 )
		    		        ORDER BY dbo.StockItemHeaders.name ASC


            END

        END

        IF(@ModuleID = -999)
        BEGIN
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
            WHERE   ( dbo.StockItemDetails.LocationID = @Locationid1 )
                    AND ( dbo.StockItemDetails.PropertyID = @Propertyid1 )
		    		ORDER BY dbo.StockItemHeaders.name ASC
        END
    END
    

	
	--SELECT * FROM StockItemHeaders
	--SELECT * FROM StockItemDetails
	--SELECT * FROM dbo.StockItemWiseAttributes WHERE StockItemAttributeID =2

	--SELECT * FROM dbo.StockItemAttributes

GO

