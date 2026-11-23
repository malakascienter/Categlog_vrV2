
CREATE PROCEDURE [dbo].[SP_CheckExpiryDateApplicable] 

    @StockItemId INT ,
    @Propertyid INT
    WITH RECOMPILE
AS
    BEGIN


        SELECT IsExpiryDateApplicable
        FROM dbo.StockItemHeaders
		WHERE CompanyId = @Propertyid AND id = @StockItemId




    END

GO

