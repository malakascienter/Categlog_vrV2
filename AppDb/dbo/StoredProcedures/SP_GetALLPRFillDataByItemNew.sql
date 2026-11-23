-- created by Ramesh
--SP_GetALLPRFillDataByItem 1,1,127

-- [dbo].[SP_GetALLPRFillDataByItemNew] 1,1,19

CREATE PROCEDURE [dbo].[SP_GetALLPRFillDataByItemNew] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@Itemid INT 
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid ,
            @ISGross BIT,@IsCUSDECSelection BIT
         
        SELECT  @ISGross = IsTaxOrSellPrice,@IsCUSDECSelection = ISNULL(IsCUSDECSelection,0)
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid


        SELECT 
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name ,
               -- dbo.StockItemDetails.AveragePrice AS CostPrice,
               dbo.[FN_GetLastAveragePrice](@LocationID,@Itemid) AS CostPrice, --Added by Isuru 2025-07-23 to loading last average price
                dbo.StockItemDetails.MasterUnitID ,
				U.Name AS MasterUnit,
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
                MaintainPriceHistory AS MaintainPriceHistory,
				ISNULL(IsProductionItem,0) IsProductionItem
				,ISNULL(IsExpiryDateApplicable,0)IsExpiryDateApplicable
                , ISNULL(C.CUSDECList,NULL) CUSDECList
        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN Units U ON U.ID = dbo.StockItemDetails.MasterUnitID
			--	LEFT JOIN Inv_ItemWiseRecipes IR ON IR.StockItemId = dbo.StockItemHeaders.Id

            CROSS APPLY dbo.fn_GetCUSDECList(@LocationID,@Itemid,-999,@propertyId,@IsCUSDECSelection) C
        WHERE    dbo.StockItemDetails.LocationID = @Locationid1 
                AND dbo.StockItemDetails.PropertyID = @Propertyid1   AND   dbo.StockItemHeaders.Id=@Itemid
    END

GO

