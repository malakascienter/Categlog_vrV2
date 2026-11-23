
--  [dbo].[SP_GetPRFillDataBySup2ForHTC] 1,1,6,1

CREATE PROCEDURE [dbo].[SP_GetPRFillDataBySup2ForHTC] --1,1,1
	-- Add the parameters for the stored procedure here
    @Locationid INT ,
    @Propertyid INT ,
    @Categoryid INT ,
	@Supplierid INT 
    WITH RECOMPILE
AS
    BEGIN

	DECLARE @IsTenderBoardApplicable BIT
	SELECT @IsTenderBoardApplicable = IsTenderBoardApplicable FROM Companies
	
	IF(@IsTenderBoardApplicable = 0)
		EXEC SP_GetPRFillDataBySup2    @Locationid , @Propertyid , @Categoryid ,@Supplierid  

	ELSE
	BEGIN
		    DECLARE @Locationid2 INT= @Locationid ,
            @Propertyid2 INT= @Propertyid ,
            @Categoryid2 INT = @Categoryid

        
    
		  

        SELECT  dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.StockItemCode + '/'+ dbo.StockItemHeaders.Name AS Name  ,
				dbo.StockItemHeaders.IsExpiryDateApplicable,
               dbo.StockItemHeaders.CategoryID CategoryID 
        FROM    dbo.StockItemDetails
                INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				INNER JOIN dbo.SupplierWiseItemDetails SD ON sd.StockItemID=dbo.StockItemHeaders.Id and sd.LocationId=@Locationid2 
				inner join TenderBoardPaperHeaders as TB  on SD.TBPHeaderID=TB.Id
        WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
                AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 )
                AND ( dbo.StockItemHeaders.CategoryID = @Categoryid2 ) AND dbo.StockItemDetails.IsActive=1
				AND SD.SupplierID=@Supplierid
				AND TB.Basetype=2
				AND TB.status=2
				AND StockItemDetails.IsActive = 1
				AND TB.ExpireDate > getdate()

		--Group by StockItemHeaders.Id,dbo.StockItemHeaders.Name
		ORDER BY dbo.StockItemHeaders.Name
	END
    
END

GO

