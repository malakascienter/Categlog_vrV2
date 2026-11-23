-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-08-08
-- Description:	Updating Selling Price Change Log Table

-- [dbo].[SP_UpdateSellingPrice] '<ArrayOfSellingPice_Changes xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><SellingPice_Changes><ID>240</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>4444</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>241</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>4443</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>242</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>1</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>243</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>2</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>244</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>3</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>245</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>5</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>246</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>8</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>247</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>9</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>248</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>10</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>249</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>11</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>250</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>22</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>251</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>12</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>252</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>15</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>253</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>19</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes><SellingPice_Changes><ID>254</ID><StockItemID>59</StockItemID><LocationID>4</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>20</SellingPrice><BusinessDate>2023-08-01</BusinessDate></SellingPice_Changes></ArrayOfSellingPice_Changes>'

-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateSellingPrice]
@XMLData AS XML
AS
BEGIN
	DECLARE @iDocID INT 
	SET NOCOUNT ON;

	 BEGIN TRY
        BEGIN TRANSACTION;

       
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

			SELECT * INTO #TempAllDetails
			FROM
            OPENXML(@iDocID, '/ArrayOfSellingPice_Changes/SellingPice_Changes', 2)
            WITH (ID INT,StockItemID INT,LocationID INT,PropertyID INT,SellingPrice INT,BusinessDate VARCHAR,IsActive BIT)


			select *
			from #TempAllDetails TP
			INNER JOIN SellingPrice_ChangeLog SE ON TP.ID = SE.ID

			UPDATE SE
			SET SE.IsActive = TP.IsActive,SE.IsUpload=0
			from #TempAllDetails TP
			INNER JOIN SellingPrice_ChangeLog SE ON TP.ID = SE.ID

			select *
			from #TempAllDetails TP
			INNER JOIN SellingPrice_ChangeLog SE ON TP.ID = SE.ID

		EXEC sp_xml_removedocument @iDocID;

    
	 COMMIT TRANSACTION;
    END TRY


    BEGIN CATCH
      
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY()
          

      
        ROLLBACK TRANSACTION;

     
        IF @iDocID IS NOT NULL
        BEGIN
            EXEC sp_xml_removedocument @iDocID;
        END

      
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

