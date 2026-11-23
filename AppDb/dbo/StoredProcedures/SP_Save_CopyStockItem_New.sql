

-- [dbo].[SP_Save_CopyStockItem_New] '<CopyStockItemNew xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><FromLocationId>48</FromLocationId><UserId>4168</UserId><CompanyId>1</CompanyId><ToLocationList><ToLocation><id>8</id></ToLocation><ToLocation><id>30</id></ToLocation></ToLocationList><CopyItemList><PropertyWiseItemsModelCopyStockitem_new><draw>0</draw><start>0</start><length>0</length><page>0</page><regex>false</regex><Id>54</Id><Name>Thalapath Guttered Headless 1kg</Name><StockItemCode>00023</StockItemCode><FromUnitName>1KG</FromUnitName><ToUnitName>1KG</ToUnitName><UnitConvertion>[{"UnitID":7,"Unitname":"1KG","Value":1},{"UnitID":176,"Unitname":"GRAMS","Value":1000}]</UnitConvertion><FromUnitId>7</FromUnitId><ToUnitId>7</ToUnitId><LocationId>0</LocationId><IsHave>false</IsHave><CompanyId>1</CompanyId><Disable>false</Disable><IsChecked>true</IsChecked><CategoryID>0</CategoryID><SubCategoryID>0</SubCategoryID><SubCategory2ID>0</SubCategory2ID><UnitConversionList><UnitModel><UnitID>7</UnitID><Unitname>1KG</Unitname><Value>1</Value></UnitModel><UnitModel><UnitID>176</UnitID><Unitname>GRAMS</Unitname><Value>1000</Value></UnitModel></UnitConversionList></PropertyWiseItemsModelCopyStockitem_new><PropertyWiseItemsModelCopyStockitem_new><draw>0</draw><start>0</start><length>0</length><page>0</page><regex>false</regex><Id>55</Id><Name>Mussel Green (Half) 1Kg</Name><StockItemCode>00024</StockItemCode><FromUnitName>1KG</FromUnitName><ToUnitName>1KG</ToUnitName><UnitConvertion>[{"UnitID":7,"Unitname":"1KG","Value":1},{"UnitID":176,"Unitname":"GRAMS","Value":1000}]</UnitConvertion><FromUnitId>7</FromUnitId><ToUnitId>7</ToUnitId><LocationId>0</LocationId><IsHave>false</IsHave><CompanyId>1</CompanyId><Disable>false</Disable><IsChecked>true</IsChecked><CategoryID>0</CategoryID><SubCategoryID>0</SubCategoryID><SubCategory2ID>0</SubCategory2ID><UnitConversionList><UnitModel><UnitID>7</UnitID><Unitname>1KG</Unitname><Value>1</Value></UnitModel><UnitModel><UnitID>176</UnitID><Unitname>GRAMS</Unitname><Value>1000</Value></UnitModel></UnitConversionList></PropertyWiseItemsModelCopyStockitem_new></CopyItemList></CopyStockItemNew>'

