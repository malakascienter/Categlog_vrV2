CREATE PROCEDURE [dbo].[SP_GetPRFillDataBySup2] --1,1,2
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

        
         
       	
		  

        SELECT  dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.Name ,
               dbo.StockItemHeaders.IsExpiryDateApplicable,
               dbo.StockItemHeaders.CategoryID CategoryID 
        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN dbo.SupplierWiseItemDetails SD ON sd.StockItemID=dbo.StockItemHeaders.Id and sd.LocationId=@Locationid2
        WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
                AND ( dbo.StockItemHeaders.CategoryID = @Categoryid2 ) AND dbo.StockItemDetails.IsActive=1
				AND SD.SupplierID=@Supplierid

		ORDER BY dbo.StockItemHeaders.Name
    END

GO

