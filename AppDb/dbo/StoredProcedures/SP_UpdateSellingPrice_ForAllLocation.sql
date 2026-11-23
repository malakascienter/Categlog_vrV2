-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-01-07
-- Description:	Updating Selling Price Change Log Table For All Location

-- [dbo].[SP_UpdateSellingPrice_ForAllLocation] '<ArrayOfSellingPice_Changes_ForAllLocations xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><SellingPice_Changes_ForAllLocations><ID>1155</ID><StockItemID>5261</StockItemID><LocationID>15</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>100</SellingPrice><BusinessDate>2024-04-15</BusinessDate><UserID>4168</UserID></SellingPice_Changes_ForAllLocations><SellingPice_Changes_ForAllLocations><ID>1156</ID><StockItemID>5261</StockItemID><LocationID>15</LocationID><PropertyID>1</PropertyID><IsActive>false</IsActive><SellingPrice>110</SellingPrice><BusinessDate>2024-04-15</BusinessDate><UserID>4168</UserID></SellingPice_Changes_ForAllLocations><SellingPice_Changes_ForAllLocations><ID>1226</ID><StockItemID>5261</StockItemID><LocationID>15</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>120</SellingPrice><BusinessDate>2024-04-15</BusinessDate><UserID>4168</UserID></SellingPice_Changes_ForAllLocations><SellingPice_Changes_ForAllLocations><ID>1227</ID><StockItemID>5261</StockItemID><LocationID>15</LocationID><PropertyID>1</PropertyID><IsActive>true</IsActive><SellingPrice>130</SellingPrice><BusinessDate>2024-04-15</BusinessDate><UserID>4168</UserID></SellingPice_Changes_ForAllLocations></ArrayOfSellingPice_Changes_ForAllLocations>'



-- =============================================
CREATE PROCEDURE [dbo].[SP_UpdateSellingPrice_ForAllLocation]
(
    @XMLData AS XML
)
AS
BEGIN
    DECLARE @iDocID INT;
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Drop and recreate temp tables to ensure clean state
        IF OBJECT_ID('tempdb..#TempStockLocations') IS NOT NULL
            DROP TABLE #TempStockLocations;

        IF OBJECT_ID('tempdb..#TempAllDetails') IS NOT NULL
            DROP TABLE #TempAllDetails;

        -- Create temp tables
        CREATE TABLE #TempStockLocations (ID INT IDENTITY, LocationID INT);

        -- Parse XML data into a temporary table
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

        SELECT ID, StockItemID, LocationID, PropertyID, SellingPrice, BusinessDate, IsActive,UserID
        INTO #TempAllDetails
        FROM OPENXML(@iDocID, '/ArrayOfSellingPice_Changes_ForAllLocations/SellingPice_Changes_ForAllLocations', 2)
        WITH (
            ID INT,
            StockItemID INT,
            LocationID INT,
            PropertyID INT,
            SellingPrice INT,
            BusinessDate VARCHAR(50),
            IsActive BIT,
			UserID INT
        );


		

        DECLARE @StockItemID INT, @LocationID INT, @SellingPrice INT, @IsActive BIT,@PropertyID INT,@BusinessDate VARCHAR(50),@UserID INT;

       WHILE EXISTS (SELECT 1 FROM #TempAllDetails)
        BEGIN
            SELECT TOP(1) @StockItemID = StockItemID, @SellingPrice = SellingPrice, @IsActive = IsActive,@PropertyID =PropertyID,@BusinessDate = BusinessDate
			,@UserID = UserID
            FROM #TempAllDetails;

			 INSERT INTO #TempStockLocations (LocationID)
			SELECT DISTINCT LocationID
			FROM StockItemDetails
			WHERE StockItemHeaderID IN (SELECT DISTINCT StockItemID FROM #TempAllDetails);

			
			WHILE EXISTS(SELECT 1 FROM #TempStockLocations)
			BEGIN

			SELECT TOP (1)  @LocationID =LocationID FROM #TempStockLocations

			

			

			 IF EXISTS (SELECT 1 FROM SellingPrice_ChangeLog
                    WHERE SellingPrice = @SellingPrice
                        AND StockItemID = @StockItemID AND LocationID = @LocationID)
			BEGIN
		
                    UPDATE SellingPrice_ChangeLog
                    SET  IsActive = @IsActive, IsUpload =0
                    WHERE StockItemID = @StockItemID AND LocationID = @LocationID AND SellingPrice = @SellingPrice;

					 INSERT INTO [dbo].[RT_Sync_MasterDataTransferStatus]
						   ([PropertyId]
						   ,[UniqueId]
						   ,[Code]
						   ,[LocationId]
						   ,[DataType]
						   ,[Active]
						   ,[Delete])
					SELECT @PropertyId,
						   ID,
						   '',
						   @LocationID,
						   'ItemPriceChangeLog',
						   @IsActive,
						   0
					FROM SellingPrice_ChangeLog
					WHERE StockItemID = @StockItemID AND LocationID = @LocationID AND SellingPrice = @SellingPrice;

			END
			ELSE
			BEGIN
					   --  Insert new record
		                INSERT INTO SellingPrice_ChangeLog (StockItemID, LocationID, SellingPrice, IsActive,PropertyID,UserID,BusinessDate,CreatedDate)
		                VALUES (@StockItemID, @LocationID, @SellingPrice, @IsActive,@PropertyID,@UserID,@BusinessDate,GETDATE());

						 INSERT INTO [dbo].[RT_Sync_MasterDataTransferStatus]
						   ([PropertyId]
						   ,[UniqueId]
						   ,[Code]
						   ,[LocationId]
						   ,[DataType]
						   ,[Active]
						   ,[Delete])
						SELECT TOP(1) @PropertyId,
							   SCOPE_IDENTITY(),
							   '',
							   @LocationID,
							   'ItemPriceChangeLog',
							   @IsActive,
							   0
						
					

						

			END
			DELETE TOP (1) FROM #TempStockLocations
			END
           
            
           
            DELETE TOP (1) FROM #TempAllDetails;
        END

        EXEC sp_xml_removedocument @iDocID;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        -- Error handling
        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;

        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();

        ROLLBACK TRANSACTION;

        IF @iDocID IS NOT NULL
            EXEC sp_xml_removedocument @iDocID;

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

