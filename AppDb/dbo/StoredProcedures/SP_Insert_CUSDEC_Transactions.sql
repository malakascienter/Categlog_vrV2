-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-09
-- Description:	Submit SP for Flood DOnation GRN
-- =============================================
CREATE PROCEDURE [dbo].[SP_Insert_CUSDEC_Transactions]
@XMLDetails XML,
@docno VARCHAR(MAX) OUTPUT,
@status INT OUTPUT,
@message VARCHAR(MAX) OUTPUT,
@headerid INT OUTPUT
AS


insert into tempCusDec (XmlDATA)
select convert(varchar(max),  @XMLDetails) 

 BEGIN
	DECLARE @iDocID INT;
	BEGIN TRY 
	BEGIN TRANSACTION;
		DECLARE @InvError VARCHAR(MAX),@UserID INT,@PropertyID INT,@NewSupplierID INT,@NewStockItemID INT,@LocationID INT,@Remark VARCHAR(MAX),@ReferenceNo VARCHAR(MAX)
		 EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
			
		
		DECLARE @SupplierTable TABLE 
		(SupplierName VARCHAR(MAX),
		 SupplierID INT
		)

		DECLARE @UnitMaster TABLE
		(
		UnitName VARCHAR(MAX),
		UnitID INT
		)
		
		DECLARE @StockItem TABLE 
		(
		 ItemName VARCHAR(MAX),
		 StockItemID INT,
		 PLUCODE VARCHAR(MAX),
		 UnitName VARCHAR(MAX),
		 ItemID INT,
		 UnitID INT,
		 CategoryID INT,
		 UnitPrice DECIMAL(18,6),
		 Qty DECIMAL(18,6),
		 SubCategoryId	INT
		)

		DECLARE @GRNStockItem TABLE 
		(
		 ItemName VARCHAR(MAX),
		 StockItemID INT,
		 PLUCODE VARCHAR(MAX),
		 UnitName VARCHAR(MAX),
		 ItemID INT,
		 UnitID INT,
		 CategoryID INT,
		 UnitPrice DECIMAL(18,6),
		 Qty DECIMAL(18,6),
		 SubCategoryId INT
		)

		SELECT @UserID = @XMLDetails.value('(/FloodReliefGRN/Header/CurrentUser)[1]', 'VARCHAR(MAX)')
		SELECT @PropertyID = @XMLDetails.value('(/FloodReliefGRN/Header/Company)[1]', 'VARCHAR(MAX)')
		SELECT @LocationID = @XMLDetails.value('(/FloodReliefGRN/Header/Location)[1]', 'VARCHAR(MAX)')
		SELECT @Remark = @XMLDetails.value('(/FloodReliefGRN/Header/Remarks)[1]', 'VARCHAR(MAX)')
		SELECT @ReferenceNo = @XMLDetails.value('(/FloodReliefGRN/Header/ReferenceNo)[1]', 'VARCHAR(MAX)')

		-- Insert into @SupplierTable
		INSERT INTO @SupplierTable (SupplierName, SupplierID)
		SELECT 
			Supplier = @XMLDetails.value('(/FloodReliefGRN/Header/Supplier)[1]', 'VARCHAR(MAX)'),
			SupplierID = @XMLDetails.value('(/FloodReliefGRN/Header/SupplierId)[1]', 'VARCHAR(MAX)') -- You can modify this based on your actual ID mapping

		-- Insert into @UnitMaster from items
		;WITH Units AS (
			SELECT DISTINCT
				UnitName = Item.value('(UnitName)[1]', 'VARCHAR(MAX)'),
				UnitID = Item.value('(UnitId)[1]', 'VARCHAR(MAX)') ---888 -- You can modify this based on your actual ID mapping
			FROM @XMLDetails.nodes('/FloodReliefGRN/Items/Item') AS T(Item)
		)
		INSERT INTO @UnitMaster (UnitName, UnitID)
		SELECT UnitName, UnitID FROM Units;

		-- Insert into @StockItem
		INSERT INTO @StockItem (ItemName, StockItemID, PLUCODE, UnitName, ItemID, UnitID, CategoryID, UnitPrice,Qty,SubCategoryId)
		SELECT
			ItemName = Item.value('(ItemText)[1]', 'VARCHAR(MAX)'),
			StockItemID = -888, -- You can modify this based on your actual ID mapping
			PLUCODE = Item.value('(AccName)[1]', 'VARCHAR(MAX)'),
			UnitName = Item.value('(UnitName)[1]', 'VARCHAR(MAX)'),
			ItemID = -888, -- You can modify this based on your actual ID mapping
			UnitID = isnull((Item.value('(UnitId)[1]', 'BIGINT')),-888),
			CategoryID = isnull((Item.value('(CategoryId)[1]', 'BIGINT')),-888),
			UnitPrice = Item.value('(UnitPrice)[1]', 'DECIMAL(18,6)'),
			ReceivedQuantity = Item.value('(ReceivedQuantity)[1]', 'DECIMAL(18,6)'),
			SubCategoryId = isnull((Item.value('(SubCategoryId)[1]', 'BIGINT')),-888)
		FROM @XMLDetails.nodes('/FloodReliefGRN/Items/Item') AS T(Item);


		INSERT INTO @GRNStockItem (ItemName, StockItemID, PLUCODE, UnitName, ItemID, UnitID, CategoryID, UnitPrice,Qty,SubCategoryId)
		SELECT
			ItemName = Item.value('(ItemText)[1]', 'VARCHAR(MAX)'),
			StockItemID = -888, -- You can modify this based on your actual ID mapping
			PLUCODE = Item.value('(AccName)[1]', 'VARCHAR(MAX)'),
			UnitName = Item.value('(UnitName)[1]', 'VARCHAR(MAX)'),
			ItemID = -888, -- You can modify this based on your actual ID mapping
			UnitID = isnull((Item.value('(UnitId)[1]', 'BIGINT')),-888),
			CategoryID = isnull((Item.value('(CategoryId)[1]', 'BIGINT')),-888),
			UnitPrice = Item.value('(UnitPrice)[1]', 'DECIMAL(18,6)'),
			ReceivedQuantity = Item.value('(ReceivedQuantity)[1]', 'DECIMAL(18,6)'),
			SubCategoryId = isnull((Item.value('(SubCategoryId)[1]', 'BIGINT')),-888)
		FROM @XMLDetails.nodes('/FloodReliefGRN/Items/Item') AS T(Item);

		UPDATE O
		SET O.StockItemID = h.Id,O.ItemID = h.Id
		FROM @GRNStockItem O INNER JOIN StockItemHeaders H ON O.PLUCODE = H.PLUCode

		UPDATE O
		SET O.StockItemID = h.Id,O.ItemID = h.Id
		FROM @StockItem O INNER JOIN StockItemHeaders H ON O.PLUCODE = H.PLUCode

	

		DECLARE  @Prefix VARCHAR(20) = 'SC', @Result VARCHAR(200), @IsAutoGen BIT,@Code nvarchar(100),@SupplierName VARCHAR(MAX),@SupplierID INT

		SELECT TOP (1) @SupplierName  =SupplierName,@SupplierID = SupplierID
		FROM @SupplierTable
		
		IF(@SupplierID = -888)
		BEGIN
			EXEC [dbo].[SP_AutoGenerateSupplierCode] @Prefix, 0,@Code OUTPUT

			IF EXISTS (SELECT 1 FROM Suppliers WHERE NAME = @SupplierName)
			BEGIN
				SET @InvError =  'Already Inserted Supplier Found For'+ ' '+@SupplierName
				RAISERROR ( @InvError, 16, 1 );  
				ROLLBACK TRANSACTION

			END

			INSERT INTO Suppliers(PropertyID, Code, Name, Address1, BillingAddress, Email, Telephone1, Telephone2, FaxNo, ContactPerson, CountryID,
			Remarks, CreditLimit, CreditPeriod, PaymentTermID, CurrencyID, NameOnCheque, SupplierGradingID, 
					  IsDefaultSupplier, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IsLabor, IsForeign, VatNo, BSPCODE,
					  AccountNo, GracePeriod, DefaultPaymentType, BankCode, BranchCode, CommissionAcc, DeductionControl, CreditorTypeID,
					  IsConsigments, IsPettyCash, EvaluationTemplateID, EvaluationCriteriaRangeID, SupplierCategoryID, Email2)
		
			SELECT 0 PropertyID,@Code Code,@SupplierName Name,'N/A' Address1,'N/A' BillingAddress,NULL Email,'0000000000' Telephone1,'0000000000' Telephone2, 
			NULL FaxNo,NULL ContactPerson,0 CountryID,NULL Remarks,0 CreditLimit,0 CreditPeriod,0 PaymentTermID,86 CurrencyID,@SupplierName NameOnCheque,
			0 SupplierGradingID, 0     IsDefaultSupplier,1 IsActive,'192.168.0.1' IPAddress,@UserID CreatedUserID,@UserID LastModUserID,GETDATE() CreatedDate
			,GETDATE() LastModDate,0 IsLabor,0 IsForeign,0 VatNo,NULL BSPCODE,0 AccountNo,0 GracePeriod,0 DefaultPaymentType,0 BankCode,0 BranchCode,0 CommissionAcc, 
			0  DeductionControl,1 CreditorTypeID,0 IsConsigments,0 IsPettyCash,0 EvaluationTemplateID,0 EvaluationCriteriaRangeID,0 SupplierCategoryID,NULL Email2

			SET @NewSupplierID = SCOPE_IDENTITY();

			EXEC Inventry_AuditTail_WriteToLog 'Suppliers', @NewSupplierID, 'INV', 'SUI', 'I', @UserID,@PropertyID, '', ''


		END
		ELSE
		BEGIN
			SET @NewSupplierID = @SupplierID
		END
		--End


		--Inserting Unit Master TABLE
		

		DECLARE @UnitName VARCHAR(MAX),@UnitID INT,@NewUnitID INT

		WHILE EXISTS(SELECT 1 FROM @UnitMaster)
		BEGIN

		SELECT TOP (1) @UnitName =UnitName,@UnitID = UnitID
		FROM @UnitMaster

		IF(@UnitID = -888)
		BEGIN
			IF NOT EXISTS(SELECT 1 FROM Units WHERE NAME = @UnitName)
			BEGIN
			INSERT INTO Units(LocationID, Code, Name, IsActive, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, CompanyId)
			SELECT 0 LocationID,SUBSTRING(@UnitName, 1, 3) AS Code,@UnitName Name,1 IsActive,'192.168.0.1' IPAddress,@UserID CreatedUserID,0 LastModUserID,
			GETDATE() CreatedDate,GETDATE() LastModDate,@PropertyID CompanyId
			
			SET @NewUnitID = SCOPE_IDENTITY();

			EXEC Inventry_AuditTail_WriteToLog 'Units', @NewUnitID, 'INV', 'UNI', 'I', @UserID,@PropertyID, '', ''	

			END
			ELSE
			BEGIN
				SELECT TOP (1)  @NewUnitID= ID
				FROM Units 
				WHERE NAME = @UnitName

			END
		END
		DELETE TOP (1) FROM @UnitMaster

		END
		--END

		--Inserting Stock Item Header and Details
		

		DECLARE @ItemName VARCHAR(MAX),@StockItemID INT,@PLUCODE VARCHAR(MAX),@ItemUnitName VARCHAR(MAX),@ItemID INT,@ItemUnitID INT,@CategoryID INT
		,@SubCategoryId INT
		,@UnitPrice DECIMAL(18,6)


		DECLARE @AutoStockItemCodeNo VARCHAR(MAX),@SubPrefix VARCHAR(10),@CatCount int,@SubPrefix2 VARCHAR(10)
		,@SubCategory2IDForCode INT,@SerialLength INT,@Suffix VARCHAR(MAX),@Serial INT
		,@CodeLength INT,@AutoStockItemProcessCode VARCHAR(5),	@ProductCode VARCHAR(MAX),@ProductCodeLength INT,@TaxGroupID INT

		DECLARE @NewStockItemHeaderID INT

		SELECT @AutoStockItemProcessCode = ISNULL(AutoStockItemProcessCode,'S')
		FROM dbo.Companies 
		WHERE CompanyID= @PropertyID

		WHILE EXISTS(SELECT 1 FROM @StockItem)
		BEGIN
		SELECT TOP (1) @ItemName = ItemName,@StockItemID = StockItemID,@PLUCODE = PLUCODE,@ItemUnitName = UnitName
		,@ItemID = ItemID , @ItemUnitID = UnitID,@CategoryID = CategoryID,@UnitPrice = UnitPrice
		,@SubCategoryId = SubCategoryId
		FROM @StockItem

		IF(@ItemID = -888)
		BEGIN

			SELECT TOP (1) @SubCategory2IDForCode = SubCategory2ID,@TaxGroupID = TaxGroupID
			FROM CUSDEC_Transactions_Settings

			SELECT TOP (1) @SubPrefix = Code
			FROM SubCategories
			WHERE   Id = @SubCategoryId

			SELECT TOP (1) @SubPrefix2=CODE
			FROM SubCategories02
			WHERE   Id = @SubCategory2IDForCode

			
			SELECT @Prefix=Prefix,@SerialLength=SerialLength,@Suffix=Suffix,@Serial=serial,@CodeLength=codelength 
			FROM dbo.Categories WHERE Id=@CategoryID

			--Auto Stock Item Code generate
			IF(@AutoStockItemProcessCode = 'C') -- If Category Only
			BEGIN
				SET @Serial= @Serial +1

				UPDATE dbo.Categories SET serial= @Serial WHERE Id=@CategoryID

				SET @ProductCode = @Prefix+'/'+RIGHT('0000000'+ CONVERT(VARCHAR(MAX),@Serial),@SerialLength)+@Suffix

				SET @ProductCodeLength= LEN(@ProductCode)

			END

			IF(@AutoStockItemProcessCode = 'S') -- If Category + Sub Category
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


					UPDATE AutoStockItemCodeCombination
					SET NextNumber = NextNumber+1
					WHERE PrefixCombination = @AutoStockItemCodeNo
			END

			IF(@AutoStockItemProcessCode = 'CS') -- If Category + Sub Category + Sub Category2
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

				UPDATE AutoStockItemCodeCombination
				SET NextNumber = NextNumber+1
				WHERE PrefixCombination = @AutoStockItemCodeNo
			END
			
			--End

			IF EXISTS(SELECT 1 FROM StockItemHeaders WHERE NAME = @ItemName AND CompanyId  =@PropertyID)
			BEGIN
				SET @InvError =  'Already Inserted Item Found For '+ ' '+@ItemName
				RAISERROR ( @InvError, 16, 1 );  
				ROLLBACK TRANSACTION
			END

			INSERT INTO StockItemHeaders(CompanyId, LocationId, StockItemCode, PLUCode, ReferanceCode, Barcode, Name, NameOnInvoice, ImageUrl, CategoryID, SubCategoryID, SupplierID, TaxGroupID, CostingMethod, Remarks, 
                  IsExpiryDateApplicable, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, SubCategory2ID, IsPriceEditable, MaintainPriceHistory, Isbundle, BrandedItem, GenericItemCode, IsMultiplePrices, IsMultipleBarcode, 
                  IsAllowDiscount, IsFractionItem, IsSerialNo, IsAllowReturnItem, IsOpenPrice, ChargeHeaderID, IsSellingItem, ERPReferenceCode, IsProductionItem)
			
			SELECT @PropertyID CompanyId,0 LocationId,@ProductCode StockItemCode,@PLUCODE PLUCode,0 ReferanceCode,0 Barcode,@ItemName Name,@ItemName NameOnInvoice,
			'sdsdsd' ImageUrl,@CategoryID CategoryID,@SubCategoryId SubCategoryID,0 SupplierID,@TaxGroupID TaxGroupID, 
			1 CostingMethod,NULL Remarks,0 IsExpiryDateApplicable,'192.168.0.1' IPAddress,@UserID CreatedUserID,0 LastModUserID,GETDATE() CreatedDate,GETDATE() LastModDate,
		 @SubCategory2IDForCode	SubCategory2ID,0 IsPriceEditable,0 MaintainPriceHistory,0 Isbundle,0 BrandedItem,NULL GenericItemCode,0 IsMultiplePrices,0 IsMultipleBarcode, 
         0 IsAllowDiscount,0 IsFractionItem,0 IsSerialNo,0 IsAllowReturnItem,0 IsOpenPrice,0 ChargeHeaderID,0 IsSellingItem,0 ERPReferenceCode,0 IsProductionItem

		SET @NewStockItemHeaderID = SCOPE_IDENTITY();

		EXEC Inventry_AuditTail_WriteToLog 'StockItemHeaders', @NewStockItemHeaderID, 'INV', 'SIHI', 'I', @UserID,@PropertyID, '', ''

		UPDATE StockItemHeaders
        SET CategoryID = 15
        WHERE Id = @NewStockItemHeaderID and ISNULL(CategoryID,0) = 0


		INSERT INTO [dbo].[HSItem]
           ([HSCode]
           ,[HSName])
		VALUES
           (@PLUCODE
           ,@ItemName)

		--Item DEtail Insert


		IF(@ItemUnitID = -888)
		BEGIN
			SELECT TOP (1) @ItemUnitID = ID
			FROM Units
			WHERE NAME  = @ItemUnitName

		END

		IF OBJECT_ID(N'tempdb..#TempLk') IS NOT NULL
        BEGIN
			DROP TABLE #TempLk
        END
        
		select LocationID
        INTO #TempLk
        from StockItemDetails
        WHERE StockItemHeaderID = @NewStockItemHeaderID
		
		INSERT INTO StockItemDetails(PropertyID, CompanyID, LocationID, StockItemHeaderID, MasterUnitID, PurchasingUnitID, MinimumQuantity, MaximumQuantity, ReOrderLevel, ReOrderQuantity, ReOrderPeriod, PurchaseAccountID, 
                  CostOfSalesAccountID, AveragePrice, SellingPrice, WholesalePrice, IsActive, ReportingUnitID, QuantityInHand, StockItemId, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, BatchNo, ProfitMargin, ItemAge)
		
		SELECT @PropertyID PropertyID,@PropertyID CompanyID,L.Id AS LocationID,@NewStockItemHeaderID StockItemHeaderID,@ItemUnitID MasterUnitID,0 PurchasingUnitID,
		0 MinimumQuantity,0 MaximumQuantity,0 ReOrderLevel,0 ReOrderQuantity,0 ReOrderPeriod,0 PurchaseAccountID, 
        0 CostOfSalesAccountID,0 AveragePrice,0 SellingPrice,0 WholesalePrice,1 IsActive,1 ReportingUnitID,0 QuantityInHand,@NewStockItemHeaderID StockItemId,
		'192.168.0.1' IPAddress,@UserID CreatedUserID,0 LastModUserID,GETDATE() CreatedDate,GETDATE() LastModDate,NULL BatchNo,0 ProfitMargin,0 ItemAge
		FROM Locations L
		WHERE L.IsActive = 1 AND L.Id not in (select LocationID from #TempLk)

		IF OBJECT_ID(N'tempdb..#TempLk') IS NOT NULL
		BEGIN
			DROP TABLE #TempLk
		END

		DELETE FROM [DepartmentWiseItems] WHERE [StockItemId] = @NewStockItemHeaderID

		INSERT INTO [dbo].[DepartmentWiseItems]
           ([DepartmentId]
           ,[StockItemId])
        SELECT D.Id,@NewStockItemHeaderID FROM Departments D 

		--ENd

		END
		ELSE
		BEGIN

		    SET @NewStockItemHeaderID = @StockItemID;

			IF NOT EXISTS(SELECT 1 FROM StockItemDetails WHERE StockItemHeaderID = @StockItemID AND LocationID = @LocationID )
			BEGIN
				IF(@ItemUnitID = -888)
				BEGIN
					SELECT TOP (1) @ItemUnitID = ID
					FROM Units
					WHERE NAME  = @ItemUnitName
				END

				

				IF(@NewStockItemHeaderID <1)
				BEGIN
					SET @InvError =  'Item details not Found for'+ ' '+@ItemName
					RAISERROR ( @InvError, 16, 1 );  
					ROLLBACK TRANSACTION
				END

				INSERT INTO StockItemDetails(PropertyID, CompanyID, LocationID, StockItemHeaderID, MasterUnitID, PurchasingUnitID, MinimumQuantity, MaximumQuantity, ReOrderLevel, ReOrderQuantity, ReOrderPeriod, PurchaseAccountID, 
                  CostOfSalesAccountID, AveragePrice, SellingPrice, WholesalePrice, IsActive, ReportingUnitID, QuantityInHand, StockItemId, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, BatchNo, ProfitMargin, ItemAge)
				SELECT @PropertyID PropertyID,@PropertyID CompanyID,@LocationID LocationID,@StockItemID StockItemHeaderID,@ItemUnitID MasterUnitID,0 PurchasingUnitID,
				0 MinimumQuantity,0 MaximumQuantity,0 ReOrderLevel,0 ReOrderQuantity,0 ReOrderPeriod,0 PurchaseAccountID, 
				0 CostOfSalesAccountID,0 AveragePrice,0 SellingPrice,0 WholesalePrice,1 IsActive,1 ReportingUnitID,0 QuantityInHand,@StockItemID StockItemId,
				'192.168.0.1' IPAddress,@UserID CreatedUserID,0 LastModUserID,GETDATE() CreatedDate,GETDATE() LastModDate,NULL BatchNo,0 ProfitMargin,0 ItemAge

			END

		END


		--Inserting into Supplier wise item table

	
			IF NOT EXISTS(SELECT 1 FROM SupplierWiseItemDetails WHERE StockItemID = @NewStockItemHeaderID AND LocationID = @LocationID AND SupplierID = @NewSupplierID)
			BEGIN

			 IF(@ItemUnitID = -888)
						BEGIN
							SELECT TOP (1) @ItemUnitID = ID
							FROM Units
							WHERE NAME  = @ItemUnitName
						END
						INSERT INTO SupplierWiseItemDetails(CompanyId, LocationId, SupplierID, StockItemID, PurchaseUnitID, CostPrice, IsDefaultSupplier, CreatedUserID, LastModUserID, CreatedDate, LastModDate, IPAddress, TBPHeaderID, TaxGroupID, Validfrom, 
								  ValidTo, IsContractedSupplier, IsQuotation, QuotationStatus)
		
						SELECT @PropertyID CompanyId,@LocationID LocationId,@NewSupplierID SupplierID,@NewStockItemHeaderID StockItemID,@ItemUnitID PurchaseUnitID,@UnitPrice CostPrice,
						0 IsDefaultSupplier,@UserID CreatedUserID,0 LastModUserID,GETDATE() CreatedDate,GETDATE() LastModDate,'192.168.0.1' IPAddress,0 TBPHeaderID,@TaxGroupID TaxGroupID,
						NULL Validfrom,NULL ValidTo,0 IsContractedSupplier,0 IsQuotation,'N' QuotationStatus

			END


			

		--Inserting into Supplier wise item table END

		DELETE TOP (1) FROM @StockItem

		END
		

		--End


		-- GRN INSERT
		--SELECT * FROM @GRNStockItem

		SELECT GETDATE() AS TxnDate,@PropertyID AS PropertyID,@LocationID AS LocationID,H.Id AS StockItemID, I.AveragePrice  AveragePrice, 
			K.Qty AS Quantity, 
				I.MasterUnitID TxnUnitID, 0 AS DepartmentID,K.UnitPrice
		INTO	#tempGRNData
		FROM	@GRNStockItem K
				INNER JOIN StockItemHeaders H ON K.PLUCODE = H.PLUCode
				INNER JOIN StockItemdetails I ON H.Id= I.StockItemHeaderID 
		WHERE	I.LocationID = @LocationID

		DECLARE @StockTransactionHeader XML 
		DECLARE @StockDetailList XML
	

		
			SET @StockTransactionHeader= (
			SELECT		TOP 1
			            @NewSupplierID AS SupplierID,
						@ReferenceNo AS ReferenceNo,
						@UserID AS UserProfileID,
						@UserID AS CreatedUserID,
						'D'Mode,
						'' DocumentNo,
						'GR' TransactionType,
						TxnDate TransactionDate,
						LocationID,
						PropertyID,
						0 SupplierID,
						'GRN' Remarks,
						0 ReferenceID,
						DepartmentID,
						0 UserProfileID,
						0 TransferLocationID,
						9 TransactionID,
						0 SuppCurrencyID,
						0 ExchangeRate,
						@UserID CreatedUserID,
						@UserID LastModUserID,
						GETDATE() CreatedDate,
						GETDATE() LastModDate,
						'' StockDetailList
			FROM #tempGRNData
			WHERE LocationId = @LocationId
			FOR XML PATH('StockTransactionHeader')
			)

			SET @StockDetailList =(
				SELECT		1 StockTransactionHeaderID,
					StockItemID,
					SUM(Quantity) Quantity,
					AVG(UnitPrice) UnitPrice,
					TxnUnitID,
					TxnUnitID MasterUnitID,
					1 MasterUnitConversion,
					1 ReportUnitID,
					1 ReportUnitConversion,
					0 DiscountValue,
					0 DiscountPercentage,
					0 StockMasterQuantity,
					AVG(AveragePrice) StockMasterAveragePrice,
					0 NewQuantity,
					AVG(AveragePrice) NewAveragePrice,
					'GRN' AS Remarks,
					0 UserProfileId,
					1 CostTransactionAccountID,
					1 PurchaseTransactionAccountID,
					'P' TxnType,
					0 ItemUnitPriceInSuppCurrency,
					0 BalanceQuantity,
					0 ReturnQuantity,
					0 CreatedUserID,
					0 LastModUserID,
					GETDATE() CreatedDate,
					GETDATE() LastModDate 
				FROM #tempGRNData
				WHERE LocationId = @LocationId

				GROUP BY StockItemID,TxnUnitID, AveragePrice
				FOR XML PATH('StockTransactionDetail'))

		
			DECLARE @FinalXml XML 
			SET  @FinalXml= CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX),@StockTransactionHeader),'<StockDetailList/>',
			'<StockDetailList>'+CONVERT(VARCHAR(MAX),@StockDetailList)+'</StockDetailList>'))


			DELETE FROM #tempGRNData 
			WHERE LocationId = @LocationId
			--SELECT @FinalXml AS AA
			exec [dbo].SP_InsertStockTransactions  @FinalXml,@docno OUTPUT,0,'',@headerid OUTPUT

			SELECT @docno, @headerid

		-- GRN INSERT
					
					
					
					
	
	COMMIT TRAN; -- Transaction Success!
    END TRY

    BEGIN CATCH

	
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	
    END CATCH;
	
END;

GO

