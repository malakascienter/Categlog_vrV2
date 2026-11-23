
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_SaveProjectWiseSupPrice
    (
      @XMLDetails XML, 
      @status INT OUTPUT 
  --    @message VARCHAR(MAX) OUTPUT
    )
AS
    DECLARE @iDocID INT 

 

    BEGIN TRY
        BEGIN TRANSACTION

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails
        DECLARE @ProjectID INT ,
            @SupplierID INT ,
            @StockItemID INT ,
            @Price DECIMAL(18, 2) ,
            @DiscountValue DECIMAL(18, 2)

 
 --
        SELECT  @ProjectID = ProjectID ,
                @SupplierID = SupplierID ,
                @Price = Price ,
				@StockItemID=StockItemID,
                @DiscountValue = DiscountValue
        FROM    OPENXML (@iDocID,'ProjectWiseSupplierPrices',2)
        WITH    ProjectWiseSupplierPrices




        IF EXISTS ( SELECT  *
                    FROM    ProjectWiseSupplierPrices
                    WHERE   ProjectID = @ProjectID
                            AND SupplierID = @SupplierID
                            AND StockItemID = @StockItemID )
            BEGIN
                UPDATE  ProjectWiseSupplierPrices
                SET     Price = @Price ,
                        DiscountValue = @DiscountValue ,
                        NetPrice = @Price - @DiscountValue
                WHERE   ProjectID = @ProjectID
                        AND SupplierID = @SupplierID
                        AND StockItemID = @StockItemID

			  SELECT @status=1
            END 

        ELSE
            BEGIN
                INSERT  INTO ProjectWiseSupplierPrices
                        SELECT  *
                        FROM    OPENXML (@iDocID,'ProjectWiseSupplierPrices',2)
                 WITH    ProjectWiseSupplierPrices

				 SELECT @status=2

            END 

 




        EXEC sp_xml_removedocument @iDocID
        IF @@TRANCOUNT > 0
            COMMIT TRAN
 
    END TRY
    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN 
    END CATCH

GO

