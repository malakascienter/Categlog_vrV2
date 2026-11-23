
--SP_GetALLProjectPRFillData 1,1,2
CREATE PROCEDURE [dbo].[SP_GetALLProjectPRFillData] 
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
    @Projectid INT
    WITH RECOMPILE
AS
    BEGIN
        DECLARE @Locationid1 INT= @Locationid ,
            @Propertyid1 INT = @Propertyid ,
            @ISGross BIT
         
        SELECT DISTINCT @ISGross = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid

        SELECT  SH.Id ,
                SH.Name + ISNULL(( '/' + D.Name ), '') AS Name ,
                ISNULL(SUP.Price, 0) AS CostPrice ,
                SD.MasterUnitID ,
                --( CASE WHEN @ISGross = 0
                --       THEN dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                --                                            SH.TaxGroupID)
                --       ELSE SD.SellingPrice
                --  END ) SellingPrice 
                0 AS SellingPrice ,
               --SH.IsPriceEditable ,
                0 AS IsPriceEditable ,
                SH.StockItemCode ,
               --SH.Barcode ,
                '' AS Barcode ,
                1 Quantity ,
                --dbo.FN_GetActualPriceWithoutTax(SD.SellingPrice,
                --                               SH.TaxGroupID) Value ,
                0 AS Value ,
               -- SD.SellingPrice AS TaxInclusivePrice ,
                0 AS TaxInclusivePrice ,
              --  MaintainPriceHistory AS MaintainPriceHistory
                0 AS MaintainPriceHistory
        FROM    dbo.StockItemDetails SD
                INNER JOIN dbo.StockItemHeaders SH ON SH.Id = SD.StockItemHeaderID

                LEFT JOIN 
				
			(SELECT sh.Name,ss.StockItemHeaderID,ss.LocationId,ss.CompanyId FROM dbo.StockItemWiseClassificationDetails ss INNER JOIN dbo.StockItemClassificationHeaders sd ON sd.Id=ss.ItemClassificationHeaderID INNER JOIN dbo.StockItemClassificationDetails sh ON sh.Id=ss.ItemClassificationDetailID AND sh.ItemClassificationHeaderID=sd.Id WHERE sd.name='UDF4'
				--WHERE SSSC.StockItemHeaderID = SH.Id
    --                                                          AND SH.LocationId = SSSC.LocationId
    --                                                          AND SH.CompanyId = SSSC.CompanyId
				
				) AS D ON D.StockItemHeaderID=SH.ID 
				--AND SH.LocationId=D.LocationId 
				AND SH.CompanyId=D.CompanyId



                LEFT JOIN ( SELECT  MIN(SDD.Price - SDD.DiscountValue) AS Price ,
                                    SDD.StockItemID
                            FROM    dbo.ProjectWiseSupplierPrices SDD
                            WHERE   SDD.ProjectID = @Projectid
                            GROUP BY SDD.StockItemID
                          ) AS SUP ON SUP.StockItemID = SH.Id
        WHERE   ( SD.LocationID = @Locationid1 )
                AND ( SD.PropertyID = @Propertyid1 )
        ORDER BY SH.Name ASC
    END

GO

