

 -- [dbo].[SP_Insert_StockMaster] '<ProductSaveModel xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><Id>10</Id><StockItemCode>FOD/DAI/BUT/010</StockItemCode><PLUCode>FOD/DAI/BUT/010</PLUCode><Name>BUTTER COCOA</Name><IsActive>true</IsActive><ImageUrl>sdsdsd</ImageUrl><TaxGroupID>4</TaxGroupID><IsExpiryDateApplicable>false</IsExpiryDateApplicable><MinimumQuantity>0</MinimumQuantity><MaximumQuantity>0</MaximumQuantity><ReOrderLevel>0</ReOrderLevel><ReOrderQuantity>0</ReOrderQuantity><AveragePrice>0</AveragePrice><IsPriceEditable>true</IsPriceEditable><MaintainPriceHistory>false</MaintainPriceHistory><Isbundle>false</Isbundle><BrandedItem>false</BrandedItem><LocationID>0</LocationID><PropertyID>1</PropertyID><ReportingUnitID>1</ReportingUnitID><StockItemHeaderID>10</StockItemHeaderID><CategoryID>6</CategoryID><ReferanceCode>0</ReferanceCode><Barcode>0</Barcode><SubCategoryID>36</SubCategoryID><SupplierID>0</SupplierID><CostingMethod>1</CostingMethod><MasterUnitID>8</MasterUnitID><PurchasingUnitID>0</PurchasingUnitID><ReOrderPeriod>0</ReOrderPeriod><PurchaseAccountID>0</PurchaseAccountID><CostOfSalesAccountID>0</CostOfSalesAccountID><SellingPrice>0</SellingPrice><ProfitMargin>0</ProfitMargin><WholesalePrice>0</WholesalePrice><QuantityInHand>0</QuantityInHand><IPAddress>::1</IPAddress><SubCategory2ID>105</SubCategory2ID><IsRequestedItem>false</IsRequestedItem><RequestedItemId xsi:nil="true" /><CopyToOtherProperties>false</CopyToOtherProperties><UserId>4168</UserId><DirectActiveType>All</DirectActiveType><IsMultiplePrices>false</IsMultiplePrices><IsMultipleBarcode>false</IsMultipleBarcode><IsAllowDiscount>false</IsAllowDiscount><IsFractionItem>false</IsFractionItem><IsSerialNo>false</IsSerialNo><IsAllowReturnItem>false</IsAllowReturnItem><IsOpenPrice>false</IsOpenPrice><ChargeHeaderID>0</ChargeHeaderID><IsSellingItem>false</IsSellingItem><IsProductionItem>false</IsProductionItem><ReferencesList /><AttributeList><AttributeViewModel><AttributeID>16</AttributeID><AttName>DAILY MARKET LIST</AttName><Remarks /><Active>false</Active></AttributeViewModel><AttributeViewModel><AttributeID>20</AttributeID><AttName>TempApplicable</AttName><Remarks /><Active>false</Active></AttributeViewModel><AttributeViewModel><AttributeID>22</AttributeID><AttName>Production Item</AttName><Remarks /><Active>false</Active></AttributeViewModel><AttributeViewModel><AttributeID>15</AttributeID><AttName>BARCODE</AttName><Remarks /><Active>false</Active></AttributeViewModel><AttributeViewModel><AttributeID>19</AttributeID><AttName>Threshold Value</AttName><Remarks /><Active>false</Active></AttributeViewModel><AttributeViewModel><AttributeID>21</AttributeID><AttName>HOTEL CODE</AttName><Remarks /><Active>false</Active></AttributeViewModel><AttributeViewModel><AttributeID>26</AttributeID><AttName>Wastage Precentage</AttName><Remarks /><Active>false</Active></AttributeViewModel></AttributeList><SupplierList><SupplierViewModel><Id>13372</Id><SuppID>3</SuppID><SuppName>ADVANCED TECHNOLOGIES</SuppName><SuppCode>SC00000003</SuppCode><CostPrice>8</CostPrice><PurchaseUnitName>BOX</PurchaseUnitName><UnitId>8</UnitId><IsDefaultsupplier>false</IsDefaultsupplier><LocationID>1</LocationID><LocationName>MAIN STORES</LocationName><SuppTaxGroupID>4</SuppTaxGroupID><TaxGroupName>VAT 18%</TaxGroupName><Edited>false</Edited></SupplierViewModel><SupplierViewModel><Id>-1</Id><SuppID>3</SuppID><SuppName>ADVANCED TECHNOLOGIES</SuppName><CostPrice>8</CostPrice><PurchaseUnitName>BOX</PurchaseUnitName><UnitId>8</UnitId><IsDefaultsupplier>false</IsDefaultsupplier><LocationID>8</LocationID><LocationName>PRODUCTION KITCHEN</LocationName><SuppTaxGroupID>4</SuppTaxGroupID><TaxGroupName>VAT 18%</TaxGroupName><Edited>false</Edited></SupplierViewModel><SupplierViewModel><Id>-1</Id><SuppID>3</SuppID><SuppName>ADVANCED TECHNOLOGIES</SuppName><CostPrice>8</CostPrice><PurchaseUnitName>BOX</PurchaseUnitName><UnitId>8</UnitId><IsDefaultsupplier>false</IsDefaultsupplier><LocationID>13</LocationID><LocationName>TUNA TURNER</LocationName><SuppTaxGroupID>4</SuppTaxGroupID><TaxGroupName>VAT 18%</TaxGroupName><Edited>false</Edited></SupplierViewModel><SupplierViewModel><Id>-1</Id><SuppID>3</SuppID><SuppName>ADVANCED TECHNOLOGIES</SuppName><CostPrice>8</CostPrice><PurchaseUnitName>BOX</PurchaseUnitName><UnitId>8</UnitId><IsDefaultsupplier>false</IsDefaultsupplier><LocationID>13</LocationID><LocationName>TUNA TURNER</LocationName><SuppTaxGroupID>4</SuppTaxGroupID><TaxGroupName>VAT 18%</TaxGroupName><Edited>false</Edited></SupplierViewModel></SupplierList><ItemWiseLocation><ItemWiseLocation><text>MAIN STORES</text><id>1</id></ItemWiseLocation><ItemWiseLocation><text>PRODUCTION KITCHEN</text><id>8</id></ItemWiseLocation><ItemWiseLocation><text>TUNA TURNER</text><id>13</id></ItemWiseLocation></ItemWiseLocation><ItemWiseBarcode /><ItemAge>0</ItemAge></ProductSaveModel>',2,1,0,0
 
 
 --go
CREATE   PROCEDURE [dbo].[SP_Insert_StockMaster]
(
    @XMLDetails XML,
    @Operation INT,
	@Page INT = 0,
    @headerid INT OUTPUT,
	@ProductItemCode VARCHAR(Max) OUTPUT
)
AS
DECLARE @iDocID INT;


BEGIN 


insert tempStockItems (xmldata)
SELECT @XMLDetails XMLDetails 