--sample table  [dbo].[StockItemDetails_New] must be changed as this table [dbo].[SockitemDetails]
CREATE procedure [dbo].[SP_Save_CopyStockItem_New]
(
@XMLDetails XML
)
as 
INSERT INTO CopyStockItem_XMLLog( XMLDetails)
VALUES (@XMLDetails)
------------------------------------TRY CATCH START----------------------------------------------
BEGIN TRY 
 BEGIN TRANSACTION;
		DECLARE @iDocID INT, @iDocID2 INT, @iDocID3 INT
		
		DECLARE @InsertedIDs_Stockitemdetails TABLE (ID INT); --Added by Nivesh 2024-03-05
		Declare @tempStItDe int = null --Added by Nivesh 2024-03-05

		----------------------------------------------Extract XML data------------------------------------------------------------------------

		DECLARE @FromLocationId INT,
				@UserId INT,
				@toLocationList xml,
				@copyItemList xml,
				@CompanyId INT,
				@IsRetail BIT

		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails


		SELECT @FromLocationId =FromLocationId,
				@UserId =UserId,
				@toLocationList =ToLocationList,
				@copyItemList = CopyItemList,
				@CompanyId =CompanyId
		FROM     OPENXML (@iDocID,'/CopyStockItemNew',2)
		WITH    (FromLocationId INT,
				UserId int, 
				ToLocationList xml,
				CopyItemList xml,
				CompanyId INT);

		--Added by Isuru 2024-03-01
		SELECT @IsRetail =IsRetail  FROM COMPANIES WHERE CompanyID = @CompanyId 

		--End
		---------------------------------------------------------------end----------------------------------------------------------------------------

		--------------------------------------------------------------- To location list------------------------------------------------------------------
		-- create temp table Tolocation
		EXEC sp_xml_preparedocument @iDocID2 OUTPUT, @toLocationList
		   CREATE TABLE #ToLocationListTemp
			(
				id INT
			);

			 INSERT INTO #ToLocationListTemp
			(
        
				id
			)
			SELECT 
				   id
			FROM
			OPENXML(@iDocID2,'/ToLocationList/ToLocation',2)
			WITH
			(
				id INT
			);

		------------------------------------------------------------------------end-------------------------------------------------------------------------------

		--------------------------------------------------------------------Copy Stock Item List--------------------------------------------------------------------
		EXEC sp_xml_preparedocument @iDocID3 OUTPUT, @copyItemList

		CREATE TABLE #CopyItemListTemp
			(
				StockItemCode VARCHAR(20),
				FromUnitId INT,
				ToUnitId INT,
				Id INT,
				IsHave bit,
				Disable bit,
				IsChecked bit,
				AveragePrice DECIMAL(18,6),
				SellingPrice DECIMAL(18,6),
			);

			 INSERT INTO #CopyItemListTemp
			(
        
				StockItemCode,
				FromUnitId,
				ToUnitId ,
				Id ,
				IsHave ,
				Disable ,
				IsChecked,
				AveragePrice,
				SellingPrice
			)
			SELECT 
				StockItemCode,
				FromUnitId ,
				ToUnitId ,
				Id ,
				IsHave ,
				Disable ,
				IsChecked,
				0,
				0
			FROM
			OPENXML(@iDocID3,'/CopyItemList/PropertyWiseItemsModelCopyStockitem_new',2)
			WITH
			(
			StockItemCode VARCHAR(20),
				FromUnitId INT,
				ToUnitId INT,
				Id INT,
				IsHave bit,
				Disable bit,
				IsChecked bit);

		-----------------------------------------------------------------------------end-----------------------------------------------------------------------------

		-------------------------------------------------------------Insert Copy Stock Items---------------------------------------------------------------------------------
		DECLARE @getDate datetime;
		SELECT @getDate= GETDATE();



		--Inserting Selling Price and Average price when IsRetail Item by Isuru 2024-03-01
		IF(@IsRetail =1)
		BEGIN

		UPDATE CO
		SET CO.AveragePrice = SD.AveragePrice,CO.SellingPrice = SD.SellingPrice
		FROM #CopyItemListTemp CO
		INNER JOIN STOCKITEMHEADERS SH ON CO.StockItemCode = SH.StockItemCode and SH.CompanyId =@CompanyId
		INNER JOIN stockitemdetails SD ON SD.StockItemHeaderID = SH.Id
		WHERE SD.LocationID = @FromLocationId and SH.CompanyId =@CompanyId

		END
		--End

			SELECT distinct
			l.id as LocationID,
			lo.Name as LocationName,
			@CompanyId as PropertyID,
			c.StockItemCode,
			h.Name as ItemName,
			u.Name as UnitName,
			c.FromUnitId,
			c.ToUnitId
		  -- c.Id,
		  -- l.id,
		  -- d.CompanyID,
		  -- h.name,
		  -- h.stockitemcode
		  --into #GetExistITems
		FROM #CopyItemListTemp c
		CROSS JOIN (
			SELECT DISTINCT id FROM #ToLocationListTemp
		) l
		inner join StockItemHeaders H on h.Id = c.Id
		inner join Units U on u.Id = c.FromUnitId
		inner join Locations lo on lo.Id = l.id
		WHERE EXISTS (
			SELECT 1
			FROM [dbo].[stockitemdetails] d
			WHERE d.StockItemHeaderID = c.Id
			AND d.LocationID = l.id
			AND d.CompanyID = @CompanyId
		) and h.Id = c.Id;

		INSERT INTO [dbo].[stockitemdetails] 
		( [PropertyID]
		  ,[CompanyID]
		  ,[LocationID]
		  ,[StockItemHeaderID]
		  ,[MasterUnitID]
		  ,[PurchasingUnitID]
		  ,[MinimumQuantity]
		  ,[MaximumQuantity]
		  ,[ReOrderLevel]
		  ,[ReOrderQuantity]
		  ,[ReOrderPeriod]
		  ,[PurchaseAccountID]
		  ,[CostOfSalesAccountID]
		  ,[AveragePrice]
		  ,[SellingPrice]
		  ,[WholesalePrice]
		  ,[IsActive]
		  ,[ReportingUnitID]
		  ,[QuantityInHand]
		  ,[StockItemId]
		  ,[IPAddress]
		  ,[CreatedUserID]
		  ,[LastModUserID]
		  ,[CreatedDate]
		  ,[LastModDate]
		  ,[BatchNo]
		  ,[ProfitMargin])
		  OUTPUT INSERTED.Id INTO @InsertedIDs_Stockitemdetails --Added by Nivesh 2024-03-05
		SELECT 
			
		   @CompanyId
		  ,@CompanyId
		  ,l.id
		  ,c.Id
		  ,c.ToUnitId --changed this
		  ,c.ToUnitId
		  ,0
		  ,0
		  ,0
		  ,0
		  ,0
		  ,''
		  ,''
		  ,C.AveragePrice
		  ,C.SellingPrice  
		  ,0
		  ,1
		  ,c.ToUnitId
		  ,0
		  , c.Id
		  ,''
		  ,@UserId
		  ,@UserId
		  ,@getDate
		  ,@getDate
		  ,0
		  ,0
		FROM #CopyItemListTemp c
		CROSS JOIN (
			SELECT DISTINCT id FROM #ToLocationListTemp
		) l
		WHERE NOT EXISTS (
			SELECT 1
			FROM [dbo].[stockitemdetails] d
			WHERE d.StockItemHeaderID = c.Id
			AND d.LocationID = l.id
			AND d.CompanyID = @CompanyId
		);
		-------------------LOG stockitemdetails INSERT Added by Nivesh 2024-03-05-----------------------------------
		DECLARE @tempTable VARCHAR(MAX);

		SET @tempTable = (
			SELECT *,@UserId UserId,@CompanyId CompanyId
			FROM @InsertedIDs_Stockitemdetails
			FOR JSON PATH
		);
	 

 COMMIT TRAN; -- Transaction Success!
 	 IF @tempTable IS NOT NULL
	 BEGIN
        -- Asynchronously start SQL Agent job for logging
        DECLARE @JobName NVARCHAR(128) = 'CopyStockItemAuditLogJob'; -- SQL Server Agent job name
        EXEC msdb.dbo.sp_start_job @job_name = @JobName;
	END
		--WHILE EXISTS (SELECT 1 FROM @InsertedIDs_Stockitemdetails)
		--BEGIN
		--	SELECT TOP(1) @tempStItDe = Id FROM @InsertedIDs_Stockitemdetails
		--	EXEC Inventry_AuditTail_WriteToLog 'stockitemdetails', @tempStItDe, 'INV', 'SIDI', 'I', @UserId,@CompanyId, '', ''
		--	DELETE TOP(1) FROM @InsertedIDs_Stockitemdetails
		--END

		------------------------------------------------------------------------------------------------------------
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;

------------------------------------TRY CATCH END-------------------------------------------

GO

