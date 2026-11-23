
--[dbo].[SP_InsertSupplierWiseItems] '<ArrayOfGetStockItemHeadersWithSuppliersModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><GetStockItemHeadersWithSuppliersModel><StockItemCode>00453</StockItemCode><LocationName>BEVERAGE STORE </LocationName><ItemName>AP Campari 750ml</ItemName><CostPrice>83.33</CostPrice><TaxName>VAT </TaxName><IsDefaultSupplier>false</IsDefaultSupplier><LocationID>2</LocationID><StockItemID>608</StockItemID><CompanyId>1</CompanyId><SupplierID>1</SupplierID><UnitId>147</UnitId><UserID>4168</UserID><TaxGroupId>1</TaxGroupId><PurchaseUnitName>BOT 1LTR</PurchaseUnitName><CompanyList><UserWiseItemWiseCompniesNew><CompanyId>1</CompanyId><Name>Monarch Imperial (Pvt) Ltd</Name><IsChecked>true</IsChecked><StockItemID xsi:nil="true" /><SupplierID>1</SupplierID></UserWiseItemWiseCompniesNew></CompanyList></GetStockItemHeadersWithSuppliersModel><GetStockItemHeadersWithSuppliersModel><StockItemCode>00455</StockItemCode><LocationName>BEVERAGE STORE </LocationName><ItemName>SF Mineral Water 500ml</ItemName><CostPrice>50</CostPrice><TaxName>VAT </TaxName><IsDefaultSupplier>false</IsDefaultSupplier><LocationID>2</LocationID><StockItemID>282</StockItemID><CompanyId>1</CompanyId><SupplierID>1</SupplierID><UnitId>136</UnitId><UserID>4168</UserID><TaxGroupId>1</TaxGroupId><PurchaseUnitName>BOT 500ML</PurchaseUnitName><CompanyList><UserWiseItemWiseCompniesNew><CompanyId>1</CompanyId><Name>Monarch Imperial (Pvt) Ltd</Name><IsChecked>true</IsChecked><StockItemID xsi:nil="true" /><SupplierID>0</SupplierID></UserWiseItemWiseCompniesNew></CompanyList></GetStockItemHeadersWithSuppliersModel><GetStockItemHeadersWithSuppliersModel><StockItemCode>02156</StockItemCode><LocationName>BEVERAGE STORE </LocationName><ItemName>SF Mineral Water 750ml</ItemName><CostPrice>47.22</CostPrice><TaxName>VAT </TaxName><IsDefaultSupplier>false</IsDefaultSupplier><LocationID>2</LocationID><StockItemID>3246</StockItemID><CompanyId>1</CompanyId><SupplierID>1</SupplierID><UnitId>6</UnitId><UserID>4168</UserID><TaxGroupId>1</TaxGroupId><PurchaseUnitName>BOT 750ML</PurchaseUnitName><CompanyList><UserWiseItemWiseCompniesNew><CompanyId>0</CompanyId><Name>Monarch Imperial (Pvt) Ltd</Name><IsChecked>true</IsChecked><StockItemID xsi:nil="true" /><SupplierID>0</SupplierID></UserWiseItemWiseCompniesNew></CompanyList></GetStockItemHeadersWithSuppliersModel></ArrayOfGetStockItemHeadersWithSuppliersModel>'

--[dbo].[SP_InsertSupplierWiseItems] '<ArrayOfGetStockItemHeadersWithSuppliersModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" />'