--SELECT * FROM tempStockItems
--DROP TABLE AAdata


    BEGIN TRY
        BEGIN TRANSACTION;

		IF OBJECT_ID('tempdb..#tempSupplierTable') IS NOT NULL
		DROP TABLE #tempSupplierTable

        DECLARE @PropertyID INT,
                @LocationID INT,
                @StockItemID INT,
                @StockItemHeaderIDIntern INT,
                @StockItemCode VARCHAR(MAX),
                @PLUCode VARCHAR(MAX),
                @Name VARCHAR(MAX),
                @CategoryID INT,
                @SubCategoryID INT,
                @Remarks NVARCHAR(MAX),
                @LastModDate DATETIME,
                @LastModUserID INT,
				@CreatedUserID INT,
                @IsExpiryDateApplicable BIT,
                @Active BIT,
                @NameOnInvoice VARCHAR(MAX),
                @SubCategory2ID INT,
                @IsPriceEditable BIT,
                @Isbundle BIT,
                @MaintainPriceHistory BIT,
                @IPAddress VARCHAR(MAX),
				@CategoryIDForCode INT,
				@Prefix VARCHAR(MAX),
				@Suffix VARCHAR(MAX),
				@SeialLength INT,
				@Serial INT,
				@CodeLength INT,
				@ProductCode VARCHAR(MAX),
				@SerialLength INT,
				@ProductCodeLength INT,
                @TaxGroupID INT,
				@BrandedItem BIT,
				@GenericItemCode VARCHAR(150),
				@IsRequestedItem BIT ,
				@RequestedItemId INT ,
				@EditItemCount INT,
				@IsCopySupplierPrice BIT,
				@DirectActiveType VARCHAR(10),
				@IsMultiplePrices BIT,
				@IsMultipleBarcode BIT,
				@IsAllowDiscount BIT,
				@IsFractionItem BIT,
				@IsSerialNo BIT,
				@IsAllowReturnItem BIT,
				@IsOpenPrice BIT,
				@SellingPrice DECIMAL(18,2),
				@Barcode VARCHAR(MAX),
				@ChargeHeaderID INT,
				@BusinessDate DATE,
				@SubCategoryIDForCode INT,
				@IsSellingItem BIT,
				@ERPReferenceCode VARCHAR(200),
				@IsProductionItem BIT =0,
				@ReportUnitID INT, --Added by Tharuka 2026-09-17
				@SubCategory2IDForCode INT

		CREATE TABLE #tempSupplierTable(
		    PropertyID INT,
			LocationID INT,
			SuppID INT,
			StockItemID INT,
			UnitId INT,
			CostPrice DECIMAL(18, 6),
			IsDefaultsupplier BIT,
			CreatedUserID INT,
			LastModUserID INT,
			CreatedDate DATE,
			LastModDate DATE,
			IPAddress Varchar(20),
			SuppTaxGroupID INT,
			IsContractedSupplier BIT,
			Validfrom VARCHAR(MAX), 
			ValidTo VARCHAR(MAX),
		)

		CREATE TABLE #SupplierList
		(
			Id INT ,
			SuppID INT,
			SuppName VARCHAR(MAX) ,
			CostPrice DECIMAL(18, 6),			
			PurchaseUnitName VARCHAR(MAX),
			UnitId INT,
			IsDefaultsupplier BIT,
			LocationID INT,
			LocationName VARCHAR(MAX) ,
			SuppTaxGroupID INT,
			TaxGroupName VARCHAR(MAX),
			Edited BIT
		)

		CREATE TABLE #ItemWiseBarcode
		(
			Barcode VARCHAR(MAX),
			UserID INT,
			PropertyID INT
		)

        CREATE TABLE #ItemList
        (
            Id INT,
            CompanyId INT,
            LocationID INT,
            StockItemCode VARCHAR(MAX),
            PLUCode VARCHAR(MAX),
            ReferanceCode VARCHAR(MAX),
            Barcode VARCHAR(MAX),
            Name VARCHAR(MAX),
            NameOnInvoice VARCHAR(MAX),
            CategoryID INT,
            SubCategoryID INT,
            SupplierID INT,
            TaxGroupID INT,
            ImageUrl NVARCHAR(MAX), --added
            CostingMethod INT,      --added
            Remarks NVARCHAR(MAX),  --added
            PropertyID INT,         --added
            StockItemHeaderID INT,  --added
            ReportingUnitID INT,    --added
            IsExpiryDateApplicable BIT,
            IPAddress VARCHAR(MAX),
            CreatedUserID INT,
            LastModUserID INT,
            CreatedDate DATETIME,
            LastModDate DATETIME,
            MasterUnitID INT,
            PurchasingUnitID INT,
                                    --	SIH decimal(18, 2),
            MinimumQuantity DECIMAL(18, 2),
            MaximumQuantity DECIMAL(18, 2),
            ReOrderLevel DECIMAL(18, 2),
            ReOrderQuantity DECIMAL(18, 2),
            ReOrderPeriod DECIMAL(18, 2),
            PurchaseAccountID VARCHAR(MAX),
            CostOfSalesAccountID VARCHAR(MAX),
                                    --	CostPrice decimal(18,2),
            AveragePrice DECIMAL(18, 2),
            SellingPrice DECIMAL(18, 2),
            WholesalePrice DECIMAL(18, 2),
            IsActive BIT,
            Isbundle BIT,
            IsPriceEditable BIT,
            MaintainPriceHistory BIT,
            QuantityInHand DECIMAL(18, 2),
            StockItemId INT,
            SubCategory2ID INT,
			BrandedItem BIT,
			GenericItemCode VARCHAR(150),
			IsRequestedItem BIT ,
			RequestedItemId INT , 
			CopyToOtherProperties BIT,
			UserId INT,
			DirectActiveType VARCHAR(10), --added by Isuru 2023-05-04
			IsMultiplePrices BIT,
			IsMultipleBarcode BIT,
			IsAllowDiscount BIT,
			IsFractionItem BIT,
			IsSerialNo BIT,
			IsAllowReturnItem BIT,
			IsOpenPrice BIT,
			ChargeHeaderID INT,
			IsSellingItem BIT,
			IsProductionItem BIT, --Added by Nivesh 2024-08-23
			-- 02.04.2024
			ItemAge DECIMAL(18, 2),
			ERPReferenceCode VARCHAR(200),
			ReportUnitID INT --Added by Tharuka 2026-09-17
        );
		-------------------------Added by Nivesh 2024-02-26-------------------------------
		DECLARE @InsertedIDs_StockItemHeaders TABLE (ID INT);
		Declare @tempStocIID int = null 
		DECLARE @InsertedIDs_StockItemWiseClassificationDetails TABLE (ID INT);
		Declare @tempStItWiClDe int = null 
		DECLARE @InsertedIDs_StockItemWiseAttributes TABLE (ID INT);
		Declare @tempStItWiAt int = null 
		DECLARE @InsertedIDs_POS_ItemBarcode TABLE (ID INT);
		Declare @tempPOS_IB int = null 
		DECLARE @InsertedIDs_StockItemDetails TABLE (ID INT);
		Declare @tempStItDe int = null 
		DECLARE @InsertedIDs_SupplierWiseItemDetails TABLE (ID INT);
		Declare @tempSuWiItDe int = null 
		---------------------------------------------------------
		DECLARE @TempSIDU_Log int
		DECLARE @TempSIHU_Log int 
		DECLARE @TempPOSIBD_Log int
		DECLARE @TempSWIDD_Log int 
		DECLARE  @TempSIWCDD_Log int
		--------------------------------------------------------
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		
		--SELECT 'XXXXXX' Commented by Nivesh 2024-07-23 Unneccesary select
        INSERT INTO #ItemList
        SELECT *
        FROM
        OPENXML(@iDocID, '/ProductSaveModel', 2) WITH #ItemList;

		INSERT INTO #ItemWiseBarcode
        SELECT *
        FROM
        OPENXML(@iDocID, '/ProductSaveModel/ItemWiseBarcode/ItemWiseBarcode', 2) WITH #ItemWiseBarcode;

		--SELECT '#ItemWiseBarcode',*
		--FROM #ItemWiseBarcode Commented by Nivesh 2024-07-23 Unneccesary select



		--SELECT 'XXXXXXg'
		--select 'Retail',* from #ItemList Commented by Nivesh 2024-07-23 Unneccesary select
		IF(@Page <>3 AND @Operation =1)
		BEGIN
		--Added by Isuru 2023-09-25 for checking stockitem code availability
		DECLARE @CheckStockItemCode VARCHAR(40),@InvoiceError VARCHAR(500)

		SELECT @CheckStockItemCode =StockItemCode
		FROM #ItemList

		IF EXISTS(SELECT 1 FROM StockItemHeaders WHERE StockItemCode = @CheckStockItemCode)
		BEGIN
		SET @InvoiceError =  'Stock Item Code Already Exists'
		RAISERROR ( @InvoiceError, 16, 1 );  
		ROLLBACK TRANSACTION
		END
		--END
		END

		--SELECT 'XXXXXXh' Commented by Nivesh 2024-07-23 Unneccesary select
		DECLARE @CopyToOtherProperties BIT 
		
		SELECT top 1 @PropertyID= PropertyID, @CopyToOtherProperties = CopyToOtherProperties, @CreatedUserID = UserId  , @LastModUserID = UserId, @DirectActiveType =DirectActiveType,@SellingPrice =SellingPrice
		FROM #ItemList
		--------START Added by Nivesh 2024-10-09 for checking of exsisting of main store in locations------
		IF(@PropertyID IS NULL)
		BEGIN
			SET @InvoiceError =  'provide Property'
			RAISERROR ( @InvoiceError, 16, 1 );  
			ROLLBACK TRANSACTION
		END

		-------------------------------------------------END------------------------------------------------------------
		
		SELECT * INTO #TempLocations
		FROM
		OPENXML(@iDocID, '/ProductSaveModel/ItemWiseLocation/ItemWiseLocation', 2) WITH (id int);
		
		--------START Added by Nivesh 2024-10-09 for checking of exsisting of main store in locations------
		IF NOT EXISTS(SELECT 1 FROM #TempLocations)
		BEGIN
			SET @InvoiceError =  'Location not selected.'
			RAISERROR ( @InvoiceError, 16, 1 );  
			ROLLBACK TRANSACTION
		END
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM locations L INNER JOIN #TempLocations TL ON TL.ID = L.Id WHERE L.PropertyId = @PropertyID and L.GroupName = 'MS')
			BEGIN
				SET @InvoiceError =  'Main Store not exists'
				RAISERROR ( @InvoiceError, 16, 1 );  
				ROLLBACK TRANSACTION
			END			
		END
		-------------------------------------------------END------------------------------------------------------------

		SELECT ID LocationID, @PropertyID PropertyId
		INTO #Locations
		FROM #TempLocations
		
		--select @CopyToOtherProperties CopyToOtherProperties, @PropertyID PropertyID Commented by Nivesh 2024-07-23 Unneccesary select

		IF @CopyToOtherProperties = 1
		BEGIN
			  SELECT GroupName INTO #LocationGrps FROM Locations L
			  INNER JOIN #TempLocations TL ON L.Id = TL.Id	
			--INSERT INTO #Locations (LocationID,PropertyID)
			--SELECT ID LocationID, CompanyID PropertyID
			--FROM Locations L
			--WHERE L.DefaultLocation = 1 and L.IsActive = 1 and CompanyID <> @PropertyID and ApplyDailyMarketProcess = 0
			INSERT INTO #Locations (LocationID,PropertyID)
			SELECT ID LocationID, L.CompanyID PropertyID
			FROM Locations L
			INNER JOIN #LocationGrps TL ON TL.GroupName = L.GroupName AND L.IsActive = 1 
			AND L.CompanyID <> @PropertyID AND ApplyDailyMarketProcess = 0
			AND  L.DefaultLocation = 1
			AND L.GroupName = 'MS'

		select '#@CopyToOtherProperties',* 
		from #Locations
		END 

		--------added--------
		SELECT  @IsRequestedItem = IsRequestedItem, @RequestedItemId = RequestedItemId FROM #ItemList
		--SELECT @IsRequestedItem,@RequestedItemId  '22222222' Commented by Nivesh 2024-07-23 Unneccesary select
		IF @IsRequestedItem = 1
			UPDATE [dbo].[TempStockItemRequest] SET Approved = 1 WHERE Id = @RequestedItemId

			-----------------Log TempStockItemRequest Update 2024-02-22---------------
			IF OBJECT_ID('tempdb..#tempTempStockItemRequest') IS NOT NULL
			BEGIN
			DROP TABLE #tempTempStockItemRequest
			END

			SELECT * INTO #tempTempStockItemRequest from [dbo].[TempStockItemRequest] WHERE Id = @RequestedItemId
			WHILE EXISTS (SELECT 1 from #tempTempStockItemRequest WHERE Id = @RequestedItemId)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequest', @RequestedItemId, 'INV', 'TSIRU', 'U', @LastModUserID,@PropertyID, '', ''
				DELETE TOP(1) FROM #tempTempStockItemRequest WHERE Id = @RequestedItemId
			END


			IF OBJECT_ID('tempdb..#tempTempStockItemRequest') IS NOT NULL
			BEGIN
			DROP TABLE #tempTempStockItemRequest
			END
			 
			--------------------------------------------------------------------------

		--------added--------
	
		DECLARE @AutoStockItemCode BIT ,@IsRetail BIT,@AutoStockItemProcessCode CHAR(2)

		SELECT @AutoStockItemCode= AutoStockItemCode,@IsRetail = IsRetail,@AutoStockItemProcessCode = ISNULL(AutoStockItemProcessCode,'S')
		FROM dbo.Companies 
		WHERE CompanyID= @PropertyID

		IF @AutoStockItemCode =1
		begin
		DECLARE @AutoStockItemCodeNo VARCHAR(MAX),@SubPrefix VARCHAR(10),@CatCount int,@SubPrefix2 VARCHAR(10)

		--select 'Sub',*
		--from #ItemList Commented by Nivesh 2024-07-23 Unneccesary select
			SELECT @CategoryIDForCode=CategoryID, @SubCategoryIDForCode = SubCategoryID,@SubCategory2IDForCode= SubCategory2ID FROM  #ItemList

			SELECT @SubPrefix = Code
			FROM subcategories
			WHERE ID=@SubCategoryIDForCode

			SELECT @SubPrefix2=CODE
			FROM SubCategories02
			WHERE ID =@SubCategory2IDForCode



			SELECT @Prefix=Prefix,@SerialLength=SerialLength,@Suffix=Suffix,@Serial=serial,@CodeLength=codelength FROM dbo.Categories WHERE Id=@CategoryIDForCode

			IF(@AutoStockItemProcessCode = 'C')
			BEGIN
				SET @Serial= @Serial +1

				UPDATE dbo.Categories SET serial= @Serial WHERE Id=@CategoryIDForCode

				SET @ProductCode = @Prefix+'/'+RIGHT('0000000'+ CONVERT(VARCHAR(MAX),@Serial),@SerialLength)+@Suffix

				SET @ProductCodeLength= LEN(@ProductCode)

			END

			IF(@AutoStockItemProcessCode = 'S')
			BEGIN
				SELECT @AutoStockItemCodeNo= @Prefix+'/'+@SubPrefix

				SELECT @CatCount =[dbo].[FN_GetNextCategoryCombinationNumber](@AutoStockItemCodeNo)

				IF(@CatCount IS NULL)
				BEGIN
					INSERT INTO  AutoStockItemCodeCombination(PrefixCombination, NextNumber)
					VALUES (@AutoStockItemCodeNo,1)

					SELECT @CatCount =[dbo].[FN_GetNextCategoryCombinationNumber](@AutoStockItemCodeNo)

				END

				SET @ProductCode = @AutoStockItemCodeNo+'/'+RIGHT('00000'+ CONVERT(VARCHAR(MAX),@CatCount),6)

				IF( @Operation = 1 )
				BEGIN

					UPDATE AutoStockItemCodeCombination
					SET NextNumber = NextNumber+1
					WHERE PrefixCombination = @AutoStockItemCodeNo

				END
			END
			
			IF(@AutoStockItemProcessCode = 'CS')
			BEGIN
				SELECT @AutoStockItemCodeNo= @Prefix+'/'+@SubPrefix+'/'+@SubPrefix2

				SELECT @CatCount =[dbo].[FN_GetNextCategoryCombinationNumber](@AutoStockItemCodeNo)

				IF(@CatCount IS NULL)
				BEGIN
					INSERT INTO  AutoStockItemCodeCombination(PrefixCombination, NextNumber)
					VALUES (@AutoStockItemCodeNo,1)

					SELECT @CatCount =[dbo].[FN_GetNextCategoryCombinationNumber](@AutoStockItemCodeNo)

				END

				SET @ProductCode = @AutoStockItemCodeNo+'/'+RIGHT('00000'+ CONVERT(VARCHAR(MAX),@CatCount),6)

				IF( @Operation = 1 )
				BEGIN

					UPDATE AutoStockItemCodeCombination
					SET NextNumber = NextNumber+1
					WHERE PrefixCombination = @AutoStockItemCodeNo

				END
			END
			
			--Added by Isuru 2023-11-29
			--SELECT @AutoStockItemCodeNo= @Prefix+'/'+@SubPrefix


			--Commented by isuru 2024-09-24 for using [FN_GetNextCategoryCombinationNumber] function
			--IF EXISTS(SELECT 1 FROM STOCKITEMHEADERS WHERE StockItemCode LIKE '%'+@AutoStockItemCodeNo+'%')
			--BEGIN
			--SELECT @CatCount = count(id)
			--FROM STOCKITEMHEADERS
			--WHERE StockItemCode LIKE '%'+@AutoStockItemCodeNo+'%'

			--SET @ProductCode = @AutoStockItemCodeNo+'/'+RIGHT('00000'+ CONVERT(VARCHAR(MAX),@CatCount+1),6)

			--END
			--ELSE
			--BEGIN

			--SET @ProductCode = @AutoStockItemCodeNo+'/'+RIGHT('00000'+ CONVERT(VARCHAR(MAX),00001),6)

			----SELECT @ProductCode ProductCode Commented by Nivesh 2024-07-23 Unneccesary select

			--END

			--end
			--end
			
			
			
			--SET @Serial= @Serial +1
			--UPDATE dbo.Categories SET serial= @Serial WHERE Id=@CategoryIDForCode

			--SET @ProductCode = @Prefix+RIGHT('0000000'+ CONVERT(VARCHAR(MAX),@Serial),@SerialLength)+@Suffix

			--SET @ProductCodeLength= LEN(@ProductCode)
		END
		ELSE
		BEGIN
			SET @ProductCode= (SELECT StockItemCode FROM #ItemList)
        end
        

		IF(@ProductCodeLength>@CodeLength)
		BEGIN
		

		SET @headerid  =-2
		SET @ProductItemCode ='-1'

		END




		

		
         IF @Operation = 1
        BEGIN
		
			SET @headerid = null
            --**********insert record to StockItemHeaders ***************************************************************
            WHILE exists(SELECT TOP 1 LocationID FROM #Locations)
			BEGIN

				Select TOP 1 @PropertyID = PropertyID, @LocationID= LocationID
				FROM #Locations

				IF EXISTS(SELECT 1 FROM StockItemHeaders WHERE StockItemCode = @ProductCode AND CompanyId = @PropertyID)
				BEGIN
					SET @InvoiceError =  'Stock Item Code Already Exists'
					RAISERROR ( @InvoiceError, 16, 1 );  
					ROLLBACK TRANSACTION
				END

				EXEC InsertMasterFileChangeLog 'Stock Master',1,'I',@Name

				---------------------------------------------------------
				IF EXISTS (SELECT 1 FROM @InsertedIDs_StockItemHeaders)
				BEGIN
					DROP TABLE #InsertedIDs_StockItemHeaders
				END
				INSERT INTO StockItemHeaders
				(
					CompanyId,
					LocationId,
					StockItemCode,
					PLUCode,
					ReferanceCode,
					Barcode,
					Name,
					NameOnInvoice,
					ImageUrl,
					CategoryID,
					SubCategoryID,
					SupplierID,
					TaxGroupID,
					CostingMethod,
					Remarks,
					IPAddress,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					IsExpiryDateApplicable,
					SubCategory2ID,
					IsPriceEditable,
					MaintainPriceHistory,
					Isbundle,
					BrandedItem,
					GenericItemCode,
					IsMultiplePrices,
					IsMultipleBarcode,
					IsAllowDiscount,
					IsFractionItem,
					IsSerialNo,
					IsAllowReturnItem,
					IsOpenPrice,
					ChargeHeaderID,
					IsSellingItem,
					ERPReferenceCode,
					IsProductionItem,
					ReportUnitID
				)
				OUTPUT INSERTED.Id INTO @InsertedIDs_StockItemHeaders --Added by Nivesh 2024-02-26
				SELECT @PropertyID,
					   0,
					   @ProductCode,
					   PLUCode,
					   ReferanceCode,
					   Barcode,
					   Name,
					   NameOnInvoice,
					   ImageUrl,
					   CategoryID,
					   SubCategoryID,
					   SupplierID,
					   TaxGroupID,
					   CostingMethod,
					   Remarks,
					   IPAddress,
					   @CreatedUserID,
					   @LastModUserID,
					   GETDATE(),
					   GETDATE(),
					   IsExpiryDateApplicable,
					   SubCategory2ID,
					   IsPriceEditable,
					   MaintainPriceHistory,
					   Isbundle,
					   BrandedItem,
					   GenericItemCode,
					   IsMultiplePrices,
					   IsMultipleBarcode,
					   IsAllowDiscount,
					   IsFractionItem,
					   IsSerialNo,
					   IsAllowReturnItem,
					   IsOpenPrice,
					   ChargeHeaderID,
					   IsSellingItem,
					   ERPReferenceCode,
					   IsProductionItem,
					   NULLIF(ReportUnitID, 0)
				FROM #ItemList; 



		
			
	--Set @CreatedUserID = 0 -- for network error testing purposes
	IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured :User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
				--***** get inserted id 
				SET @StockItemHeaderIDIntern = SCOPE_IDENTITY();
				
				IF @headerid is null
					SET @headerid = @StockItemHeaderIDIntern;


				SET @StockItemID = @StockItemHeaderIDIntern
				
				----------------------------------------------Log StockItemHeaders Insert 2024-02-26-----------------------------------------------
				while exists (select 1 from @InsertedIDs_StockItemHeaders)
				begin
					select top(1) @tempStocIID = Id from @InsertedIDs_StockItemHeaders
					EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @tempStocIID, 'INV', 'SIHI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_StockItemHeaders
				end


				--Added by Isuru 2025-11-07
				IF @IsRequestedItem = 1
				BEGIN

				UPDATE [dbo].[TempStockItemRequest] 
				SET StockItemHeaderID = @StockItemID 
				WHERE Id = @RequestedItemId

				DECLARE @IsItemCreationMail BIT
				SELECT @IsItemCreationMail= ISNULL(IsItemCreationMail,0)
				FROM COMPANIES
				WHERE COMPANYID=@PropertyID

				IF(@IsItemCreationMail =1)
				BEGIN
					IF EXISTS(SELECT 1 FROM TempStockItemRequest WITH (NOLOCK)
					WHERE ID = @RequestedItemId AND CreatedUserID IS NOT NULL)
					BEGIN
					
						EXEC [dbo].[SendTransactionWiseEmailS] 'SM',@RequestedItemId,0,@PropertyID,'C'
				
					END

				 --EXEC [dbo].[SendTransactionWiseEmailS] 'SM',@RequestedItemId,0,@PropertyID,'C'
				END
				--End


				END

				--IF PROCUREMENT EVALUATED SUPPLIER FOUND 2025-05-05
				IF(@IsRequestedItem =1)
				BEGIN
					IF EXISTS(SELECT 1 FROM ProcurementRequest WHERE StockItemRequestID =@RequestedItemId AND StatusID= 2 AND ISNULL(StockItemHeaderID,0) = 0)
					BEGIN

					DECLARE @ProcurementID INT,@SupplierQuotationID INT,@IsContractedSupplier BIT,@NewId INT,@ProcurementSupplierID INT

					SELECT @IsContractedSupplier =IsContractedSupplier
					FROM Companies
					WHERE CompanyID = @PropertyID

					SELECT @ProcurementID =PR.ID,@SupplierQuotationID =  SQ.ID ,@ProcurementSupplierID = SQ.SupplierID
					FROM ProcurementRequest PR 
					INNER JOIN SupplierQuotation SQ ON PR.ID = SQ.ProcurementID
					WHERE PR.StockItemRequestID =@RequestedItemId AND PR.StatusID= 2
					AND SQ.StatusID = 3
					AND ISNULL(PR.StockItemHeaderID,0) = 0

					INSERT INTO  SupplierWiseItemDetails(CompanyId, LocationId, SupplierID, StockItemID, PurchaseUnitID, CostPrice, IsDefaultSupplier, CreatedUserID, LastModUserID, 
					CreatedDate, LastModDate, IPAddress, TBPHeaderID, TaxGroupID, Validfrom, ValidTo, IsContractedSupplier)

					SELECT PR.CompanyID,PR.LocationID,SQ.SupplierID,@StockItemHeaderIDIntern StockItemID,PR.UnitID PurchaseUnitID,SQ.Price CostPrice,1 IsDefaultSupplier,@CreatedUserID CreatedUserID,@CreatedUserID LastModUserID,
					GETDATE() CreatedDate,GETDATE() LastModDate,'' IPAddress,0 TBPHeaderID,SQ.TaxGroupId,NULL Validfrom,NULL ValidTo
					,CASE WHEN @IsContractedSupplier = 1 THEN 1 ELSE 0 END AS IsContractedSupplier
					FROM ProcurementRequest PR
					INNER JOIN SupplierQuotation SQ ON PR.ID = SQ.ProcurementID
					WHERE PR.ID = @ProcurementID AND SQ.ID = @SupplierQuotationID
					AND PR.StatusID =2
					AND SQ.StatusID=3

					SELECT SCOPE_IDENTITY() AS Id
					SET @NewId = SCOPE_IDENTITY()

					EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @NewId, 'INV', 'SWDI', 'I', @CreatedUserID,@PropertyID, '', ''

					UPDATE ProcurementRequest
					SET StockItemHeaderID = @StockItemHeaderIDIntern
					WHERE ID = @ProcurementID

					--Added by Isuru 2025-05-15
					EXEC  [dbo].[SendSupplierQuotationEmail] @ProcurementID,@ProcurementSupplierID,@StockItemHeaderIDIntern,@PropertyID
					--End


					END

				END

				--END

				

				-----------------------------------------------------------------------------------------------------------------------------------
				IF EXISTS (SELECT 1 FROM @InsertedIDs_StockItemWiseClassificationDetails)
				BEGIN
					DROP TABLE #InsertedIDs_StockItemWiseClassificationDetails
				END
				INSERT INTO StockItemWiseClassificationDetails
				(
					CompanyId,
					LocationId,
					StockItemHeaderID,
					ItemClassificationHeaderID,
					ItemClassificationDetailID,
					IsActive,
					IPAddress,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate
				)
				OUTPUT INSERTED.Id INTO @InsertedIDs_StockItemWiseClassificationDetails --Added by Nivesh 2024-02-26
				SELECT @PropertyID,
					   @LocationID,
					   @StockItemID,
					   HeadID,
					   DeatailID,
					   1,
					   '',
					   1,
					   1,
					   GETDATE(),
					   GETDATE()
				FROM
					OPENXML(@iDocID, '/ProductSaveModel/ReferencesList/ReferencesViewModel', 2)
					WITH
					(
						HeadID INT,
						DeatailID INT
					);
			-----------------Log StockItemWiseClassificationDetails Insert 2024-02-26---------------

			while exists (select 1 from @InsertedIDs_StockItemWiseClassificationDetails)
				begin
					select top(1) @tempStItWiClDe = Id from @InsertedIDs_StockItemWiseClassificationDetails
					EXEC Inventry_AuditTail_WriteToLog 'StockItemWiseClassificationDetails', @tempStItWiClDe, 'INV', 'SIWCDI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_StockItemWiseClassificationDetails
				end
			----------------------------------------------------------------------------------------

				--**********insert record to StockItemWiseAttributes ********************************************************
				IF EXISTS (SELECT 1 FROM @InsertedIDs_StockItemWiseAttributes)
				BEGIN
					DROP TABLE #InsertedIDs_StockItemWiseAttributes
				END
				INSERT INTO StockItemWiseAttributes
				(
					CompanyId,
					LocationId,
					StockItemHeaderID,
					StockItemAttributeID,
					Remarks,
					IsActive,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					IPAddress
				)
				OUTPUT INSERTED.Id INTO @InsertedIDs_StockItemWiseAttributes --Added by Nivesh 2024-02-26
				SELECT @PropertyID,
					   @LocationID,
					   @StockItemID,
					   AttributeID,
					   Remarks,
					   Active,
					   1,
					   1,
					   GETDATE(),
					   GETDATE(),
					   ''
				FROM
					OPENXML(@iDocID, '/ProductSaveModel/AttributeList/AttributeViewModel', 2)
					WITH
					(
						AttributeID INT,
						Remarks VARCHAR(MAX),
						Active BIT
					);

			--------------------Log StockItemWiseAttributes Insert 2024-02-26-----------------------
			while exists (select 1 from @InsertedIDs_StockItemWiseAttributes)
			begin
				select top(1) @tempStItWiAt = Id from @InsertedIDs_StockItemWiseAttributes
				EXEC Inventry_AuditTail_WriteToLog 'StockItemWiseAttributes', @tempStItWiAt, 'INV', 'SIWAI', 'I', @LastModUserID,@PropertyID, '', ''
				delete top(1) from @InsertedIDs_StockItemWiseAttributes
			end
			----------------------------------------------------------------------------------------

					/** Inserting into Selling_Price Change Log**/

					SELECT @BusinessDate =CurrentDate FROM Companies WHERE CompanyID = @PropertyID
					IF(@IsRetail = 1)
					BEGIN
					INSERT INTO SellingPrice_ChangeLog
					(PropertyID,LocationID,SellingPrice,StockItemID,UserID,BusinessDate,CreatedDate)
				SELECT @PropertyID,@LocationID,@SellingPrice,@StockItemID,@LastModUserID,@BusinessDate,GETDATE()

					END

					/** Inserting into Selling_Price Change Log End **/

/** Inserting into Barcode**/
				IF(@IsRetail = 1)
				BEGIN
				WHILE EXISTS(SELECT TOP (1) Barcode FROM #ItemWiseBarcode)
				BEGIN

				SELECT TOP(1)PropertyID,@StockItemHeaderIDIntern,Barcode
				FROM #ItemWiseBarcode

				SELECT TOP (1) @Barcode = Barcode
				FROM #ItemWiseBarcode

				IF EXISTS(select 1 from POS_ItemBarcode WHERE Barcode = @Barcode AND CompanyID= @PropertyID)
				BEGIN
				SET @InvoiceError =  'BarCode Already Exists'
				RAISERROR ( @InvoiceError, 16, 1 );  
				ROLLBACK TRANSACTION
				END

				IF EXISTS (SELECT 1 FROM @InsertedIDs_POS_ItemBarcode)
				BEGIN
					DROP TABLE #InsertedIDs_POS_ItemBarcode
				END
				INSERT INTO POS_ItemBarcode(CompanyID, ItemID, Barcode,UserID,SysDate)
				OUTPUT INSERTED.Id INTO @InsertedIDs_POS_ItemBarcode --Added by Nivesh 2024-02-26
				SELECT TOP(1) PropertyID,@StockItemHeaderIDIntern,Barcode,@LastModUserID,GETDATE()
				FROM #ItemWiseBarcode
			--------------------Log POS_ItemBarcode Insert 2024-02-22-----------------------
				while exists (select 1 from @InsertedIDs_POS_ItemBarcode)
				begin
					select top(1) @tempPOS_IB = Id from @InsertedIDs_POS_ItemBarcode
					EXEC Inventry_AuditTail_WriteToLog 'POS_ItemBarcode', @tempPOS_IB, 'INV', 'POSIBI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_POS_ItemBarcode
				end
			----------------------------------------------------------------------------------------
				DELETE TOP (1) FROM #ItemWiseBarcode
				END
				END
/** Inserting into Barcode End **/

				WHILE exists(SELECT TOP 1 LocationID FROM #Locations WHERE PropertyID = @PropertyID)
				BEGIN
					
					SELECT TOP 1 @LocationID = LocationID 
					FROM #Locations
					WHERE PropertyID = @PropertyID

				
			
					SET @ProductItemCode= @ProductCode

					--**********insert record to StockItemDetails ***************************************************************
					IF EXISTS (SELECT 1 FROM @InsertedIDs_StockItemDetails)
					BEGIN
						DROP TABLE #InsertedIDs_StockItemDetails
					END
					INSERT INTO StockItemDetails
					(
						PropertyID,
						CompanyID,
						LocationID,
						StockItemHeaderID,
						MasterUnitID,
						PurchasingUnitID,
						MinimumQuantity,
						MaximumQuantity,
						ReOrderLevel,
						ReOrderQuantity,
						ReOrderPeriod,
						PurchaseAccountID,
						CostOfSalesAccountID,
						AveragePrice,
						SellingPrice,
						WholesalePrice,
						IsActive,
						ReportingUnitID,
						QuantityInHand,
						StockItemId,
						IPAddress,
						CreatedUserID,
						LastModUserID,
						CreatedDate,
						LastModDate,
						ItemAge
					)
					OUTPUT INSERTED.Id INTO @InsertedIDs_StockItemDetails --Added by Nivesh 2024-02-26
					SELECT @PropertyID,
						   @PropertyID,
						   @LocationID,
						   @StockItemHeaderIDIntern,
						   MasterUnitID,
						   PurchasingUnitID,
						   MinimumQuantity,
						   MaximumQuantity,
						   ReOrderLevel,
						   ReOrderQuantity,
						   ReOrderPeriod,
						   PurchaseAccountID,
						   CostOfSalesAccountID,
						   AveragePrice,
						   SellingPrice,
						   WholesalePrice,
						   #ItemList.IsActive,
						   ReportingUnitID,
						   QuantityInHand,
						   @StockItemHeaderIDIntern,
						   '',
						   1,
						   1,
						   GETDATE(),
						   GETDATE(),
						   ItemAge
					FROM #ItemList
					
		    --------------------Log StockItemDetails Insert 2024-02-22-----------------------
				while exists (select 1 from @InsertedIDs_StockItemDetails)
				begin
					select top(1) @tempStItDe = Id from @InsertedIDs_StockItemDetails
					EXEC Inventry_AuditTail_WriteToLog 'StockItemDetails', @tempStItDe, 'INV', 'SIDI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_StockItemDetails
				end
			----------------------------------------------------------------------------------------
					--INNER JOIN Locations 
					--ON #ItemList.PropertyID = Locations.CompanyID
					--Inner join #TempLocations t on t.id= Locations.Id

							/** Inserting into Selling_Price Change Log**/
					SELECT @BusinessDate =CurrentDate FROM Companies WHERE CompanyID = @PropertyID
					IF(@IsRetail = 1)
					BEGIN
					INSERT INTO SellingPrice_ChangeLog
					(PropertyID,LocationID,SellingPrice,StockItemID,UserID,BusinessDate,CreatedDate)
					SELECT @PropertyID,@LocationID,@SellingPrice,@StockItemID,@LastModUserID,@BusinessDate,GETDATE()

					END

					/** Inserting into Selling_Price Change Log End **/
				

					DELETE FROM #Locations 
					WHERE LocationID=@LocationID

					--SELECT * from #Locations where LocationID =@LocationID Commented by Nivesh 2024-07-23 Unneccesary select

				END 




			END
				
			--**********insert record to SupplierWiseItemDetails ********************************************************
				IF EXISTS (SELECT 1 FROM @InsertedIDs_SupplierWiseItemDetails)
				BEGIN
					DROP TABLE #InsertedIDs_SupplierWiseItemDetails
				END

			---------------------------------Added by Nivesh 2024-11-23 Check duplicate supplier items Start--------------------------


				INSERT INTO #tempSupplierTable
				SELECT @PropertyID,
				LocationID,
				SuppID,
				@headerid,
				UnitId,
				CostPrice,
				IsDefaultsupplier,
				1,
				1,
				GETDATE(),
				GETDATE(),
				'',
				SuppTaxGroupID,
				IsContractedSupplier,
				Validfrom,
				ValidTo
				FROM
					OPENXML(@iDocID, '/ProductSaveModel/SupplierList/SupplierViewModel', 2)
					WITH
					(
						SuppID INT,
						StockItemID INT,
						UnitId INT,
						CostPrice DECIMAL(18, 6),
						IsDefaultsupplier BIT,
						LocationID INT,
						SuppTaxGroupID INT,
						IsContractedSupplier BIT,
						Validfrom VARCHAR(MAX),
						ValidTo VARCHAR(MAX)
					);

			IF EXISTS (
			SELECT  SuppID, LocationID
			FROM #tempSupplierTable
			GROUP BY SuppID, LocationID
			HAVING COUNT(*) > 1
				)
			BEGIN
				RAISERROR('Duplicate Supplier Item found',16,1)
				ROLLBACK TRANSACTION
			END

				--------------------------------------------------
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
					TaxGroupID,
					IsContractedSupplier,
					Validfrom,
					ValidTo
				)
				OUTPUT INSERTED.Id INTO @InsertedIDs_SupplierWiseItemDetails --Added by Nivesh 2024-02-26
				SELECT @PropertyID,
					   LocationID,
					   SuppID,
					   @headerid,
					   UnitId,
					   CostPrice,
					   IsDefaultsupplier,
					   1,
					   1,
					   GETDATE(),
					   GETDATE(),
					   '',
					   SuppTaxGroupID
					   ,IsContractedSupplier
					   ,CASE WHEN IsContractedSupplier = 1 THEN CONVERT(DATE,Validfrom) ELSE NULL END
					   ,CASE WHEN IsContractedSupplier = 1 THEN CONVERT(DATE,ValidTo) ELSE NULL END
				FROM #tempSupplierTable
		    --------------------Log SupplierWiseItemDetails Insert 2024-02-22-----------------------
			while exists (select 1 from @InsertedIDs_SupplierWiseItemDetails)
				begin
					select top(1) @tempSuWiItDe = Id from @InsertedIDs_SupplierWiseItemDetails
					EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @tempSuWiItDe, 'INV', 'SWDI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_SupplierWiseItemDetails
				end
			----------------------------------------------------------------------------------------
				--**********insert record to StockItemWiseClassificationDetails *********************************************



				--SELECT @headerid; Commented by Nivesh 2024-07-23 Unneccesary select

			 
        END;

        ELSE
        BEGIN
            SELECT @StockItemID = Id,
                   @StockItemCode = StockItemCode,
                   @IsPriceEditable = IsPriceEditable,
                   @MaintainPriceHistory = MaintainPriceHistory,
                   @PLUCode = PLUCode,
                   @Name = Name,
                   @CategoryID = CategoryID,
                   @SubCategoryID = SubCategoryID,
                   @Remarks = Remarks,
                   @IsExpiryDateApplicable = IsExpiryDateApplicable,
                   @Active = IsActive,
                   @Isbundle = Isbundle,
                   @NameOnInvoice = NameOnInvoice,
                   @SubCategory2ID = SubCategory2ID,
                   @TaxGroupID = TaxGroupID,
				   @BrandedItem = BrandedItem,
				   @GenericItemCode = GenericItemCode,
				   @IsMultiplePrices = IsMultiplePrices,
				@IsMultipleBarcode = IsMultipleBarcode,
				@IsAllowDiscount = IsAllowDiscount,
				@IsFractionItem = IsFractionItem,
				@IsSerialNo = IsSerialNo,
				@IsAllowReturnItem =IsAllowReturnItem,
				@IsOpenPrice =IsOpenPrice,
				@ChargeHeaderID = ChargeHeaderID,
				@IsSellingItem = IsSellingItem,
				@ERPReferenceCode = ERPReferenceCode,
				@IsProductionItem = IsProductionItem,
				@ReportUnitID = NULLIF(ReportUnitID, 0),
				@CopyToOtherProperties = CopyToOtherProperties

            FROM #ItemList;
			

            SELECT @LocationID = LocationID,
                   @PropertyID = PropertyID,
                   @StockItemID = Id
            FROM #ItemList;

			EXEC InsertMasterFileChangeLog 'Stock Master',1,'U',@Name
	--set @LastModUserID = 0 ;		 --used for network error texting purposes

	--------------------------------------------------------------------------------
			IF(@LastModUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('Error Occured :User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END

--------------------------------------------------------------------------------
            UPDATE dbo.StockItemHeaders
            SET --StockItemCode = @StockItemCode,
                PLUCode = @PLUCode,
                Name = @Name,
                CategoryID = @CategoryID,
                SubCategoryID = @SubCategoryID,
                Remarks = @Remarks,
                LastModDate = GETDATE(),
                LastModUserID = @LastModUserID,
                IsExpiryDateApplicable = @IsExpiryDateApplicable,
                NameOnInvoice = @NameOnInvoice,
                SubCategory2ID = CASE WHEN  @SubCategory2ID = 0 THEN  SubCategory2ID ELSE @SubCategory2ID END  ,
                IsPriceEditable = @IsPriceEditable,
                MaintainPriceHistory = @MaintainPriceHistory,
                Isbundle = @Isbundle,
                TaxGroupID = @TaxGroupID,
				BrandedItem = @BrandedItem,
				GenericItemCode = @GenericItemCode,
				IsMultiplePrices = @IsMultiplePrices,
				IsMultipleBarcode = @IsMultipleBarcode,
				IsAllowDiscount = @IsAllowDiscount,
				IsFractionItem = @IsFractionItem,
				IsSerialNo = @IsSerialNo,
				IsAllowReturnItem = @IsAllowReturnItem,
				IsOpenPrice = @IsOpenPrice,
				ChargeHeaderID = @ChargeHeaderID,
				IsSellingItem = @IsSellingItem,
				ERPReferenceCode = @ERPReferenceCode,
				IsProductionItem = @IsProductionItem,
				ReportUnitID = ISNULL(ReportUnitID, @ReportUnitID) --once set it cannot be changed
            WHERE Id = @StockItemID;
			--added by Isuru
		    --------------------Log StockItemHeaders Update 2024-02-22-----------------------
			IF EXISTS (SELECT 1 FROM dbo.StockItemHeaders WHERE Id = @StockItemID)
			BEGIN
				EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @StockItemID, 'INV', 'SIHD', 'U', @LastModUserID,@PropertyID, '', ''
			END

			----------------------------------------------------------------------------------------

			IF (@DirectActiveType = 'All')
			BEGIN

				IF EXISTS(SELECT 1 FROM StockItemDetails WHERE StockItemHeaderID = @StockItemID AND IsActive =1 AND QuantityInHand >0)
				BEGIN
					RAISERROR('Quantity in Hand Found for item in Locations, Cannot Inactive!',16,1)
					ROLLBACK TRANSACTION
				

				END

				--Remove from InactiveStockItemTable if item exists
				IF EXISTS(SELECT 1 FROM InactiveStockItemTable WHERE StockItemID = @StockItemID AND PropertyID = @PropertyID)
				BEGIN
					IF(@Active = 1)
					BEGIN
						DELETE FROM InactiveStockItemTable
						WHERE StockItemID = @StockItemID AND PropertyID = @PropertyID
					END
				END

				--End
			
				UPDATE dbo.StockItemDetails
				SET IsActive = @Active
				WHERE StockItemHeaderID = @StockItemID;


		    --------------------Log StockItemDetails Update 2024-02-22-----------------------
				IF EXISTS (SELECT 1 FROM dbo.StockItemDetails WHERE StockItemHeaderID = @StockItemID)
				BEGIN
					SELECT @TempSIDU_Log = id FROM dbo.StockItemDetails WHERE StockItemHeaderID = @StockItemID
					EXEC Inventry_AuditTail_WriteToLog 'StockItemDetails', @TempSIDU_Log, 'INV', 'SIDU', 'U', @LastModUserID,@PropertyID, '', ''
				END
			----------------------------------------------------------------------------------------
				--UPDATE dbo.StockItemDetails
				--SET dbo.StockItemDetails.MasterUnitID = #ItemList.MasterUnitID
				--FROM #ItemList
				--WHERE  dbo.StockItemDetails.StockItemHeaderID = @StockItemID; 
		  --  --------------------Log StockItemDetails Update 2024-02-22-----------------------
				--IF EXISTS (SELECT 1 FROM dbo.StockItemDetails WHERE StockItemHeaderID = @StockItemID)
				--BEGIN
				--	SELECT @TempSIDU_Log = id FROM dbo.StockItemDetails WHERE StockItemHeaderID = @StockItemID
				--	EXEC Inventry_AuditTail_WriteToLog 'StockItemDetails', @TempSIDU_Log, 'INV', 'SIDU', 'U', @LastModUserID,@PropertyID, '', ''
				--END  Commented by Isuru to prevent updating all locations with same unitID
			----------------------------------------------------------------------------------------
			
			END
			-- added by Isuru 2023-05-04


			-- UPDATE dbo.StockItemDetails
   --         SET IsActive = @Active
   --         WHERE StockItemHeaderID = @StockItemID AND LocationID = @LocationID; --EDITED BY ISURU
			--PRINT '2';
			--PRINT @StockItemCode;
			--PRINT @Active;

			---------------------UPDATE BY CODE------------------------------------------------
				--print '373' Commented by Nivesh 2024-07-23 Unneccesary select
            UPDATE dbo.StockItemHeaders
            SET --StockItemCode = @StockItemCode,
                PLUCode = @PLUCode,
                Name = @Name,
                CategoryID = @CategoryID,
                SubCategoryID = @SubCategoryID,
                Remarks = @Remarks,
                LastModDate = GETDATE(),
                LastModUserID =	@LastModUserID,
                IsExpiryDateApplicable = @IsExpiryDateApplicable,
                NameOnInvoice = @NameOnInvoice,
                SubCategory2ID = CASE WHEN  @SubCategory2ID = 0 THEN  SubCategory2ID ELSE @SubCategory2ID END  ,
                IsPriceEditable = @IsPriceEditable,
                MaintainPriceHistory = @MaintainPriceHistory,
                Isbundle = @Isbundle,
                TaxGroupID = @TaxGroupID,
				BrandedItem = @BrandedItem,
				GenericItemCode = @GenericItemCode,
				IsMultiplePrices = @IsMultiplePrices,
				IsMultipleBarcode = @IsMultipleBarcode,
				IsAllowDiscount = @IsAllowDiscount,
				IsFractionItem = @IsFractionItem,
				IsSerialNo = @IsSerialNo,
				IsAllowReturnItem = @IsAllowReturnItem,
				IsOpenPrice = @IsOpenPrice,
				ChargeHeaderID = @ChargeHeaderID,
				IsSellingItem = @IsSellingItem,
				ERPReferenceCode = @ERPReferenceCode,
				IsProductionItem = @IsProductionItem,
				ReportUnitID = ISNULL(ReportUnitID, @ReportUnitID) --once set it cannot be changed
            WHERE StockItemCode = @StockItemCode;
		    --------------------Log StockItemHeaders Update 2024-02-22-----------------------
			--IF EXISTS (SELECT 1 FROM dbo.StockItemHeaders WHERE StockItemCode = @StockItemCode)
			--BEGIN
			-- SELECT @TempSIHU_Log = id FROM dbo.StockItemHeaders WHERE StockItemCode = @StockItemCode
			--	EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @TempSIHU_Log, 'INV', 'SIHU', 'U', @LastModUserID,@PropertyID, '', ''
			--END //Comment by Nivesh 2024-03-12 duplication update stockitemheader 
			----------------------------------------------------------------------------------------
			---------------------UPDATE BY CODE------------------------------------------------

			--Added by Isuru 2025-08-06 to  insert into other properties if item not exists
			IF(@CopyToOtherProperties = 1)
			BEGIN
			DECLARE @CopyCompanyID INT,@CopyLocationID INT,@CopyCompanyName VARCHAR(MAX),@CopyStockItemID INT,@MainLocationID INT,@CopyStockDetailID INT

			SELECT CompanyID,Name
			INTO #AllCompanies
			FROM Companies
			WHERE CompanyID NOT IN (
			SELECT CompanyId
			FROM StockItemHeaders WITH (NOLOCK)
			WHERE StockItemCode = @StockItemCode)


			WHILE EXISTS(SELECT 1 FROM #AllCompanies)
			BEGIN
				SELECT TOP 1 @CopyCompanyID = CompanyID,@CopyCompanyName = Name FROM #AllCompanies

				IF NOT EXISTS(SELECT  1  FROM Locations WITH (NOLOCK) WHERE CompanyID=@CopyCompanyID AND IsActive=1AND GroupName = 'MS')
				BEGIN
					SET @InvoiceError =  'Main Store not exists at '+@CopyCompanyName
					RAISERROR ( @InvoiceError, 16, 1 );  
					ROLLBACK TRANSACTION

				END

				SELECT TOP 1 @CopyLocationID = ID
				FROM Locations WITH (NOLOCK)
				WHERE CompanyID=@CopyCompanyID
				AND IsActive=1
				AND GroupName = 'MS'

				--INSERTING INTO StockItemHeaders


				INSERT INTO StockItemHeaders(CompanyId, LocationId, StockItemCode, PLUCode, ReferanceCode, Barcode, Name, NameOnInvoice, ImageUrl, CategoryID, SubCategoryID, SupplierID, TaxGroupID, CostingMethod, Remarks, 
                  IsExpiryDateApplicable, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, SubCategory2ID, IsPriceEditable, MaintainPriceHistory, Isbundle, BrandedItem, GenericItemCode, IsMultiplePrices, IsMultipleBarcode, 
                  IsAllowDiscount, IsFractionItem, IsSerialNo, IsAllowReturnItem, IsOpenPrice, ChargeHeaderID, IsSellingItem, ERPReferenceCode, IsProductionItem, ReportUnitID)
				
				SELECT TOP (1) @CopyCompanyID, LocationId, StockItemCode, PLUCode, ReferanceCode, Barcode, Name, NameOnInvoice, ImageUrl, CategoryID, SubCategoryID, SupplierID, TaxGroupID, CostingMethod, Remarks, IsExpiryDateApplicable, 
                  IPAddress, @LastModUserID, @LastModUserID, GETDATE(), GETDATE(), SubCategory2ID, IsPriceEditable, MaintainPriceHistory, Isbundle, BrandedItem, GenericItemCode, IsMultiplePrices, IsMultipleBarcode, IsAllowDiscount, 
                  IsFractionItem, IsSerialNo, IsAllowReturnItem, IsOpenPrice, ChargeHeaderID, IsSellingItem, ERPReferenceCode, IsProductionItem, ReportUnitID
				FROM     StockItemHeaders WITH (NOLOCK)
				WHERE ID = @StockItemID

				SET @CopyStockItemID = SCOPE_IDENTITY()


				EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @CopyStockItemID, 'INV', 'SIHI', 'I', @LastModUserID,@CopyCompanyID, '', ''
				--END

				SELECT @MainLocationID = ID 
				FROM Locations WITH (NOLOCK)
				WHERE CompanyID = @PropertyID
				AND GroupName = 'MS'

				IF (@MainLocationID IS NULL)
				BEGIN
					SELECT TOP (1) @MainLocationID = ID 
					FROM Locations WITH (NOLOCK)
					WHERE CompanyID = @PropertyID
				END

				INSERT INTO StockItemDetails(PropertyID, CompanyID, LocationID, StockItemHeaderID, MasterUnitID, PurchasingUnitID, MinimumQuantity, MaximumQuantity, ReOrderLevel, ReOrderQuantity, ReOrderPeriod, PurchaseAccountID, 
                  CostOfSalesAccountID, AveragePrice, SellingPrice, WholesalePrice, IsActive, ReportingUnitID, QuantityInHand, StockItemId, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, BatchNo, ProfitMargin, ItemAge)

				SELECT TOP (1)  @CopyCompanyID, @CopyCompanyID, @CopyLocationID, @CopyStockItemID, MasterUnitID, PurchasingUnitID, MinimumQuantity, MaximumQuantity, ReOrderLevel, ReOrderQuantity, ReOrderPeriod, PurchaseAccountID, CostOfSalesAccountID, 
                  0, 0, 0, 1, ReportingUnitID, 0, @CopyStockItemID, IPAddress, @LastModUserID, @LastModUserID, GETDATE(), GETDATE(), NULL, 0, ItemAge
				FROM     StockItemDetails WITH (NOLOCK)
				WHERE StockItemHeaderID = @StockItemID
				AND LocationID = @MainLocationID

				SET @CopyStockDetailID = SCOPE_IDENTITY()


				EXEC Inventry_AuditTail_WriteToLog 'StockItemDetails', @CopyStockDetailID, 'INV', 'SIDI', 'I', @LastModUserID,@CopyCompanyID, '', ''



			DELETE TOP (1) FROM #AllCompanies

			END



			END





			--End




			/** Inserting into Barcode**/
				IF(@IsRetail = 1)
				BEGIN
		    --------------------Log POS_ItemBarcode Delete 2024-02-22-----------------------
				IF EXISTS (SELECT 1 FROM dbo.POS_ItemBarcode WHERE ItemID = @StockItemID)
				BEGIN
					SELECT @TempPOSIBD_Log = id FROM dbo.POS_ItemBarcode WHERE ItemID = @StockItemID
					EXEC Inventry_AuditTail_WriteToLog 'POS_ItemBarcode', @TempPOSIBD_Log, 'INV', 'POSIBD', 'D', @LastModUserID,@PropertyID, '', ''
				END
			----------------------------------------------------------------------------------------
				DELETE FROM POS_ItemBarcode WHERE ItemID = @StockItemID
				WHILE EXISTS(SELECT TOP (1) Barcode FROM #ItemWiseBarcode)
				BEGIN
				SELECT TOP (1) @Barcode = Barcode
				FROM #ItemWiseBarcode

				IF EXISTS(select 1 from POS_ItemBarcode WHERE Barcode = @Barcode AND CompanyID= @PropertyID)
				BEGIN
				SET @InvoiceError =  'BarCode Already Exists'
				RAISERROR ( @InvoiceError, 16, 1 );  
				ROLLBACK TRANSACTION
				END

				IF EXISTS (SELECT 1 FROM @InsertedIDs_POS_ItemBarcode)
				BEGIN
					DROP TABLE #InsertedIDs_POS_ItemBarcode
				END
				INSERT INTO POS_ItemBarcode(CompanyID, ItemID, Barcode,UserID,SysDate)
				OUTPUT INSERTED.Id INTO @InsertedIDs_POS_ItemBarcode --Added by Nivesh 2024-02-26
				SELECT TOP(1)@PropertyID,@StockItemID,Barcode,@LastModUserID,GETDATE()
				FROM #ItemWiseBarcode
		    --------------------Log POS_ItemBarcode Insert 2024-02-22-----------------------
				while exists (select 1 from @InsertedIDs_POS_ItemBarcode)
				begin
					select top(1) @tempPOS_IB = Id from @InsertedIDs_POS_ItemBarcode
					EXEC Inventry_AuditTail_WriteToLog 'POS_ItemBarcode', @tempPOS_IB, 'INV', 'POSIBI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_POS_ItemBarcode
				end
			----------------------------------------------------------------------------------------
				DELETE TOP (1) FROM #ItemWiseBarcode
				END
				END
/** Inserting into Barcode End **/

			--select @StockItemID as wewew	
			INSERT INTO #SupplierList
			SELECT *
			FROM
			OPENXML(@iDocID, '/ProductSaveModel/SupplierList/SupplierViewModel', 2) WITH #SupplierList;

			---------------------------------Added by Nivesh 2024-11-23 Check duplicate supplier items Start--------------------------

			IF EXISTS (
			SELECT  SuppID, LocationID
			FROM #SupplierList
			GROUP BY SuppID, LocationID
			HAVING COUNT(*) > 1
				)
			BEGIN
				RAISERROR('Duplicate Supplier Item found',16,1)
				ROLLBACK TRANSACTION
			END

			-------------------------------------------------End----------------------------------------
		    --------------------Log SupplierWiseItemDetails Delete 2024-02-22-----------------------
			IF EXISTS (SELECT 1 FROM dbo.SupplierWiseItemDetails WHERE StockItemID = @StockItemID)
			BEGIN
				SELECT @TempSWIDD_Log = id FROM dbo.SupplierWiseItemDetails WHERE StockItemID = @StockItemID
				EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @TempSWIDD_Log, 'INV', 'SWDD', 'D', @LastModUserID,@PropertyID, '', ''
			END

			----------------------------------------------------------------------------------------			
            DELETE FROM dbo.SupplierWiseItemDetails
            WHERE StockItemID = @StockItemID;

			IF EXISTS (SELECT 1 FROM @InsertedIDs_SupplierWiseItemDetails)
			BEGIN
				DROP TABLE #InsertedIDs_SupplierWiseItemDetails
			END
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
				TaxGroupID,
				IsContractedSupplier
				,Validfrom
				,ValidTo
            )
			OUTPUT INSERTED.Id INTO @InsertedIDs_SupplierWiseItemDetails --Added by Nivesh 2024-02-26
            SELECT @PropertyID,
                   LocationID,
                   SuppID,
                   @StockItemID,
                   UnitId,
                   CostPrice,
                   IsDefaultsupplier,
                   1,
                   1,
                   GETDATE(),
                   GETDATE(),
                   '',
				   SuppTaxGroupID,
				   IsContractedSupplier
				   ,CASE WHEN IsContractedSupplier = 1 THEN CONVERT(DATE,Validfrom) ELSE NULL END 
				 ,CASE WHEN IsContractedSupplier = 1 THEN CONVERT(DATE,ValidTo) ELSE NULL END 
            FROM
                OPENXML(@iDocID, '/ProductSaveModel/SupplierList/SupplierViewModel', 2)
                WITH
                (
                    SuppID INT,
                    StockItemID INT,
                    UnitId INT,
                    CostPrice DECIMAL(18, 6),
                    IsDefaultsupplier BIT,
                    LocationID INT,
					SuppTaxGroupID INT,
					IsContractedSupplier BIT,
					Validfrom   VARCHAR(MAX),
					ValidTo VARCHAR(MAX)
                );
		    --------------------Log SupplierWiseItemDetails Insert 2024-02-22-----------------------
			while exists (select 1 from @InsertedIDs_SupplierWiseItemDetails)
				begin
					select top(1) @tempSuWiItDe = Id from @InsertedIDs_SupplierWiseItemDetails
					EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @tempSuWiItDe, 'INV', 'SWDI', 'I', @LastModUserID,@PropertyID, '', ''
					delete top(1) from @InsertedIDs_SupplierWiseItemDetails
				end
			----------------------------------------------------------------------------------------				
			SET @EditItemCount = CASE WHEN (SELECT COUNT(*) FROM #SupplierList  where Edited=1 GROUP BY SuppID having count (*) > 1) > 1 THEN 2 ELSE 0 END	
			
			IF @EditItemCount < 1
			BEGIN
				UPDATE SW
				SET SW.CostPrice = SL.CostPrice, SW.TaxGroupID = Sl.SuppTaxGroupID
				FROM SupplierWiseItemDetails SW
				INNER JOIN #SupplierList SL
				ON SW.SupplierID = SL.SuppID and SW.StockItemID = @StockItemID and SW.CompanyId = @PropertyID
				AND SL.LocationID = SW.LocationId --Added by Nivesh 2024-11-22 beacuse of should update only supllier and particular location only
				WHERE SL.Edited = 1
		    --------------------Log SupplierWiseItemDetails Update 2024-02-22-----------------------
				IF EXISTS (SELECT 1  FROM SupplierWiseItemDetails SW
					INNER JOIN #SupplierList SL
					ON SW.SupplierID = SL.SuppID and SW.StockItemID = @StockItemID and SW.CompanyId = @PropertyID
					AND SL.LocationID = SW.LocationId --Added by Nivesh 2024-11-22 beacuse of should update only supllier and particular location only
					WHERE SL.Edited = 1)
				BEGIN
					SELECT @TempSWIDD_Log = SW.ID FROM SupplierWiseItemDetails SW
					INNER JOIN #SupplierList SL
					ON SW.SupplierID = SL.SuppID and SW.StockItemID = @StockItemID and SW.CompanyId = @PropertyID
					AND SL.LocationID = SW.LocationId --Added by Nivesh 2024-11-22 beacuse of should update only supllier and particular location only
					WHERE SL.Edited = 1
					EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @TempSWIDD_Log, 'INV', 'SWDU', 'U', @LastModUserID,@PropertyID, '', ''
				END
			----------------------------------------------------------------------------------------
			END 

		    --------------------Log StockItemWiseClassificationDetails Delete 2024-02-22-----------------------
			IF EXISTS (SELECT 1 FROM dbo.StockItemWiseClassificationDetails
            WHERE StockItemHeaderID = @StockItemID)
			BEGIN
				SELECT @TempSIWCDD_Log = ID FROM dbo.StockItemWiseClassificationDetails  WHERE StockItemHeaderID = @StockItemID
				EXEC Inventry_AuditTail_WriteToLog 'StockItemWiseClassificationDetails', @TempSIWCDD_Log, 'INV', 'SIWCDD', 'D', @LastModUserID,@PropertyID, '', ''
			END
			----------------------------------------------------------------------------------------
            DELETE FROM dbo.StockItemWiseClassificationDetails
            WHERE StockItemHeaderID = @StockItemID;

			IF EXISTS (SELECT 1 FROM @InsertedIDs_StockItemWiseClassificationDetails)
			BEGIN
				DROP TABLE #InsertedIDs_StockItemWiseClassificationDetails
			END
            INSERT INTO StockItemWiseClassificationDetails
            (
                CompanyId,
                LocationId,
                StockItemHeaderID,
                ItemClassificationHeaderID,
                ItemClassificationDetailID,
                IsActive,
                IPAddress,
                CreatedUserID,
                LastModUserID,
                CreatedDate,
                LastModDate
            )
			OUTPUT INSERTED.Id INTO @InsertedIDs_StockItemWiseClassificationDetails --Added by Nivesh 2024-02-26
            SELECT @PropertyID,
                   @LocationID,
                   @StockItemID,
                   HeadID,
                   DeatailID,
                   1,
                   '',
                   1,
                   1,
                   GETDATE(),
                   GETDATE()
            FROM
                OPENXML(@iDocID, '/ProductSaveModel/ReferencesList/ReferencesViewModel', 2)
                WITH
                (
                    HeadID INT,
                    DeatailID INT
                );

		    --------------------Log StockItemWiseClassificationDetails Insert 2024-02-22-----------------------
			while exists (select 1 from @InsertedIDs_StockItemWiseClassificationDetails)
			begin
				select top(1) @tempStItWiClDe = Id from @InsertedIDs_StockItemWiseClassificationDetails
				EXEC Inventry_AuditTail_WriteToLog 'StockItemWiseClassificationDetails', @tempStItWiClDe, 'INV', 'SIWCDI', 'I', @LastModUserID,@PropertyID, '', ''
				delete top(1) from @InsertedIDs_StockItemWiseClassificationDetails
			end
			----------------------------------------------------------------------------------------

		    --------------------Log StockItemWiseAttributes Delete 2024-02-22-----------------------
			IF EXISTS (SELECT 1 FROM dbo.StockItemWiseAttributes WHERE StockItemHeaderID = @StockItemID)
			BEGIN
				SELECT @tempStItWiAt =ID FROM dbo.StockItemWiseAttributes WHERE StockItemHeaderID = @StockItemID
				EXEC Inventry_AuditTail_WriteToLog 'StockItemWiseAttributes', @tempStItWiAt, 'INV', 'SIWAD', 'D', @LastModUserID,@PropertyID, '', ''
			END
			----------------------------------------------------------------------------------------
            DELETE FROM dbo.StockItemWiseAttributes
            WHERE StockItemHeaderID = @StockItemID;


			IF EXISTS (SELECT 1 FROM @InsertedIDs_StockItemWiseAttributes)
			BEGIN
				DROP TABLE #InsertedIDs_StockItemWiseAttributes
			END
            INSERT INTO StockItemWiseAttributes
            (
                CompanyId,
                LocationId,
                StockItemHeaderID,
                StockItemAttributeID,
                Remarks,
                IsActive,
                CreatedUserID,
                LastModUserID,
                CreatedDate,
                LastModDate,
                IPAddress
            )
			OUTPUT INSERTED.Id INTO @InsertedIDs_StockItemWiseAttributes --Added by Nivesh 2024-02-26
            SELECT @PropertyID,
                   @LocationID,
                   @StockItemID,
                   AttributeID,
                   Remarks,
                   Active,
                   1,
                   1,
                   GETDATE(),
                   GETDATE(),
                   ''
            FROM
                OPENXML(@iDocID, '/ProductSaveModel/AttributeList/AttributeViewModel', 2)
                WITH
                (
                    AttributeID INT,
                    Remarks VARCHAR(MAX),
					Active BIT
                );
		    --------------------Log StockItemWiseAttributes Insert 2024-02-22-----------------------
			while exists (select 1 from @InsertedIDs_StockItemWiseAttributes)
			begin
				select top(1) @tempStItWiAt = Id from @InsertedIDs_StockItemWiseAttributes
				EXEC Inventry_AuditTail_WriteToLog 'StockItemWiseAttributes', @tempStItWiAt, 'INV', 'SIWAI', 'I', @LastModUserID,@PropertyID, '', ''
				delete top(1) from @InsertedIDs_StockItemWiseAttributes
			end
			----------------------------------------------------------------------------------------
            SET @headerid = @StockItemID;



        END;


		  Declare @LocationJson VARCHAR(MAX)
          SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID  AND IsSalesLocation=1 FOR JSON PATH,INCLUDE_NULL_VALUES)
          EXEC RT_SYNC_DATA_INSERT @PropertyID,@StockItemID,@StockItemCode,'StockItem',1,0,@LocationJson
          EXEC RT_SYNC_DATA_INSERT @PropertyID,@StockItemID,@StockItemCode,'ItemBarcode',1,0,@LocationJson


        COMMIT TRAN; -- Transaction Success!
    END TRY
 --   BEGIN CATCH
	--	--IF @@TRANCOUNT > 0
	--	--	ROLLBACK TRAN; --RollBack in case of Error

 -- --      RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line '
 -- --             + CAST(ERROR_LINE() AS VARCHAR(10));

 -- ROLLBACK TRANSACTION
	
	--DECLARE @ErrorMessage NVARCHAR(4000);  
	--DECLARE @ErrorSeverity INT;  
	--DECLARE @ErrorState INT;
	--DECLARE @ErrorProcedure NVARCHAR(4000);  

	--SELECT   
 --   @ErrorMessage = ERROR_MESSAGE(),  
 --   @ErrorSeverity = ERROR_SEVERITY(),  
 --   @ErrorState = ERROR_STATE(),
	--@ErrorProcedure = ERROR_PROCEDURE(); 
	--RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
 --   END CATCH;

 	BEGIN CATCH
		ROLLBACK TRANSACTION
	
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
	

END;









--select * from SupplierWiseItemDetails

GO

