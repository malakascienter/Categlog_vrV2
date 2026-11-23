-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

--[dbo].[SP_SaveExcelProjectWiseSupPrice] '<ArrayOfProjectWiseSupplierPrices xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><ProjectWiseSupplierPrices><IPAddress>12</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-01-07T08:34:28.54Z</CreatedDate><LastModDate>2019-01-07T08:34:28.54Z</LastModDate><Id>-1</Id><ProjectID>13</ProjectID><SupplierID>280</SupplierID><StockItemID>101</StockItemID><Price>122</Price><DiscountValue>12</DiscountValue><NetPrice>110</NetPrice><ProjectName>ss</ProjectName><SupplierName>sds</SupplierName><StockItemName /><Code>AKBP09</Code></ProjectWiseSupplierPrices><ProjectWiseSupplierPrices><IPAddress>12</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2019-01-07T08:34:28.54Z</CreatedDate><LastModDate>2019-01-07T08:34:28.54Z</LastModDate><Id>-1</Id><ProjectID>13</ProjectID><SupplierID>280</SupplierID><StockItemID>207</StockItemID><Price>231</Price><DiscountValue>33</DiscountValue><NetPrice>198</NetPrice><ProjectName>ss</ProjectName><SupplierName>sds</SupplierName><StockItemName /><Code>ABC005</Code></ProjectWiseSupplierPrices></ArrayOfProjectWiseSupplierPrices>',1
CREATE PROCEDURE [dbo].[SP_SaveExcelProjectWiseSupPrice]
    (
      @XMLDetails XML ,
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

 

        IF OBJECT_ID('tempdb.dbo.#TMP', 'U') IS NOT NULL
            DROP TABLE #TMP; 
 --
        SELECT  *
        INTO    #TMP
        FROM    OPENXML (@iDocID,'ArrayOfProjectWiseSupplierPrices/ProjectWiseSupplierPrices',2)
        WITH    ProjectWiseSupplierPrices


		SELECT * FROM #TMP

        WHILE ( SELECT  COUNT(*)
                FROM    #TMP
              ) > 0
            BEGIN



                SELECT TOP ( 1 )
                        @ProjectID = ProjectID ,
                        @SupplierID = SupplierID ,
                        @Price = Price ,
                        @StockItemID = StockItemID ,
                        @DiscountValue = DiscountValue
                FROM    #TMP
                ORDER BY StockItemID


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

                        SELECT  @status = 1
                    END 

                ELSE
                    BEGIN
                        INSERT  INTO ProjectWiseSupplierPrices
                                SELECT TOP ( 1 )
                                        *
                                FROM    #TMP
                 --       SELECT  *
                 --       FROM    OPENXML (@iDocID,'ProjectWiseSupplierPrices',2)
                 --WITH    ProjectWiseSupplierPrices

                        SELECT  @status = 2

                    END 

                DELETE  FROM #TMP
                WHERE   StockItemID = @StockItemID


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

