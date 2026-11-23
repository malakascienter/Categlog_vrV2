


--Ann Fernando
--[SP_GetSupplierWiseStockItems]

CREATE PROCEDURE [dbo].[SP_GetSupplierWiseStockItems] --1,1,2
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
	@Supplierid INT 
    WITH RECOMPILE
AS
    BEGIN


        SELECT  H.Id ,
                H.Name ,
                D.AveragePrice ,
                D.MasterUnitID ,
                SD.CostPrice  SellingPrice,
                H.StockItemCode,
				U.Name AS Barcode 

        FROM    dbo.StockItemDetails D
                INNER JOIN dbo.StockItemHeaders H ON D.StockItemHeaderID = H.Id
				INNER JOIN dbo.SupplierWiseItemDetails SD ON sd.StockItemID=D.Id and SD.LocationId=D.LocationID
				Inner join [dbo].[Units] U on U.id = D.MasterUnitID
        WHERE   ( D.LocationID = @Locationid )
                AND ( D.PropertyID = @Propertyid )
                AND D.IsActive=1
				AND SD.SupplierID=@Supplierid
    END

GO

