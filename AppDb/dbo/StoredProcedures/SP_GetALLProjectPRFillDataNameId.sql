
--SP_GetALLProjectPRFillData 1,1,3
CREATE PROCEDURE [dbo].[SP_GetALLProjectPRFillDataNameId] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT,
	@Projectid INT 
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
                SH.Id ,
                SH.Name 
              -- ISNULL(SUP.Price,0) AS CostPrice,
              -- SD.MasterUnitID ,
                --( CASE WHEN @ISGross = 0
                --       THEN dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                --                                            SH.TaxGroupID)
                --       ELSE SD.SellingPrice
                --  END ) SellingPrice 
				--0 AS SellingPrice,
               --SH.IsPriceEditable ,
			  -- 0 AS IsPriceEditable,
              -- SH.StockItemCode ,
               --SH.Barcode ,
			  -- '' AS Barcode,
              --  1 Quantity ,
                --dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                --                               SH.TaxGroupID) Value ,
			--	0 AS Value,
               -- SD.SellingPrice AS TaxInclusivePrice ,
			 --  0 AS TaxInclusivePrice,
              --  MaintainPriceHistory AS MaintainPriceHistory
			 -- 0 AS MaintainPriceHistory
        FROM    dbo.StockItemDetails SD
                INNER JOIN dbo.StockItemHeaders SH ON SH.Id = SD.StockItemHeaderID
				left JOIN 
	(SELECT  MIN(SDD.Price-SDD.DiscountValue) AS Price,SDD.StockItemID FROM  dbo.ProjectWiseSupplierPrices SDD WHERE SDD.ProjectID=@Projectid GROUP BY SDD.StockItemID) as SUP ON SUP.StockItemID=SH.Id
        WHERE   ( SD.LocationID = @Locationid1 )
                AND ( SD.PropertyID = @Propertyid1)
				ORDER BY SH.name ASC
    END

GO