CREATE PROCEDURE [dbo].[SP_InsertSupplierWiseItems] (@XMLDetails XML)
AS
BEGIN

  INSERT tempStockItems
    (
        xmldata
    )
    SELECT @XMLDetails XMLDetails;

    BEGIN TRANSACTION;

    BEGIN TRY
    SET NOCOUNT ON;

  

    DECLARE @iDocID INT,
            @StockitemID int,
            @SupplierID int,
            @CompanyList XML,
            @IsCheck BIT,
            @StockItemCode VARCHAR(MAX),
            @iDocIDProp INT,
            @ItemName VARCHAR(MAX),
            @TaxGroupID INT,
            @LocationID INT,
            @CompanyId INT,
			@IsCurrentCompany BIT,
			@SUPWD_ID INT,
			@AuditTailUserID INT;

	
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    CREATE TABLE #ItemListTemp
    (
        StockItemCode VARCHAR(MAX),
        LocationName VARCHAR(MAX),
        ItemName VARCHAR(MAX),
        CostPrice DECIMAL(18,8),
        TaxName VARCHAR(MAX),
        IsDefaultSupplier BIT,
        LocationID INT,
        StockItemID INT,
        CompanyId INT,
        SupplierID INT,
        UnitId INT,
        UserID INT,
        TaxGroupId INT,
        PurchaseUnitName VARCHAR(MAX),
        CompanyList XML
    );

    INSERT INTO #ItemListTemp
    (
        StockItemCode,
        LocationName,
        ItemName,
        CostPrice,
        TaxName,
        IsDefaultSupplier,
        LocationID,
        StockItemID,
        CompanyId,
        SupplierID,
        UnitId,
        UserID,
        TaxGroupId,
        PurchaseUnitName,
        CompanyList
    )
    SELECT StockItemCode,
           LocationName,
           ItemName,
           CostPrice,
           TaxName,
           IsDefaultSupplier,
           LocationID,
           StockItemID,
           CompanyId,
           SupplierID,
           UnitId,
           UserID,
           TaxGroupId,
           PurchaseUnitName,
           CompanyList
    FROM
        OPENXML(@iDocID, '/ArrayOfGetStockItemHeadersWithSuppliersModel/GetStockItemHeadersWithSuppliersModel', 2)
        WITH
        (
            StockItemCode VARCHAR(MAX),
            LocationName VARCHAR(MAX),
            ItemName VARCHAR(MAX),
            CostPrice DECIMAL(18,8),
            TaxName VARCHAR(MAX),
            IsDefaultSupplier BIT,
            LocationID INT,
            StockItemID INT,
            CompanyId INT,
            SupplierID INT,
            UnitId INT,
            UserID INT,
            TaxGroupId INT,
            PurchaseUnitName VARCHAR(MAX),
            CompanyList XML
        );

		CREATE TABLE #TempPropIN
		 (
                CompanyId INT,
                IsChecked BIT,
                SupplierID INT,
                StockItemID INT,
				LocationId INT,
				LocationName VARCHAR(MAX),
				IsCurrentCompany BIT,
				CostPrice DECIMAL(18,8),
				UnitId INT,
				TaxGroupId INT
            )
    --------------------------------------------------Things Updates---------------------------------------------------------------------------
    SELECT @StockItemID = StockItemID,
           @StockItemCode = StockItemCode,
           @ItemName = ItemName,
           @TaxGroupID = TaxGroupID,
           @LocationID = LocationID,
           @CompanyId = CompanyId,
           @StockItemID = StockItemID,
		   @SupplierID = SupplierID,
		   @AuditTailUserID = UserID
    FROM #ItemListTemp;

   -- EXEC InsertMasterFileChangeLog 'Stock Master', 1, 'U', @ItemName;
	
    --UPDATE dbo.StockItemHeaders
    --SET StockItemCode = @StockItemCode,
    --    Name = @ItemName,
    --    LastModDate = GETDATE(),
    --    TaxGroupID = @TaxGroupID
    --WHERE Id = @StockItemID;

    --UPDATE dbo.StockItemHeaders
    --SET StockItemCode = @StockItemCode,
    --    Name = @ItemName,
    --    LastModDate = GETDATE(),
    --    TaxGroupID = @TaxGroupID
    --WHERE StockItemCode = @StockItemCode;
	-------------------------------------------Log StockItemHeaders Update-2024-02-22-----------------
	--IF EXISTS (SELECT 1 FROM dbo.StockItemHeaders WHERE Id = @StockItemID)
	--BEGIN
	--	EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @StockItemID, 'INV', 'SIHU', 'U', 0,@CompanyId, '', ''
	--END
	--IF EXISTS (SELECT 1 FROM dbo.StockItemHeaders WHERE StockItemCode = @StockItemCode)
	--BEGIN
	--	EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @StockItemID, 'INV', 'SIHU', 'U', 0,@CompanyId, '', ''
	--END

	---------------------------------------------------------------------------------------------------
    -------------------------------------------------------------------------------------------------------------------------------------------

    ------------------------------------------------------------Insert Propertywise-------------------------------------------------------------------------------

    ------------------------------------------------------------------------Delete Items------------------------------------------------------------------------------------------
	-------------------------------------------Log SupplierWiseItemDetails Delete-2024-02-22-----------------
	--IF EXISTS (SELECT 1 FROM dbo.SupplierWiseItemDetails WHERE SupplierID = @SupplierID)
	--BEGIN
	--	SELECT @SUPWD_ID = id FROM dbo.SupplierWiseItemDetails WHERE SupplierID = @SupplierID
	--	EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDD', 'D', 0,@CompanyId, '', ''
	--END
	WHILE EXISTS (SELECT 1 FROM dbo.SupplierWiseItemDetails WHERE SupplierID = @SupplierID AND CompanyId =@CompanyId )
	BEGIN
		SELECT TOP (1) @SUPWD_ID = id FROM dbo.SupplierWiseItemDetails WHERE SupplierID = @SupplierID
		EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDD', 'D', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
		DELETE TOP (1) FROM dbo.SupplierWiseItemDetails WHERE SupplierID = @SupplierID AND CompanyId =@CompanyId
	END
	---------------------------------------------------------------------------------------------------
    --DELETE FROM dbo.SupplierWiseItemDetails
    --WHERE SupplierID = @SupplierID;
    -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    WHILE
    (SELECT COUNT(*) FROM #ItemListTemp) > 0
    BEGIN
        SELECT TOP (1)
            @CompanyList = CompanyList,
           @StockItemID = StockItemID,
           @StockItemCode = StockItemCode,
           @ItemName = ItemName,
           @TaxGroupID = TaxGroupID,
           @LocationID = LocationID,
           @CompanyId = CompanyId,
		   @SupplierID = SupplierID

        FROM #ItemListTemp

        EXEC sp_xml_preparedocument @iDocIDProp OUTPUT, @CompanyList;

        
		INSERT INTO #TempPropIN ( CompanyId,
               IsChecked,
               SupplierID,
               StockItemID,
			   LocationId,
			   LocationName,
			   IsCurrentCompany,
			   CostPrice,
			   UnitId,
			   TaxGroupId)
		SELECT CompanyId,
               IsChecked,
               SupplierID,
               StockItemID,
			   LocationId,
			   LocationName,
			   IsCurrentCompany,
			   CostPrice,
			   UnitId,
			   TaxGroupId
       -- INTO #TempPropIN
        FROM
            OPENXML(@iDocIDProp, '/CompanyList/UserWiseItemWiseCompniesNew', 2)
            WITH
            (
                CompanyId INT,
                IsChecked BIT,
                SupplierID INT,
                StockItemID INT,
				LocationId INT,
				LocationName VARCHAR(MAX),
				IsCurrentCompany BIT,
				CostPrice DECIMAL(18,8),
				UnitId INT,
				TaxGroupId INT
            )

        WHILE
        (SELECT COUNT(*) FROM #TempPropIN) > 0
        BEGIN
			DECLARE @tempLocationID INT = 0, @tempCostPrice DECIMAL(18,8) =0, @tempUnitID INT =0, @tempTaxGroupID INT =0

            SELECT TOP (1)
                @CompanyId = CompanyId,
                @IsCheck = IsChecked,
				@IsCurrentCompany = IsCurrentCompany,
                @StockitemID = StockitemID,
				@tempLocationID = LocationId,
				@tempCostPrice = ISNULL(CostPrice,0),
				@tempUnitID = UnitId,
				@tempTaxGroupID = TaxGroupId
            FROM #TempPropIN

            IF (
                   @IsCheck = 1
                   and EXISTS
            (
                SELECT 1
                FROM StockItemHeaders
                WHERE CompanyId = @CompanyId
                      AND StockItemCode = @StockItemCode
            )
               )
            BEGIN

			-----------------------------------------------------------------------------------------------
			if(EXISTS
            (
                SELECT 1
                FROM SupplierWiseItemDetails
                WHERE CompanyId = @CompanyId
                      AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID
            ))
			BEGIN
			-------------------------------------------Log SupplierWiseItemDetails Delete-2024-02-22-----------------
				IF EXISTS (SELECT 1 FROM dbo.SupplierWiseItemDetails WHERE CompanyId = @CompanyId
						  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID)
				BEGIN
					SELECT @SUPWD_ID = id FROM dbo.SupplierWiseItemDetails WHERE CompanyId = @CompanyId
						  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID

					EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDD', 'D', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
				END
				---------------------------------------------------------------------------------------------------
					DELETE FROM SupplierWiseItemDetails WHERE CompanyId = @CompanyId
						  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID
				END
			---------------------------------------------------------------------------------------------
             IF NOT EXISTS (SELECT 1 FROM SupplierWiseItemDetails WHERE CompanyId = @CompanyId AND SupplierID = @SupplierID AND StockItemID = @StockitemID AND LocationId = @tempLocationID) And @tempLocationID is not null
			 BEGIN
                INSERT INTO SupplierWiseItemDetails
                (
                    CompanyId,
                    LocationId,
                    SupplierID,
                    StockItemID,
                    PurchaseUnitID,
                    CostPrice,
                    IsDefaultSupplier,
                    CreatedUserID,
                    LastModUserID,
                    CreatedDate,
                    LastModDate,
                    IPAddress,
                    TaxGroupID
                )
                SELECT @CompanyId,
                       ( CASE WHEN @IsCurrentCompany = 1 THEN LocationID ELSE
					   case when @tempLocationID =0 then
					   (SELECT TOP 1 id FROM Locations WHERE CompanyID =@CompanyId and DefaultLocation =1 )
					   else @tempLocationID end
					   END),
                       @SupplierId,
                       @StockitemID,
                      case when @tempUnitID =0 then UnitId else @tempUnitID end ,
                       case when @tempCostPrice =0 then CostPrice else @tempCostPrice end,
                       IsDefaultSupplier,
                       UserID,
                       UserID,
                       GETDATE(),
                       GETDATE(),
                       '',
                      case when @tempTaxGroupID =0 then TaxGroupId else @tempTaxGroupID end 
                FROM #ItemListTemp
                WHERE StockItemCode = @StockItemCode
			END

            END

			SET @SUPWD_ID =  SCOPE_IDENTITY()

			-------------------------------------------Log SupplierWiseItemDetails Insert-2024-02-22-----------------
			IF EXISTS (SELECT 1 FROM #ItemListTemp where StockItemCode = @StockItemCode)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDI', 'I', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
			END
			---------------------------------------------------------------------------------------------------
            DELETE TOP (1)
            FROM #TempPropIN

        END

        ----------------------------------------------------if item temp is empty-------------------------------------------------------------------------------
        IF (@CompanyList IS NULL)
        BEGIN
            --------------------------------------------------------------If exist delete-------------------------------------------------------------------------
            IF (EXISTS
            (
                SELECT 1
                FROM SupplierWiseItemDetails
                WHERE CompanyId = @CompanyId
                      and StockitemID = @StockitemID
						and LocationID = @LocationID
            )
               )
            BEGIN
                DELETE FROM SupplierWiseItemDetails
                WHERE StockitemID = @StockitemID
                      and SupplierID = @SupplierID
                      and CompanyId = @CompanyId
			and LocationID = @LocationID
            END
            ----------------------------------------------------------------------------------------------------------------------------------------

            
            INSERT INTO SupplierWiseItemDetails
            (
                CompanyId,
                LocationId,
                SupplierID,
                StockItemID,
                PurchaseUnitID,
                CostPrice,
                IsDefaultSupplier,
                CreatedUserID,
                LastModUserID,
                CreatedDate,
                LastModDate,
                IPAddress,
                TaxGroupID
            )
            SELECT @CompanyId,
                   LocationID,
                   @SupplierId,
                   @StockitemID,
                   UnitId,
                   CostPrice,
                   IsDefaultSupplier,
                   UserID,
                   UserID,
                   GETDATE(),
                   GETDATE(),
                   '',
                   TaxGroupId
            FROM #ItemListTemp
            where StockItemCode = @StockItemCode
		-------------------------------------------Log SupplierWiseItemDetails Insert-2024-02-22-----------------
		SET @SUPWD_ID =  SCOPE_IDENTITY()
		IF EXISTS (SELECT 1 FROM #ItemListTemp where StockItemCode = @StockItemCode)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDI', 'I', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
			END
		---------------------------------------------------------------------------------------------------
        END
        -----------------------------------------------------------------------------------------------------------------------------------
        TRUNCATE TABLE #TempPropIN
        DELETE TOP (1)
        FROM #ItemListTemp
    END
----------------------------------------------------------------------------------------------------------------------------------------------------------------------



        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
        ROLLBACK TRANSACTION;
        
    END CATCH
END;

GO

