-- =============================================
-- Author:		Tharuka sachintha
-- Create date: 2026-05-22
-- Description:	get selected items details 

-- [dbo].[SP_GetItemDetailsForFranchise] 1,3598,1,3415


-- =============================================
CREATE PROCEDURE [dbo].[SP_GetItemDetailsForFranchise]
	-- Add the parameters for the stored procedure here
    @MainLocationid INT,
    @Locationid INT ,
    @Propertyid INT,
	@Itemid INT 
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid ,
            @ISGross BIT,@IsCUSDECSelection BIT

        DECLARE @SupplierID INT;
         
        SELECT  @ISGross = IsTaxOrSellPrice,@IsCUSDECSelection = ISNULL(IsCUSDECSelection,0),@SupplierID = SupplierId
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid


        SELECT 
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name ,
               --ISNULL((
               --     SELECT TOP 1 s.AveragePrice        
               --     FROM dbo.StockItemDetails s
               --     WHERE s.LocationId = @MainLocationid
               --       AND s.StockItemID = @Itemid      
               --     ORDER BY s.LocationId           
               -- ), 0) AS CostPrice,
               --ISNULL((
               --     SELECT TOP 1 s.CostPrice        
               --     FROM dbo.SupplierWiseItemDetails s
               --     WHERE s.LocationId = @Locationid
               --       AND s.StockItemID = @Itemid        -- replace 'ItemID' with your exact column name
               --     ORDER BY s.LocationId         
               -- ), 0) AS SellingPrice, 
               sw.CostPrice AS CostPrice,
               sw.CostPrice AS SellingPrice,
                sw.PurchaseUnitID as MasterUnitID ,
				U.Name AS MasterUnit,
                --( CASE WHEN @ISGross = 0
                --       THEN dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
                --                                            dbo.StockItemHeaders.TaxGroupID)
                --       ELSE dbo.StockItemDetails.SellingPrice
                --  END ) SellingPrice ,
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
				-- INNER JOIN Units U ON U.ID = dbo.StockItemDetails.MasterUnitID
                INNER JOIN SupplierWiseItemDetails sw on sw.StockItemID = dbo.StockItemDetails.StockItemHeaderID and sw.LocationId = @Locationid1 
                AND SW.SupplierID = @SupplierID
                INNER JOIN Units U ON U.ID = sw.PurchaseUnitID
			--	LEFT JOIN Inv_ItemWiseRecipes IR ON IR.StockItemId = dbo.StockItemHeaders.Id

            CROSS APPLY dbo.fn_GetCUSDECList(@LocationID,@Itemid,-999,@propertyId,@IsCUSDECSelection) C
        WHERE    dbo.StockItemDetails.LocationID = @Locationid1
                AND dbo.StockItemDetails.PropertyID = @Propertyid1   AND   dbo.StockItemHeaders.Id=@Itemid
    END

GO

