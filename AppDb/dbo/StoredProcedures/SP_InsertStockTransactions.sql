
-- [dbo].[SP_InsertStockTransactions] '',0,'',0,0,0,'',0

CREATE PROCEDURE [dbo].[SP_InsertStockTransactions]
(
    @XMLDetails XML,
    @docno VARCHAR(MAX) OUTPUT,
    @status INT OUTPUT,
    @message VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT,
	@SkipApproval BIT = 0,
	@SkipBeginCommit BIT =0,
	@TempBulkDocNoJson NVARCHAR(MAX) = '' OUTPUT,  ----------Added by Nivesh 2025-11-07--------------
	@IsApprovalEnable BIT =0 OUTPUT
)
AS
SET XACT_ABORT ON; --added by isuru 2026-10-02 Reason: roll back at once on timeout/error, no open transaction left holding locks
DECLARE @statusIN [INT];
SET @statusIN = 1;
SET @message = '';

SET NOCOUNT ON;
DECLARE @trancount INT;
SET @trancount = @@trancount;
SET @IsApprovalEnable =0
--Added by Isuru 2023-9-20
DECLARE @tempStockTranId INT

--End

--select @XMLDetails xmlD into AADATA
--SELECT * FROM AADATA


insert into tempStockTran (XmlDATA)
select convert(varchar(max),  @XMLDetails) 

SET @tempStockTranId = SCOPE_IDENTITY();

--select top(1)@tempStockTranId= ID 
--from tempStockTran
--order by ID desc

BEGIN
    BEGIN TRY 

 
		----------Added by Nivesh 2025-11-07--------------
		DECLARE @TempBulkDocNo TABLE(
			Id INT,
			DocNo NVARCHAR(100)
		)
		---------------------------------------------------

 		CREATE TABLE #TempAllDetails(
		[StockTransactionHeaderID] [int] ,
		[StockItemID] [int] ,
		[Quantity] [decimal](18, 6) ,
		[UnitPrice] [decimal](18, 6) ,
		[TxnUnitID] [int] ,
		[MasterUnitID] [int] ,
		[MasterUnitConversion] [decimal](18, 6) ,
		[ReportUnitID] [int] ,
		[ReportUnitConversion] [decimal](18, 6) ,
		[DiscountValue] [decimal](18, 6) ,
		[DiscountPercentage] [decimal](18, 6) ,
		[TimeStamp] [nvarchar](256) ,
		[StockMasterQuantity] [decimal](18, 6) ,
		[StockMasterAveragePrice] [decimal](18, 6) ,
		[NewQuantity] [decimal](18, 6) ,
		[NewAveragePrice] [decimal](18, 6) ,
		[Remarks] [nvarchar](max) ,
		[UserProfileId] [int] ,
		[CostTransactionAccountID] [int] ,
		[PurchaseTransactionAccountID] [int] ,
		[TxnType] [nvarchar](1) ,
		[BalanceQuantity] [decimal](18, 6) ,
		[ReturnQuantity] [decimal](18, 6) ,
		[ItemUnitPriceInSuppCurrency] [decimal](18, 6),
		[IPAddress] [nvarchar](max) ,
		[CreatedUserID] [int] ,
		[LastModUserID] [int] ,
		[CreatedDate] [datetime] ,
		[LastModDate] [datetime] ,
		[TBPHeaderId] [int] ,
		[Isserialadded] [bit] ,
		[SkipGL] [bit] ,
		[BalVal] [decimal](38, 8) ,
		[AccName] [nvarchar](250) ,
		[RequestedGenericItemId] [int] ,
		[PhysicalQuantity] [int] ,
		IssuedQuantity DECIMAL(18,6),
		[SellingPrice] [decimal](18, 6),
		[SelectedCUSDECID] [int] -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
		)

		CREATE TABLE #TempStockTransactionHeader(
		[DocumentNo] [nvarchar](20) ,
		[TransactionType] [nvarchar](2) ,
		[TransactionDate] [date] ,
		[PropertyID] [int] ,
		[LocationID] [int] ,
		[ReferenceNo] [nvarchar](200) ,
		[SupplierID] [int] ,
		[Remarks] [nvarchar](MAX) ,
		[ReferenceID] [int] ,
		[DepartmentID] [int] ,
		[UserProfileID] [int] ,
		[TransferLocationID] [int] ,
		[TimeStamp] [nvarchar](256) ,
		[TransactionID] [int] ,
		[Mode] [nvarchar](1) ,
		[SuppCurrencyID] [int] ,
		[ExchangeRate] [decimal](18, 2) ,
		[IPAddress] [nvarchar](max) ,
		[CreatedUserID] [int] ,
		[LastModUserID] [int] ,
		[CreatedDate] [datetime] ,
		[LastModDate] [datetime] ,
		[IsPrint] [bit] ,
		[IsApproved] [bit] ,
		[IsTrasferIn] [bit] ,
		[InvoiceDate] [datetime] ,
		[GLDATE] [date] ,
		[IsDirectIssue] [bit] ,
		[GRNTypeID] [int] ,
		[BudgetID] [int] ,
		[PaidAmount] [decimal](18, 8) ,
		[SendMail] [bit] ,
		[IsProdGenerate] [bit] ,	
		[IsProductionPlan] BIT,
		[FileName] VARCHAR(MAX),
		[PaxCount] DECIMAL(8,2) NULL,
		[SubstractNetValue] DECIMAL(18,2) DEFAULT 0,
		[IsAutoTrasferGRN] BIT DEFAULT 0 --For identify auto transfer GRN - Added by Nivesh 2025-11-07
		,[InvoiceLocationID] INT DEFAULT 0
		
		 ,[IsInvoiceBasedTransaction] BIT DEFAULT 0
		 ,[InvoiceDueDate] [datetime] NULL --Added by Tharuka 2026-08-18
		)

		CREATE TABLE #TempStockItemWiseEXPDateIns(
		[PropertyID] [int] ,
		[LocationID] [int] ,
		[TransactionID] [nvarchar](max) ,
		[TransactionType] [nvarchar](max) ,
		[StockItemID] [bigint] ,
		[Quantity] [decimal](18, 8) ,
		[BalanceQuantity] [decimal](18, 8) ,
		[EXPDate] [datetime] ,
		[LogDate] [datetime] ,
		[BatchNo] [varchar](200) ,
		[TxnUnitID] [int] ,
		[StockMasterQty] [decimal](18, 8) ,
		[TransactionDate] [date] ,
		[MasterUnitID] [int] ,
		[PhysicalQty] [decimal](18, 8) ,
		[TxnType] [nvarchar](1) ,
		[SellingPrice] DECIMAL(18,8)
		)

		CREATE TABLE #TempStockItemWiseTemperature(
		[PropertyID] [int] ,
		[LocationID] [int] ,
		[TransactonID] [int] ,
		[TransactionType] [nvarchar](10) ,
		[StockItemID] [int] ,
		[Quantity] [decimal](18, 6) ,
		[Temperature] [decimal](18, 6) ,
		[LogDate] [datetime] ,
		[TypeId] [int] 
		)

		CREATE TABLE #TempStockTransactionwiseCharges(
		[StockTransactionwiseChangesID] [bigint] ,
		[StockTransactionHeaderID] [bigint] ,
		[AdditionalChargeID] [bigint] ,
		[ChargeAmount] [decimal](18, 2) ,
		[AddedToItemCost] [bit] ,
		)

		CREATE TABLE #StockItemWiseEXPDateIns(
		ID INT,
		StockItemID BIGINT,
		Quantity DECIMAL(18,2),
		EXPDate DATETIME,
		BatchNo VARCHAR(200),
		SellingPrice DECIMAL(18,8)
		)

		CREATE TABLE #TempContractSupplier(
		StockItemID	INT,
		UnitPrice DECIMAL(18,6),
		RequestedQuantity FLOAT,
		ContractSupplierReason VARCHAR(MAX),
		ContractSupplierPrice DECIMAL(18, 6),
		ContractSupplierID INT
	)

		IF(@SkipBeginCommit = 0)
		-- IF(@SkipBeginCommit = 0 AND XACT_STATE() <> 0)   commented by Tharuka 2026-09-14 
		BEGIN
		 BEGIN TRANSACTION; 
		END

        INSERT INTO Inputpara
        (
            xmldata
        )
        VALUES
        (@XMLDetails);

        SET DATEFORMAT MDY;
        DECLARE @iDocID INT;
		DECLARE @BadUnitItems VARCHAR(MAX);
        DECLARE @addtionalCostPre DECIMAL(18,6)
        DECLARE @addtionalCostTotal DECIMAL(18,6) =0,
				@addtionalCostAddToCostTrue DECIMAL(18,6) =0, --ADDED BY ISURU
				@addtionalCostAddToCostFalse DECIMAL(18,6)=0, --ADDED BY ISURU
                @txnDate DATETIME,
				@txnDateFromFront DATETIME,
				@SubstractNetValue DECIMAL(18,2),
				@IsSubstractNetTotal BIT = 0,
				@DepartmentID INT,
				@IsInvoiceBasedTransaction BIT;


        SET @addtionalCostPre = 0;
        SET @addtionalCostTotal = 0;


		--RAISERROR ('test error', 16, 1 );  
		--		ROLLBACK TRANSACTION


        DECLARE @TransactionType CHAR(2),
                @DocumentNo VARCHAR(MAX),
                @StockTransactionHeaderID BIGINT,
                @PropertyID INT,
                @unitID INT,
                @LocationID INT,
                @Quantity DECIMAL(18,6),
                @AveragePrice DECIMAL(18,6),
                @StockItemID BIGINT,
                @unitPrice DECIMAL(18,6),
                @ReferenceID BIGINT,
                @TxnType CHAR(1),
                @StockTransactionDetailID BIGINT,
                @Qty DECIMAL(18,6),
                @ItemTotal DECIMAL(18,6),
                @Mode CHAR(1),
				@TransferLocationID INT,
				@SupplierID INT,
				@IsApproval BIT,
				@CreatedUserId INT,
				@IsApprovalForIssueReturn BIT,
				@ReferenceNo VARCHAR(500),
				@StockID INT,
				@ConversionRate INT -- Added by Isuru 2023-08-22
				,@StockReconciliationIsApproval BIT =0 --Added by Nivesh 2024-03-01
				,@IsAutoTransferGRN BIT=0,
				@IsGRNTransactionApproval bit = 0, -- added by vinuki 2024.06.12
				@StockTransactionHeaderQuantity decimal(18,6) = 0,
				@IsSRNTransactionApproval bit = 0, -- added by vinuki 2024.06.18
				@GRNTypeID INT =0,
				@BudgetID INT ,
				@GRNTotal DECIMAL(18,8),
				@IsBudgetGRN BIT=0,
				@BalanceBudget MONEY,
				@RecipeItemID INT,
				@RecipeQuantity DECIMAL(18,8),
				@RecipeQuantityVariance DECIMAL(18,8),
				@RecipeUnitID INT,
				@IsAutoProduction BIT,
				@IsMailNotification BIT,
				@RecipeTransactionDate DATETIME,
				@IsProdGenerate BIT
				,@IsGLEnabled BIT =1 --Added by Isuru 2025-01-01 for validating Locationwise GL Connect
			  , @AveragePrice2 DECIMAL(18,6)
			   ,@IsReconBackDateEnable BIT =1
			   ,@IsReconMandatory BIT =0
			   ,@IsOnlyOneReconPerDay BIT =0
			   ,@BackdateDayCountWhenBackDateDisable INT
			   ,@IsContractedSupplier bit
			   ,@IsProductionPlan BIT,
			   @IsModifyTransferIn BIT,
			   @FileName VARCHAR(MAX),
			   @DisplayOriginalTRQty BIT,
			   @TransferNoteIsApproval BIT =0 --Added by Isuru 2025-12-10
			   ,@POLocationID INT
			   ,@IsLocationWiseDayendEnable BIT

        CREATE TABLE #ItemList
        (
            StockItemID BIGINT,
            Quantity DECIMAL(18,6),
            TxnUnitID INT,
            UnitPrice DECIMAL(18,6),
            TxnType CHAR(1),
			BrandedItem BIT,
			GenericCode VARCHAR(150),
			StockItemCode VARCHAR(150),
			DiscountValue DECIMAL(18,6),
			DiscountPercentage DECIMAL(18,6),
			MasterUnitID INT,
			SellingPrice MONEY -- Added by Uditha 2025-06-26 For Invoice Module
        );

	--IF OBJECT_ID('tempdb..#TaxTableSRN') IS NOT NULL
	--BEGIN
	--DROP TABLE #TaxTableSRN
	--END
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
  --------Added 15/02/2022--------------------

 			INSERT INTO #TempAllDetails (
				[StockTransactionHeaderID]  ,
				[StockItemID] ,
				[Quantity]  ,
				[UnitPrice]  ,
				[TxnUnitID]  ,
				[MasterUnitID] ,
				[MasterUnitConversion]  ,
				[ReportUnitID]  ,
				[ReportUnitConversion] ,
				[DiscountValue]  ,
				[DiscountPercentage]  ,
				[TimeStamp] ,
				[StockMasterQuantity]  ,
				[StockMasterAveragePrice]  ,
				[NewQuantity] ,
				[NewAveragePrice]  ,
				[Remarks]  ,
				[UserProfileId] ,
				[CostTransactionAccountID] ,
				[PurchaseTransactionAccountID]  ,
				[TxnType] ,
				[BalanceQuantity]  ,
				[ReturnQuantity]  ,
				[ItemUnitPriceInSuppCurrency],
				[IPAddress],
				[CreatedUserID],
				[LastModUserID]  ,
				[CreatedDate]  ,
				[LastModDate]  ,
				[TBPHeaderId] ,
				[Isserialadded],
				[SkipGL],
				[BalVal] ,
				[AccName] ,
				[RequestedGenericItemId] ,
				[PhysicalQuantity] ,
				[IssuedQuantity],
				[SellingPrice] -- Add by Uditha 2025-06-26 For Invoice Module
				,[SelectedCUSDECID] -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
			)
			SELECT 
				[StockTransactionHeaderID]  ,
				[StockItemID] ,
				[Quantity]  ,
				[UnitPrice]  ,
				[TxnUnitID]  ,
				[MasterUnitID] ,
				[MasterUnitConversion]  ,
				[ReportUnitID]  ,
				[ReportUnitConversion] ,
				[DiscountValue]  ,
				[DiscountPercentage]  ,
				[TimeStamp] ,
				[StockMasterQuantity]  ,
				[StockMasterAveragePrice]  ,
				[NewQuantity] ,
				[NewAveragePrice]  ,
				[Remarks]  ,
				[UserProfileId] ,
				[CostTransactionAccountID] ,
				[PurchaseTransactionAccountID]  ,
				[TxnType] ,
				[BalanceQuantity]  ,
				[ReturnQuantity]  ,
				[ItemUnitPriceInSuppCurrency],
				[IPAddress],
				[CreatedUserID],
				[LastModUserID]  ,
				[CreatedDate]  ,
				[LastModDate]  ,
				[TBPHeaderId] ,
				[Isserialadded],
				[SkipGL],
				[BalVal] ,
				[AccName] ,
				[RequestedGenericItemId] ,
				[PhysicalQuantity] ,
				[IssuedQuantity],
				[UnitPrice] -- Add by Uditha 2025-06-26 For Invoice Module
				,[SelectedCUSDECID] -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
			FROM
            OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
            WITH StockTransactionDetails;


			
 --------Added 15/02/2022--------------------

			 --added by isuru 2025-03-06 to fix 0 itemid inserting in AA
			 delete from #TempAllDetails
			 where stockitemid =0

			 --end

			 --Added by Tharuka 2026-06-24
			 DECLARE @IsRangeWiseApproval BIT = 0;
			 DECLARE @ApprovalRowsInserted INT = 0;
			 DECLARE @TotalAmount DECIMAL(18,6);

			 SET @TotalAmount = (SELECT SUM(TAL.UnitPrice * TAL.Quantity) FROM #TempAllDetails TAL); 
				

			 --End


			INSERT INTO #TempStockTransactionHeader (
				[DocumentNo],
				[TransactionType] ,
				[TransactionDate],
				[PropertyID],
				[LocationID] ,
				[ReferenceNo] ,
				[SupplierID],
				[Remarks] ,
				[ReferenceID] ,
				[DepartmentID] ,
				[UserProfileID],
				[TransferLocationID]  ,
				[TimeStamp]  ,
				[TransactionID] ,
				[Mode] ,
				[SuppCurrencyID] ,
				[ExchangeRate]  ,
				[IPAddress] ,
				[CreatedUserID]  ,
				[LastModUserID]  ,
				[CreatedDate]  ,
				[LastModDate]  ,
				[IsPrint]  ,
				[IsApproved]  ,
				[IsTrasferIn] ,
				[InvoiceDate] ,
				[GLDATE] ,
				[IsDirectIssue] ,
				[GRNTypeID] ,
				[BudgetID] ,
				[PaidAmount] ,
				[SendMail]  ,
				[IsProdGenerate] 	
				,[IsProductionPlan]
				,[FileName],
				[PaxCount],
				[SubstractNetValue],
				[IsAutoTrasferGRN], --For identify auto transfer GRN - Added by Nivesh 2025-11-07
				[IsInvoiceBasedTransaction] -- for identifying InvoiceBasedTransactions by Isuru 2026-05-25
				,[InvoiceDueDate] --Added by Tharuka 2026-08-18
			)
			SELECT 
				[DocumentNo],
				[TransactionType] ,
				[TransactionDate],
				[PropertyID],
				[LocationID] ,
				[ReferenceNo] ,
				[SupplierID],
				[Remarks] ,
				[ReferenceID] ,
				[DepartmentID] ,
				[UserProfileID],
				[TransferLocationID]  ,
				[TimeStamp]  ,
				[TransactionID] ,
				[Mode] ,
				[SuppCurrencyID] ,
				[ExchangeRate]  ,
				[IPAddress] ,
				[CreatedUserID]  ,
				[LastModUserID]  ,
				[CreatedDate]  ,
				[LastModDate]  ,
				[IsPrint]  ,
				[IsApproved]  ,
				[IsTrasferIn] ,
				[InvoiceDate] ,
				[GLDATE] ,
				[IsDirectIssue] ,
				[GRNTypeID] ,
				[BudgetID] ,
				[PaidAmount] ,
				[SendMail]  ,
				[IsProdGenerate] ,
				[IsProductionPlan],
				[FileName],
				[PaxCount],
				[SubstractNetValue],
				ISNULL([IsAutoTrasferGRN],0) AS IsAutoTrasferGRN,--For identify auto transfer GRN - Added by Nivesh 2025-11-07
				ISNULL([IsInvoiceBasedTransaction],0) AS IsInvoiceBasedTransaction -- for identifying InvoiceBasedTransactions by Isuru 2026-05-25
				,[InvoiceDueDate] --Added by Tharuka 2026-08-18
			FROM
            OPENXML(@iDocID, 'StockTransactionHeader', 2)
                WITH
            (
				[DocumentNo] [nvarchar](20) ,
				[TransactionType]  VARCHAR(2) ,
				[TransactionDate]  VARCHAR(MAX) ,
				[PropertyID] [int] ,
				[LocationID] [int] ,
				[ReferenceNo] VARCHAR(MAX) ,
				[SupplierID] [int] ,
				[Remarks] [nvarchar](MAX) ,
				[ReferenceID] [int] ,
				[DepartmentID] [int] ,
				[UserProfileID] [int] ,
				[TransferLocationID] [int] ,
				[TimeStamp] [nvarchar](256) ,
				[TransactionID] [int] ,
				[Mode] [nvarchar](1) ,
				[SuppCurrencyID] [int] ,
				[ExchangeRate] [decimal](18, 2) ,
				[IPAddress] [nvarchar](max) ,
				[CreatedUserID] [int] ,
				[LastModUserID] [int] ,
				[CreatedDate] [datetime] ,
				[LastModDate] [datetime] ,
				[IsPrint] [bit] ,
				[IsApproved] [bit] ,
				[IsTrasferIn] [bit] ,
				[InvoiceDate] [datetime] ,
				[GLDATE] [date] ,
				[IsDirectIssue] [bit] ,
				[GRNTypeID] [int] ,
				[BudgetID] [int] ,
				[PaidAmount] [decimal](18, 8) ,
				[SendMail] [bit] ,
				[IsProdGenerate] [bit],
				[IsProductionPlan] BIT,
				[FileName] VARCHAR(MAX),
				[PaxCount] DECIMAL(8,2),
				[SubstractNetValue] DECIMAL(18,2),
				[IsAutoTrasferGRN] BIT, --For identify auto transfer GRN - Added by Nivesh 2025-11-07
				[IsInvoiceBasedTransaction] BIT
				,[InvoiceDueDate] [datetime] --Added by Tharuka 2026-08-18
            );


			-- ===== added by Isuru 2026-07-01 to LEAK GUARD: Transfer-In lines must all belong to the referenced source doc =====
			DECLARE @HdrRefID INT, @HdrTxnType VARCHAR(2);
			SELECT TOP 1 @HdrRefID = ReferenceID, @HdrTxnType = TransactionType
			FROM #TempStockTransactionHeader;

			IF (@HdrTxnType = 'TI' AND @HdrRefID > 0
			AND EXISTS (SELECT 1 FROM #TempAllDetails
			WHERE ISNULL(StockTransactionHeaderID,0) <> @HdrRefID))
			BEGIN
			RAISERROR('Transfer-In payload contains line(s) from a different source document (stale-buffer leak). Save aborted.',16,1);
			ROLLBACK TRANSACTION;   -- adapt to this SP's own TRY/CATCH + transaction convention
			RETURN;
			END
			-- =====================================================================================
			
			INSERT INTO #TempStockTransactionwiseCharges (AdditionalChargeID,ChargeAmount, AddedToItemCost)
			SELECT Id AS AdditionalChargeID, Amount AS ChargeAmount, IsAddToItemCost AS AddedToItemCost
			FROM
            OPENXML(@iDocID, '/StockTransactionHeader/AdditionalChargesList/AdditionalChargesDetails', 2)
            WITH (Id int ,Amount DECIMAL(18,6), IsAddToItemCost bit  );
			
			INSERT INTO #StockItemWiseEXPDateIns  (ID,StockItemID,Quantity,EXPDate,BatchNo,SellingPrice)
			SELECT ID,StockItemID,Quantity,EXPDate,BatchNo,SellingPrice
			FROM
			OPENXML(@iDocID, '/StockTransactionHeader/ItemWiseExpireDates/ItemWiseExpireDates', 2)
			WITH (
			ID INT,
			StockItemID BIGINT,
			Quantity DECIMAL(18,2),
			EXPDate DATETIME,
			BatchNo VARCHAR(200),
			SellingPrice DECIMAL(18,8)
			);
			
			INSERT INTO #TempStockItemWiseEXPDateIns(
			[PropertyID] ,
			[LocationID]  ,
			[TransactionID]  ,
			[TransactionType]  ,
			[StockItemID]  ,
			[Quantity] ,
			[BalanceQuantity]  ,
			[EXPDate]  ,
			[LogDate]  ,
			[BatchNo]  ,
			[TxnUnitID] ,
			[StockMasterQty]  ,
			[TransactionDate],
			[MasterUnitID]  ,
			[PhysicalQty] ,
			[TxnType]  ,
			[SellingPrice]
			)
			SELECT 
			[PropertyID] ,
			[LocationID]  ,
			[TransactionID]  ,
			[TransactionType]  ,
			[StockItemID]  ,
			[Quantity] ,
			[BalanceQuantity]  ,
			[EXPDate]  ,
			[LogDate]  ,
			[BatchNo]  ,
			[TxnUnitID] ,
			[StockMasterQty]  ,
			[TransactionDate],
			[MasterUnitID]  ,
			[PhysicalQty] ,
			[TxnType] ,
			[SellingPrice]
			FROM
			OPENXML(@iDocID, '/StockTransactionHeader/ItemWiseExpireDates/ItemWiseExpireDates', 2)
			--WITH StockItemWiseEXPDateIns; --COMMENTED BY ISURU 2025-12-18
			WITH (
			[PropertyID] [int],
			[LocationID] [int],
			[TransactionID] [nvarchar](max) ,
			[TransactionType] [nvarchar](max) ,
			[StockItemID] [bigint] ,
			[Quantity] [decimal](18, 8),
			[BalanceQuantity] [decimal](18, 8),
			[EXPDate] [datetime] ,
			[LogDate] [datetime],
			[BatchNo] [varchar](200) ,
			[TxnUnitID] [int] ,
			[StockMasterQty] [decimal](18, 8) ,
			[TransactionDate] [date] ,
			[MasterUnitID] [int] ,
			[PhysicalQty] [decimal](18, 8) ,
			[TxnType] [nvarchar](1) ,
			[SellingPrice] [decimal](18, 8) 
			); --ADDED BY ISURU 2025-12-18
			
			INSERT INTO #TempStockItemWiseTemperature(
			[PropertyID],
			[LocationID],
			[TransactonID]  ,
			[TransactionType] ,
			[StockItemID],
			[Quantity] ,
			[Temperature]  ,
			[LogDate],
			[TypeId] 		
			)
			SELECT 
			[PropertyID],
			[LocationID],
			[TransactonID]  ,
			[TransactionType] ,
			[StockItemID],
			[Quantity] ,
			[Temperature]  ,
			[LogDate],
			[TypeId] 	
			FROM
			OPENXML(@iDocID, '/StockTransactionHeader/ItemWiseTemperature/ItemWiseTemperature', 2)
			WITH stockitemwisetemperature;

         SELECT --@txnDate = [dbo].[FN_GetTransactionDate] (PropertyID), Commented by isuru 2024-10-08 to get currentdate before dayend
			   @txnDate = ISNULL([dbo].[FN_GetCurrentDate](PropertyID,LocationID),GETDATE()),
			   @txnDateFromFront = TransactionDate,
               @TransactionType = TransactionType,
               @LocationID = LocationID,
               @PropertyID = PropertyID ,
               @ReferenceID = ReferenceID,
               @Mode = Mode,
			   @TransferLocationID = TransferLocationID,
			   @SupplierID = SupplierID,
			   @CreatedUserId = CreatedUserID,
			   @ReferenceNo = ReferenceNo,--REPLACE(ReferenceNo, '\', '/'), commented by Isuru 2026-02-03 to fix invoiceno replacing
			   @GRNTypeID = GRNTypeID,
			   @IsProdGenerate = ISNULL(IsProdGenerate,0),
			   @IsProductionPlan = ISNULL(IsProductionPlan,0),
			   @FileName = ISNULL(FileName,'N/A'),
			   @SubstractNetValue = ISNULL(SubstractNetValue,0),
			   @DepartmentID = DepartmentID,
			   @IsInvoiceBasedTransaction = IsInvoiceBasedTransaction
		FROM
        #TempStockTransactionHeader;

				--added by isuru 2026-08-06
		--Reason: reject duplicate Transfer OUT submissions using the client submit token,
		--        so a slow/timed-out retry cannot create duplicate transfer-out documents.
		DECLARE @SubmitToken UNIQUEIDENTIFIER =
			TRY_CONVERT(UNIQUEIDENTIFIER,
				@XMLDetails.value('(/StockTransactionHeader/SubmitToken)[1]', 'VARCHAR(50)'));
		SET @SubmitToken = NULLIF(@SubmitToken, '00000000-0000-0000-0000-000000000000');   -- line 691

		--added by isuru 2026-08-06
		--Reason: auto-transfer spawns nested SP calls from a COPY of this XML (GR->TO line 5188, TO->TI line 5424).
		--        Strip the token so spawned documents don't inherit it and collide on UX_STH_SubmitToken.
		IF (@SubmitToken IS NOT NULL AND @XMLDetails.exist('/StockTransactionHeader/SubmitToken') = 1)
			SET @XMLDetails.modify('delete (/StockTransactionHeader/SubmitToken)');

		IF (@TransactionType IN ('TO','TI','GR','AA') AND @SubmitToken IS NOT NULL)
		BEGIN
			DECLARE @ExistingDocNo VARCHAR(50);

			SELECT TOP 1 @ExistingDocNo = DocumentNo
			FROM StockTransactionHeaders
			WHERE SubmitToken     = @SubmitToken
			  AND TransactionType = @TransactionType;

			IF (@@ROWCOUNT > 0)   -- a matching row exists (robust even if its DocumentNo were NULL)
			BEGIN
				DECLARE @DupMsg VARCHAR(MAX) =
					'Duplicated records found for selected transaction. Already saved in ' + ISNULL(@ExistingDocNo, '');
				;THROW 50100, @DupMsg, 1;   --added by isuru 2026-08-06  dedicated code 50100 = duplicate submit token
			END
		END
		--end added by isuru 2026-08-06


		--Added by Isuru 2026-08-03
		declare @OverIssuedItem NVARCHAR(MAX),@OverIssueError  NVARCHAR(MAX),@IsRequestedQuantityExceed  bit
						SET @OverIssuedItem = NULL;

		SELECT @IsRequestedQuantityExceed = ISNULL(IsRequestedQuantityExceed, 0)
		FROM   Companies WHERE CompanyID = @PropertyID;
		--End

		--Added by Tharuka 2026-06-24 -----

		SELECT @IsRangeWiseApproval = ISNULL(IsRangeWiseApproval,0) FROM Companies WHERE CompanyID = @PropertyID
		--ENd

		DECLARE @SourceIsInvoiceBased BIT = 0;

		IF (@TransactionType = 'GR' AND @ReferenceID > 0)
		BEGIN
			SELECT @SourceIsInvoiceBased = ISNULL(IsInvoiceBasedTransaction, 0)
			FROM   dbo.StockTransactionHeaders
			WHERE  Id              = @ReferenceID
			  AND  TransactionType = 'BI';

			UPDATE #TempStockTransactionHeader
			SET    IsInvoiceBasedTransaction = @SourceIsInvoiceBased;

			SET @IsInvoiceBasedTransaction = @SourceIsInvoiceBased;
		END

		--Added by Tharuka 2026-09-15 : 'BR' Franchise Return
		CREATE TABLE #BRPrice (StockItemID INT, SellingPrice DECIMAL(18, 6));   -- (FIX)

		
		--added by Isuru 2026-09-17 BR tax: original BI lines covered by this return, used to copy BI tax to the BR (created for every type, filled only by the 'BR' block)
		CREATE TABLE #BRTaxAlloc (StockItemID INT, SourceDetailID BIGINT, SourceQty DECIMAL(18, 6));
		--end added by Isuru 2026-09-17

		IF (@TransactionType = 'BR')
		BEGIN
			DECLARE @BRSourceType CHAR(2), @BRSourceDocNo VARCHAR(100), @BRBIHeaderID INT, @BRBIDocNo VARCHAR(100),
			        @BRInvoiceLocationID INT, @BRError NVARCHAR(2000);

			SELECT @BRSourceType  = TransactionType,
			       @BRSourceDocNo = DocumentNo
			FROM   dbo.StockTransactionHeaders WITH (UPDLOCK, HOLDLOCK)
			WHERE  Id         = @ReferenceID
			  AND  PropertyID = @PropertyID;

			IF (ISNULL(@BRSourceType, '') NOT IN ('BI', 'SR'))
			BEGIN
				RAISERROR ( 'Franchise Return: select a Franchise Invoice or Supplier Return document.', 16, 1 );
				ROLLBACK TRANSACTION
			END

			IF (@BRSourceType = 'BI')
			BEGIN
				SELECT @BRBIHeaderID = @ReferenceID, @BRBIDocNo = @BRSourceDocNo;
			END
			ELSE
			BEGIN
				SELECT @BRBIHeaderID = BI.Id, @BRBIDocNo = BI.DocumentNo
				FROM   dbo.StockTransactionHeaders SR
				INNER JOIN dbo.StockTransactionHeaders GR ON GR.Id = SR.ReferenceID AND GR.TransactionType = 'GR'
				INNER JOIN dbo.StockTransactionHeaders BI WITH (UPDLOCK, HOLDLOCK)
				                                          ON BI.Id = GR.ReferenceID AND BI.TransactionType = 'BI'
				WHERE  SR.Id = @ReferenceID;
			END

			IF (@BRBIHeaderID IS NULL)
			BEGIN
				SET @BRError = 'Franchise Return: ' + ISNULL(@BRSourceDocNo, '') + ' is not linked to a Franchise Invoice.';
				RAISERROR ( '%s', 16, 1, @BRError );
				ROLLBACK TRANSACTION
			END

			-- the return belongs to the franchise location the BI was invoiced to
			SELECT @BRInvoiceLocationID = InvoiceLocationID
			FROM   dbo.StockTransactionHeaders
			WHERE  Id = @BRBIHeaderID;

			UPDATE #TempStockTransactionHeader
			SET    InvoiceLocationID         = ISNULL(@BRInvoiceLocationID, 0),
			       IsInvoiceBasedTransaction = 1;

			SET @IsInvoiceBasedTransaction = 1;

			-- returned quantity per item, in the return line's unit
			SELECT StockItemID,
			       MAX(TxnUnitID)            AS TxnUnitID,
			       COUNT(DISTINCT TxnUnitID) AS UnitCount,
			       SUM(Quantity)             AS Quantity
			INTO   #BRLines
			FROM   #TempAllDetails
			WHERE  Quantity > 0
			GROUP BY StockItemID;

			IF NOT EXISTS (SELECT 1 FROM #BRLines)
			BEGIN
				RAISERROR ( 'Franchise Return: enter a return quantity for at least one item.', 16, 1 );
				ROLLBACK TRANSACTION
			END

			-- source lines on the SR / BI being returned against (both are the same header for a 'BI')
			SELECT SD.Id                       AS DetailID,
			       SD.StockTransactionHeaderID AS HeaderID,
			       SD.StockItemID,
			       BR.Quantity                 AS ReturnQty,
			       -- rate from the source line unit to the return line unit
			       CASE WHEN SD.TxnUnitID = BR.TxnUnitID THEN 1
			            ELSE dbo.FN_GetUnitConvertionRate(@PropertyID, SD.TxnUnitID, BR.TxnUnitID) END AS Rate,
			       -- still open on the line, in the source line unit
			       CASE WHEN SD.Quantity - ISNULL(SD.ReturnQuantity, 0) > 0
			            THEN SD.Quantity - ISNULL(SD.ReturnQuantity, 0) ELSE 0 END                 AS OpenQty,
			       SD.SellingPrice
			INTO   #BRSource
			FROM   dbo.StockTransactionDetails SD WITH (UPDLOCK, HOLDLOCK)
			INNER JOIN #BRLines BR ON BR.StockItemID = SD.StockItemID
			WHERE  SD.StockTransactionHeaderID IN (@ReferenceID, @BRBIHeaderID);

			-- first failing line: mixed units, item not on the document, no unit conversion,
			-- or more than is still open on the SR / BI
			SELECT TOP (1)
			       @BRError = SI.Name + CASE
			                  WHEN BR.UnitCount > 1
			                       THEN ' - is entered in more than one unit.'
			                  WHEN ISNULL(S.LineCount, 0) = 0
			                       THEN ' - is not on ' + D.DocNo + '.'
			                  WHEN S.MinRate <= 0
			                       THEN ' - has no unit conversion to the unit on ' + D.DocNo + '.'
			                  ELSE ' - return quantity ' + CONVERT(VARCHAR(40), CAST(BR.Quantity AS DECIMAL(18, 4)))
			                       + ' cannot exceed the returnable quantity '
			                       + CONVERT(VARCHAR(40), CAST(S.OpenQty AS DECIMAL(18, 4))) + ' on ' + D.DocNo + '.'
			                  END
			FROM   #BRLines BR
			INNER JOIN dbo.StockItemHeaders SI ON SI.Id = BR.StockItemID
			CROSS JOIN (SELECT DISTINCT HeaderID, DocNo
			            FROM (VALUES (@ReferenceID, @BRSourceDocNo), (@BRBIHeaderID, @BRBIDocNo)) V(HeaderID, DocNo)) D
			OUTER APPLY (
				SELECT COUNT(*)            AS LineCount,
				       MIN(S.Rate)         AS MinRate,
				       SUM(S.OpenQty * CASE WHEN S.Rate > 0 THEN S.Rate ELSE 0 END) AS OpenQty
				FROM   #BRSource S
				WHERE  S.HeaderID    = D.HeaderID
				  AND  S.StockItemID = BR.StockItemID
			) S
			WHERE  BR.UnitCount > 1
			   OR  ISNULL(S.LineCount, 0) = 0
			   OR  S.MinRate <= 0
			   OR  BR.Quantity > S.OpenQty + 0.000001
			ORDER BY SI.Name;

			IF (@BRError IS NOT NULL)
			BEGIN
				SET @BRError = 'Franchise Return: ' + @BRError;
				RAISERROR ( '%s', 16, 1, @BRError );
				ROLLBACK TRANSACTION
			END

			-- book the return: spread it over the item's open lines in line order, on the SR and the BI
			;WITH BRAlloc AS (
				SELECT S.DetailID,
				       S.Rate,
				       S.ReturnQty,
				       S.OpenQty * S.Rate AS OpenInReturnUnit,
				       ISNULL(SUM(S.OpenQty * S.Rate) OVER (PARTITION BY S.HeaderID, S.StockItemID ORDER BY S.DetailID
				                                            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS OpenBefore
				FROM   #BRSource S
			)
			UPDATE SD
			SET    SD.ReturnQuantity = ISNULL(SD.ReturnQuantity, 0) + CAST(X.Alloc / A.Rate AS DECIMAL(18, 6))
			FROM   dbo.StockTransactionDetails SD
			INNER JOIN BRAlloc A ON A.DetailID = SD.Id
			CROSS APPLY (SELECT CASE WHEN A.ReturnQty - A.OpenBefore <= 0                  THEN 0
			                         WHEN A.ReturnQty - A.OpenBefore >= A.OpenInReturnUnit THEN A.OpenInReturnUnit
			                         ELSE A.ReturnQty - A.OpenBefore END AS Alloc) X
			WHERE  X.Alloc > 0;


			
			--added by Isuru 2026-09-17 BR tax: save the original BI lines and quantities (source-line unit) this return is booked against, same allocation as the ReturnQuantity update above; tax always comes from the BI for both SR- and BI-sourced returns
			;WITH BRTaxAlloc AS (
				SELECT S.DetailID,
				       S.HeaderID,
				       S.StockItemID,
				       S.Rate,
				       S.ReturnQty,
				       S.OpenQty * S.Rate AS OpenInReturnUnit,
				       ISNULL(SUM(S.OpenQty * S.Rate) OVER (PARTITION BY S.HeaderID, S.StockItemID ORDER BY S.DetailID
				                                            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS OpenBefore
				FROM   #BRSource S
			)
			INSERT INTO #BRTaxAlloc (StockItemID, SourceDetailID, SourceQty)
			SELECT A.StockItemID,
			       A.DetailID,
			       CAST(X.Alloc / A.Rate AS DECIMAL(18, 6))
			FROM   BRTaxAlloc A
			CROSS APPLY (SELECT CASE WHEN A.ReturnQty - A.OpenBefore <= 0                  THEN 0
			                         WHEN A.ReturnQty - A.OpenBefore >= A.OpenInReturnUnit THEN A.OpenInReturnUnit
			                         ELSE A.ReturnQty - A.OpenBefore END AS Alloc) X
			WHERE  A.HeaderID = @BRBIHeaderID
			  AND  X.Alloc > 0;
			--end added by Isuru 2026-09-17

			-- selling price of the source line, per return unit - written to the BR detail's SellingPrice
			INSERT INTO #BRPrice (StockItemID, SellingPrice)   -- (FIX) was: SELECT ... INTO #BRPrice
			SELECT S.StockItemID,
			       CAST(MAX(CASE WHEN S.Rate > 0 THEN ISNULL(S.SellingPrice, 0) / S.Rate ELSE 0 END) AS DECIMAL(18, 6)) AS SellingPrice
			FROM   #BRSource S
			WHERE  S.HeaderID = @ReferenceID
			GROUP BY S.StockItemID;

			-- stock comes back at the location's current average cost (same basis a 'BI' used to issue it)
			UPDATE #TempAllDetails
			SET    UnitPrice = dbo.[FN_GetLastAveragePrice](@LocationID, StockItemID)
			WHERE  Quantity > 0;

			DROP TABLE #BRLines;
			DROP TABLE #BRSource;
		END
		--End 'BR' Franchise Return ------------------------------------------------------------------------------


		-- end 

		--Added by Tharuka 2026-09-15 : a Supplier Return against an invoice-based GRN is saved as invoice-based too
		IF (@TransactionType = 'SR' AND @ReferenceID > 0)
		BEGIN
			SELECT @SourceIsInvoiceBased = ISNULL(IsInvoiceBasedTransaction, 0)
			FROM   dbo.StockTransactionHeaders
			WHERE  Id              = @ReferenceID
			  AND  TransactionType = 'GR';

			UPDATE #TempStockTransactionHeader
			SET    IsInvoiceBasedTransaction = @SourceIsInvoiceBased;

			SET @IsInvoiceBasedTransaction = @SourceIsInvoiceBased;
		END
		--End

	
		SELECT @IsContractedSupplier = ISNULL(IsContractedSupplier,0),@IsModifyTransferIn = ISNULL(IsModifyTransferIn,0), @IsSubstractNetTotal = ISNULL(IsSubstractNetTotal,0) 
		,@DisplayOriginalTRQty = ISNULL(DisplayOriginalTRQty,0)
		,@IsLocationWiseDayendEnable =ISNULL(IsLocationWiseDayendEnable,0)
		FROM COMPANIES WHERE COMPANYID = @PropertyID

		IF(@IsModifyTransferIn =1)
		BEGIN
			SELECT StockTransactionHeaderID,StockItemID,Quantity,BalanceQuantity,IssuedQuantity
			INTO #TempAllDetailsModifyTran 
			FROM #TempAllDetails WHERE BalanceQuantity <>  IssuedQuantity

			UPDATE #TempAllDetailsModifyTran
			SET IssuedQuantity = IssuedQuantity +Quantity
		END
		--Added by Isuru 2025-04-23 for Contracted Supplier changes---
		IF(@IsContractedSupplier =1)
		BEGIN
			INSERT INTO #TempContractSupplier
			SELECT StockItemID,UnitPrice,RequestedQuantity,ContractSupplierReason,ContractSupplierPrice,ContractSupplierID
			FROM
			OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
			WITH
			(
			StockItemID	INT,
			UnitPrice DECIMAL(18,6),
			RequestedQuantity FLOAT,
			ContractSupplierReason VARCHAR(MAX),
			ContractSupplierPrice DECIMAL(18, 6),
			ContractSupplierID INT
			) 
		END
		--Added by Isuru 2025-04-23 for Contracted Supplier changes---

		SET @IsProdGenerate = ISNULL(@IsProdGenerate,0)

		SELECT @BudgetID = ID
		FROM BudgetAllocation
		WHERE LocationID = @LocationID

		---------------------  ADDED BY ISURU
		SELECT  @StockID = StockTransactionHeaderID
		FROM
        #TempAllDetails
		------------------------ADDED BY ISURU END

			--------added by Isuru 2023-07-13

		DECLARE @GRNApprovalID INT

		SELECT  @GRNApprovalID = GRNApprovalID
		FROM
        OPENXML(@iDocID, '/StockTransactionHeader/GRNApprovalDetails', 2)
        WITH
        (
			GRNApprovalID INT
        );



		--Added by Isuru 2026-01-08 to validate Incorrect Item in GRN
		IF(@TransactionType = 'GR')
		BEGIN
			
			IF EXISTS(SELECT 1 FROM #TempAllDetails
			WHERE StockItemID NOT IN (SELECT StockItemID FROM SupplierWiseItemDetails 
			WHERE SupplierID = @SupplierID 	AND LocationId = @LocationID))
			BEGIN
				 DECLARE @MissingItems VARCHAR(MAX);

				 select *
				 from #TempAllDetails

				SELECT @MissingItems = STRING_AGG(si.Name, ', ')
				FROM #TempAllDetails t
				INNER JOIN StockItemHeaders si ON si.ID = t.StockItemID
				WHERE t.StockItemID NOT IN (
				SELECT StockItemID 
				FROM SupplierWiseItemDetails 
				WHERE SupplierID = @SupplierID 
				AND LocationId = @LocationID
				);

				RAISERROR('These items are not linked to the selected supplier/location: %s', 16, 1, @MissingItems);
				ROLLBACK TRANSACTION;
			END
		END

		--End


		--Added by Isuru 2026-05-22 for BackEnd Invoice
		IF(@TransactionType ='BI')
		BEGIN
			DECLARE @InvoiceLocationID INT

			SELECT @InvoiceLocationID= ID 
			FROM Locations
			WHERE FranchiseDepartmentID = @DepartmentID

			IF(@InvoiceLocationID IS NULL OR @InvoiceLocationID = 0)
			BEGIN
				RAISERROR ( 'Franchise Location and Department Mapping Not exists', 16, 1 );  
				ROLLBACK TRANSACTION
			END

			UPDATE #TempStockTransactionHeader
			SET InvoiceLocationID = @InvoiceLocationID

			--Added by <name> 2026-08-14 : VAT Tax Invoice Number, Gazette 2463/05 format YYMMM_QQQQ_XXXXX
			DECLARE @TaxInvoiceNumber VARCHAR(50) = NULL,
			@TaxInvPrefix     VARCHAR(20),
			@TaxInvSeq        BIGINT;
			DECLARE @TaxInvAllocated TABLE (Num BIGINT);
			DECLARE @TaxInvSubmitPrefix VARCHAR(20);

			-- QQQQ : entity code = Prefix of the franchise location being invoiced
			SELECT @TaxInvPrefix = UPPER(REPLACE(LTRIM(RTRIM(CONVERT(VARCHAR(20), Prefix))), ' ', ''))
			FROM   Locations
			WHERE  ID = @InvoiceLocationID;

			SELECT @TaxInvSubmitPrefix =
			UPPER(REPLACE(LTRIM(RTRIM(CONVERT(VARCHAR(20), Prefix))), ' ', ''))
			FROM Locations
			WHERE ID = @LocationID;

			IF ISNULL(@TaxInvSubmitPrefix, '') = ''
			BEGIN
				RAISERROR('Tax Invoice Number: Prefix is not set for the invoice submit location.', 16, 1);
				ROLLBACK TRANSACTION;
			END

			IF (ISNULL(@TaxInvPrefix,'') = '')
			BEGIN
			RAISERROR ( 'Tax Invoice Number: Prefix is not set for the franchise location.', 16, 1 );
			ROLLBACK TRANSACTION
			END

			-- create the counter on first use for this location
			IF NOT EXISTS (SELECT 1 FROM TransactionTypeWiseNextNumbers
			WHERE PropertyID = @PropertyID
			AND LocationID = @InvoiceLocationID
			AND TransactionType = 'TX')
			BEGIN
				INSERT INTO TransactionTypeWiseNextNumbers
				(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
				VALUES (@PropertyID, @InvoiceLocationID, 'TX', 1, 0);
			END

			-- XXXXX : allocate the next serial atomically
			UPDATE N
			SET NextNumber = NextNumber + 1
			OUTPUT deleted.NextNumber INTO @TaxInvAllocated(Num)
			FROM   TransactionTypeWiseNextNumbers AS N WITH (UPDLOCK, ROWLOCK)
			WHERE  N.PropertyID      = @PropertyID
			AND  N.LocationID      = @InvoiceLocationID
			AND  N.TransactionType = 'TX';

			SELECT @TaxInvSeq = Num FROM @TaxInvAllocated;

			SET @TaxInvoiceNumber =
			RIGHT(CONVERT(VARCHAR(4), YEAR(@txnDate)), 2)
			+ CHOOSE(MONTH(@txnDate),'JAN','FEB','MAR','APR','MAY','JUN',
					'JUL','AUG','SEP','OCT','NOV','DEC')
			+ '_' + @TaxInvSubmitPrefix + @TaxInvPrefix
			+ '_' + CONVERT(VARCHAR(20), @TaxInvSeq);
			IF (LEN(@TaxInvoiceNumber) > 40)
			BEGIN
				RAISERROR ( 'Tax Invoice Number exceeds the 40 character legal limit - shorten the location Prefix.', 16, 1 );
				ROLLBACK TRANSACTION
			END
			--End
		
		END

		--End

		-- Added by Isuru 2025-02-17 to check IsReconBackDateEnable on locations
			SELECT @IsReconBackDateEnable = ISNULL(IsReconBackDateEnable,1),@IsReconMandatory = IsReconMandatory,@IsOnlyOneReconPerDay = IsOnlyOneReconPerDay,@BackdateDayCountWhenBackDateDisable = BackdateDayCountWhenBackDateDisable
			FROM Locations
			WHERE ID = @LocationID
			IF (@TransactionType = 'AA' AND CONVERT(DATE,@txnDateFromFront) < CONVERT(DATE,DATEADD(DAY, @BackdateDayCountWhenBackDateDisable, GETDATE())) AND @IsReconBackDateEnable =0)
			BEGIN
				RAISERROR ( 'Back Date Disable for selected Location', 16, 1 );  
				ROLLBACK TRANSACTION
			END

			IF NOT EXISTS(  SELECT 1 FROM Location_Ref LF
			INNER JOIN BillHeader BH ON LF.code = BH.Outlet AND BH.PropertyId = LF.PropertyId
			WHERE StockLocationID=@LocationID
			AND LF.PropertyId = @PropertyID
			AND CONVERT(DATE,BH.OrderDate) =  CONVERT(DATE,DATEADD(DAY, -1, @txnDate)))
			BEGIN
				SET @IsReconMandatory =0
			END

			IF( @IsReconMandatory = 1 AND @TransactionType <> 'AA' )
			BEGIN

				IF EXISTS (SELECT 1 FROM StockTransactionHeaders WHERE TransactionDate = CONVERT(DATE,@txnDate) AND LocationID = @LocationID AND PropertyID = @PropertyID AND TransactionType = 'AA')
				BEGIN
					RAISERROR ( 'Cannot do trancation..Already reconciliation found for this location', 16, 1 );  
					ROLLBACK TRANSACTION
				END 
				ELSE IF ((SELECT COUNT(*) FROM StockTransactionHeaders WHERE TransactionDate = CONVERT(DATE,@txnDate) AND LocationID = @LocationID AND PropertyID = @PropertyID AND TransactionType NOT IN ( 'IF' )) = 0 )
				BEGIN

						IF NOT EXISTS (SELECT 1 FROM StockTransactionHeaders WHERE TransactionDate = CONVERT(DATE,DATEADD(DAY, -1, @txnDate)) AND LocationID = @LocationID AND PropertyID = @PropertyID AND TransactionType = 'AA')
						BEGIN
							RAISERROR ( 'Cannot do trancation..please process reconciliation for this location', 16, 1 );  
							ROLLBACK TRANSACTION
						END 
					
				END 


			END

			IF( @IsOnlyOneReconPerDay = 1 AND @TransactionType = 'AA' )
			BEGIN

				IF EXISTS (SELECT 1 FROM StockTransactionHeaders WHERE TransactionDate = CONVERT(DATE,@txnDateFromFront) AND LocationID = @LocationID AND PropertyID = @PropertyID AND TransactionType = 'AA')
				BEGIN
					RAISERROR ( 'Already reconciliation found for this location', 16, 1 );  
					ROLLBACK TRANSACTION
				END 

			END

		--End

		--Added by Isuru 2026-01-06 to validate Store DayEnd before transaction

	DECLARE @RequestDeliveryDate DATE,@TransferOutTransactionDate DATE
		
	IF(@IsLocationWiseDayendEnable = 1)
	BEGIN
		IF(@TransactionType IN ('TO','TI'))
		BEGIN
		IF EXISTS(SELECT 1 FROM Locations WHERE ID = @LocationID AND DayEndValidationMode IN ('OU','ST') AND CurrentDate <> CONVERT(DATE,GETDATE()))
			BEGIN
			
				IF(@TransactionType = 'TO' AND @ReferenceID >0)
				BEGIN
					SELECT @RequestDeliveryDate = CONVERT(DATE,DeliveryDate)
					FROM RequestHeaders
					WHERE ID = @ReferenceID
					AND RequestType = 'RT'
					SELECT @RequestDeliveryDate RequestDeliveryDate,@ReferenceID ReferenceID

					IF EXISTS(SELECT 1 FROM Locations WHERE ID = @LocationID AND DayEndValidationMode IN ('OU','ST')
					AND CurrentDate <> @RequestDeliveryDate)
					BEGIN
						RAISERROR ( 'Cannot do trancation..please process day end for this location', 16, 1 );  
						ROLLBACK TRANSACTION
					END

				END

				IF (@TransactionType = 'TI' AND @ReferenceID >0)
				BEGIN
				

					--SELECT @TransferOutTransactionDate = CONVERT(DATE,TransactionDate)
					SELECT @TransferOutTransactionDate = CASE WHEN RH.Id IS NULL THEN S1.TransactionDate ELSE CONVERT( DATE,RH.DeliveryDate) END
					FROM StockTransactionHeaders S1
					LEFT JOIN RequestHeaders RH ON RH.Id = S1.ReferenceID
					WHERE S1.ID = @ReferenceID
					AND S1.TRANSACTIONTYPE='TO'

					SELECT @TransferOutTransactionDate 
					IF EXISTS(SELECT 1 FROM Locations WHERE ID = @LocationID AND DayEndValidationMode IN ('OU','ST') 
					AND CurrentDate <> @TransferOutTransactionDate)
					BEGIN
						RAISERROR ( 'Cannot do trancation..please process day end for this location', 16, 1 );  
						ROLLBACK TRANSACTION
					END

				END

			END
		END
		ELSE
		BEGIN
			IF EXISTS(SELECT 1 FROM Locations WHERE ID = @LocationID AND DayEndValidationMode IN ('OU','ST'))
				BEGIN
			

					IF EXISTS(SELECT 1 FROM Locations WHERE ID = @LocationID AND DayEndValidationMode IN ('OU','ST') AND CurrentDate <> CONVERT(DATE,GETDATE()))
					BEGIN
						IF(@TransactionType NOT IN ('IF','PU','PI','RC','AA'))
						BEGIN

							RAISERROR ( 'Cannot do trancation..please process day end for this location', 16, 1 );  
							ROLLBACK TRANSACTION 

						END
					END

				END
		END
	END
		--End


---------------------------------- added by vinuki 17.06.2024------------------------------
			select @StockTransactionHeaderQuantity = ISNULL(SUM(Quantity),0) from #TempAllDetails

			--select @StockTransactionHeaderQuantity StockTransactionHeaderQuantity

 ---------------------------------------------------------------------------------------------
 	IF(@CreatedUserId = 0 AND @TransactionType NOT IN ( 'IF','RC','PU','PI','FW'))
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
                -------Stock Reconciliation 'AA' Added by Nivesh 2024-03-01
				IF(@TransactionType = 'AA')
				-------------------- START - Tharuka -2026-06-24 rangewise approval for Reconciliation --------------------------------------
				IF(@IsRangeWiseApproval = 1)
				BEGIN
					IF EXISTS(SELECT 1 FROM (
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 10
					AND U.RangeFrom = 0 AND U.RangeTo = 0
					
					UNION ALL
					
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 10
					AND U.RangeFrom IS NOT NULL 
					AND U.RangeFrom <> 0
					AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) 
						 OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))
						 )AS A
					)
					BEGIN
						
						SET @StockReconciliationIsApproval = 1
					END
				END 
				ELSE 
				BEGIN 
				------------------------------end ---------------------------------------------
                IF EXISTS(SELECT 1
                FROM TransactionWiseApprovalTypes TW
                INNER JOIN TransactionTypes TR ON TR.ID = TW.TransactionID
                WHERE TW.LocationID= @LocationID AND TR.Code = @TransactionType AND TW.PropertyID= @PropertyID)
                BEGIN
                 SET @StockReconciliationIsApproval = 1
                END
				END 
                --------


				-------GRN Transaction Approval Check 'GR' Added by Vinuki 2024-06-12
				if (@TransactionType = 'GR')
				-------------------- START - Tharuka -2026-06-24 rangewise approval for SRN --------------------------------------

				IF(@IsRangeWiseApproval = 1)
				BEGIN
					IF EXISTS(SELECT 1 FROM (
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 3
					AND U.RangeFrom = 0 AND U.RangeTo = 0
					
					UNION ALL
					
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 3
					AND U.RangeFrom IS NOT NULL 
					AND U.RangeFrom <> 0
					AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) 
						 OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))
						 )AS A
					)
					BEGIN
						
						SET @IsGRNTransactionApproval = 1
					END


				END
				ELSE
				BEGIN
				-------------------------------end-----------------------------------------------------
					IF EXISTS(SELECT 1
					FROM TransactionWiseApprovalTypes TW
					INNER JOIN TransactionTypes TR ON TR.ID = TW.TransactionID
					WHERE TW.LocationID= @LocationID AND TR.Code = @TransactionType AND TW.PropertyID= @PropertyID)
					BEGIN
					 SET @IsGRNTransactionApproval = 1
					END
				END
                --------
				

				-------SRN Transaction Approval Check 'SR' Added by Vinuki 2024-06-12
				if (@TransactionType = 'SR')
				-------------------- START - Tharuka -2026-06-24 rangewise approval for grn --------------------------------------
				IF(@IsRangeWiseApproval =1)
				BEGIN
					IF EXISTS(SELECT 1 FROM (
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 4
					AND U.RangeFrom = 0 AND U.RangeTo = 0
					
					UNION ALL
					
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 4
					AND U.RangeFrom IS NOT NULL 
					AND U.RangeFrom <> 0
					AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) 
						 OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))
						 )AS A
					)
					BEGIN
						
						SET @IsSRNTransactionApproval = 1
					END
				END
				ELSE 
				BEGIN 
			------------------------- END -------------------------------------------------------------
					IF EXISTS(SELECT 1
					FROM TransactionWiseApprovalTypes TW
					INNER JOIN TransactionTypes TR ON TR.ID = TW.TransactionID
					WHERE TW.LocationID= @LocationID AND TR.Code = @TransactionType AND TW.PropertyID= @PropertyID)
					BEGIN
						SET @IsSRNTransactionApproval = 1
					END
				END
                --------

				-------T/O Transaction Approval Check 'TO' Added by ISURU 2025-12-18
				if (@TransactionType = 'TO')
				-------------------- START - Tharuka -2026-06-24 rangewise approval for SRN --------------------------------------
				IF(@IsRangeWiseApproval = 1)
				BEGIN
					IF EXISTS(SELECT 1 FROM (
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 5
					AND U.RangeFrom = 0 AND U.RangeTo = 0
					
					UNION ALL
					
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 5
					AND U.RangeFrom IS NOT NULL 
					AND U.RangeFrom <> 0
					AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) 
						 OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))
						 )AS A
					)
					BEGIN
						
						SET @TransferNoteIsApproval = 1
					END
				END 
				ELSE 
				BEGIN 
					------------------------- END -------------------------------------------------------------
					IF EXISTS(SELECT 1
					FROM TransactionWiseApprovalTypes TW
					INNER JOIN TransactionTypes TR ON TR.ID = TW.TransactionID
					WHERE TW.LocationID= @LocationID AND TR.Code = @TransactionType AND TW.PropertyID= @PropertyID)
					BEGIN
						SET @TransferNoteIsApproval = 1
					END
				END 
                --------


				------I/R Transaction approval check 'IR' Added by Isuru 2026-05-11
				IF (@TransactionType = 'IR')
				-------------------- START - Tharuka -2026-06-24 rangewise approval for SRN --------------------------------------
				IF(@IsRangeWiseApproval =1)
				BEGIN
					IF EXISTS(SELECT 1 FROM (
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 7
					AND U.RangeFrom = 0 AND U.RangeTo = 0
					
					UNION ALL
					
					SELECT U.UserProfileId
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
					WHERE T.PropertyID = @PropertyID
					AND T.LocationID = @LocationID  
					AND T.TransactionID = 7
					AND U.RangeFrom IS NOT NULL 
					AND U.RangeFrom <> 0
					AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) 
						 OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))
						 )AS A
					)
					BEGIN
						
						SET @IsApprovalForIssueReturn = 1
					END
				END 
				ELSE
				BEGIN
				------------------------- END -------------------------------------------------------------
					IF EXISTS(SELECT 1
					FROM TransactionWiseApprovalTypes TW
					INNER JOIN TransactionTypes TR ON TR.ID = TW.TransactionID
					WHERE TW.LocationID= @LocationID AND TR.Code = @TransactionType AND TW.PropertyID= @PropertyID)
					BEGIN
						SET @IsApprovalForIssueReturn = 1
					END
				END 



				--End

 ----------------------------------------------------------------------------------------------

			----------Added 4/1/21------------
			IF(@TransactionType IN ('GR', 'IN') )
			BEGIN
				SELECT * INTO #TempAllItemsIN
				FROM
				#TempAllDetails

					IF(SELECT  1
					FROM #TempAllItemsIN
					GROUP BY StockItemID
					HAVING COUNT(StockItemID)>1) >0
					BEGIN		
						RAISERROR ( 'Cannot insert duplicate items', 16, 1 );  
						ROLLBACK TRANSACTION
					END
			END


			--Added by Isuru 2024-09-10
			SELECT @IsMailNotification =  ISNULL(IsMailNotification,0)
			FROM TransactionTypes
			WHERE CODE = @TransactionType
			--End

			--Added by isuru 2024-09-03 for Production
			SELECT @IsAutoProduction = IsAutoProduction,@IsContractedSupplier =IsContractedSupplier FROM Companies WHERE CompanyID = @PropertyID 

			----------
			DECLARE @ProductionOutHeaderID INT
			DECLARE @ProductionOutHeaderTable TABLE (
				ID INt
			)
			----------

			IF(@IsAutoProduction =1)
			BEGIN
				IF @TransactionType IN('TO','AA','IF')	 -- 'DN' removed from auto production as Dilmah instruction 2026-06-08
				BEGIN
					SELECT * 
					INTO #TempRecipeDetails
					FROM #TempAllDetails

					SELECT @RecipeTransactionDate = CASE  WHEN @TransactionType <> 'AA' AND @TransactionType <> 'IF' AND @TransactionType <> 'RC' THEN @txnDate
									  ELSE  @txnDateFromFront END;

					WHILE EXISTS(SELECT 1 FROM #TempRecipeDetails)
					BEGIN
						SELECT TOP (1) @RecipeItemID= StockItemID, @RecipeQuantity = Quantity,@RecipeUnitID =  TxnUnitID FROM #TempRecipeDetails

						IF EXISTS(SELECT 1
							FROM StockItemHeaders SH 
							INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
							WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID AND SH.CompanyId = @PropertyID
							AND SH.IsProductionItem =1 AND --SD.QuantityInHand commented by isuru 2024-10-23 for getting relevant date quantityhand
							[dbo].[GetBalance](@RecipeTransactionDate,SH.Id, @LocationId,0, 0) < @RecipeQuantity)
						BEGIN
							
							SELECT @RecipeQuantityVariance = @RecipeQuantity - [dbo].[GetBalance](@RecipeTransactionDate,SH.Id, @LocationId,0, 0)   --SD.QuantityInHand
							FROM StockItemHeaders SH 
							INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
							WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID AND SH.CompanyId = @PropertyID
							AND SH.IsProductionItem =1 AND -- SD.QuantityInHand
							[dbo].[GetBalance](@RecipeTransactionDate,SH.Id, @LocationId,0, 0) < @RecipeQuantity

							IF EXISTS(SELECT 1 FROM Inv_RecipeDetails rd
							INNER JOIN Inv_RecipeHeader rh ON rd.RecipeHeaderId = rh.Id
							INNER JOIN Inv_ItemWiseRecipes ir ON ir.RecipeId = rh.Id
							INNER JOIN StockItemDetails id ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
							WHERE ir.StockItemId = @RecipeItemID )
							BEGIN
								
								IF( @TransactionType = 'AA' )
								BEGIN
										IF( @IsProdGenerate = 1  )
										BEGIN

											EXEC SaveProductionRecipeDetails  @LocationID,@RecipeItemID,@PropertyID ,@RecipeUnitID , @RecipeQuantityVariance,@CreatedUserId,@RecipeTransactionDate,1,@ProductionOutHeaderID OUTPUT  

								IF(@ProductionOutHeaderID IS NOT NULL)
								BEGIN
									INSERT INTO @ProductionOutHeaderTable (Id)
									values(@ProductionOutHeaderID)
								END
										END
								END
								ELSE
								BEGIN


								SELECT 'AUTO PRODUCTION SP CALLED',@LocationID LocationID,@RecipeItemID RecipeItemID ,@RecipeUnitID RecipeUnitID
								, @RecipeQuantityVariance RecipeQuantityVariance,@RecipeTransactionDate RecipeTransactionDate
								


									EXEC SaveProductionRecipeDetails  @LocationID,@RecipeItemID,@PropertyID ,@RecipeUnitID , @RecipeQuantityVariance,@CreatedUserId,@RecipeTransactionDate,1,@ProductionOutHeaderID OUTPUT 

								IF(@ProductionOutHeaderID IS NOT NULL)
								BEGIN
									INSERT INTO @ProductionOutHeaderTable (Id)
									values(@ProductionOutHeaderID)
								END
								END

							END

						END

						DELETE TOP (1) FROM #TempRecipeDetails
					END
				END
			END
			--End



			----------Added 4/1/21------------
		 DECLARE @ApprovalPrefix VARCHAR(MAX), @ApprovalCode VARCHAR(MAX)

		SELECT @IsApproval = IsApprovalForGRN,--@IsApprovalForIssueReturn = IsApprovalForIssueReturn,
		@IsAutoTransferGRN =IsAutoTransferGRN,@IsBudgetGRN = IsBudgetGRN 
		FROM Companies WHERE CompanyID = @PropertyID

		set @IsApproval = 0  --- added by vinuki 2024.06.18
		

		--IF(@IsApproval = 1 AND @SkipApproval = 0 AND (
		----@TransactionType = 'GR' 
		----OR   commented by vinuki 17.06.2024 commented as for grn approval the comapny bit is not considered 
		--@TransactionType = 'SR'))
		--BEGIN
			
		--	------------------------
		--	SELECT * INTO #TempGRNDetailsNew
		--	FROM
  --         #TempAllDetails WHERE Quantity > 0;

		--	WHILE(SELECT COUNT(*) FROM #TempGRNDetailsNew ) > 0
		--	BEGIN
		--		SELECT TOP(1) @Quantity = Quantity,@StockItemID = StockItemID  FROM #TempGRNDetailsNew


		--		IF @TransactionType='GR'
		--		BEGIN
		--			UPDATE PoDetails
		--			SET ReceivedQuantity = ReceivedQuantity + @Quantity
		--			WHERE PoHeaderID = @ReferenceID
		--				  AND StockItemID = @StockItemID;

  --              IF
  --              (
  --                  SELECT COUNT(*)
  --                  FROM PoDetails
  --                  WHERE PoHeaderID = @ReferenceID
  --                        AND ApprovedQuantity > ReceivedQuantity
  --              ) = 0 and @TransactionType='GR'
  --              BEGIN
  --                  UPDATE PoHeaders
  --                  SET DocumentStatus = 'C'
  --                  WHERE Id = @ReferenceID;
  --              END;

				

		--		END

		--		IF @TransactionType = 'SR'
		--		BEGIN
			
		--			UPDATE StockTransactionDetails
		--			SET ReturnQuantity = ReturnQuantity + @Quantity
		--			WHERE StockTransactionHeaderID = @ReferenceID
		--			AND StockItemID = @StockItemID;

		--		END;

		--	DELETE TOP(1) FROM #TempGRNDetailsNew
				
		--	END
			
		--	-------------Generate Doc No for GRN approval--------------------
		--	IF(@TransactionType = 'GR')
		--	BEGIN
		--		SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'GA');
		
		--		IF @DocumentNo IS NULL
		--		BEGIN

		--			INSERT INTO TransactionTypeWiseNextNumbers
		--			(
		--				PropertyID,
		--				LocationID,
		--				TransactionType,
		--				NextNumber,
		--				LengthOfFormatting
		--			)
		--			VALUES
		--			(@PropertyID, @LocationID, 'GA', 1, 6);

		--			SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'GA');

		--		END;

		--		SELECT @ApprovalPrefix = Prefix
		--		FROM dbo.Locations
		--		WHERE Id = @LocationID;
		--		SELECT @ApprovalCode = Code
		--		FROM dbo.TransactionTypes
		--		WHERE Code = 'GA';

		--		SELECT @ApprovalPrefix = SUBSTRING(@ApprovalPrefix, 1, 2)
	

		--		SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;

		--		UPDATE TransactionTypeWiseNextNumbers
		--		SET NextNumber = NextNumber + 1
		--		WHERE LocationID = @LocationID
		--		AND TransactionType =  'GA';

		--	END
		--	-------------Generate Doc No for GRN approval--------------------
		--	-------------Generate Doc No for SR approval--------------------
		--	IF(@TransactionType = 'SR')
		--	BEGIN
		--		SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'SA');
		
		--		IF @DocumentNo IS NULL
		--		BEGIN

		--			INSERT INTO TransactionTypeWiseNextNumbers
		--			(
		--				PropertyID,
		--				LocationID,
		--				TransactionType,
		--				NextNumber,
		--				LengthOfFormatting
		--			)
		--			VALUES
		--			(@PropertyID, @LocationID, 'SA', 1, 6);

		--			SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'SA');

		--		END;

				
		--		SELECT @ApprovalPrefix = Prefix
		--		FROM dbo.Locations
		--		WHERE Id = @LocationID;
		--		SELECT @ApprovalCode = Code
		--		FROM dbo.TransactionTypes
		--		WHERE Code =  'SA';

		--		SELECT @ApprovalPrefix =  SUBSTRING(@ApprovalPrefix, 1,3)
	
		--		SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;

		--		UPDATE TransactionTypeWiseNextNumbers
		--		SET NextNumber = NextNumber + 1
		--		WHERE LocationID = @LocationID
		--		AND TransactionType =  'SA';

		--	END
		--	-------------Generate Doc No for SR approval--------------------

		--	-----------------Added 30-04-2021------------------------------------------------
		--	DECLARE @POId INT,@InvoiceNo VARCHAR(350),@InvoiceError VARCHAR(350)

		--		SELECT  @InvoiceNo = REPLACE(ReferenceNo, '\', '/'),@POId = ReferenceID
		--		FROM OPENXML(@iDocID, '/StockTransactionHeader', 2) WITH (SuppCurrencyID INT,ReferenceNo VARCHAR(200),ReferenceID INT);


		--	IF EXISTS (SELECT (1) FROM dbo.GRNApprovalLog WHERE ReferenceID = @POId AND @ReferenceID <> 0 AND  ReferenceNo = @InvoiceNo AND TransactionType = 'GR' )
		--		BEGIN
		--			SET @InvoiceError =  'Cannot duplicate invoice number for this document!'
		--			RAISERROR ( @InvoiceError, 16, 1 );  
		--			ROLLBACK TRANSACTION
		--		END 
		--	-----------------Added 30-04-2021------------------------------------------------

		--	------2024-03-25 Validatting same invoice number inserting for same supplier------

		--	IF EXISTS (SELECT (1) FROM dbo.GRNApprovalLog WHERE  SupplierId = @SupplierID AND TransactionType = 'GR' AND ReferenceNo = @InvoiceNo AND ReferenceNo<>'FreeQty')
		--		BEGIN
		--			SET @InvoiceError =  'Cannot duplicate invoice number for Same Supplier!'
		--			RAISERROR ( @InvoiceError, 16, 1 );  
		--			ROLLBACK TRANSACTION
		--		END 

		--	--------END--------

		--	INSERT INTO [dbo].[GRNApprovalLog](SupplierId,LocationId,CreatedUserId,ReferenceId,XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo  )
		--	VALUES(@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),  @XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo)
		--	SELECT @docno = @DocumentNo
		--	set @status = 1
		--	set @message = ''
		--	set @headerid = SCOPE_IDENTITY()
		--END
		--ELSE 

		IF(@StockReconciliationIsApproval=1 AND @SkipApproval = 0 AND @TransactionType = 'AA')
        BEGIN
                ----------------------Stock Reconciliation 'AA' By Nivesh 2024-02-29---------------------------------
                        -------------Generate Doc No for Stock Reconciliation approval--------------------
                        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'AP');
                
                        SELECT @DocumentNo DocumentNo
                                IF @DocumentNo IS NULL
                                BEGIN
                                        INSERT INTO TransactionTypeWiseNextNumbers
                                        (
                                                PropertyID,
                                                LocationID,
                                                TransactionType,
                                                NextNumber,
                                                LengthOfFormatting
                                        )
                                        VALUES
                                        (@PropertyID, @LocationID, 'AP', 1, 6);
                                        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'AP');
                                END;
                                
                                SELECT @ApprovalPrefix = Prefix
                                FROM dbo.Locations
                                WHERE Id = @LocationID;
                                SELECT @ApprovalCode = Code
                                FROM dbo.TransactionTypes
                                WHERE Code =  'AP';
                                SELECT @ApprovalPrefix =  SUBSTRING(@ApprovalPrefix, 1,3)
        
                                SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;
                                UPDATE TransactionTypeWiseNextNumbers
                                SET NextNumber = NextNumber + 1
                                WHERE LocationID = @LocationID
                                AND TransactionType =  'AP';
                ---------------Transaction Type 'AA' into GRNApprovalLogs-----------------------
                                IF (@TransactionType = 'AA')
                                BEGIN
                                        insert into AAdata(propertyID,locationID,transactionID,TH)
                                        SELECT @PropertyID propertyID, @LocationID locationID, 10 transactionID,@StockTransactionHeaderID TH
                                        SELECT @LocationID = LocationID FROM StockTransactionHeaders where ID= @StockTransactionHeaderID
                                        DECLARE @UserProfileID INT
                                        SELECT @UserProfileID = UserProfileID
                                        FROM StockTransactionHeaders
                                        WHERE Id= @StockTransactionHeaderID
                                END
        ---------------------------------------------------------------------------------
		-------------------- START - Tharuka -2026-06-24 rangewise approval for Reconciliation --------------------------------------

							IF(@IsRangeWiseApproval = 1)
							BEGIN
								INSERT INTO [dbo].[GRNApprovalLog]
                                        (SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                                        XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
                                (SELECT
                                        SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
                                        @XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0
                                        FROM dbo.TransactionWiseApprovalTypes T
                                        INNER JOIN UserWiseApproveLevels U ON
                                        T.TransactionID = U.TransactionTypeID AND
                                        T.LocationID = U.LocationId AND
                                        T.PropertyID = U.PropertyId AND
                                        T.ApprovalTypeID = U.ApproveLevelID
                                WHERE   T.PropertyID = @PropertyID
                                        AND T.LocationID =   @LocationID  
                                        AND T.TransactionID = 10
										AND U.RangeFrom = 0 AND U.RangeTo = 0)

										SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT


										INSERT INTO [dbo].[GRNApprovalLog]
                                        (SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                                        XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
                                (SELECT
                                        SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
                                        @XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0
                                        FROM dbo.TransactionWiseApprovalTypes T
                                        INNER JOIN UserWiseApproveLevels U ON
                                        T.TransactionID = U.TransactionTypeID AND
                                        T.LocationID = U.LocationId AND
                                        T.PropertyID = U.PropertyId AND
                                        T.ApprovalTypeID = U.ApproveLevelID
                                WHERE   T.PropertyID = @PropertyID
                                        AND T.LocationID =   @LocationID  
                                        AND T.TransactionID = 10
										AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo)))

										SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

										IF (@ApprovalRowsInserted > 0)
										BEGIN
														SELECT @docno = @DocumentNo
														SET @status = 1
														SET @message = ''
														SET @headerid = SCOPE_IDENTITY()
														SET @IsApprovalEnable = 1
										END

							END 
							ELSE 
							BEGIN
							--------------------------------- end ---------------------------------------------
                                INSERT INTO [dbo].[GRNApprovalLog]
                                        (SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                                        XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
                                (SELECT
                                        SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
                                        @XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0
                                        FROM dbo.TransactionWiseApprovalTypes T
                                        INNER JOIN UserWiseApproveLevels U ON
                                        T.TransactionID = U.TransactionTypeID AND
                                        T.LocationID = U.LocationId AND
                                        T.PropertyID = U.PropertyId AND
                                        T.ApprovalTypeID = U.ApproveLevelID
                                WHERE   T.PropertyID = @PropertyID
                                        AND T.LocationID =   @LocationID  
                                        AND T.TransactionID = 10 )
								SET @IsApprovalEnable =1
        ------------------------------------------------------------------------------------
                        SELECT @docno = @DocumentNo
                        set @status = 1
                        set @message = ''
                        set @headerid = SCOPE_IDENTITY()
        -------------Generate Doc No for Stock Reconciliation approval--------------------
            END    
        END

		
		ELSE IF(@TransferNoteIsApproval=1 AND @SkipApproval = 0 AND @TransactionType = 'TO')
        BEGIN
                ----------------------Transfer Note 'TO' By ISURU 2025-12-10---------------------------------
                        -------------Generate Doc No for Transfer Note approval--------------------
                        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'TP');
                
                        SELECT @DocumentNo DocumentNo
                                IF @DocumentNo IS NULL
                                BEGIN
                                        INSERT INTO TransactionTypeWiseNextNumbers
                                        (
                                                PropertyID,
                                                LocationID,
                                                TransactionType,
                                                NextNumber,
                                                LengthOfFormatting
                                        )
                                        VALUES
                                        (@PropertyID, @LocationID, 'TP', 1, 6);
                                        SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'TP');
                                END;
                                
                                SELECT @ApprovalPrefix = Prefix
                                FROM dbo.Locations
                                WHERE Id = @LocationID;
                                SELECT @ApprovalCode = Code
                                FROM dbo.TransactionTypes
                                WHERE Code =  'TP';
                                SELECT @ApprovalPrefix =  SUBSTRING(@ApprovalPrefix, 1,3)
        
                                SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;
                                UPDATE TransactionTypeWiseNextNumbers
                                SET NextNumber = NextNumber + 1
                                WHERE LocationID = @LocationID
                                AND TransactionType =  'TP';
								-------------------- START - Tharuka -2026-06-24 rangewise approval for TO --------------------------------------

								IF(@IsRangeWiseApproval =1)
								BEGIN 
									INSERT INTO [dbo].[GRNApprovalLog]
                                        (SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                                        XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
									(SELECT
											SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,0,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
											@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,@TransferLocationID
											FROM dbo.TransactionWiseApprovalTypes T
											INNER JOIN UserWiseApproveLevels U ON
											T.TransactionID = U.TransactionTypeID AND
											T.LocationID = U.LocationId AND
											T.PropertyID = U.PropertyId AND
											T.ApprovalTypeID = U.ApproveLevelID
									WHERE   T.PropertyID = @PropertyID
											AND T.LocationID =   @LocationID  
											AND T.TransactionID = 5 
											AND U.RangeFrom = 0 AND U.RangeTo = 0)
									
									SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

										INSERT INTO [dbo].[GRNApprovalLog]
                                        (SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                                        XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
									(SELECT
											SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,0,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
											@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,@TransferLocationID
											FROM dbo.TransactionWiseApprovalTypes T
											INNER JOIN UserWiseApproveLevels U ON
											T.TransactionID = U.TransactionTypeID AND
											T.LocationID = U.LocationId AND
											T.PropertyID = U.PropertyId AND
											T.ApprovalTypeID = U.ApproveLevelID
									WHERE   T.PropertyID = @PropertyID
											AND T.LocationID =   @LocationID  
											AND T.TransactionID = 5 
											AND U.RangeFrom IS NOT NULL 
											AND U.RangeFrom <> 0
											AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo)))

										SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

										IF (@ApprovalRowsInserted > 0)
										BEGIN
														SELECT @docno = @DocumentNo
														SET @status = 1
														SET @message = ''
														SET @headerid = SCOPE_IDENTITY()
														SET @IsApprovalEnable = 1
										END

								END 
								--------------------------- end -----------------------------------------------

                ---------------Transaction Type 'AA' into GRNApprovalLogs-----------------------
								ELSE 
								BEGIN 
                                INSERT INTO [dbo].[GRNApprovalLog]
                                        (SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                                        XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
                                (SELECT
                                        SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,0,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
                                        @XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,@TransferLocationID
                                        FROM dbo.TransactionWiseApprovalTypes T
                                        INNER JOIN UserWiseApproveLevels U ON
                                        T.TransactionID = U.TransactionTypeID AND
                                        T.LocationID = U.LocationId AND
                                        T.PropertyID = U.PropertyId AND
                                        T.ApprovalTypeID = U.ApproveLevelID
                                WHERE   T.PropertyID = @PropertyID
                                        AND T.LocationID =   @LocationID  
                                        AND T.TransactionID = 5 )
								SET @IsApprovalEnable =1
        ------------------------------------------------------------------------------------
									SELECT @docno = @DocumentNo
									set @status = 1
									set @message = ''
									set @headerid = SCOPE_IDENTITY()
        -------------Generate Doc No for Stock Reconciliation approval--------------------
							END 
                
        END

		
		------------------------------------- GRN APPROVAL IF THERE IS APPROVALS SET 2024.06.13 added by vinuki --------------------------------
		ELSE IF(@IsGRNTransactionApproval = 1 AND @SkipApproval = 0 AND @TransactionType = 'GR')
		BEGIN
			
		--- Added by Isuru 2026-05-25 to update Invoice Status after GRN
			IF(@IsInvoiceBasedTransaction = 1 AND @TransactionType = 'GR')
			BEGIN
				select @ReferenceID ReferenceID 
				SELECT TransactionType,InvoiceDocStatus,*
				FROM StockTransactionHeaders WHERE ID = @ReferenceID


				IF EXISTS(SELECT 1 FROM StockTransactionHeaders WHERE ID = @ReferenceID AND TransactionType = 'BI' AND InvoiceDocStatus = 'C')
				BEGIN
					RAISERROR ( 'Document Already Completed!.', 16, 1 );  
					ROLLBACK TRANSACTION
				END

				UPDATE StockTransactionHeaders 
				SET InvoiceDocStatus = 'C'
				WHERE ID = @ReferenceID
				AND TransactionType = 'BI'

						
			END
		--End
			
			SELECT * INTO #TempGRNDetailsNew1
			FROM
           #TempAllDetails WHERE Quantity > 0;

		   DECLARE @TxnUnitID1 INT,@GRNQty2 DECIMAL(18,6)
			WHILE(SELECT COUNT(*) FROM #TempGRNDetailsNew1 ) > 0
			BEGIN
				SELECT TOP(1) @Quantity = Quantity,@StockItemID = StockItemID,@TxnUnitID1 = TxnUnitID 
				FROM #TempGRNDetailsNew1

				SET @GRNQty2  = dbo.FN_GetUnitConvertionRate(@propertyID,@TxnUnitID1,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,@StockItemID)) * @Quantity


				IF @TransactionType='GR'
				BEGIN
					UPDATE PoDetails
					SET ReceivedQuantity = ReceivedQuantity + 
					--(@Quantity/dbo.FN_GetUnitConvertionRate(@PropertyId,@TxnUnitID1,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,@StockItemID)))
					--Commented by Isuru 2026-02-12 to fix po qty converting issue
					(@GRNQty2/dbo.FN_GetUnitConvertionRate(@PropertyId,@TxnUnitID1,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,@StockItemID)))
					WHERE PoHeaderID = @ReferenceID
						  AND StockItemID = @StockItemID;

                IF
                (
                    SELECT COUNT(*)
                    FROM PoDetails
                    WHERE PoHeaderID = @ReferenceID
                          AND ApprovedQuantity > ReceivedQuantity
                ) = 0 and @TransactionType='GR'
                BEGIN
					IF EXISTS (SELECT 1 FROM PoHeaders WHERE ID = @ReferenceID AND DocumentStatus = 'C')
					BEGIN
					
						RAISERROR ( 'PO Document Already Completed', 16, 1 );  
						ROLLBACK TRANSACTION

					END
                    UPDATE PoHeaders
                    SET DocumentStatus = 'C'
                    WHERE Id = @ReferenceID;
                END;

					--Added by Isuru 2025-12-22 to validate invalid Location submitting with PO based GRN

					IF(@ReferenceID >0 and @TransactionType='GR')
					BEGIN
						SELECT @POLocationID = LocationID
						FROM PoHeaders PH
						WHERE Id = @ReferenceID 

						IF(@LocationID <> @POLocationID)
						BEGIN
							RAISERROR ( 'PO location and GRN location mismatch Found', 16, 1 );  
							ROLLBACK TRANSACTION
						END

					END
					--End
				END


			DELETE TOP(1) FROM #TempGRNDetailsNew1
				
			END
			
			-------------Generate Doc No for GRN approval--------------------
			IF(@TransactionType = 'GR')
			BEGIN
				SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'GA');
		
				IF @DocumentNo IS NULL
				BEGIN

					INSERT INTO TransactionTypeWiseNextNumbers
					(
						PropertyID,
						LocationID,
						TransactionType,
						NextNumber,
						LengthOfFormatting
					)
					VALUES
					(@PropertyID, @LocationID, 'GA', 1, 6);

					SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'GA');

				END;

				SELECT @ApprovalPrefix = Prefix
				FROM dbo.Locations
				WHERE Id = @LocationID;
				SELECT @ApprovalCode = Code
				FROM dbo.TransactionTypes
				WHERE Code = 'GA';

				SELECT @ApprovalPrefix = SUBSTRING(@ApprovalPrefix, 1, 3)
	

				SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;

				UPDATE TransactionTypeWiseNextNumbers
				SET NextNumber = NextNumber + 1
				WHERE LocationID = @LocationID
				AND TransactionType =  'GA';

			END


			-----------------Added 30-04-2021------------------------------------------------
			DECLARE @POId1 INT,@InvoiceNo1 VARCHAR(350),@InvoiceError1 VARCHAR(350)

				SELECT  @InvoiceNo1 = REPLACE(ReferenceNo, '\', '/'),@POId1 = ReferenceID
				FROM #TempStockTransactionHeader;


			IF EXISTS (SELECT (1) FROM dbo.GRNApprovalLog WITH (NOLOCK) WHERE ReferenceID = @POId1 
			AND @ReferenceID <> 0 
			AND  ReferenceNo = @InvoiceNo1 
			AND TransactionType = 'GR' 
			GROUP BY ReferenceID, ReferenceNo, TransactionType
			HAVING 
            SUM(CASE WHEN Status = 'X' THEN 1 ELSE 0 END) = 0 
			AND SUM(CASE WHEN Status IN ('C','P') THEN 1 ELSE 0 END) > 0 
			) -- AND Status <> 'X' added by Isuru 2026-04-21
			BEGIN
				SET @InvoiceError1 =  'Cannot duplicate invoice number for this document!'
				RAISERROR ( @InvoiceError1, 16, 1 );  
				ROLLBACK TRANSACTION
			END 
			-----------------Added 30-04-2021------------------------------------------------

			------2024-03-25 Validatting same invoice number inserting for same supplier------

			IF EXISTS (SELECT (1) FROM dbo.GRNApprovalLog WITH (NOLOCK) WHERE  SupplierId = @SupplierID 
			AND TransactionType = 'GR' 
			AND ReferenceNo = @InvoiceNo1 
			AND ReferenceNo<>'FreeQty' 
			GROUP BY SupplierId, ReferenceNo, TransactionType
			 HAVING 
			SUM(CASE WHEN Status = 'X' THEN 1 ELSE 0 END) = 0 
			AND SUM(CASE WHEN Status IN ('C','P') THEN 1 ELSE 0 END) > 0 
			) -- AND Status <> 'X' added by Isuru 2026-04-21
			BEGIN
				SET @InvoiceError1 =  'Cannot duplicate invoice number for Same Supplier!'
				RAISERROR ( @InvoiceError1, 16, 1 );  
				ROLLBACK TRANSACTION
			END 

			----------END--------

						------------------------------- START - Tharuka 2026-06-23 cutoff range approval -----------------------------------------

		

			IF(@IsRangeWiseApproval = 1)
			BEGIN 

				INSERT INTO [dbo].[GRNApprovalLog](SupplierId,LocationId,CreatedUserId,ReferenceId,XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo
					,IsComplete,StockTransactionHeaderID,UserProfileId,SeqID,ApprovalLevelID,ToLocationID)
				SELECT
				@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max), @XMLDetails),'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0,@StockTransactionHeaderID
				,U.UserProfileId,SeqID,ApprovalTypeID,0
				FROM dbo.TransactionWiseApprovalTypes T
				INNER JOIN UserWiseApproveLevels U ON
				T.TransactionID = U.TransactionTypeID AND
				T.LocationID = U.LocationId AND
				T.PropertyID = U.PropertyId AND
				T.ApprovalTypeID = U.ApproveLevelID
				WHERE T.PropertyID = @PropertyID
				AND T.LocationID = @LocationID  
				AND T.TransactionID = 3
				AND U.RangeFrom = 0 AND U.RangeTo = 0

				SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

          
				INSERT INTO [dbo].[GRNApprovalLog](SupplierId,LocationId,CreatedUserId,ReferenceId,XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo
					,IsComplete,StockTransactionHeaderID,UserProfileId,SeqID,ApprovalLevelID,ToLocationID)
				SELECT
				@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max), @XMLDetails),'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0,@StockTransactionHeaderID
				,U.UserProfileId,SeqID,ApprovalTypeID,0
				FROM dbo.TransactionWiseApprovalTypes T
				INNER JOIN UserWiseApproveLevels U ON
				T.TransactionID = U.TransactionTypeID AND
				T.LocationID = U.LocationId AND
				T.PropertyID = U.PropertyId AND
				T.ApprovalTypeID = U.ApproveLevelID
				WHERE T.PropertyID = @PropertyID
				AND T.LocationID = @LocationID  
				AND T.TransactionID = 3
				AND U.RangeFrom IS NOT NULL 
				AND U.RangeFrom <> 0
				AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) 
					 OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo))

				SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

				IF (@ApprovalRowsInserted > 0)
				BEGIN
					SELECT @docno = @DocumentNo
					SET @status = 1
					SET @message = ''
					SET @headerid = SCOPE_IDENTITY()
					SET @IsApprovalEnable = 1
				END

			END 
			ELSE
			BEGIN 
			--------------------------- END 2026-06-23 --------------------------------------------------------------------------
			-- ADDING TO THE GRN APPROVAL LOG 2024.06.13
				INSERT INTO [dbo].[GRNApprovalLog](SupplierId,LocationId,CreatedUserId,ReferenceId,XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo
				,IsComplete,StockTransactionHeaderID,UserProfileId,SeqID,ApprovalLevelID,ToLocationID)
				SELECT
				@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max), @XMLDetails),'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0,@StockTransactionHeaderID
				,U.UserProfileId,SeqID,ApprovalTypeID,0
				FROM dbo.TransactionWiseApprovalTypes T
				INNER JOIN UserWiseApproveLevels U ON
				T.TransactionID = U.TransactionTypeID AND
				T.LocationID = U.LocationId AND
				T.PropertyID = U.PropertyId AND
				T.ApprovalTypeID = U.ApproveLevelID
				WHERE T.PropertyID = @PropertyID
				AND T.LocationID = @LocationID  
				AND T.TransactionID = 3

				SELECT @docno = @DocumentNo
				SET @status = 1
				SET @message = ''
				SET @headerid = SCOPE_IDENTITY()
				SET @IsApprovalEnable = 1

			END

			-- When IsRangeWiseApproval = 1 but no rows matched any range,
			-- @IsApprovalEnable remains 0 and flow continues to direct insert below

			SELECT @docno = @DocumentNo
			SET @status = 1
			SET @message = ''
			SET @headerid = SCOPE_IDENTITY()
		END
			-------------------------------end ---------------------------------------
		------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		-- SRN APPROVAL IF THERE IS APPROVALS SET 2024.06.18 VINUKI ----------------------------------------------------------------------------
		ELSE IF(@IsSRNTransactionApproval = 1 AND @SkipApproval = 0 AND @TransactionType = 'SR')
		BEGIN
			
			DECLARE @TxnUnitID2 INT,@ReferencePOID INT,@ReturnItemName VARCHAR(MAX),@SRNError VARCHAR(350)

			SELECT * INTO #TempSRNDetails
			FROM
           #TempAllDetails WHERE Quantity > 0;

			WHILE(SELECT COUNT(*) FROM #TempSRNDetails ) > 0
			BEGIN
				SELECT TOP(1) @Quantity = Quantity,@StockItemID = StockItemID ,@TxnUnitID2 = TxnUnitID 
				FROM #TempSRNDetails

				SELECT @ReferencePOID =ReferenceID
				FROM StockTransactionHeaders
				WHERE ID = @ReferenceID

				SELECT @ReferenceID ReferenceID,@ReferencePOID ReferencePOID

				
				 --IF(@TransactionType = 'SR')
				 --BEGIN
					
					--UPDATE SD
					--SET SD.ReturnQuantity = ISNULL(SD.ReturnQuantity,0) + TD.Quantity
					--FROM StockTransactionDetails SD
					--INNER JOIN #TempAllDetails TD ON SD.StockItemID = TD.StockItemID
					--WHERE SD.StockTransactionHeaderID = @ReferenceID

				 --END

				 IF EXISTS(SELECT 1
				 FROM StockTransactionDetails SD
				 INNER JOIN #TempAllDetails TD ON SD.StockItemID = TD.StockItemID
				 WHERE SD.StockTransactionHeaderID = @ReferenceID
				 AND SD.Quantity < TD.Quantity)
				 BEGIN
					SELECT TOP 1 @ReturnItemName = SH.Name 
					FROM StockTransactionDetails SD
					INNER JOIN #TempAllDetails TD ON SD.StockItemID = TD.StockItemID
					INNER JOIN StockItemHeaders SH ON SH.ID= SD.StockItemID
					WHERE SD.StockTransactionHeaderID = @ReferenceID
					AND SD.Quantity < SD.ReturnQuantity

					SET @SRNError =  'Return Quantity cannot exceed received qunatity :-'+ ' '+@ReturnItemName
					RAISERROR ( @SRNError, 16, 1 );  
					ROLLBACK TRANSACTION	
				 END


				 IF EXISTS(SELECT 1 FROM #TempAllDetails WHERE Quantity > dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID))
				 BEGIN
					SELECT TOP 1  @ReturnItemName =  SH.Name
					FROM #TempAllDetails TD 
					INNER JOIN StockItemHeaders SH ON TD.StockItemID = SH.Id
					WHERE Quantity > dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)

					SET @SRNError =  'Quantity can''t exceed requested quantity'+ ' '+@ReturnItemName
					RAISERROR ( @SRNError, 16, 1 );  
					ROLLBACK TRANSACTION
				 END

				

				
				IF (@TransactionType='SR' AND @ReferencePOID <>0)
				BEGIN
					UPDATE PoDetails
					SET ReceivedQuantity = ReceivedQuantity +( @Quantity/dbo.FN_GetUnitConvertionRate(@PropertyId,@TxnUnitID2,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,@StockItemID)))
					WHERE PoHeaderID = @ReferenceID
						  AND StockItemID = @StockItemID;

                IF
                (
                    SELECT COUNT(*)
                    FROM PoDetails
                    WHERE PoHeaderID = @ReferenceID
                          AND ApprovedQuantity > ReceivedQuantity
                ) = 0 and @TransactionType='SR'
                BEGIN
				

                    UPDATE PoHeaders
                    SET DocumentStatus = 'C'
                    WHERE Id = @ReferenceID;

                END;	

				END


			DELETE TOP(1) FROM #TempSRNDetails
				
			END
			
			-------------Generate Doc No for GRN approval--------------------
			IF(@TransactionType = 'SR')
			BEGIN
				SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'SA');
		
				IF @DocumentNo IS NULL
				BEGIN

					INSERT INTO TransactionTypeWiseNextNumbers
					(
						PropertyID,
						LocationID,
						TransactionType,
						NextNumber,
						LengthOfFormatting
					)
					VALUES
					(@PropertyID, @LocationID, 'SA', 1, 6);

					SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'SA');

				END;

				SELECT @ApprovalPrefix = Prefix
				FROM dbo.Locations
				WHERE Id = @LocationID;
				SELECT @ApprovalCode = Code
				FROM dbo.TransactionTypes
				WHERE Code = 'SA';

				SELECT @ApprovalPrefix = SUBSTRING(@ApprovalPrefix, 1, 3)
	

				SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;

				UPDATE TransactionTypeWiseNextNumbers
				SET NextNumber = NextNumber + 1
				WHERE LocationID = @LocationID
				AND TransactionType =  'SA';

			END



			----------END--------
		----------------------------- START - Tharuka 2026-06-24 - rangewise approval for SRN --------------------------------------------------
		IF(@IsRangeWiseApproval =1)
		BEGIN 
			INSERT INTO [dbo].[GRNApprovalLog]
				(SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
				XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
			(SELECT
					SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
					@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
			WHERE   T.PropertyID = @PropertyID
					AND T.LocationID =   @LocationID  
					AND T.TransactionID = 4 
					AND U.RangeFrom = 0 AND U.RangeTo = 0)

				SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT


				INSERT INTO [dbo].[GRNApprovalLog]
				(SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
				XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
			(SELECT
					SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
					@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
			WHERE   T.PropertyID = @PropertyID
					AND T.LocationID =   @LocationID  
					AND T.TransactionID = 4 
					AND U.RangeFrom IS NOT NULL 
					AND U.RangeFrom <> 0
					AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo)))

				SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

				IF (@ApprovalRowsInserted > 0)
				BEGIN
					SELECT @docno = @DocumentNo
					SET @status = 1
					SET @message = ''
					SET @headerid = SCOPE_IDENTITY()
					SET @IsApprovalEnable = 1
				END
		END 
		ELSE 
		BEGIN

		-- ADDING TO THE SRN APPROVAL LOG 2024.06.13---------------------------------------------------------------------------------------------------------------------------
			INSERT INTO [dbo].[GRNApprovalLog]
					(SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
					XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
			(SELECT
					SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
					@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,0
					FROM dbo.TransactionWiseApprovalTypes T
					INNER JOIN UserWiseApproveLevels U ON
					T.TransactionID = U.TransactionTypeID AND
					T.LocationID = U.LocationId AND
					T.PropertyID = U.PropertyId AND
					T.ApprovalTypeID = U.ApproveLevelID
			WHERE   T.PropertyID = @PropertyID
					AND T.LocationID =   @LocationID  
					AND T.TransactionID = 4 )

				SELECT @docno = @DocumentNo
				set @status = 1
				set @message = ''
				set @headerid = SCOPE_IDENTITY()

				SET @IsApprovalEnable =1
		END
		END
		
		-----------------------------------------------------------------------------------------------------------------------------------------
		ELSE
		BEGIN
			IF(@IsApprovalForIssueReturn = 1 AND @SkipApproval = 0 AND @TransactionType = 'IR')
				BEGIN
					SELECT * INTO #TempIRDetails
					FROM
					#TempAllDetails  WHERE Quantity > 0;

					WHILE(SELECT COUNT(*) FROM #TempIRDetails ) > 0
					BEGIN
						SELECT TOP(1) @Quantity = Quantity,@StockItemID = StockItemID  FROM #TempIRDetails

						--select * from StockTransactionDetails WHERE StockTransactionHeaderID = 1
						--AND StockItemID = 1053;
												
						UPDATE StockTransactionDetails
						SET ReturnQuantity = ReturnQuantity + @Quantity
						WHERE StockTransactionHeaderID = @ReferenceID
						AND StockItemID = @StockItemID;

						--select * from StockTransactionDetails WHERE StockTransactionHeaderID = 1
						--AND StockItemID = 1053;

						DELETE TOP(1) FROM #TempIRDetails
					END

			-------------Generate Doc No for IR approval--------------------
			
			IF(@TransactionType = 'IR' AND @SkipApproval = 0)
			BEGIN
				SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'IA');

			
		
				IF @DocumentNo IS NULL
				BEGIN

					INSERT INTO TransactionTypeWiseNextNumbers
					(
						PropertyID,
						LocationID,
						TransactionType,
						NextNumber,
						LengthOfFormatting
					)
					VALUES
					(@PropertyID, @LocationID,  'IA', 1, 6);

					SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, 'IA');

				END;

				SELECT @ApprovalPrefix = Prefix
					FROM dbo.Locations
					WHERE Id = @LocationID;
					SELECT @ApprovalCode = Code
					FROM dbo.TransactionTypes
					WHERE Code =  'IA';

					SELECT @ApprovalPrefix =  SUBSTRING(@ApprovalPrefix, 1,3)

					SET @DocumentNo = @ApprovalPrefix + '/' + @ApprovalCode + '/' + @DocumentNo;

					UPDATE TransactionTypeWiseNextNumbers
					SET NextNumber = NextNumber + 1
					WHERE LocationID = @LocationID
					AND TransactionType =  'IA';

			END
			-------------Generate Doc No for IR approval--------------------


					--INSERT INTO [dbo].[GRNApprovalLog](SupplierId,LocationId,CreatedUserId,ReferenceId,XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo ,ToLocationID )
					--VALUES(@SupplierID,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),  @XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,0)
					--SELECT @docno = @DocumentNo
					--set @status = 1
					--set @message = ''
					--set @headerid = SCOPE_IDENTITY()
					DECLARE @TXNId INT,@RequestHeaderID INT
					-------------------- START - Tharuka -2026-06-24 rangewise approval for IR --------------------------------------
					IF(@IsRangeWiseApproval =1)
					BEGIN
					DECLARE @deptID INT;

					SELECT @deptID = DepartmentID  FROM #TempStockTransactionHeader

						INSERT INTO [dbo].[GRNApprovalLog](SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
						XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
						(SELECT SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,0,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
						@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,@TransferLocationID
						FROM dbo.TransactionWiseApprovalTypes T
							INNER JOIN UserWiseApproveLevels U ON
							T.TransactionID = U.TransactionTypeID AND
							T.LocationID = U.LocationId AND
							T.PropertyID = U.PropertyId AND
							T.ApprovalTypeID = U.ApproveLevelID
						WHERE   T.PropertyID = @PropertyID
							AND T.LocationID =   @LocationID  
							AND T.TransactionID = 7 
							AND U.RangeFrom = 0 AND U.RangeTo = 0)

						INSERT INTO [dbo].[GRNApprovalLog](SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
						XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
						(SELECT SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,0,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
						@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,@TransferLocationID
						FROM dbo.TransactionWiseApprovalTypes T
							INNER JOIN UserWiseApproveLevels U ON
							T.TransactionID = U.TransactionTypeID AND
							T.LocationID = U.LocationId AND
							T.PropertyID = U.PropertyId AND
							T.ApprovalTypeID = U.ApproveLevelID
						WHERE   T.PropertyID = @PropertyID
							AND T.LocationID =   @LocationID  
							AND T.TransactionID = 7 
							AND U.RangeFrom IS NOT NULL 
							AND U.RangeFrom <> 0
							AND ((U.RangeTo = 0 AND @TotalAmount >= U.RangeFrom) OR (U.RangeTo <> 0 AND @TotalAmount BETWEEN U.RangeFrom AND U.RangeTo)))

							SET @ApprovalRowsInserted = @ApprovalRowsInserted + @@ROWCOUNT

							SET @IsApprovalEnable =1
							IF (@ApprovalRowsInserted > 0)
							BEGIN
								SELECT @docno = @DocumentNo
								SET @status = 1
								SET @message = ''
								SET @headerid = SCOPE_IDENTITY()
								SET @RequestHeaderID = SCOPE_IDENTITY()
								SET @IsApprovalEnable = 1

								SELECT @TXNId = Id FROM TransactionTypes WHERE Code = @TransactionType

						

					
						EXEC dbo.SP_InsertApprovalLevelForRange @PropertyID, @LocationID,@TXNId, @RequestHeaderID, @deptID, @CreatedUserId, @TotalAmount
							END
					END

					ELSE 
					BEGIN
					------------------------------end ----------------------------------------------------
					INSERT INTO [dbo].[GRNApprovalLog](SeqID,ApprovalLevelID,IsComplete,UserProfileId,StockTransactionHeaderID,SupplierId,LocationId,CreatedUserId,ReferenceId,
                     XMLDetails,Status,TransactionType,CompanyId,CreatedDate,ApprovalDocNo,ReferenceNo,ToLocationID)
                      (SELECT SeqID,ApprovalTypeID,0,U.UserProfileId,@StockTransactionHeaderID,0,@LocationID,@CreatedUserId,@ReferenceID,convert(varchar(max),
						@XMLDetails) ,'P',@TransactionType,@PropertyID,GETDATE(),@DocumentNo,@ReferenceNo,@TransferLocationID
						FROM dbo.TransactionWiseApprovalTypes T
						INNER JOIN UserWiseApproveLevels U ON
						T.TransactionID = U.TransactionTypeID AND
						T.LocationID = U.LocationId AND
						T.PropertyID = U.PropertyId AND
						T.ApprovalTypeID = U.ApproveLevelID
				WHERE   T.PropertyID = @PropertyID
						AND T.LocationID =   @LocationID  
						AND T.TransactionID = 7 )

				SET @IsApprovalEnable =1
		------------------------------------------------------------------------------------
					SELECT @docno = @DocumentNo
					set @status = 1
					set @message = ''
					set @headerid = SCOPE_IDENTITY()

					SET @RequestHeaderID = SCOPE_IDENTITY()

					SET @IsApprovalEnable =1

					SELECT @TXNId = Id FROM TransactionTypes WHERE Code = @TransactionType

					--IF(@IsApproval = 0)
						EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID, @LocationID,@TXNId, @RequestHeaderID


					--INSERT  INTO dbo.ApprovalLogs( SeqID,TransactionID ,ApprovalLevelID ,TransactionHeaderID ,PropertyID 
					--,LocationID ,IsComplete ,DocStatus ,IPAddress ,CreatedUserID ,LastModUserID ,CreatedDate ,LastModDate ,ApprovalUserID
					--)
					--SELECT  GA.SeqID ,
					--TR.Id TransactionID ,
					--ApprovalTypeID ,
					--GA.ID TransactionHeaderID ,
					--@PropertyID ,
					--@LocationID  ,
					--0 ,
					--'P' ,
					--T.IPAddress,
					--@CreatedUserId,
					--@CreatedUserId,
					--GETDATE() ,
					--GETDATE() ,
					--U.UserProfileId
					
					--FROM    dbo.TransactionWiseApprovalTypes T
					--INNER JOIN UserWiseApproveLevels U ON 
					--T.TransactionID = U.TransactionTypeID AND T.LocationID = U.LocationId 
					--AND T.PropertyID = U.PropertyId AND T.ApprovalTypeID = U.ApproveLevelID
					--INNER JOIN TransactionTypes TR ON TR.ID = T.TransactionID
					--INNER JOIN GRNApprovalLog GA ON GA.LocationId = U.LocationId AND GA.TransactionType = TR.Code 
					--AND GA.ApprovalLevelID = U.ApproveLevelID

					--WHERE   T.PropertyID = @PropertyID 
					--AND T.LocationID =    @LocationID  
					--AND T.TransactionID = 7
					--AND MinValue = 0
					--AND GA.ApprovalDocNo = @DocumentNo



					END
				END
			ELSE
				BEGIN
					SELECT '12', @TransactionType TransactionType,@SkipApproval SkipApproval

					----------- ADDED BY VINUKI 18.06.2024 ----------------------
					--IF (@TransactionType = 'SR' AND @IsApproval = 0)
					--BEGIN
						
					--	UPDATE StockTransactionDetails
					--	SET ReturnQuantity = ReturnQuantity + @Quantity
					--	WHERE StockTransactionHeaderID = @ReferenceID
					--	AND StockItemID = @StockItemID;
					--END
					----------------------------------------------------------------
						------------------------------------------------------------------------------------------------------------------------------------------------------------
				--- for reconcilation added 07-12-2018 to pass frontEndDate-----------------------
				SELECT @txnDate = CASE
									  WHEN @TransactionType <> 'AA' AND @TransactionType <> 'IF' AND @TransactionType <> 'FW' AND @TransactionType <> 'RC' AND @TransactionType <>'PU' AND @TransactionType <>'PI' THEN
										 @txnDate
									  ELSE
										 ISNULL( @txnDateFromFront,@txnDate)
								  END;
				---------------------------------------------------------------------------------- 
				DECLARE @ExchangeRate DECIMAL(18,6) = 1;
				DECLARE @SuppCurrencyID INT = 0, @InvNo VARCHAR(200), @PORefId INT, @InvError VARCHAR(MAX)


				IF (@TransactionType = 'GR')
				BEGIN
		

					SELECT @SuppCurrencyID = SuppCurrencyID, @InvNo =REPLACE(ReferenceNo, '\', '/'),@PORefId = ReferenceID
					FROM
						#TempStockTransactionHeader ;

					SELECT @ExchangeRate = ISNULL(
										   (
											   SELECT top(1) ExchangeRate FROM Currency WHERE CurrencyId = @SuppCurrencyID order by Date desc
										   ),
										   0
												 );


				IF EXISTS (SELECT (1) FROM dbo.StockTransactionHeaders WITH (NOLOCK) WHERE ReferenceID = @PORefId AND @ReferenceID <> 0 AND  ReferenceNo = @InvNo AND TransactionType = 'GR' )
				BEGIN
							SET @InvError =  'Cannot duplicate invoice number for this document!'
							RAISERROR ( @InvError, 16, 1 );  
							ROLLBACK TRANSACTION
				END 



				------2024-03-25 Validatting same invoice number inserting for same supplier------
				IF EXISTS (SELECT (1) FROM dbo.StockTransactionHeaders WITH (NOLOCK) WHERE SupplierID = @SupplierID AND  ReferenceNo = @InvNo AND TransactionType = 'GR' AND ReferenceNo <>'FreeQty')
				BEGIN
					SET @InvError =  'Cannot duplicate invoice number for same Supplier'
					RAISERROR ( @InvError, 16, 1 );  
					ROLLBACK TRANSACTION
				END 
				----------End-----------------------------------

				END;
				------------------------------------------------------------------------------------------------------------------------------------------------------------

				SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);
		
				IF @DocumentNo IS NULL
				BEGIN

					INSERT INTO TransactionTypeWiseNextNumbers
					(
						PropertyID,
						LocationID,
						TransactionType,
						NextNumber,
						LengthOfFormatting
					)
					VALUES
					(@PropertyID, @LocationID, @TransactionType, 1, 6);

					SET @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);

				END;


				DECLARE @Prefix VARCHAR(MAX),
						@Code VARCHAR(MAX);

				SELECT @Prefix = Prefix
				FROM dbo.Locations
				WHERE Id = @LocationID;
				SELECT @Code = Code
				FROM dbo.TransactionTypes
				WHERE Code = @TransactionType;


			

				

				SELECT @Prefix = CASE
									 WHEN @TransactionType = 'GR' THEN
										 SUBSTRING(@Prefix, 1, 3) -- ADDED BY Isuru 2025-05-07 to save Documentn no with 3 prefx
									 ELSE
										 SUBSTRING(@Prefix, 1, 3)
								 END;

				--SELECT @Prefix

				SET @DocumentNo = @Prefix + '/' + @Code + '/' + @DocumentNo;
				--SELECT @DocumentNo


				

				if (@TransactionType <> 'GR')  -- added by vinuki 13.06.2024
				begin
				UPDATE TransactionTypeWiseNextNumbers
				SET NextNumber = NextNumber + 1
				WHERE LocationID = @LocationID
					  AND TransactionType = @TransactionType;
				end


				if (@TransactionType <> 'GR' and  @TransactionType <> 'SR')  -- added by vinuki 13.06.2024
				begin
			
				INSERT INTO StockTransactionHeaders
				(
					Mode,
					DocumentNo,
					TransactionType,
					TransactionDate,
					LocationID,
					PropertyID,
					ReferenceNo,
					SupplierID,
					Remarks,
					ReferenceID,
					DepartmentID,
					UserProfileID,
					TransferLocationID,
					TransactionID,
					SuppCurrencyID,
					ExchangeRate,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					InvoiceDate,
					IsDirectIssue,
					GRNTypeID,
					IsProdGenerate,
					IsProductionPlan,
					FileName,
					PaxCount,
					IsAutoTrasferGRN --For identify auto transfer GRN - Added by Nivesh 2025-11-07
					,InvoiceLocationID
					,IsInvoiceBasedTransaction -- for identifying InvoiceBasedTransactions by Isuru 2026-05-25
					,InvoiceDocStatus
					,SubmitToken                 --added by isuru 2026-08-06  Reason: store idempotency token (TO only)
					,TaxInvoiceNumber            --added by <name> 2026-08-14  Gazette 2463/05 VAT invoice serial
					,InvoiceDueDate                --Added by Tharuka 2026-08-18
				)
				(SELECT @TxnType,
						@DocumentNo,
						TransactionType,
						@txnDate,
						LocationID,
						PropertyID,
						REPLACE(ReferenceNo, '\', '/'),
						SupplierID,
						Remarks,
						ReferenceID,
						DepartmentID,
						UserProfileID,
						TransferLocationID,
						dbo.FN_getTransactionID(TransactionType),
						SuppCurrencyID,
						@ExchangeRate,
						CreatedUserID,
						LastModUserID,
						GETDATE(),
						GETDATE(),
						InvoiceDate,
						IsDirectIssue,
						GRNTypeID,
						@IsProdGenerate,
						@IsProductionPlan,
						@FileName,
						PaxCount,
						CASE WHEN @IsAutoTransferGRN = 1 AND @TransactionType = 'TO' THEN  IsAutoTrasferGRN ELSE 0 END --For identify auto transfer GRN - Added by Nivesh 2025-11-07
						,InvoiceLocationID
						,IsInvoiceBasedTransaction, -- for identifying InvoiceBasedTransactions by Isuru 2026-05-25
						CASE WHEN TransactionType = 'BI' THEN 'P' ELSE NULL END
						--added by isuru 2026-08-06  Reason: persist token only for Transfer OUT; other types stay NULL
						,CASE WHEN @TransactionType in ('TO','TI','AA') THEN @SubmitToken ELSE NULL END
						,@TaxInvoiceNumber       --added by <name> 2026-08-14  NULL for every type except BI
						,CASE WHEN TransactionType = 'BI' THEN InvoiceDueDate ELSE NULL END --Added by Tharuka 2026-08-18  NULL for every type except BI
				 FROM
					 #TempStockTransactionHeader);
				end
					


				DECLARE @StockTransactionwiseChangesID BIGINT, @RequestNo VARCHAR(500);

				DECLARE @TempPropertyID INT, @TempDocNo NVARCHAR(20), @TempRowCount INT, @TempRowCount2 INT


				SELECT @StockTransactionHeaderID = SCOPE_IDENTITY();


				select 'StockTransactionHeaders',*
				from StockTransactionHeaders
				where id=@StockTransactionHeaderID


				
				--Inserting into Audit Log Table 2025-05-14
				EXEC Inventry_AuditTail_WriteToLog 'StockTransactionHeaders', @StockTransactionHeaderID, 'INV', 'STHI', 'I', @CreatedUserId,@PropertyID, '', ''

				--End

				

				----------------Transaction Type AA update PU ------------------
				IF(@TransactionType IN('TO','AA','IF') AND @IsAutoProduction =1)
				BEGIN
					DECLARE @StockReconciliationDocumentNo VARCHAR(50)

					IF EXISTS(SELECT 1 FROM @ProductionOutHeaderTable)
					BEGIN
					
					SELECT @StockReconciliationDocumentNo =DocumentNo FROM StockTransactionHeaders WHERE Id = @StockTransactionHeaderID AND TransactionType = 'AA'
						
						UPDATE sh
						SET ReferenceID = @StockTransactionHeaderID,
						ReferenceNo = @StockReconciliationDocumentNo
						FROM
						StockTransactionHeaders SH
						INNER JOIN @ProductionOutHeaderTable P ON P.ID = SH.Id
						WHERE SH.TransactionType = 'PU'

					END
				END
				----------------------------------

				update tempStockTran
				set StockTransactionHeaderID = @StockTransactionHeaderID
				where ID = @tempStockTranId


				
				---ADDED BY Isuru 2023-07-13
				IF(@TransactionType in ('AA','GR'))
				BEGIN
				UPDATE [dbo].[GRNApprovalLog]
				SET [StockTransactionHeaderID] =@StockTransactionHeaderID
				WHERE Id = @GRNApprovalID
				AND TransactionType = @TransactionType

				END	 
					
                                ----------------------Stock Reconciliation Added By Nivesh 2024-03-01--------------------------------------------------------------
                SELECT @TempPropertyID =CompanyId ,@TempDocNo =ApprovalDocNo FROM [dbo].[GRNApprovalLog] WHERE Id = @GRNApprovalID
				
				--UPDATE [dbo].[GRNApprovalLog]
				--SET [StockTransactionHeaderID] =@StockTransactionHeaderID
				--WHERE ApprovalDocNo = @TempDocNo AND CompanyId= @TempPropertyID
				
				IF(@TransactionType = 'AA')
				BEGIN
					SELECT @TempRowCount = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND CompanyId = @TempPropertyID
						
					SELECT @TempRowCount2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNo AND Status ='C' AND CompanyId = @TempPropertyID

					IF(@TempRowCount=@TempRowCount2)
					BEGIN
						UPDATE [dbo].[GRNApprovalLog]
						SET IsComplete =1
						WHERE ApprovalDocNo = @TempDocNo AND CompanyId= @TempPropertyID
					END
				END

				--------------------------------------- 13.06.2024 VINUKI  FOR GRN APPROVAL---------------------------------------------------------------------------------------------

				DECLARE @RowCount INT , @RowCount2 INT , @TempDocNogrn varchar(60) , @TempIsComplete int
				SELECT @TempPropertyID =CompanyId ,@TempDocNogrn =ApprovalDocNo FROM [dbo].[GRNApprovalLog] WHERE Id = @GRNApprovalID
				DECLARE @LastInsertedID INT;


				
				--select @TempDocNogrn TempDocNogrn2323


				IF(@TransactionType = 'GR')
				BEGIN
				--select 99999
				--select @TempPropertyID ffref

					SELECT @RowCount = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNogrn AND CompanyId = @TempPropertyID

					SELECT @RowCount2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNogrn AND Status ='C' AND CompanyId = @TempPropertyID
					SELECT @TempIsComplete = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNogrn AND Status ='C' AND CompanyId = @TempPropertyID

					IF(@RowCount=@RowCount2)
					BEGIN

					--select @TempDocNogrn TempDocNogrn
					--select 23232322
					-- commented by vinuki 14.06.2024
					if (ISNULL(@StockTransactionHeaderQuantity,0) <= 0) -- if block added by vinuki on 17.06.2024
					begin 
					raiserror('Zero Quantity Cannot Be added' , 16,0)
					end
					else
					begin

			--------------Update transaction header id the GRN with free quantity and firstly approve Orginal GRN--------Added by Nivesh 2024-10-25
				DECLARE @TempGRNLogRefNo INT, @TempGRNLogRefID INT ;
				SELECT @TempGRNLogRefNo = ReferenceId FROM GRNApprovalLog WHERE Id = @GRNApprovalID AND ReferenceNo ='FreeQty'

				IF @TempGRNLogRefNo IS NOT NULL
				BEGIN
					SELECT @TempGRNLogRefID= StockTransactionHeaderID FROM GRNApprovalLog WHERE Id = @TempGRNLogRefNo;

				END
				---------------------------------
				INSERT INTO StockTransactionHeaders
				(
					Mode,
					DocumentNo,
					TransactionType,
					TransactionDate,
					LocationID,
					PropertyID,
					ReferenceNo,
					SupplierID,
					Remarks,
					ReferenceID,
					DepartmentID,
					UserProfileID,
					TransferLocationID,
					TransactionID,
					SuppCurrencyID,
					ExchangeRate,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					InvoiceDate,
					IsDirectIssue,
					GRNTypeID,
					BudgetID,
					IsProdGenerate,
					IsProductionPlan,
					FileName,
					SubstractNetValue
					,IsInvoiceBasedTransaction -- for identifying InvoiceBasedTransactions by Isuru 2026-05-25
					,SubmitToken

				)
				(SELECT @TxnType,
						@DocumentNo,
						TransactionType,
						@txnDate,
						LocationID,
						PropertyID,
						REPLACE(ReferenceNo, '\', '/'),
						SupplierID,
						Remarks,
						CASE WHEN @TempGRNLogRefID IS NULL THEN ReferenceID ELSE @TempGRNLogRefID END, --------Modifyied by Nivesh 2024-10-25
						DepartmentID,
						UserProfileID,
						TransferLocationID,
						dbo.FN_getTransactionID(TransactionType),
						SuppCurrencyID,
						@ExchangeRate,
						CreatedUserID,
						LastModUserID,
						GETDATE(),
						GETDATE(),
						InvoiceDate,
						IsDirectIssue,
						GRNTypeID,
						@BudgetID,
						@IsProdGenerate,
						@IsProductionPlan,
						@FileName,
						CASE WHEN @IsSubstractNetTotal = 1 THEN @SubstractNetValue ELSE 0 END --Added by Nivesh 2025-08-22
						,IsInvoiceBasedTransaction -- for identifying InvoiceBasedTransactions by Isuru 2026-05-25
						,@SubmitToken
					FROM #TempStockTransactionHeader);
					 SET @LastInsertedID = SCOPE_IDENTITY();
					 set @StockTransactionHeaderID = @LastInsertedID

					--Inserting into Audit Log Table 2025-05-14
				EXEC Inventry_AuditTail_WriteToLog 'StockTransactionHeaders', @StockTransactionHeaderID, 'INV', 'STHI', 'I', @CreatedUserId,@PropertyID, '', ''

				--End
		
					 -- setting is cmplete n headerid to the grlapprovalLog table 13.06.2024 - vinuki 
						UPDATE [dbo].[GRNApprovalLog]
						SET IsComplete =1 , StockTransactionHeaderID = @StockTransactionHeaderID
						WHERE ApprovalDocNo = @TempDocNogrn AND CompanyId= @TempPropertyID 


					--- Added by Isuru 2026-05-25 to update Invoice Status after GRN
					IF(@IsInvoiceBasedTransaction = 1 AND @TransactionType = 'GR')
					BEGIN
						IF EXISTS(SELECT 1 FROM StockTransactionHeaders WHERE ID = @ReferenceID AND TransactionType = 'BI' AND InvoiceDocStatus = 'C' 
						and @TempDocNogrn IS NULL)
						BEGIN
							RAISERROR ( 'Document Already Completed!.', 16, 1 );  
							ROLLBACK TRANSACTION
						END

						UPDATE StockTransactionHeaders 
						SET InvoiceDocStatus = 'C'
						WHERE ID = @ReferenceID
						AND TransactionType = 'BI'

						
					END
					--End
				
				--------------Update transaction header id the GRN with free quantity and firstly approve free quantity GRN--------Added by Nivesh 2024-10-25
				SELECT @TempGRNLogRefNo = StockTransactionHeaderID FROM GRNApprovalLog WHERE ReferenceId = @GRNApprovalID AND ReferenceNo = 'FreeQty'

				IF @TempGRNLogRefNo IS NOT NULL
				BEGIN
					UPDATE StockTransactionHeaders
					SET ReferenceID = @StockTransactionHeaderID
					WHERE Id = @TempGRNLogRefNo;

				END
				------------------------------------
				UPDATE TransactionTypeWiseNextNumbers
				SET NextNumber = NextNumber + 1
				WHERE LocationID = @LocationID
				AND TransactionType = @TransactionType;
			
				end
					END

		--Added by Isuru 2025-04-23 for Contracted Supplier changes---
		IF(@IsContractedSupplier =1 AND @TransactionType ='GR')
		BEGIN

			INSERT INTO ContracterChangeReason(PropertyID, LocationID, StockItemID, TransactionHeaderID, TransactionType, 
			SupplierID, SupplierPrice, ContractedSupplierID, ContractSupplierPrice, ContractSupplierChangeReason, CreatedUserID,CreatedDate)
			SELECT @PropertyID,@LocationID,StockItemID,@StockTransactionHeaderID,'GR',@SupplierID,UnitPrice,ContractSupplierID,ContractSupplierPrice,ContractSupplierReason
			,@CreatedUserId,GETDATE()
			FROM #TempContractSupplier
			WHERE ContractSupplierID <> 0

		END


		---End----
					





				END
				--------------------------------------------------------------------------------------------------------------------------------------------------


				--------------------------------------- 18.06.2024 VINUKI  FOR SRN APPROVAL---------------------------------------------------------------------------------------------

				DECLARE @RowCountSR INT , @RowCountSR2 INT , @TempDocNoSrn varchar(60) , @TempIsCompleteSR int , @TempPropertyIDSR INT
				SELECT @TempPropertyIDSR =CompanyId ,@TempDocNoSrn =ApprovalDocNo FROM [dbo].[GRNApprovalLog] WHERE Id = @GRNApprovalID
				DECLARE @LastInsertedIDSR INT;

				IF(@TransactionType = 'SR')
				BEGIN
						
					SELECT @RowCountSR = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNoSrn AND CompanyId = @TempPropertyIDSR
				

					SELECT @RowCountSR2= COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNoSrn AND Status ='C' AND CompanyId = @TempPropertyIDSR
				
					SELECT @TempIsCompleteSR = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNoSrn AND IsComplete = 1 AND CompanyId = @TempPropertyIDSR

					select 'supplier return part'
					select @RowCountSR RowCountSR,@RowCountSR2 RowCountSR2,@TempIsCompleteSR TempIsCompleteSR

				IF(@RowCountSR=@RowCountSR2)
				BEGIN
								
				INSERT INTO StockTransactionHeaders
				(
					Mode,
					DocumentNo,
					TransactionType,
					TransactionDate,
					LocationID,
					PropertyID,
					ReferenceNo,
					SupplierID,
					Remarks,
					ReferenceID,
					DepartmentID,
					UserProfileID,
					TransferLocationID,
					TransactionID,
					SuppCurrencyID,
					ExchangeRate,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					InvoiceDate,
					IsDirectIssue,
					GRNTypeID,
					IsProdGenerate,
					FileName,
					IsInvoiceBasedTransaction --Added by Tharuka 2026-09-15 for BI return process
				)
				(SELECT @TxnType,
						@DocumentNo,
						TransactionType,
						@txnDate,
						LocationID,
						PropertyID,
						REPLACE(ReferenceNo, '\', '/'),
						SupplierID,
						Remarks,
						ReferenceID,
						DepartmentID,
						UserProfileID,
						TransferLocationID,
						dbo.FN_getTransactionID(TransactionType),
						SuppCurrencyID,
						@ExchangeRate,
						CreatedUserID,
						LastModUserID,
						GETDATE(),
						GETDATE(),
						InvoiceDate,
						IsDirectIssue,
						GRNTypeID,
						@IsProdGenerate,
						@FileName,
						ISNULL(IsInvoiceBasedTransaction, 0) --Added by Tharuka 2026-09-15 for BI return process
				 FROM
					 #TempStockTransactionHeader);
					 SET @LastInsertedIDSR = SCOPE_IDENTITY();
					 set @StockTransactionHeaderID = @LastInsertedIDSR
			
					--Inserting into Audit Log Table 2025-05-14
				EXEC Inventry_AuditTail_WriteToLog 'StockTransactionHeaders', @StockTransactionHeaderID, 'INV', 'STHI', 'I', @CreatedUserId,@PropertyID, '', ''

				--End


					 -- setting is cmplete n headerid to the grlapprovalLog table 13.06.2024 - vinuki 
						UPDATE [dbo].[GRNApprovalLog]
						SET IsComplete =1 , StockTransactionHeaderID = @StockTransactionHeaderID
						WHERE ApprovalDocNo = @TempDocNoSrn AND CompanyId= @TempPropertyIDSR 

				--UPDATE TransactionTypeWiseNextNumbers
				--SET NextNumber = NextNumber + 1
				--WHERE LocationID = @LocationID
				--AND TransactionType = @TransactionType; -- Commented by Nivesh 2024-11-22 because when the transaction is 'SR', the document number updates twice



					
			-------------------------------------------- 18.06.2024 updates the approved quantity to the table - vinuki -----------------------------------------
			SELECT * INTO #TempGRNDetailsNew
			FROM
           #TempAllDetails WHERE Quantity > 0;



		   ---ADDED BY Isuru 2026-05-21 to validate Qty when doing SRN
		   DECLARE @ReturnItemName2 VARCHAR(MAX),@SRNError2 VARCHAR(MAX)
		   
		   IF EXISTS(SELECT 1
		   FROM #TempGRNDetailsNew TD
		   INNER JOIN StockTransactionDetails SD ON TD.StockItemID = SD.StockItemID
		   WHERE SD.StockTransactionHeaderID = @ReferenceID
		   AND SD.Quantity < SD.ReturnQuantity)
		   BEGIN
				SELECT TOP 1 @ReturnItemName = SH.Name 
			   FROM #TempGRNDetailsNew TD
			   INNER JOIN StockTransactionDetails SD ON TD.StockItemID = SD.StockItemID
			   	INNER JOIN StockItemHeaders SH ON SH.ID= SD.StockItemID
				WHERE SD.StockTransactionHeaderID = @ReferenceID
			   AND SD.Quantity < SD.ReturnQuantity
			  
			   SET @SRNError =  'Return Quantity cannot exceed received qunatity :-'+ ' '+@ReturnItemName
				RAISERROR ( @SRNError, 16, 1 );  
				ROLLBACK TRANSACTION	

		   END



			IF EXISTS(SELECT 1 FROM #TempGRNDetailsNew WHERE Quantity > dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID))
			BEGIN
				SELECT TOP 1  @ReturnItemName =  SH.Name
				FROM #TempGRNDetailsNew TD 
				INNER JOIN StockItemHeaders SH ON TD.StockItemID = SH.Id
				WHERE Quantity > dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)

				SET @SRNError =  'Quantity can''t exceed requested quantity'+ ' '+@ReturnItemName
				RAISERROR ( @SRNError, 16, 1 );  
				ROLLBACK TRANSACTION
			END
		   --End

		   IF(@TempIsCompleteSR = 0) --Added by Isuru 2026-06-01 to fix return qty double update
		   BEGIN
				--WHILE(SELECT COUNT(*) FROM #TempGRNDetailsNew ) > 0      --Commented By Isuru 2026-08-13 for update return quantity in SRN
				--BEGIN
				--	SELECT TOP(1) @Quantity = Quantity,@StockItemID = StockItemID  FROM #TempGRNDetailsNew
						

							SELECT 'UPDATED --- 2'

							UPDATE SD
							SET    SD.ReturnQuantity = ISNULL(SD.ReturnQuantity,0) + TD.Quantity
							FROM   StockTransactionDetails SD
							INNER JOIN (SELECT StockItemID, SUM(Quantity) AS Quantity
							FROM #TempGRNDetailsNew
							GROUP BY StockItemID) TD ON TD.StockItemID = SD.StockItemID
							WHERE  SD.StockTransactionHeaderID = @ReferenceID;

				--	DELETE TOP(1) FROM #TempGRNDetailsNew
				--END
			END
			-------------------------------------------------------------------------------------------------------------------------------------------------------
				
					END
				END
				--------------------------------------------------------------------------------------------------------------------------------------------------


				--END

				/*BEGIN AdditionalChargesList */ --added by IsuruT 2023-03-02
                Insert into StockTransactionwiseCharges ( [StockTransactionHeaderID], [AdditionalChargeID], [ChargeAmount], [AddedToItemCost])
                select @StockTransactionHeaderID, AdditionalChargeID, ChargeAmount,AddedToItemCost from
                #TempStockTransactionwiseCharges
                /*END  AdditionalChargesList */
				
				-- ADDED BY ISURUT 2023-03-02
				SELECT @addtionalCostAddToCostTrue = SUM(ChargeAmount)
				FROM StockTransactionwiseCharges
				WHERE StockTransactionHeaderID = @StockTransactionHeaderID
				AND AddedToItemCost = 1;

			
				SELECT @addtionalCostAddToCostFalse = SUM(ChargeAmount)
				FROM StockTransactionwiseCharges
				WHERE StockTransactionHeaderID = @StockTransactionHeaderID
				AND AddedToItemCost = 0;

				SET @addtionalCostTotal = @addtionalCostAddToCostTrue+ @addtionalCostAddToCostFalse
				--END 

				SELECT @RequestNo = ReferenceNo FROM StockTransactionHeaders WHERE Id = @StockTransactionHeaderID

				IF(@TransactionType = 'TI')
				BEGIN
					DECLARE @TODocNo VARCHAR(50),@TOReferID INT
					SELECT @TODocNo= DocumentNo, @TOReferID = ReferenceID FROM StockTransactionHeaders WHERE Id = @StockID AND TransactionType = 'TO'
					
					IF EXISTS(SELECT 1 FROM StockTransactionHeaders WHERE Id = @StockID AND TransactionType = 'TO' AND IsTrasferIn = 1)
					BEGIN
						RAISERROR ( 'Document Already Completed!.', 16, 1 );  
						ROLLBACK TRANSACTION
					END
				IF(@IsModifyTransferIn =0)
				BEGIN
					UPDATE StockTransactionHeaders
					SET IsTrasferIn = 1
					--WHERE ReferenceNo = @RequestNo AND TransactionType = 'TO'
					WHERE Id = @StockID AND TransactionType = 'TO'-- ADDED BY ISURU
				END
				ELSE
				BEGIN
					

					DECLARE @ItemIDModTran INT, @QuantityModTran INT, @BalanceQuantityModTran INT

					IF EXISTS(SELECT 1 FROM #TempAllDetailsModifyTran   )
					BEGIN
						IF EXISTS (SELECT 1
							FROM #TempAllDetailsModifyTran
							GROUP BY StockTransactionHeaderID
							HAVING SUM(CASE WHEN BalanceQuantity <> IssuedQuantity THEN 1 ELSE 0 END) = 0)
						BEGIN
							UPDATE StockTransactionHeaders
							SET IsTrasferIn = 1
							WHERE Id = @StockID AND TransactionType = 'TO'
						END

						WHILE EXISTS (SELECT 1 FROM #TempAllDetailsModifyTran )
						BEGIN
							SELECT TOP 1 @ItemIDModTran = StockItemID, @QuantityModTran = Quantity, @BalanceQuantityModTran= BalanceQuantity FROM #TempAllDetailsModifyTran;
							
							IF(@QuantityModTran > @BalanceQuantityModTran)
							BEGIN
								RAISERROR ( 'Quantity can''t exceed requested quantity', 16, 1 );  
								ROLLBACK TRANSACTION
							END
							UPDATE StockTransactionDetails
							SET IssuedQuantity =IssuedQuantity+ @QuantityModTran
							WHERE StockTransactionHeaderID =@StockID AND StockItemID = @ItemIDModTran

							DELETE TOP (1) FROM #TempAllDetailsModifyTran ;
						END
					END	
					
				END
					

					--UPDATE StockTransactionHeaders
					--SET ReferenceID = @StockID,
					--ReferenceNo = @TODocNo
					----WHERE ReferenceNo = @RequestNo AND TransactionType = 'TO'
					--WHERE Id = @StockTransactionHeaderID AND TransactionType = 'TI' AND @TOReferID =-999 --Added by Nivesh for adding reference for Direct TransferNote
					UPDATE StockTransactionHeaders
					SET ReferenceID = @StockID,
					ReferenceNo = @TODocNo
					--WHERE ReferenceNo = @RequestNo AND TransactionType = 'TO'
					WHERE Id = @StockTransactionHeaderID AND TransactionType = 'TI' --Added by Nivesh for adding reference for Direct TransferNote


				END 
				ELSE IF(@TransactionType = 'IF')
				BEGIN
					UPDATE StockTransactionHeaders
					SET GLDate= TransactionDate
					WHERE ID = @StockTransactionHeaderID
				END
				ELSE IF(@TransactionType = 'RC')
				BEGIN
					UPDATE StockTransactionHeaders
					SET GLDate= TransactionDate
					WHERE ID = @StockTransactionHeaderID
				END
				ELSE IF(@TransactionType = 'FW')
				BEGIN
					UPDATE StockTransactionHeaders
					SET GLDate= TransactionDate
					WHERE ID = @StockTransactionHeaderID
				END
				--print @addtionalCostTotal //comment by Nivesh 2024-01-31
		
				SELECT @addtionalCostPre = (@addtionalCostTotal / SUM(UnitPrice * Quantity * 1.0000)) * 100.0000
				FROM
				#TempAllDetails WHERE Quantity > 0;
				--print @addtionalCostPre //comment by Nivesh 2024-01-31
		
				--------------------------------------------------------------

				SET @addtionalCostPre = ISNULL(@addtionalCostPre, 0);

				SET @addtionalCostTotal = ISNULL(@addtionalCostTotal, 0);


	
				EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

					------added 8/3/2022------
				CREATE TABLE #tempTxnDetails(
				[Id] [int] IDENTITY(1,1) NOT NULL,
				[StockTransactionHeaderID] [int] ,
				[StockItemID] [int],
				[Quantity] [decimal](18, 6),
				[UnitPrice] [decimal](18, 6),
				[TxnUnitID] [int],
				[MasterUnitID] [int] ,
				[MasterUnitConversion] [decimal](18, 6) ,
				[ReportUnitID] [int],
				[ReportUnitConversion] [decimal](18, 6),
				[DiscountValue] [decimal](18, 6),
				[DiscountPercentage] [decimal](18, 6) ,
				[TimeStamp] [nvarchar](256),
				[StockMasterQuantity] [decimal](18, 6),
				[StockMasterAveragePrice] [decimal](18, 6) ,
				[NewQuantity] [decimal](18, 6) ,
				[NewAveragePrice] [decimal](18, 6),
				[Remarks] [nvarchar](max) ,
				[UserProfileId] [int] ,
				[CostTransactionAccountID] [int] ,
				[PurchaseTransactionAccountID] [int] ,
				[TxnType] [nvarchar](1),
				[BalanceQuantity] [decimal](18, 6),
				[ReturnQuantity] [decimal](18, 6) ,
				[ItemUnitPriceInSuppCurrency] [decimal](18, 6) ,
				[IPAddress] [nvarchar](max),
				[CreatedUserID] [int] ,
				[LastModUserID] [int] ,
				[CreatedDate] [datetime] ,
				[LastModDate] [datetime] ,
				[TBPHeaderId] [int] ,
				[Isserialadded] [bit] ,
				[SkipGL] [bit] ,
				[BalVal] [decimal](18, 6) ,
				[AccName] [nvarchar](250),
				[RequestedGenericItemId] INT,
                [PhysicalQuantity] INT,
				[SellingPrice] [decimal](18, 6)
				,[SelectedCUSDECID] INT)

				IF(@TransactionType = 'AA')
				BEGIN 
					INSERT INTO #tempTxnDetails  ( StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID,
					MasterUnitConversion, ReportUnitID, ReportUnitConversion, DiscountValue, DiscountPercentage, TimeStamp, StockMasterQuantity,
					StockMasterAveragePrice, NewQuantity, NewAveragePrice, Remarks, UserProfileId, CostTransactionAccountID, 
					PurchaseTransactionAccountID, TxnType, BalanceQuantity, ReturnQuantity, ItemUnitPriceInSuppCurrency, IPAddress, 
					CreatedUserID, LastModUserID, CreatedDate, LastModDate, TBPHeaderId, Isserialadded, SkipGL, BalVal, AccName,
					RequestedGenericItemId, PhysicalQuantity,SellingPrice -- Add by Uditha 2025-06-26 For Invoice Module
					,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
					)
					SELECT  StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID,
					MasterUnitConversion, ReportUnitID, ReportUnitConversion, DiscountValue, DiscountPercentage, TimeStamp, 
					StockMasterQuantity, StockMasterAveragePrice, NewQuantity, NewAveragePrice, Remarks, UserProfileId,
					CostTransactionAccountID, PurchaseTransactionAccountID, TxnType, BalanceQuantity, ReturnQuantity,
					ItemUnitPriceInSuppCurrency, IPAddress, CreatedUserID, LastModUserID, CreatedDate, LastModDate, TBPHeaderId, Isserialadded,
					SkipGL, BalVal, AccName, RequestedGenericItemId, PhysicalQuantity ,UnitPrice -- Add by Uditha 2025-06-26 For Invoice Module
					,ISNULL(SelectedCUSDECID,0) -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
					FROM #TempAllDetails
				END
				ELSE
				BEGIN
					INSERT INTO #tempTxnDetails  ( StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID,
					MasterUnitConversion, ReportUnitID, ReportUnitConversion, DiscountValue, DiscountPercentage, TimeStamp, StockMasterQuantity,
					StockMasterAveragePrice, NewQuantity, NewAveragePrice, Remarks, UserProfileId, CostTransactionAccountID,
					PurchaseTransactionAccountID, TxnType, BalanceQuantity, ReturnQuantity, ItemUnitPriceInSuppCurrency, IPAddress,
					CreatedUserID, LastModUserID, CreatedDate, LastModDate, TBPHeaderId, Isserialadded, SkipGL, BalVal, AccName, 
					RequestedGenericItemId, PhysicalQuantity,SellingPrice-- Add by Uditha 2025-06-26 For Invoice Module
					,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
					)
					SELECT  StockTransactionHeaderID, StockItemID, Quantity, UnitPrice, TxnUnitID, MasterUnitID, MasterUnitConversion,
					ReportUnitID, ReportUnitConversion, DiscountValue, DiscountPercentage, TimeStamp, StockMasterQuantity,
					StockMasterAveragePrice, NewQuantity, NewAveragePrice, Remarks, UserProfileId, CostTransactionAccountID,
					PurchaseTransactionAccountID, TxnType, BalanceQuantity, ReturnQuantity, ItemUnitPriceInSuppCurrency, IPAddress,
					CreatedUserID, LastModUserID, CreatedDate, LastModDate, TBPHeaderId, Isserialadded, SkipGL, BalVal, AccName,
					RequestedGenericItemId, PhysicalQuantity ,UnitPrice -- Add by Uditha 2025-06-26 For Invoice Module
					,ISNULL(SelectedCUSDECID,0) -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
					FROM #TempAllDetails
					WHERE Quantity > 0
				END


				select '-------#tempTxnDetails  --------',*
				from #tempTxnDetails

				--ADDED BY Kapila ON 07/07/2025------------------------------------------------------------------------------------------------------------------
				--IF @TransactionType= 'IF'
				--BEGIN
				--	DECLARE @StockInHand DECIMAL(18,6),@ParkQty DECIMAL(18,6),@IsMinusStockValidate BIT

				--	SELECT @IsMinusStockValidate = ISNULL(IsMinusStockValidate,0)
				--	FROM Locations WITH (NOLOCK)
				--	WHERE ID = @LocationID

				--	IF(@IsMinusStockValidate = 1)
				--	BEGIN

				--		SELECT StockItemID,Quantity INTO #TempGRNDetails FROM #tempTxnDetails

				--		WHILE EXISTS(SELECT  StockItemID, Quantity FROM #TempGRNDetails)
				--		BEGIN
				--			SELECT TOP (1) @StockItemID = StockItemID, @Quantity = Quantity FROM #TempGRNDetails

				--			SET @ParkQty = 0
				--			SET @StockInHand = 0

				--			IF EXISTS (SELECT TOP (1) ParkQuantity FROM  StockTransactionParkDetails WITH (NOLOCK) WHERE LocationID = @LocationID and StockItemID = @StockItemID ORDER BY TransactionDate DESC, Idx DESC)
				--			BEGIN
				--				SELECT TOP (1) @ParkQty = ParkQuantity + @Quantity FROM  StockTransactionParkDetails WITH (NOLOCK) WHERE LocationID = @LocationID and StockItemID = @StockItemID ORDER BY TransactionDate DESC, Idx DESC
				--			END
				--			ELSE
				--			BEGIN
				--				SET @ParkQty = @Quantity
				--			END

				--			SET @StockInHand = ISNULL([dbo].[GetBalance](@txnDate,@StockItemID,@LocationID,0,0),0)

				--			IF(@StockInHand <=0)
				--			BEGIN
				--						UPDATE #tempTxnDetails
				--						SET Quantity = 0
				--						WHERE StockItemID = @StockItemID

				--					INSERT INTO StockTransactionParkDetails ([LocationID], [StockItemID], [TransactionDate], [CurQuantity], [TxnQuantity], [ParkQuantity]) 
				--					VALUES (@LocationID,@StockItemID,@txnDate,@StockInHand,@Quantity,@ParkQty)

				--			END
				--			IF (@StockInHand > 0 AND @StockInHand < @ParkQty)
				--			BEGIN

				--				SET @ParkQty = @ParkQty - @StockInHand

				--				UPDATE #tempTxnDetails
				--				SET Quantity = @StockInHand
				--				WHERE StockItemID = @StockItemID

				--				INSERT INTO StockTransactionParkDetails ([LocationID], [StockItemID], [TransactionDate], [CurQuantity], [TxnQuantity], [ParkQuantity]) 
				--				VALUES (@LocationID,@StockItemID,@txnDate,@StockInHand,@Quantity,@ParkQty)

				--			END

				--			DELETE FROM #TempGRNDetails WHERE StockItemID = @StockItemID
				--		END
				--	END
				--END
				--ENDED BY Kapila-----------------------------------------------------------------------------------------------------------------------------------

					--SELECT * FROM #tempTxnDetails
				IF(@TransactionType = 'AA')
				BEGIN
					INSERT INTO #ItemList(StockItemID,Quantity,TxnUnitID,UnitPrice,TxnType,DiscountValue,DiscountPercentage,MasterUnitID,BrandedItem,GenericCode,StockItemCode,SellingPrice)
					SELECT StockItemID,Quantity,TxnUnitID,UnitPrice,TxnType,DiscountValue,DiscountPercentage,MasterUnitID,0 BrandedItem,'' GenericCode,'' StockItemCode,SellingPrice FROM #TempAllDetails 
				END
				ELSE
				BEGIN
				
					INSERT INTO #ItemList(StockItemID,Quantity,TxnUnitID,UnitPrice,TxnType,DiscountValue,DiscountPercentage,MasterUnitID,BrandedItem,GenericCode,StockItemCode,SellingPrice)
					SELECT StockItemID,Quantity,TxnUnitID,UnitPrice,TxnType,DiscountValue,DiscountPercentage,MasterUnitID,0 BrandedItem,'' GenericCode,'' StockItemCode, SellingPrice 
					FROM #TempAllDetails
					WHERE Quantity > 0;

					SELECT 343434
				END
				
 

					IF(@TransactionType = 'TI')		
					BEGIN
						DECLARE @masterUnitid INT ,@TIItemName varchar(max)
						
						---------2025-12-18 Added by Isuru for checking Unit Conversion FOR TRANSFER IN
						--select @ConversionRate = dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,i.StockItemID))
						--,@TIItemName =SH.Name
						--FROM #tempTxnDetails i 
						--INNER JOIN StockItemDetails D ON D.StockItemHeaderID = i.StockItemID and d.LocationID=@LocationID
						--INNER JOIN StockItemHeaders SH ON D.StockItemHeaderID = SH.Id
						--WHERE SH.CompanyId = @PropertyID

						--IF @ConversionRate =-1
						--BEGIN
						--	SET @InvError =  'Unit Conversion not Found for'+ ' '+@TIItemName
						--	RAISERROR ( @InvError, 16, 1 );  
						--	ROLLBACK TRANSACTION	
						--END 
						------- 2026-07-31 fixed: per-row check (scalar assign only kept the last row)
						SET @BadUnitItems = NULL;

						SELECT @BadUnitItems = STUFF((
							SELECT ', ' + SH.Name
							FROM #tempTxnDetails i
							INNER JOIN StockItemDetails  D  ON D.StockItemHeaderID = i.StockItemID AND D.LocationID = @LocationID
							INNER JOIN StockItemHeaders  SH ON SH.Id = D.StockItemHeaderID
							WHERE SH.CompanyId = @PropertyID
								AND dbo.FN_GetUnitConvertionRate(@propertyID, i.TxnUnitID,
									dbo.FN_GetMasterUnitID(@propertyID, @LocationID, i.StockItemID)) = -1
							FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')

						IF @BadUnitItems IS NOT NULL
						BEGIN
							SET @InvError = 'Unit Conversion not Found for: ' + @BadUnitItems
							RAISERROR (@InvError, 16, 1)
						END
						------ END
						-------- END


						--select dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID)) * Quantity '--- Qty',TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),
						--UnitPrice / dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID)) '---UnitPrice'
						--from #tempTxnDetails //comment by Nivesh 2024-01-31
							IF (SELECT IsFranchise FROM Locations WHERE ID = @LocationID) = 1 --  Add by Uditha 2025-06-26 For Invoice Module
						BEGIN
							UPDATE #tempTxnDetails 
							SET Quantity = dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID)) * Quantity,
							TxnUnitID=dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),MasterUnitID = dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),
							UnitPrice = SellingPrice / dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID))
				
							UPDATE #ItemList 
							SET Quantity = dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID)) * Quantity ,
							TxnUnitID=dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),MasterUnitID = dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),
							UnitPrice = SellingPrice / dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID))
						END
						ELSE
						BEGIN
							UPDATE #tempTxnDetails 
							SET Quantity = dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID)) * Quantity,
							TxnUnitID=dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),MasterUnitID = dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),
							UnitPrice = UnitPrice / dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID))
				
							UPDATE #ItemList 
							SET Quantity = dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID)) * Quantity ,
							TxnUnitID=dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),MasterUnitID = dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID),
							UnitPrice = UnitPrice / dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@propertyID,@LocationID,StockItemID))
						END



				
						--SELECT dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,MasterUnitID) * Quantity FROM #tempTxnDetails t //comment by Nivesh 2024-01-31
			
			

			
					END 

					---------
					IF @TransactionType IN( 'TO', 'IN','DN','PI')		
					BEGIN
					-------2023-08-22 Added by Isuru for checking Unit Conversion 
					--	select @ConversionRate = dbo.FN_GetUnitConvertionRate(@propertyID,D.MasterUnitID,TxnUnitID)
					--	FROM #tempTxnDetails i 
					--	INNER JOIN StockItemDetails D ON D.StockItemHeaderID = i.StockItemID and d.LocationID=@LocationID

					--IF @ConversionRate =-1
					--BEGIN
					--		SET @InvError =  'Unit Conversion not Found'
					--		RAISERROR ( @InvError, 16, 1 );  
					--		ROLLBACK TRANSACTION
					--END 
					------- 2026-07-31 fixed: per-row check (scalar assign only kept the last row)
					SELECT @BadUnitItems = STUFF((
						SELECT ', ' + SH.Name
						FROM #tempTxnDetails i
						INNER JOIN StockItemDetails  D  ON D.StockItemHeaderID = i.StockItemID AND D.LocationID = @LocationID
						INNER JOIN StockItemHeaders  SH ON SH.Id = i.StockItemID
						WHERE dbo.FN_GetUnitConvertionRate(@propertyID, D.MasterUnitID, i.TxnUnitID) = -1
						FOR XML PATH(''), TYPE).value('.', 'VARCHAR(MAX)'), 1, 2, '')

					IF @BadUnitItems IS NOT NULL
					BEGIN
						SET @InvError = 'Unit Conversion not Found for: ' + @BadUnitItems
						RAISERROR (@InvError, 16, 1)
					END
					-- END
					
						UPDATE i
						--SET i.UnitPrice= d.AveragePrice * dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,D.MasterUnitID) --commented by Isuru 2025-07-24 to load last avg price
						SET i.UnitPrice= dbo.[FN_GetLastAveragePrice](@LocationID,i.StockItemID) * dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,D.MasterUnitID)
						FROM #tempTxnDetails i 
						INNER JOIN StockItemDetails D ON D.StockItemHeaderID = i.StockItemID and d.LocationID=@LocationID

						UPDATE i
						--SET i.UnitPrice= d.AveragePrice * dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,D.MasterUnitID) --commented by Isuru 2025-07-24 to load last avg price
						SET i.UnitPrice= dbo.[FN_GetLastAveragePrice](@LocationID,i.StockItemID)  * dbo.FN_GetUnitConvertionRate(@propertyID,TxnUnitID,D.MasterUnitID) 
						FROM #ItemList i 
						INNER JOIN StockItemDetails D ON D.StockItemHeaderID = i.StockItemID and d.LocationID=@LocationID

					END 
					---------

					--ADDED BY ISURU FOR CHECHKIN UNIT CONVERSION RATE 2023-10-03
					IF(@TransactionType='GR')
					BEGIN

					DECLARE @UnitConversionRate INT,@InvError2 VARCHAR(MAX),@UnitConversionItemName VARCHAR(200)

					SELECT *
					INTO #tempUnitCheck
					FROM #tempTxnDetails

					WHILE (SELECT COUNT(*) FROM #tempUnitCheck) > 0
					BEGIN
						--select 'FROM #tempUnitCheck ',@PropertyID,TxnUnitID,@LocationID,StockItemID,dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
						--FROM #tempUnitCheck //comment by Nivesh 2024-01-31
					
						SELECT  top(1)@UnitConversionItemName= sh.name, @UnitConversionRate = dbo.FN_GetUnitConvertionRate(@PropertyID,TxnUnitID,dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID))
						FROM #tempUnitCheck tm
						inner join StockItemHeaders sh on tm.StockItemID = sh.Id

						--select @UnitConversionRate '@UnitConversionRate' //comment by Nivesh 2024-01-31

					
						IF @UnitConversionRate =-1
						BEGIN
							SET @InvError2 =  'Unit Conversion not Found for'+ ' '+@UnitConversionItemName
							RAISERROR ( @InvError2, 16, 1 );  
							ROLLBACK TRANSACTION
						END

						DELETE TOP (1) FROM #tempUnitCheck
					END
					END
					--END
		
		
			
				------added------



				if (@TransactionType <> 'GR')  -- added by vinuki 13.06.2024
				BEGIN
				--SELECT 3243455


				--SELECT @StockTransactionHeaderID,
				--		StockItemID,
				--		CASE
				--			WHEN @TransactionType = 'AA'
				--			THEN
				--				ABS(Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID))
				--			ELSE
				--				Quantity
				--		END,
				--		--UnitPrice + CASE WHEN @addtionalCostPre> 0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END , -- Commented by Isuru 2026-05-25 to insert last avg price if reconcile unitprice =0
				--		CASE WHEN @TransactionType = 'AA' AND UnitPrice = 0 AND dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) <0
				--		THEN  dbo.[FN_GetLastAveragePrice](@LocationID,StockItemID)
				--		ELSE UnitPrice + CASE WHEN @addtionalCostPre> 0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END END, --- Added by Isuru 2026-06-01 to insert last avg price if reconcile unitprice =0
				--		TxnUnitID,
				--		ISNULL(dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID), 0) MasterUnitID,
				--		dbo.FN_GetUnitConvertionRate(
				--										@PropertyID,
				--										TxnUnitID,
				--										dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
				--									),
				--		ISNULL(dbo.FN_GetReportingUnitID(@PropertyID, @LocationID, StockItemID), 0),
				--		dbo.FN_GetUnitConvertionRate(
				--										@PropertyID,
				--										TxnUnitID,
				--										dbo.FN_GetReportingUnitID(@PropertyID, @LocationID, StockItemID)
				--									),
				--		DiscountValue,
				--		DiscountPercentage,
				--		dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) StockMasterQuantity,
				--		dbo.FN_GetAveragePrice(@PropertyID, @LocationID, StockItemID, @TransactionType, 0, TxnUnitID, 0),
				--		dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)
				--		+ CASE
				--			  WHEN @TransactionType = 'AA' THEN
				--				  Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)
				--			  ELSE
				--				  CASE
				--					  WHEN TxnType = 'P' THEN
				--						  1
				--					  ELSE
				--						  -1
				--				  END * Quantity * dbo.FN_GetUnitConvertionRate(
				--										@PropertyID,
				--										TxnUnitID,
				--										dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
				--									)
				--		  END NewQuantity,
				--		dbo.FN_GetAveragePrice(
				--								  @PropertyID,
				--								  @LocationID,
				--								  StockItemID,
				--								  @TransactionType,
				--								  Quantity,
				--								  TxnUnitID,
				--								  UnitPrice + CASE WHEN  @addtionalCostPre >0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END - ( CASE WHEN DiscountValue > 0 THEN ( DiscountValue / Quantity ) ELSE UnitPrice * DiscountPercentage /100 END )
				--							  ),
				--		Remarks,
				--		UserProfileId,
				--		dbo.FN_GetPurchaseCostOfSalesAccountID(StockItemID, @LocationID) CostTransactionAccountID,
				--		dbo.FN_GetPurchaseTransactionAccountID(StockItemID, @LocationID) PurchaseTransactionAccountID,
				--		CASE
				--			WHEN @TransactionType <> 'AA' THEN
				--				TxnType
				--			ELSE
				--				CASE
				--					WHEN Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) > 0 THEN
				--						'P'
				--					ELSE
				--						'M'
				--				END
				--		END,
				--		CAST((CASE
				--				  WHEN @ExchangeRate <= 0 THEN
				--					  0
				--				  ELSE
				--		(UnitPrice / @ExchangeRate)
				--			  END
				--			 ) AS DECIMAL(18, 6)),
				--		BalanceQuantity,
				--		ReturnQuantity,
				--		CreatedUserID,
				--		LastModUserID,
				--		GETDATE(),
				--		GETDATE(),
				--		 [dbo].[FN_GetNewBalVal](StockItemId,@LocationID,@TransactionType,Quantity, UnitPrice),
				--		 AccName,
				--		 0,
    --                     Quantity
				--		  ,CASE WHEN @TransactionType = 'BI' THEN [dbo].[FN_GetCostPriceBI] (StockItemId,@InvoiceLocationID,@PropertyID) ELSE SellingPrice END
				--		  ,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
				-- FROM #tempTxnDetails




				INSERT INTO StockTransactionDetails
				(
					StockTransactionHeaderID,
					StockItemID,
					Quantity,
					UnitPrice,
					TxnUnitID,
					MasterUnitID,
					MasterUnitConversion,
					ReportUnitID,
					ReportUnitConversion,
					DiscountValue,
					DiscountPercentage,
					StockMasterQuantity,
					StockMasterAveragePrice,
					NewQuantity,
					NewAveragePrice,
					Remarks,
					UserProfileId,
					CostTransactionAccountID,
					PurchaseTransactionAccountID,
					TxnType,
					ItemUnitPriceInSuppCurrency,
					BalanceQuantity,
					ReturnQuantity,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					BalVal,
					AccName,
					RequestedGenericItemId,
                    PhysicalQuantity,
					SellingPrice -- Add by Uditha 2025-06-26 For Invoice Module
					,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
				)
				SELECT @StockTransactionHeaderID,
						StockItemID,
						CASE
							WHEN @TransactionType = 'AA'
							THEN
								ABS(Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID))
							ELSE
								Quantity
						END,
						--UnitPrice + CASE WHEN @addtionalCostPre> 0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END , -- Commented by Isuru 2026-05-25 to insert last avg price if reconcile unitprice =0
						CASE WHEN @TransactionType = 'AA' AND UnitPrice = 0 AND dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) <0
						THEN  dbo.[FN_GetLastAveragePrice](@LocationID,StockItemID)
						WHEN @TransactionType = 'BI' THEN  dbo.[FN_GetLastAveragePrice](@LocationID,StockItemID)
						ELSE UnitPrice + CASE WHEN @addtionalCostPre> 0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END END, --- Added by Isuru 2026-06-01 to insert last avg price if reconcile unitprice =0
						TxnUnitID,
						ISNULL(dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID), 0) MasterUnitID,
						dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														TxnUnitID,
														dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
													),
						ISNULL(dbo.FN_GetReportingUnitID(@PropertyID, @LocationID, StockItemID), 0),
						dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														TxnUnitID,
														dbo.FN_GetReportingUnitID(@PropertyID, @LocationID, StockItemID)
													),
						DiscountValue,
						DiscountPercentage,
						dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) StockMasterQuantity,
						dbo.FN_GetAveragePrice(@PropertyID, @LocationID, StockItemID, @TransactionType, 0, TxnUnitID, 0),
						dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)
						+ CASE
							  WHEN @TransactionType = 'AA' THEN
								  Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)
							  ELSE
								  CASE
									  WHEN TxnType = 'P' THEN
										  1
									  ELSE
										  -1
								  END * Quantity * dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														TxnUnitID,
														dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
													)
						  END NewQuantity,
						dbo.FN_GetAveragePrice(
												  @PropertyID,
												  @LocationID,
												  StockItemID,
												  @TransactionType,
												  Quantity,
												  TxnUnitID,
												  UnitPrice + CASE WHEN  @addtionalCostPre >0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END - ( CASE WHEN DiscountValue > 0 THEN ( DiscountValue / Quantity ) ELSE UnitPrice * DiscountPercentage /100 END )
											  ),
						Remarks,
						UserProfileId,
						dbo.FN_GetPurchaseCostOfSalesAccountID(StockItemID, @LocationID) CostTransactionAccountID,
						dbo.FN_GetPurchaseTransactionAccountID(StockItemID, @LocationID) PurchaseTransactionAccountID,
						CASE
							WHEN @TransactionType <> 'AA' THEN
								TxnType
							ELSE
								CASE
									WHEN Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) > 0 THEN
										'P'
									ELSE
										'M'
								END
						END,
						CAST((CASE
								  WHEN @ExchangeRate <= 0 THEN
									  0
								  ELSE
						(UnitPrice / @ExchangeRate)
							  END
							 ) AS DECIMAL(18, 6)),
						BalanceQuantity,
						ReturnQuantity,
						CreatedUserID,
						LastModUserID,
						GETDATE(),
						GETDATE(),
						 [dbo].[FN_GetNewBalVal](StockItemId,@LocationID,@TransactionType,Quantity, UnitPrice),
						 AccName,
						 0,
                         Quantity
						  ,CASE WHEN @TransactionType = 'BI' THEN [dbo].[FN_GetCostPriceBI] (StockItemId,@InvoiceLocationID,@PropertyID,TxnUnitID)
							  --Added 2026-09-15 : Franchise Return - selling price of the source SR / BI line (#BRPrice: created for every type, filled only by the 'BR' block)
							  WHEN @TransactionType = 'BR' THEN ISNULL((SELECT TOP (1) P.SellingPrice FROM #BRPrice P WHERE P.StockItemID = #tempTxnDetails.StockItemID), SellingPrice)
							  ELSE SellingPrice END
						  ,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
				 FROM #tempTxnDetails
			

			SELECT 1111111

				SELECT 'StockTransactionDetails',*
				FROM StockTransactionDetails 
				WHERE StockTransactionHeaderID = @StockTransactionHeaderID


				--Added by Isuru 2026-05-26

				IF(@TransactionType = 'BI')
				BEGIN
					CREATE TABLE #BITaxTable
					(
						TaxTypeId INT,
						TaxValue DECIMAL(18,6)
					);

					SELECT *
					INTO #BIStockTransactionDetails
					FROM StockTransactionDetails
					WHERE StockTransactionHeaderID = @StockTransactionHeaderID

					DECLARE @BIStockItemID INT,@BIItemTotal DECIMAL(18,6),@BISupplierID INT,@BILocationID INT,@BIStockTransactionDetailID INT
					,@BIItemQty DECIMAL(18,6)

					SELECT @BISupplierID = SupplierId
					FROM Companies
					WHERE CompanyID = @PropertyID

					WHILE EXISTS(SELECT 1 FROM #BIStockTransactionDetails)
					BEGIN
						
						SELECT TOP 1 @BIStockItemID = StockItemID,@BIItemTotal =  SellingPrice ,@BIStockTransactionDetailID = Id
						,@BIItemQty = Quantity
						FROM #BIStockTransactionDetails


						SELECT @BIStockItemID BIStockItemID, @BIItemTotal BIItemTotal,@BISupplierID BISupplierID,@InvoiceLocationID LocationID

						INSERT INTO #BITaxTable
						EXEC [SP_Select_StockItemWiseTaxAmount] @BIStockItemID, @BIItemTotal,@BISupplierID,@InvoiceLocationID;


						SELECT '#BITaxTable',*
						FROM #BITaxTable


						INSERT INTO StockTransactionwiseTaxes
						(
							StockTransactionDetailID,
							StockItemID,
							TaxTypeID,
							TaxAmount
						)
						SELECT @BIStockTransactionDetailID,
								@BIStockItemID,
								TaxTypeId,
								TaxValue * @BIItemQty
						FROM #BITaxTable WHERE TaxValue > 0
						DELETE FROM #BITaxTable;

						DELETE 
						FROM #BIStockTransactionDetails
						WHERE StockItemID = @BIStockItemID

					END
				END
				--End

				
				--added by Isuru 2026-09-17 BR Franchise Return tax: copy the original BI's stored tax to the BR lines, proportional to the BI quantity returned (no live tax setup is read, same approach as SR copying its GR tax)
				IF (@TransactionType = 'BR')
				BEGIN
					INSERT INTO StockTransactionwiseTaxes
					(
						StockTransactionDetailID,
						StockItemID,
						TaxTypeID,
						TaxAmount
					)
					SELECT BRD.Id,
					       BRD.StockItemID,
					       T.TaxTypeID,
					       CAST(T.ItemTax * BRD.Quantity / Q.ItemQty AS DECIMAL(18, 8))
					FROM   StockTransactionDetails BRD
					CROSS APPLY (SELECT SUM(X.Quantity) AS ItemQty
					             FROM   StockTransactionDetails X
					             WHERE  X.StockTransactionHeaderID = @StockTransactionHeaderID
					               AND  X.StockItemID             = BRD.StockItemID) Q
					INNER JOIN (
						SELECT A.StockItemID,
						       TX.TaxTypeID,
						       SUM(TX.TaxAmount * A.SourceQty / SD.Quantity) AS ItemTax
						FROM   #BRTaxAlloc A
						INNER JOIN StockTransactionDetails   SD ON SD.Id = A.SourceDetailID
						INNER JOIN StockTransactionwiseTaxes TX ON TX.StockTransactionDetailID = SD.Id
						                                       AND TX.StockItemID              = SD.StockItemID
						WHERE  SD.Quantity > 0
						GROUP BY A.StockItemID, TX.TaxTypeID
					) T ON T.StockItemID = BRD.StockItemID
					WHERE  BRD.StockTransactionHeaderID = @StockTransactionHeaderID
					  AND  BRD.Quantity > 0
					  AND  Q.ItemQty    > 0
					  AND  T.ItemTax    > 0;
				END
				--end added by Isuru 2026-09-17


				
			--added by Isuru 2026-09-18 mark the source Franchise Invoice as fully returned ('R') once no quantity is left open on any of its lines; ReturnQuantity for this return is already booked above
			IF EXISTS (SELECT 1
			           FROM   dbo.StockTransactionDetails
			           WHERE  StockTransactionHeaderID = @BRBIHeaderID)
			   AND NOT EXISTS (SELECT 1
			                   FROM   dbo.StockTransactionDetails
			                   WHERE  StockTransactionHeaderID = @BRBIHeaderID
			                     AND  Quantity - ISNULL(ReturnQuantity, 0) > 0.000001)
			BEGIN
				UPDATE dbo.StockTransactionHeaders
				SET    InvoiceDocStatus = 'R' 
				WHERE  Id              = @BRBIHeaderID
				  AND  TransactionType = 'BI'
				  AND  ISNULL(InvoiceDocStatus, '') <> 'R';
			END
			--end added by Isuru 2026-09-18

				--ADDED BY Isuru 2025-09-22
				IF(@DisplayOriginalTRQty = 1)
				BEGIN
					--Added by Tharuka 2026-08-18 : 'BI' records RequestionStatus like an IN
					IF(@TransactionType IN ('TO','IN','BI') AND @ReferenceID >0)
					BEGIN

					SELECT *
					INTO #TempOriginalQtyItems
					FROM #TempAllDetails

					select 'RequestionStatus',*
					from #TempOriginalQtyItems

					DECLARE @BandedItemID INT,@BandedItemQty DECIMAL(18,6),@BandedItemUnitID INT,@GenericItemCodeTO NVARCHAR(MAX)
					,@GenericItemIDTO INT

					IF(@TransactionType = 'TO')
					BEGIN
						select TP.StockItemID,TP.Quantity,TP.TxnUnitID
						INTO #BrandedItemList
						from #TempOriginalQtyItems TP
						INNER JOIN StockItemHeaders SH ON TP.StockItemID = SH.Id
						WHERE SH.BrandedItem=1

						WHILE EXISTS(SELECT 1 FROM #BrandedItemList)
						BEGIN
						SELECT TOP (1) @BandedItemID = StockItemID,@BandedItemQty = Quantity,@BandedItemUnitID =TxnUnitID 
						FROM #BrandedItemList

						SELECT @GenericItemCodeTO  GenericItemCode
						FROM STOCKITEMHEADERS
						WHERE ID = @BandedItemID

						SELECT TOP (1) '#BrandedItemList',*
						FROM #BrandedItemList
						
						DELETE TOP (1) FROM #BrandedItemList
						END

					END


						INSERT INTO RequestionStatus(TransactionType,RequestHeaderID, TransactionHeaderID, StockItemID, RequestedQty, BalanceRequestedQty  ,RecievedQty, SysDateTime)
						SELECT @TransactionType,RequestHeaderID,@StockTransactionHeaderID,RD.StockItemID,RD.ApprovedQuantity RequestedQty,(RD.ApprovedQuantity - RD.IssuedQuantity) RequestedQty,ISNULL(TD.Quantity,0),GETDATE()
						FROM RequestDetails RD WITH (NOLOCK)
						LEFT JOIN #TempOriginalQtyItems TD ON RD.StockItemID = TD.StockItemID
						WHERE RD.RequestHeaderID = @ReferenceID
						AND RD.ApprovedQuantity - RD.IssuedQuantity  <>0
					 END

					 IF(@TransactionType = ('TI') AND @ReferenceID >0)
					BEGIN
						INSERT INTO RequestionStatus(TransactionType,RequestHeaderID, TransactionHeaderID, StockItemID, RequestedQty, BalanceRequestedQty  ,RecievedQty, SysDateTime)
						SELECT @TransactionType,RQ.RequestHeaderID, @StockTransactionHeaderID, RQ.StockItemID, RQ.RequestedQty, RQ.BalanceRequestedQty  ,RQ.RecievedQty, GETDATE()
						FROM RequestionStatus RQ 
						INNER JOIN StockTransactionHeaders SHTO ON RQ.TransactionHeaderID = SHTO.Id
						INNER JOIN StockTransactionHeaders SHTI ON SHTI.ReferenceID = SHTO.ID
						WHERE SHTI.ID= @StockTransactionHeaderID
					 END
				END

				 --END

				 --Check empty Detail in stocktransacitondetail xml
				  --Added by Nivesh 2025-01-27
				 IF(@StockTransactionHeaderID IS NOT NULL AND NOT EXISTS(SELECT 1  FROM #tempTxnDetails))
				 BEGIN
					RAISERROR ( 'Item not exists', 16, 1 );  
					ROLLBACK TRANSACTION
				 END
				 --
				 END

				-- SELECT @TempPropertyID =CompanyId ,@TempDocNogrn =ApprovalDocNo FROM [dbo].[GRNApprovalLog] WHERE Id = @GRNApprovalID

				SELECT @TempIsComplete = COUNT(ID) FROM GRNApprovalLog WHERE ApprovalDocNo = @TempDocNogrn AND Status ='C' AND CompanyId = @TempPropertyID AND IsComplete = 1   -- added by vinuki 13.06.2024

				IF (@TransactionType = 'GR' AND @RowCount2 = @TempIsComplete )   -- added by vinuki 13.06.2024
				BEGIN
						INSERT INTO StockTransactionDetails
				(
					StockTransactionHeaderID,
					StockItemID,
					Quantity,
					UnitPrice,
					TxnUnitID,
					MasterUnitID,
					MasterUnitConversion,
					ReportUnitID,
					ReportUnitConversion,
					DiscountValue,
					DiscountPercentage,
					StockMasterQuantity,
					StockMasterAveragePrice,
					NewQuantity,
					NewAveragePrice,
					Remarks,
					UserProfileId,
					CostTransactionAccountID,
					PurchaseTransactionAccountID,
					TxnType,
					ItemUnitPriceInSuppCurrency,
					BalanceQuantity,
					ReturnQuantity,
					CreatedUserID,
					LastModUserID,
					CreatedDate,
					LastModDate,
					BalVal,
					AccName,
					RequestedGenericItemId,
                    PhysicalQuantity
					,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
				)
				SELECT @StockTransactionHeaderID,
						StockItemID,
						CASE
							WHEN @TransactionType = 'AA'
							THEN
								ABS(Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID))
							ELSE
								Quantity
						END,
						UnitPrice + CASE WHEN @addtionalCostPre> 0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END ,
						TxnUnitID,
						ISNULL(dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID), 0) MasterUnitID,
						dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														TxnUnitID,
														dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
													),
						ISNULL(dbo.FN_GetReportingUnitID(@PropertyID, @LocationID, StockItemID), 0),
						dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														TxnUnitID,
														dbo.FN_GetReportingUnitID(@PropertyID, @LocationID, StockItemID)
													),
						DiscountValue,
						DiscountPercentage,
						dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) StockMasterQuantity,
						dbo.FN_GetAveragePrice(@PropertyID, @LocationID, StockItemID, @TransactionType, 0, TxnUnitID, 0),
						dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)
						+ CASE
							  WHEN @TransactionType = 'AA' THEN
								  Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID)
							  ELSE
								  CASE
									  WHEN TxnType = 'P' THEN
										  1
									  ELSE
										  -1
								  END * Quantity * dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														TxnUnitID,
														dbo.FN_GetMasterUnitID(@PropertyID, @LocationID, StockItemID)
													)
						  END NewQuantity,
						dbo.FN_GetAveragePrice(
												  @PropertyID,
												  @LocationID,
												  StockItemID,
												  @TransactionType,
												  Quantity,
												  TxnUnitID,
												  UnitPrice + CASE WHEN  @addtionalCostPre >0 THEN (UnitPrice * @addtionalCostPre / 100.000) ELSE 0 END - ( CASE WHEN DiscountValue > 0 THEN ( DiscountValue / Quantity ) ELSE UnitPrice * DiscountPercentage /100 END )
											  ),
						Remarks,
						UserProfileId,
						dbo.FN_GetPurchaseCostOfSalesAccountID(StockItemID, @LocationID) CostTransactionAccountID,
						dbo.FN_GetPurchaseTransactionAccountID(StockItemID, @LocationID) PurchaseTransactionAccountID,
						CASE
							WHEN @TransactionType <> 'AA' THEN
								TxnType
							ELSE
								CASE
									WHEN Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) > 0 THEN
										'P'
									ELSE
										'M'
								END
						END,
						CAST((CASE
								  WHEN @ExchangeRate <= 0 THEN
									  0
								  ELSE
						(UnitPrice / @ExchangeRate)
							  END
							 ) AS DECIMAL(18, 6)),
						BalanceQuantity,
						ReturnQuantity,
						CreatedUserID,
						LastModUserID,
						GETDATE(),
						GETDATE(),
						 [dbo].[FN_GetNewBalVal](StockItemId,@LocationID,@TransactionType,Quantity, UnitPrice),
						 AccName,
						 0,
                         Quantity
				,SelectedCUSDECID -- Added by Isuru 2026-02-11 to insert CUSDEC ID in Transactions
				 FROM #tempTxnDetails
				 --Check empty Detail in stocktransacitondetail xml 
				 --Added by Nivesh 2025-01-27
				 IF(@StockTransactionHeaderID IS NOT NULL AND NOT EXISTS(SELECT 1  FROM #tempTxnDetails))
				 BEGIN
					RAISERROR ( 'Item not exists', 16, 1 );  
					ROLLBACK TRANSACTION
				 END
				 --
				
				
				END








					 --OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
					 --WITH StockTransactionDetails);
					 --#tempTxnDetails

				-- Commented this to fix reconcilation on 06/12/2018



	


				CREATE TABLE #TaxTable
				(
					TaxTypeId INT,
					TaxValue DECIMAL(18,6)
				);

			
				SELECT *
				INTO #TempAccIdTable
				from #ItemList


				--Added by Isuru 2025-02-18 for Batch transactions
				DECLARE @IsBatchTransactionEnable BIT,
				@BatchStockItemID INT,
				@BatchQuantity DECIMAL(18,8),
				@BatchNO VARCHAR(MAX)
				,@BatchEXPDate DATE
				,@BatchID INT
				,@SellingPrice DECIMAL(18,8)

				DECLARE @TransactionIDBatch INT = dbo.FN_getTransactionID(@TransactionType)

				SELECT @IsBatchTransactionEnable =ISNULL(IsBatchTransactionEnable,0)
				FROM Companies

				IF(@IsBatchTransactionEnable =1)
				BEGIN
					IF @TransactionType IN('SR','IN','IR','GR','AA','TO','TI','IF')
					BEGIN
						
						WHILE EXISTS(SELECT 1 FROM  #StockItemWiseEXPDateIns)
						BEGIN
							SELECT TOP (1) @BatchStockItemID = StockItemID,@BatchQuantity = Quantity,@BatchEXPDate = CONVERT(DATE,EXPDate),
							@BatchNO = BatchNo,@BatchID = ID,@SellingPrice = SellingPrice
							FROM #StockItemWiseEXPDateIns

							SELECT @BatchStockItemID BatchStockItemID,@BatchQuantity BatchQuantity,@BatchEXPDate BatchEXPDate
							,@PropertyID PropertyID,@LocationID  LocationID,@StockTransactionHeaderID StockTransactionHeaderID,@BatchNO '@BatchNO', @BatchID BatchID,@SellingPrice SellingPrice

							
							EXEC [UpdateExpDateFIFO_WithBatchNo] @PropertyID,@LocationID,  @BatchStockItemID, @BatchQuantity , @StockTransactionHeaderID ,  @TransactionIDBatch,@BatchNO,@BatchEXPDate,@BatchID,@SellingPrice

							INSERT INTO [dbo].[RT_Sync_MasterDataTransferStatus]([PropertyId],[UniqueId],[Code],[LocationId],[DataType],[Active],[Delete])
							SELECT @PropertyID,@BatchStockItemID,'',@LocationID,'ItemBatchBalance',1,0

							DELETE TOP (1) FROM #StockItemWiseEXPDateIns

						END
					

					END
				END


		
				WHILE (SELECT COUNT(*) FROM #ItemList) > 0
				BEGIN
				  --Added by Tharuka 2026-08-18 : request-sourced 'BI' joins this block so @RequestUnitId/@ItemId are set for the settlement below
				  IF (@TransactionType IN ( 'IN', 'TO','DN','SR' ) OR (@TransactionType = 'BI' AND @ReferenceID > 0))
				  BEGIN
						DECLARE @BrandedItem BIT, @GenericCode VARCHAR(150)=0, @StockItemCode VARCHAR(100),@StockItemName VARCHAR(500) , @TOError VARCHAR(MAX), 
						@QuantityInHandError VARCHAR(MAX), @ItemId INT, @OrgItemID INT, @OrgItemCode VARCHAR(500),@TransferUnitID INT,
						@RequestUnitId INT, @DiscountValue DECIMAL(18,6)

						


						SELECT @RequestUnitId = unitid FROM dbo.RequestDetails WHERE RequestHeaderID = @ReferenceID
 						--SELECT * FROM #ItemList
						SELECT TOP(1)  @ItemId = StockItemID,@GenericCode = GenericCode,@BrandedItem = BrandedItem,
						@Quantity = Quantity,@StockItemCode = StockItemCode,@TransferUnitID = TxnUnitID, 
						@DiscountValue =  CASE WHEN DiscountValue =0 THEN Quantity * UnitPrice * DiscountPercentage / 100 ELSE DiscountValue END 
						FROM #ItemList    
						ORDER BY StockItemID;


						IF(@TransactionType='TO')
						BEGIN
					
							SELECT @BrandedItem = BrandedItem, @GenericCode =  GenericItemCode
							FROM StockItemHeaders
							WHERE CompanyId = @PropertyID
							AND ID = @ItemId

							UPDATE #ItemList
							SET GenericCode=@GenericCode,BrandedItem=@BrandedItem
							WHERE StockItemID = @ItemId

						END


						
	


						SELECT @StockItemName = StockItemcode + ' / ' + Name
						FROM StockItemHeaders SH INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
						WHERE SH.ID= @ItemId AND  SD.LocationId = @LocationID

						IF(@IsAutoProduction = 1)
						BEGIN
							IF EXISTS(	SELECT 1 FROM StockItemDetails SD 
									inner join StockItemHeaders H ON H.Id = SD.StockItemHeaderID
										WHERE sd.StockItemHeaderID = @ItemId 
									AND SD.QuantityInHand < @Quantity * dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														@TransferUnitID,
														dbo.FN_GetMasterUnitID(@PropertyID, SD.LocationID, sd.StockItemHeaderID) --Modified by Nivesh 2025-01-27 convert unit with master unit
													) 
									AND SD.LocationID = @LocationID and ISNULL(IsProductionItem,0)= 0
									)
						BEGIN
							SET @QuantityInHandError =  @StockItemName + ' - Cannot exceed quantity in hand!'
							RAISERROR ( @QuantityInHandError, 16, 1 );  
							ROLLBACK TRANSACTION
						END 

						END
						ELSE
						BEGIN
								IF EXISTS(	SELECT 1 FROM StockItemDetails SD 
									inner join StockItemHeaders H ON H.Id = SD.StockItemHeaderID
										WHERE sd.StockItemHeaderID = @ItemId 
									AND SD.QuantityInHand < @Quantity * dbo.FN_GetUnitConvertionRate(
														@PropertyID,
														@TransferUnitID,
														dbo.FN_GetMasterUnitID(@PropertyID, SD.LocationID, sd.StockItemHeaderID) --Modified by Nivesh 2025-01-27 convert unit with master unit
													)
									AND SD.LocationID = @LocationID 
									)
						BEGIN
							SET @QuantityInHandError =  @StockItemName + ' - Cannot exceed quantity in hand!'
							RAISERROR ( @QuantityInHandError, 16, 1 );  
							ROLLBACK TRANSACTION
						END 

						END
				
					IF @TransactionType = 'TO'
						BEGIN

							IF NOT EXISTS(SELECT 1 FROM stockitemdetails SD 
										  INNER JOIN StockItemHeaders SH 
										  ON SD.StockItemHeaderID = SH.Id 
										  WHERE   SH.Id  =@ItemId 
										  AND SD.LocationID = @TransferLocationID AND SD.IsActive = 1
										  )
							BEGIN
					

							IF(@BrandedItem = 1)
							BEGIN

								--SET @StockItemCode = @GenericCode
								SELECT @OrgItemID = Id FROM dbo.StockItemHeaders WHERE StockItemCode = @GenericCode AND CompanyId = @PropertyID

					
								IF NOT EXISTS(SELECT 1 FROM stockitemdetails SD 
											  INNER JOIN StockItemHeaders SH 
											  ON SD.StockItemHeaderID = SH.Id 
											  WHERE SH.StockItemCode = @GenericCode 
											  AND SD.LocationID = @TransferLocationID AND SD.IsActive = 1
											  )
								BEGIN
									IF(@Quantity > 0)
											 BEGIN
												SET @TOError = @StockItemName + ' - Item is not available in transfer location'
												RAISERROR ( @TOError, 16, 1 );  
												ROLLBACK TRANSACTION
											END
								END
							END
							IF(@BrandedItem = 0 AND @Quantity > 0)
								BEGIN
									SET @TOError = @StockItemName + ' - Item is not available in transfer location'
									RAISERROR ( @TOError, 16, 1 );  
									ROLLBACK TRANSACTION
								END
							END
						
						END
		
							--IF(@BrandedItem = 1)
							--	SELECT @OrgItemID = Id FROM dbo.StockItemHeaders WHERE StockItemCode = @GenericCode
				  END

		

					SELECT TOP (1)
						   @StockItemID = StockItemID,
						   @unitID = TxnUnitID,
						   @Quantity = CASE
										   WHEN @TransactionType = 'AA' THEN
											   ABS(Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID))
										   ELSE
											   Quantity
									   END,
						   @unitPrice = UnitPrice,
						   @TxnType
							   = CASE
									 WHEN @TransactionType <> 'AA' THEN
										 TxnType
									 ELSE
										 CASE
											 WHEN Quantity - dbo.FN_GetStockInHand(@PropertyID, @LocationID, StockItemID) > 0 THEN
												 'P'
											 ELSE
												 'M'
										 END
								 END, @DiscountValue = CASE WHEN DiscountValue =0 THEN  Quantity *  UnitPrice * DiscountPercentage /100 ELSE DiscountValue END 
					FROM #ItemList
					ORDER BY StockItemID;

		
					DECLARE @TxnCode CHAR(3);

					SET @TxnCode = CASE
									   WHEN @TransactionType + @TxnType = 'AAM' THEN
										   @TransactionType + @TxnType
									   ELSE
										   @TransactionType
								   END;

 

					SET @AveragePrice = dbo.FN_GetAveragePrice(
													@PropertyID,
													@LocationID,
													@StockItemID,
													@TxnCode,
													@Quantity,
													@unitID,
													@unitPrice - CASE WHEN @Quantity=0 THEN 0 ELSE (@DiscountValue / @Quantity) END 
												);
					---added

			
					IF (NOT (
								(
									@TransactionType = 'AAM'
									OR @TransactionType = 'AA'
								)
								AND @Mode = 'M'
							)
					   )
					BEGIN

					DECLARE @masterUnit INT 
					SELECT @masterUnit = MasterUnitID FROM dbo.StockItemDetails
					WHERE StockItemHeaderID = @StockItemID AND LocationID = @LocationID  
					IF @unitID <> @masterUnit

					SET @Quantity  =  dbo.FN_GetUnitConvertionRate(@propertyID,@unitID,@masterUnit) * @Quantity

					-------------added------------------------------
					IF((@TransactionType = 'TI'  )  AND @Quantity > 0 )
					BEGIN 

						SET @AveragePrice = dbo.FN_GetAveragePrice(
													@PropertyID,
													@LocationID,
													@StockItemID,
													@TxnCode,
													@Quantity,
													@unitID,
													@unitPrice - (@DiscountValue / @Quantity)
												);

						--SELECT @PropertyID,
						--	@LocationID,
						--	@StockItemID,
						--	@TxnCode,
						--	@Quantity,
						--	@unitID,
						--	@unitPrice - (@DiscountValue / @Quantity) 'oooo' //comment by Nivesh 2024-01-31



					END

					----------------added----------------------------


					-- Added by Isuru 2025-02-06 to prevent using FN_GetAveragePrice to get average price 
					-- because FN_GetAveragePrice recalculate avg price again 
					--it will affect difference avg prices in StockTransactionDetails and StockItemDetails

					SET @AveragePrice2 = dbo.[FN_GetLastAveragePrice](@LocationID,@StockItemID);
 
					
		
						--EXEC SP_UpdateStockItemBalance @PropertyID,
						--							   @LocationID,
						--							   @StockItemID,
						--							   @TxnCode,
						--							   @Quantity,
						--							   @unitID,
						--							   @AveragePrice;
							--END
						EXEC SP_UpdateStockItemBalance @PropertyID,
													   @LocationID,
													   @StockItemID,
													   @TxnCode,
													   @Quantity,
													   @unitID,
													   @AveragePrice2; -- added by Isuru 2025-02-06



					--select 'SP_UpdateStockItemBalance',@PropertyID,
					--								   @LocationID,
					--								   @StockItemID,
					--								   @TxnCode,
					--								   @Quantity,
					--								   @unitID,
					--								   @AveragePrice	//comment by Nivesh 2024-01-31	

					END;

					IF( @TransactionType = 'IR' AND @IsApprovalForIssueReturn = 0)
					BEGIN
						
						UPDATE StockTransactionDetails
						SET ReturnQuantity = ReturnQuantity + @Quantity
						WHERE StockTransactionHeaderID = @ReferenceID
							  AND StockItemID = @StockItemID;

					END;
					-----------If not approval for SR-------------
					--IF (@TransactionType = 'SR' AND @IsApproval = 0)-- commented by vinuki 18.06.2024
					--BEGIN
					--	--SELECT @ReferenceID; //comment by Nivesh 2024-01-31
					--	UPDATE StockTransactionDetails
					--	SET ReturnQuantity = ReturnQuantity + @Quantity
					--	WHERE StockTransactionHeaderID = @ReferenceID
					--	AND StockItemID = @StockItemID;
					--END
					-----------If not approval for SR-------------
					--Added by Tharuka 2026-08-18 : request-sourced 'BI' tops up RequestDetails.IssuedQuantity like an IN
					IF (@TransactionType IN ( 'IN', 'TO' ) OR (@TransactionType = 'BI' AND @ReferenceID > 0))
					BEGIN

					DECLARE @GenericStockItemID INT = 0

					--SELECT '#ItemList33',* FROM #ItemList //comment by Nivesh 2024-01-31

					--select @GenericCode GenericCodekk //comment by Nivesh 2024-01-31

					--select GenericCode
					--from #ItemList //comment by Nivesh 2024-01-31
					
					--update #ItemList
					--set BrandedItem =1
					--where GenericCode = @GenericCode

					--select @ItemId ItemId
					--select '#ItemList----',* from #ItemList //comment by Nivesh 2024-01-31



						--SELECT @BrandedItem = BrandedItem FROM #ItemList WHERE StockItemID = @ItemId

						--select @GenericStockItemID = Id
						--from StockItemHeaders where StockItemCode = @GenericCode

						--select @GenericStockItemID ,'@GenericStockItemID'
						--select @GenericCode,'@GenericCode' //comment by Nivesh 2024-01-31

						IF(@BrandedItem =1)
						BEGIN

							SELECT @GenericStockItemID= Id
							FROM StockItemHeaders
							WHERE StockItemCode = @GenericCode
							AND CompanyId = @PropertyID

							UPDATE StockTransactionDetails
							SET RequestedGenericItemId = @GenericStockItemID
							WHERE StockItemID = @ItemId
						END


						--SELECT '44444******',*
						--FROM StockTransactionDetails
						--WHERE StockTransactionHeaderID = @StockTransactionHeaderID //comment by Nivesh 2024-01-31
						



							IF(@BrandedItem = 1 AND @quantity > 0)
								BEGIN
									SELECT @OrgItemID = Id FROM dbo.StockItemHeaders WHERE StockItemCode = @GenericCode AND CompanyId = @PropertyID

									SELECT @Quantity = SUM(Quantity) FROM #ItemList WHERE StockItemID = @StockItemID
									--SELECT @Quantity = SUM(Quantity) FROM #ItemList WHERE GenericCode = @GenericCode
							

								
									--SET @Quantity = dbo.FN_GetUnitConvertionRate(@propertyID,@TransferUnitID,@RequestUnitId) * @Quantity
							
									-----updated------*****
									DECLARE @reqItem INT 

									--select @ItemId '@ItemId' //comment by Nivesh 2024-01-31

									SELECT @reqItem = StockItemID FROM  RequestDetails
									WHERE RequestHeaderID = @ReferenceID AND StockItemID = @ItemId

									SELECT @reqItem reqItem,@ItemId ItemId

									IF(@ItemId = @reqItem)
									BEGIN 

									--select @reqItem '@reqItem' //comment by Nivesh 2024-01-31
							 			SET @OrgItemID = @ItemId
										--SELECT @Quantity '88888'
									END 
									ELSE 
										--SET @Quantity = dbo.FN_GetUnitConvertionRate(@propertyID,@TransferUnitID,@RequestUnitId) * @Quantity
								
							
							
									-----updated------*****

									--SELECT @OrgItemID , @Quantity '5555'
									--	select @Quantity '@Quantity 1--'

									SELECT @ReferenceID ReferenceID,@OrgItemID OrgItemID, @Quantity Quantity
						
									--UPDATE RequestDetails
									--SET IssuedQuantity = IssuedQuantity + @Quantity
									----SET IssuedQuantity = RequestedQuantity
									--WHERE RequestHeaderID = @ReferenceID
									--AND StockItemID = @GenericStockItemID --commented by nivesh 2024-08-20
									DECLARE @mastUnID INT
									SELECT @masterUnit = TxnUnitID FROM #ItemList WHERE StockItemID = @GenericStockItemID

									IF(@TransactionType = 'TO')
									BEGIN
										IF(@IsProductionPlan = 0)
										BEGIN
										UPDATE RequestDetails
										SET IssuedQuantity = IssuedQuantity + dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,UnitID) * @Quantity
										--SET IssuedQuantity = RequestedQuantity
										WHERE RequestHeaderID = @ReferenceID
										AND StockItemID = @GenericStockItemID --modified by nivesh 2024-08-20
										END
										ELSE
										BEGIN	
											UPDATE  ProductionConsolidateRecipeSummary
											SET RecievedQuantity = RecievedQuantity + dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,MasterUnitID) * @Quantity
											WHERE ProductionConsolidateHeaderID = @ReferenceID
											AND RecipeItemID = @GenericStockItemID

										END
									END
									--BEGIN
									--	UPDATE RequestDetails
									--	SET IssuedQuantity = IssuedQuantity + dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,UnitID) * @Quantity
									--	--SET IssuedQuantity = RequestedQuantity
									--	WHERE RequestHeaderID = @ReferenceID
									--	AND StockItemID = @GenericStockItemID --modified by nivesh 2024-08-20
									--END
							  

								END
							ELSE

							--select @Quantity '@Quantity 2' //comment by Nivesh 2024-01-31
								IF(@TransactionType = 'TO')
								BEGIN
									IF(@IsProductionPlan = 0)
									BEGIN
										--UPDATE RequestDetails
										--SET IssuedQuantity = IssuedQuantity + @Quantity
										--WHERE RequestHeaderID = @ReferenceID
										--AND StockItemID = @StockItemID;  
										--Added by Isuru 2026-08-03 to convert unit into master unit
										UPDATE RequestDetails
										SET IssuedQuantity = IssuedQuantity +
											CASE WHEN dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,UnitID) > 0
												 THEN dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,UnitID)
												 ELSE 1 END * @Quantity
										WHERE RequestHeaderID = @ReferenceID
										AND StockItemID = @StockItemID;  

									END
									ELSE
									BEGIN
											UPDATE  ProductionConsolidateRecipeSummary
											SET RecievedQuantity = RecievedQuantity + dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,MasterUnitID) * @Quantity
											WHERE ProductionConsolidateHeaderID = @ReferenceID
											AND RecipeItemID = @StockItemID;
									END
								END
								ELSE
								BEGIN
										--UPDATE RequestDetails
										--SET IssuedQuantity = IssuedQuantity + @Quantity
										--WHERE RequestHeaderID = @ReferenceID
										--AND StockItemID = @StockItemID;  

										--Added by Isuru 2026-08-03 to convert unit into master unit
										UPDATE RequestDetails
										SET IssuedQuantity = IssuedQuantity +
											CASE WHEN dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,UnitID) > 0
												 THEN dbo.FN_GetUnitConvertionRate(@propertyID,@masterUnit,UnitID)
												 ELSE 1 END * @Quantity
										WHERE RequestHeaderID = @ReferenceID
										AND StockItemID = @StockItemID;  

								END

						

					 --Added by Isuru 2026-08-03
							IF (@TransactionType = 'TO'
						   AND ISNULL(@IsProductionPlan, 0) = 0
						   AND ISNULL(@ReferenceID, 0) > 0
						   AND ISNULL(@IsRequestedQuantityExceed, 0) = 0)
							BEGIN
								SELECT TOP (1)
								@OverIssuedItem = ISNULL(SH.StockItemCode + ' / ' + SH.Name,
														'StockItemID ' + CAST(RD.StockItemID AS VARCHAR(20)))
								FROM   RequestDetails RD
										LEFT JOIN StockItemHeaders SH
												ON SH.Id        = RD.StockItemID
												AND SH.CompanyId = @PropertyID
								WHERE  RD.RequestHeaderID = @ReferenceID
									AND  RD.IssuedQuantity  > RD.ApprovedQuantity
									AND  EXISTS (SELECT 1
												FROM   StockTransactionDetails STD
												WHERE  STD.StockTransactionHeaderID = @StockTransactionHeaderID
													AND (STD.StockItemID            = RD.StockItemID
													OR STD.RequestedGenericItemId = RD.StockItemID))
								ORDER BY RD.StockItemID;

								IF @OverIssuedItem IS NOT NULL
								BEGIN
									SET @OverIssueError = 'Issued quantity cannot exceed approved quantity :- ' + @OverIssuedItem;
									RAISERROR ( @OverIssueError, 16, 1 );
									ROLLBACK TRANSACTION
								END
							END
						--ENd
 
					END;

	
					IF @TransactionType in ('GR','SR') 
					BEGIN
                
 
				
						SELECT @StockTransactionDetailID = Id,
							   @Qty = Quantity,
							   @ItemTotal = (UnitPrice - CASE WHEN DiscountValue>0 THEN ( DiscountValue / Quantity) ELSE UnitPrice * DiscountPercentage /100 END )
						FROM StockTransactionDetails
						WHERE StockItemID = @StockItemID
							  AND StockTransactionHeaderID = @StockTransactionHeaderID;
				
			 
		
						--INSERT INTO #TaxTable
						--EXEC [SP_Select_StockItemWiseTaxAmount] @StockItemID, @ItemTotal,@SupplierID; commented by isuru


			

					---added by ISURU 2023-04-27

						IF(@TransactionType='SR')
						BEGIN
						DECLARE @StockItemID2 BIGINT
						--print '@ReferenceID'
						--print @ReferenceID //comment by Nivesh 2024-01-31


						SELECT @StockItemID2 =  tt.StockItemID
						FROM    dbo.StockTransactionwiseTaxes tt
						INNER JOIN dbo.StockTransactionDetails sd ON sd.Id = tt.StockTransactionDetailID
						AND sd.StockItemID = tt.StockItemID
						INNER JOIN dbo.TaxDetails td ON td.TaxTypeId = tt.TaxTypeID
						WHERE   sd.StockTransactionHeaderID = @ReferenceID



						INSERT INTO #TaxTable
						SELECT tt.TaxTypeID,(tt.TaxAmount / Quantity)
						FROM    dbo.StockTransactionwiseTaxes tt
						INNER JOIN dbo.StockTransactionDetails sd ON sd.Id = tt.StockTransactionDetailID
						AND sd.StockItemID = tt.StockItemID
						INNER JOIN dbo.TaxDetails td ON td.TaxTypeId = tt.TaxTypeID
						WHERE   sd.StockTransactionHeaderID = @ReferenceID AND  sd.stockitemid = @StockItemID

							INSERT INTO StockTransactionwiseTaxes
							(
								StockTransactionDetailID,
								StockItemID,
								TaxTypeID,
								TaxAmount
							)
							SELECT
							@StockTransactionDetailID,
								   @StockItemID,
								   TaxTypeId,
								   TaxValue * @Qty
							FROM #TaxTable WHERE  TaxValue > 0 --AND @StockItemID = @StockItemID2
							DELETE FROM #TaxTable;
						END

				

						IF(@TransactionType in ('GR'))
						BEGIN

						INSERT INTO #TaxTable
						EXEC [SP_Select_StockItemWiseTaxAmount] @StockItemID, @ItemTotal,@SupplierID,@LocationID; --@LocationID added by Isuru 2024-12-10

						--SELECT t.TaxValue as yyyyy
						--FROM #TaxTable t //comment by Nivesh 2024-01-31

							INSERT INTO StockTransactionwiseTaxes
							(
								StockTransactionDetailID,
								StockItemID,
								TaxTypeID,
								TaxAmount
							)
							SELECT @StockTransactionDetailID,
								   @StockItemID,
								   TaxTypeId,
								   TaxValue * @Qty
							FROM #TaxTable WHERE TaxValue > 0
							DELETE FROM #TaxTable;
						END


						---END 2023-04-27
				-------------If not GRN approval-----------------
						IF(@IsGRNTransactionApproval = 0)
						BEGIN
				
							IF @TransactionType='GR'
							BEGIN
							SELECT @Quantity grnQty

							SELECT 'UPDATE PO',@Quantity/dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,@StockItemID))

								UPDATE PoDetails
								SET ReceivedQuantity = ReceivedQuantity + ( @Quantity/dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,@StockItemID)))
								WHERE PoHeaderID = @ReferenceID
									  AND StockItemID = @StockItemID;
							END 

							IF
							(
								SELECT COUNT(*)
								FROM PoDetails
								WHERE PoHeaderID = @ReferenceID
									  AND ApprovedQuantity > ReceivedQuantity
							) = 0 and @TransactionType='GR'
							BEGIN

							IF EXISTS (SELECT 1 FROM PoHeaders WHERE ID = @ReferenceID AND DocumentStatus = 'C')
							BEGIN
					
								RAISERROR ( 'PO Document Already Completed', 16, 1 );  
								ROLLBACK TRANSACTION

							END

								UPDATE PoHeaders
								SET DocumentStatus = 'C'
								WHERE Id = @ReferenceID;

								--Added by Isuru 2025-12-22 to validate invalid Location submitting with PO based GRN

							IF(@ReferenceID >0 and @TransactionType='GR')
							BEGIN
								SELECT @POLocationID = LocationID
								FROM PoHeaders PH
								WHERE Id = @ReferenceID 

								IF(@LocationID <> @POLocationID)
								BEGIN
									RAISERROR ( 'PO location and GRN location mismatch Found', 16, 1 );  
									ROLLBACK TRANSACTION
								END

							END
							--End


							END;

						END
				-------------If not GRN approval-----------------
					END;

					IF @Mode = 'M'
					   AND @TransactionType = 'AA'  
					BEGIN

						SELECT 'SP_AjustMonthlyReconcellation',
						@LocationID LocationID,@StockItemID StockItemID,@txnDateFromFront txnDateFromFront,@StockTransactionHeaderID StockTransactionHeaderID
						
						EXEC SP_AjustMonthlyReconcellation @LocationID,
														   @StockItemID,
														   --@txnDate,
														   @txnDateFromFront,
														   @StockTransactionHeaderID;
			

					END;
					DELETE FROM #ItemList
					WHERE StockItemID = @StockItemID;

				END;


				--added 16/10/2018 for partial IN fix
						
				IF @TransactionType IN ( 'IN', 'TO', 'BI' )
				BEGIN
					

				--Added by Isuru 2023-06-14 
				Declare @IsCompleteRequests bit

				SELECT @IsCompleteRequests = IsCompleteRequests
				FROM Companies WHERE CompanyID = @PropertyID
				IF (@IsCompleteRequests = 1)
				BEGIN
					IF(@TransactionType = 'TO' AND @IsProductionPlan =1)
					BEGIN
						UPDATE ProductionConsolidateHeader
						SET IsTransferComplete = 1
						WHERE ID = @ReferenceID

					END
					ELSE
					BEGIN
						UPDATE RequestHeaders
						SET DocumentStatus = 'C'
						WHERE Id = @ReferenceID;
					END
			
				END
				--end
				--SELECT @ReferenceID '555'
				ELSE
				BEGIN
					IF(@TransactionType = 'TO' AND @IsProductionPlan = 1)
					BEGIN
						IF NOT EXISTS (SELECT 1 FROM ProductionConsolidateRecipeSummary
						WHERE ProductionConsolidateHeaderID = @ReferenceID AND RecievedQuantity < ConvertedQuanity)
						BEGIN
							UPDATE ProductionConsolidateHeader
							SET IsTransferComplete = 1
							WHERE ID = @ReferenceID
						END;	
					END
					ELSE
					BEGIN
						IF(SELECT SUM(ApprovedQuantity - IssuedQuantity)
							FROM RequestDetails
							WHERE RequestHeaderID = @ReferenceID) = 0
						BEGIN
							UPDATE RequestHeaders
							SET DocumentStatus = 'C'
							WHERE Id = @ReferenceID;
						END;
					END
				END


				END;

				-- For Item Wise Expire Dates ---

			--Add expiry Date -- Added by Nivesh 2024-06-28
				--DECLARE @EXPDate DATETIME
				--IF @TransactionType = 'PI'
				--BEGIN
					
				--	SELECT @EXPDate = EXPDate
				--	FROM
				--	OPENXML(@iDocID, '/StockTransactionHeader', 2)
				--	WITH StockItemWiseEXPDateIns;

				--	INSERT INTO StockItemWiseEXPDateIns
				--	SELECT @PropertyID,@LocationID,@StockTransactionHeaderID,@TransactionType,StockItemID,Quantity,Quantity,@EXPDate,GETDATE()
				--	FROM
				--	OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
				--	WITH StockItemWiseEXPDateIns;
					
				--END

				DECLARE @EXPDatePU DATETIME
				IF @TransactionType = 'PU'
				BEGIN
					
					--SELECT @EXPDatePU = EXPDate
					--FROM
					--OPENXML(@iDocID, '/StockTransactionHeader', 2)
					--WITH StockItemWiseEXPDateIns;

					select 11111 --test

					--SELECT @PropertyID,@LocationID,@StockTransactionHeaderID,@TransactionType,StockItemID,Quantity,Quantity,@EXPDatePU,GETDATE()
					--FROM
					--OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
					--WITH StockItemWiseEXPDateIns; --test

					--INSERT INTO StockItemWiseEXPDateIns
					--SELECT @PropertyID,@LocationID,@StockTransactionHeaderID,@TransactionType,StockItemID,Quantity,Quantity,@EXPDatePU,GETDATE()
					--FROM
					--OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
					--WITH StockItemWiseEXPDateIns;
					
				END
			---------------------				
				IF (@TransactionType in ('AA','GR') AND @IsBatchTransactionEnable =0) -- Reconcilation added by Isuru 2026-02-10 
				BEGIN

					INSERT INTO StockItemWiseEXPDateIns
					( PropertyID, LocationID, TransactionID, TransactionType, StockItemID, Quantity, BalanceQuantity, EXPDate, LogDate, BatchNo, TxnUnitID, StockMasterQty, TransactionDate, MasterUnitID, PhysicalQty, TxnType, 
                         SellingPrice)
					SELECT @PropertyID,@LocationID,@StockTransactionHeaderID,@TransactionType,StockItemID,Quantity,Quantity,EXPDate,GETDATE(),BatchNo,NULL,NULL,NULL,NULL,NULL,NULL,NULL
					FROM
					#TempStockItemWiseEXPDateIns;

					------for temperature----------
					INSERT INTO stockitemwisetemperature
					SELECT @PropertyID,@LocationID,@StockTransactionHeaderID,@TransactionType,StockItemID,Quantity,Temperature,GETDATE(),TypeId
					FROM
					#TempStockItemWiseTemperature;
					------for temperature----------
		
				END
				ELSE IF (@TransactionType IN ('IN','II','TO') AND @IsBatchTransactionEnable =0)
				BEGIN


	
					--SELECT  @PropertyID , @LocationID,  @StockItemID, @Quantity , @StockTransactionHeaderID 'sss' //comment by Nivesh 2024-01-31
				
					declare @TransactionID INT = dbo.FN_getTransactionID(@TransactionType)
					--SELECT @TransactionID 'sss2' //comment by Nivesh 2024-01-31
					EXEC [UpdateExpDateFIFO] @PropertyID,@LocationID,  @StockItemID, @Quantity , @StockTransactionHeaderID ,  @TransactionID

				END 



				SELECT	@docno = DocumentNo
				FROM	dbo.StockTransactionHeaders
				WHERE	Id = @StockTransactionHeaderID;

				SET		@headerid = @StockTransactionHeaderID;

				--if @trancount = 0
       
				SET @status = @statusIN;
				DECLARE @POSTGL INT, @GLCOMPCODE VARCHAR(10), @BLOCKCODEID INT, @LEVEL1 VARCHAR(10), @TID INT, @LocationCode VARCHAR(120), @GLPostType CHAR(4)

				SELECT @POSTGL=POSTGL, @GLCOMPCODE= C.CODE, @LEVEL1=l.Code, @LocationCode=l.Code, @GLPostType = PostGLType  
				FROM Companies  C
				INNER JOIN Locations L ON L.CompanyID= c.CompanyID
				where C.CompanyID= @propertyID and L.ID= @LocationID


				IF @TransactionType IN ('IN','IR','IF','RC','FW')
				BEGIN 

					SELECT @LEVEL1= D.CODE FROM StockTransactionHeaders s
					INNER JOIN Departments D ON D.ID = S.DepartmentID
					WHERE S.ID= @StockTransactionHeaderID

				END 
						
				SELECT @TID= dbo.FN_getTransactionID(@TransactionType)

				---------Added--------------------------------
				DECLARE @IsDalyMarketBit BIT , @DailymarketDepartment INT , @DeptTag VARCHAR(500), @TxnTypeTag VARCHAR(250), @TxnIdTag VARCHAR(250), @TxnMode VARCHAR(250)	
				SELECT @IsDalyMarketBit = ApplyDailyMarketProcess,@DailymarketDepartment = DailyMarketDepartment FROM dbo.Locations WHERE Id = @LocationID

				--SELECT @TransactionType 'GR' ,  @IsDalyMarketBit  IsDalyMarketBit  //comment by Nivesh 2024-01-31

					SELECT StockItemID INTO #TempAllItems FROM 
					#TempAllDetails WHERE Quantity > 0

		
				IF (@TransactionType = 'GR' AND @IsDalyMarketBit = 1 AND ( EXISTS(SELECT T.*
					FROM #TempAllItems T
					INNER JOIN StockItemWiseAttributes SA
					ON StockItemID = SA.StockItemHeaderID
					INNER JOIN dbo.CompanySettings C
					ON C.DailyMarketItemAttributeid = SA.StockItemAttributeID
					WHERE C.CompanyId = @PropertyID AND  SA.IsActive = 1)))
				BEGIN 
					DECLARE @RemovetemId INT

			
					DELETE FROM  T
					FROM #TempAllItems T
					INNER JOIN StockItemWiseAttributes SA
					ON StockItemID = SA.StockItemHeaderID
					INNER JOIN dbo.CompanySettings C
					ON C.DailyMarketItemAttributeid = SA.StockItemAttributeID
					WHERE C.CompanyId = @PropertyID AND  SA.IsActive = 1
         
					WHILE ((SELECT COUNT(*) FROM #TempAllItems ) > 0)
					BEGIN
						SELECT  TOP(1) @RemovetemId = StockItemID
						FROM #TempAllItems

						SET @XMLDetails.modify
						('delete /StockTransactionHeader/StockDetailList/StockTransactionDetail[StockItemID = sql:variable("@RemovetemId")]')

						DELETE TOP(1) FROM #TempAllItems
					END
			
					--SELECT @XMLDetails //comment by Nivesh 2024-01-31

					SET @DeptTag = '<DepartmentID>'+CONVERT(VARCHAR(10),@DailymarketDepartment)+'</DepartmentID>'
					SET @TxnTypeTag = '<TransactionType>IN</TransactionType>'
					SET @TxnIdTag = '<TransactionID>6</TransactionID>'
					SET @TxnMode = '<TxnType>M</TxnType>'

					DECLARE @TmpXml VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @XMLDetails)
			
					SET @TmpXml = REPLACE( @TmpXml , '<DepartmentID>0</DepartmentID>', @DeptTag)
					SET @TmpXml = REPLACE( @TmpXml ,'<TransactionType>GR</TransactionType>', @TxnTypeTag)
					SET @TmpXml = REPLACE( @TmpXml ,'<TransactionID>3</TransactionID>', @TxnIdTag)
					SET @TmpXml = REPLACE( @TmpXml ,'<TxnType>P</TxnType>', @TxnMode)


					 
					

					EXEC  [dbo].[SP_InsertStockTransactions]  @TmpXml, '',0,'',0,1
	

				END 
				---------Added--------------------------------


								 --------------------------Auto Transfer Out With GRN-----------
				DECLARE  @GRLocTag VARCHAR(500), @TransferGRLocTag VARCHAR(500),@OldGRLocTag VARCHAR(500), @OldGRTransferLocTag VARCHAR(500),@TransferGRNID INT,@TransferStockItemID INT
				,@TransferStockItemName VARCHAR(200),@TransferItemCheckErr VARCHAR(MAX),@OldRefrenceID INT
		
		
				IF(@IsAutoTransferGRN =1 AND @TransactionType = 'GR' AND @TransferLocationID <>0)
				BEGIN
					
					----- Add new element IsAutoTransferGRN - Added by Nivesh 2025-11-07----------
					IF @XMLDetails.exist('/StockTransactionHeader/IsAutoTrasferGRN') = 0
					BEGIN
						SET @XMLDetails.modify('insert <IsAutoTrasferGRN>1</IsAutoTrasferGRN> as last into (/StockTransactionHeader)[1]');
					END
					--------------------------------
					
					DECLARE @TmpGRXmlTI VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @XMLDetails)


					SELECT @OldRefrenceID= ReferenceID FROM StockTransactionHeaders WHERE Id =@StockTransactionHeaderID

				
					SET @OldGRLocTag = '<LocationID>'+CONVERT(VARCHAR(10),@LocationID)+'</LocationID>'
					SET @OldGRTransferLocTag = '<TransferLocationID>'+CONVERT(VARCHAR(10),@TransferLocationID)+'</TransferLocationID>'
					SET @GRLocTag = '<LocationID>'+CONVERT(VARCHAR(10),@LocationID)+'</LocationID>'
					SET @TransferGRLocTag = '<TransferLocationID>'+CONVERT(VARCHAR(10),@TransferLocationID)+'</TransferLocationID>'
					SET @TmpGRXmlTI = REPLACE( @TmpGRXmlTI , '<TxnType>M</TxnType>','<TxnType>M</TxnType>')
					SET @TmpGRXmlTI = REPLACE( @TmpGRXmlTI , '<ReferenceID>'+CONVERT(VARCHAR(10),@OldRefrenceID)+'</ReferenceID>','<ReferenceID>'+CONVERT(VARCHAR(10),@StockTransactionHeaderID)+'</ReferenceID>')
					SET @TmpGRXmlTI = REPLACE( @TmpGRXmlTI ,'<TransactionType>GR</TransactionType>', '<TransactionType>TO</TransactionType>')
					SET @TmpGRXmlTI = REPLACE( @TmpGRXmlTI ,@OldGRLocTag, @GRLocTag)
					SET @TmpGRXmlTI = REPLACE( @TmpGRXmlTI ,@OldGRTransferLocTag, @TransferGRLocTag)

					DECLARE @MainGRXML AS XML = CONVERT(XML,@TmpGRXmlTI)

					SELECT * INTO #GRTransferInItems FROM #TempAllDetails

					UPDATE  TIN
					SET TIN.unitPrice = TON.UnitPrice, TIN.txnType='M',TIN.TxnUnitID= dbo.FN_GetMasterUnitID(@propertyID,@LocationID,TIN.stockItemId)
					from #GRTransferInItems TIN 
					INNER JOIN #tempTxnDetails  TON ON TIN.stockItemId = TON.StockItemID

					DECLARE @GRXMLDataTI XML

					SET @GRXMLDataTI = (SELECT * FROM #GRTransferInItems for xml path ('StockTransactionDetail'),root('StockDetailList'))

					declare @TmpGRXml2 AS XML= CONVERT(XML,@GRXMLDataTI)

					SET @MainGRXML.modify('delete (/StockTransactionHeader/StockDetailList/StockTransactionDetail)')

					
					SET @MainGRXML.modify('insert sql:variable("@GRXMLDataTI") as first into (/StockTransactionHeader)[1]')

					select *
					into #tempTransferItemCheck
					from #GRTransferInItems

					WHILE EXISTS(SELECT 1 FROM #tempTransferItemCheck)
					BEGIN
					SELECT TOP(1) @TransferStockItemID= STOCKITEMID, @TransferStockItemName = SH.Name 
					FROM #tempTransferItemCheck TP
					INNER JOIN StockItemHeaders SH ON TP.STOCKITEMID = SH.Id

					IF NOT EXISTS (SELECT 1 FROM StockItemDetails WHERE StockItemId =@TransferStockItemID AND LocationID=@TransferLocationID )
					BEGIN
							SET @TransferItemCheckErr =  @TransferStockItemName + ' - is not in Transferring Location'
							RAISERROR ( @TransferItemCheckErr, 16, 1 );  
							ROLLBACK TRANSACTION
					END


					DELETE TOP(1) FROM #tempTransferItemCheck
					END
					----------Modified by Nivesh 2025-11-07--------------
					DECLARE @TOGRNDocNO NVARCHAR(100), @TOGRNDocID INT

					EXEC  [dbo].[SP_InsertStockTransactions]  @MainGRXML, @TOGRNDocNO OUTPUT,0,'',@TOGRNDocID OUTPUT,1

					INSERT INTO @TempBulkDocNo (DocNo, Id)
					VALUES (@TOGRNDocNO,@TOGRNDocID)
					------------------------
				END




				-----------End------------------

			----------------auto TI-------------
					DECLARE @AutoTI BIT, @LocTag VARCHAR(500), @TransferLocTag VARCHAR(500),@OldLocTag VARCHAR(500), @OldTransferLocTag VARCHAR(500),@OldTOReferenceID INT
					



					SELECT @AutoTI = IsAutoTransferIn FROM Companies WHERE CompanyID = @PropertyID

					IF(@TransactionType = 'TO' AND @IsProductionPlan =1)
					BEGIN
						SET @AutoTI = 1
					END


					IF(@AutoTI = 1 AND @TransactionType = 'TO')
					BEGIN
						DECLARE @TmpXmlTI VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @XMLDetails), @TransferINItemID INT,@INAVGPrice decimal(18,8)


						SELECT @OldTOReferenceID = ReferenceID FROM StockTransactionHeaders WHERE Id = @StockTransactionHeaderID

						select @StockTransactionHeaderID 'inside TO @StockTransactionHeaderID'

						SET @OldLocTag = '<LocationID>'+CONVERT(VARCHAR(10),@LocationID)+'</LocationID>'
						SET @OldTransferLocTag = '<TransferLocationID>'+CONVERT(VARCHAR(10),@TransferLocationID)+'</TransferLocationID>'
						SET @LocTag = '<LocationID>'+CONVERT(VARCHAR(10),@TransferLocationID)+'</LocationID>'
						SET @TransferLocTag = '<TransferLocationID>'+CONVERT(VARCHAR(10),@LocationID)+'</TransferLocationID>'

						SET @TmpXmlTI = REPLACE( @TmpXmlTI , '<ReferenceID>'+CONVERT(VARCHAR(10),@OldTOReferenceID)+'</ReferenceID>','<ReferenceID>'+CONVERT(VARCHAR(10),@StockTransactionHeaderID)+'</ReferenceID>')
						SET @TmpXmlTI = REPLACE( @TmpXmlTI , '<TxnType>M</TxnType>','<TxnType>P</TxnType>')
						SET @TmpXmlTI = REPLACE( @TmpXmlTI ,'<TransactionType>TO</TransactionType>', '<TransactionType>TI</TransactionType>')
						SET @TmpXmlTI = REPLACE( @TmpXmlTI , '<StockTransactionHeaderID>-1</StockTransactionHeaderID>','<StockTransactionHeaderID>'+CONVERT(VARCHAR(10),@StockTransactionHeaderID)+'</StockTransactionHeaderID>')
						SET @TmpXmlTI = REPLACE( @TmpXmlTI ,@OldLocTag, @LocTag)
						SET @TmpXmlTI = REPLACE( @TmpXmlTI ,@OldTransferLocTag, @TransferLocTag)

						DECLARE @MainXML AS XML = CONVERT(XML,@TmpXmlTI)
				
						SELECT * INTO #TransferInItems FROM #TempAllDetails 
						WHERE Quantity >0

						SELECT * INTO #TempGenericItem FROM #TransferInItems

						WHILE EXISTS(SELECT 1 FROM #TempGenericItem)
						BEGIN
						SET @GenericStockItemID = 0
						SET @GenericCode = 0

						SELECT TOP(1) @TransferINItemID =  STOCKITEMID FROM #TempGenericItem

						SELECT @GenericCode =SH.GenericItemCode
						FROM #TransferInItems TI
						INNER JOIN STOCKITEMHEADERS SH ON TI.StockitemID = sh.Id
						AND STOCKITEMID = @TransferINItemID
						WHERE CompanyId = @PropertyID

						SELECT @GenericStockItemID = Id
						FROM StockItemHeaders SH
						WHERE StockItemCode = @GenericCode
						AND CompanyId = @PropertyID

						
						
						
						IF (@GenericStockItemID <>0)
						BEGIN

						SELECT @INAVGPrice =SD.AveragePrice
						FROM #TransferInItems TP
						INNER JOIN StockItemHeaders SH ON SH.Id = TP.StockitemID
						INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.ID 
						WHERE SH.Id = @GenericStockItemID AND SD.LocationID = @TransferLocationID AND SH.CompanyId = @PropertyID;
						
						IF @INAVGPrice IS NULL
						BEGIN
							SELECT @INAVGPrice =SD.AveragePrice
							FROM StockItemHeaders SH 
							INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.ID 
							WHERE SH.Id = @GenericStockItemID AND SD.LocationID = @TransferLocationID AND SH.CompanyId = @PropertyID;							
						END
						SELECT @masterUnitid= TxnUnitID FROM #TransferInItems WHERE StockitemID= @GenericStockItemID; --Added Nivesh for getting master unit id of generic item
						IF @masterUnitid IS NULL
						BEGIN
							SELECT @masterUnitid =SD.MasterUnitID
							FROM StockItemHeaders SH 
							INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.ID 
							WHERE SH.Id = @GenericStockItemID AND SD.LocationID = @TransferLocationID AND SH.CompanyId = @PropertyID;							
						END
						DECLARE @tempmasid INT
						SELECT @tempmasid= TxnUnitID FROM #TransferInItems WHERE StockitemID= @TransferINItemID; --Added Nivesh for getting item master unit id

						WITH ConversionRates AS (
						SELECT 
							StockitemID,
							dbo.FN_GetUnitConvertionRate(@PropertyID, @tempmasid, @masterUnitid) AS ConversionRate,
							Quantity,
							TxnUnitID
						FROM 
							#TransferInItems
						WHERE StockitemID =@TransferINItemID
						)
						UPDATE #TransferInItems
						SET 
							TxnUnitID = @masterUnitid,
							Quantity = ti.Quantity * cr.ConversionRate	-- Added by Isuru 2025-07-29 to fix generic item avg price issue
							,unitPrice = ti.unitPrice / cr.ConversionRate  -- Added by Isuru 2025-07-29 to fix generic item avg price issue
							,SellingPrice = ti.unitPrice / cr.ConversionRate -- Added by Isuru 2025-07-29 to fix generic item avg price issue
							
						FROM 
							#TransferInItems ti
						JOIN 
							ConversionRates cr ON ti.StockitemID = cr.StockitemID and ti.Quantity= cr.Quantity and ti.TxnUnitID =cr.TxnUnitID
						WHERE ti.StockitemID =@TransferINItemID; --Added Nivesh update quantity according to unit conversion to generic item
			

			
							UPDATE #TransferInItems
							SET StockitemID = @GenericStockItemID--,unitPrice =@INAVGPrice
							,RequestedGenericItemId =@GenericStockItemID
							WHERE StockitemID = @TransferINItemID

						END



						DELETE TOP (1) FROM #TempGenericItem

						END;

						
				

						UPDATE  TIN
						SET TIN.unitPrice = TON.UnitPrice, TIN.txnType='P'
						from #TransferInItems TIN 
						INNER JOIN #tempTxnDetails  TON ON TIN.stockItemId = TON.StockItemID;


						
					

					SELECT StockItemID,SUM(Quantity) Quantity,SUM(UnitPrice) UnitPrice2,SUM(UnitPrice * Quantity)/SUM(Quantity) UnitPrice
					INTO #tempTransferInItems
					FROM #TransferInItems
					GROUP BY StockItemID --Added Nivesh


					
			
					------------------


					select t1.Quantity t1Quantity, t2.Quantity t2Quantity,t1.UnitPrice t1UnitPrice, t2.UnitPrice t2UnitPrice,T1.SellingPrice t1SellingPrice,t2.UnitPrice t2
					FROM #TransferInItems t1
					INNER JOIN
					#tempTransferInItems t2 ON t2.StockItemID = t1.StockItemID 

					UPDATE t1
					SET t1.Quantity = t2.Quantity,t1.UnitPrice = t2.UnitPrice,T1.SellingPrice =t2.UnitPrice -- Added by Isuru 2025-07-29 to fix generic item avg price issue
					FROM
					#TransferInItems t1
					INNER JOIN
					#tempTransferInItems t2 ON t2.StockItemID = t1.StockItemID --AND t1.UnitPrice = t2.UnitPrice --Added Nivesh Convert item master unitwise quantity into generic tiem master unitewise quantity
					
					------------------
						DECLARE @XMLDataTI XML
						
						UPDATE #TransferInItems
						SET StockTransactionHeaderID = @StockTransactionHeaderID --Added by Nivesh 2025-01-06
						--For updating isTransferin flag true when auto transfer transaction
						DECLARE @CurrentDate DATETIME = GETDATE()

						UPDATE #TransferInItems
						SET CreatedDate = @CurrentDate ,
							LastModDate = @CurrentDate,
							txnType='P'

							--Added by Isuru 2025-07-31 to validate missing item in auto transfer in

							SELECT *
							INTO #CHECKTO
							FROM (
							SELECT DISTINCT StockItemID
							FROM StockTransactionDetails
							WHERE StockTransactionHeaderID = @StockTransactionHeaderID
							AND RequestedGenericItemId =0
							UNION ALL
							SELECT DISTINCT RequestedGenericItemId
							FROM StockTransactionDetails
							WHERE StockTransactionHeaderID = @StockTransactionHeaderID
							AND RequestedGenericItemId <>0
							) A

							SELECT distinct  StockItemID
							INTO #CheckTI
							FROM #TransferInItems
							
							DECLARE @MissingItemName VARCHAR(MAX),@MissingItemID INT
							IF EXISTS (SELECT 1 FROM #CHECKTO WHERE StockItemID NOT IN (SELECT StockItemID FROM #CheckTI))
							BEGIN
								SELECT TOP 1 @MissingItemID =StockItemID FROM #CHECKTO WHERE StockItemID NOT IN (SELECT StockItemID FROM #CheckTI)
								
								SELECT @MissingItemName = Name
								FROM StockItemHeaders
								WHERE ID = @MissingItemID

								SET @InvError2 =  'Missing Item  found in Auto Transfer In. Item Name :' +@MissingItemName+' .'
								RAISERROR ( @InvError2, 16, 1 );  
								ROLLBACK TRANSACTION

							END

						--End

						SET @XMLDataTI = (SELECT distinct * FROM #TransferInItems for xml path ('StockTransactionDetail'),root('StockDetailList'))
						
						declare @TmpXml2 AS XML= CONVERT(XML,@XMLDataTI)

						SET @MainXML.modify('delete (/StockTransactionHeader/StockDetailList/StockTransactionDetail)')
					
						--select @MainXML 'delete ' //comment by Nivesh 2024-01-31

						SET @MainXML.modify('insert sql:variable("@XMLDataTI") as first into (/StockTransactionHeader)[1]')
						--select @MainXML 'insert' //comment by Nivesh 2024-01-31
						
						EXEC  [dbo].[SP_InsertStockTransactions]  @MainXML, '',0,'',0,1
					END

					----------------auto TI-------------
					SELECT @IsAutoProduction = IsAutoProduction FROM Companies WHERE CompanyID = @PropertyID 
					-- Removed 2026-08-19 by Isuru production retro-costing.
					-- This block used to overwrite the PU (production stock-in) row AFTER it had
					-- already posted, ASSIGNING the batch cost over the finished item's average
					-- price instead of blending it in:
					--     NewAveragePrice = SUM(PI.UnitPrice * PI.Quantity) / PU.Quantity / rate
					-- Any stock already on hand was silently revalued to the latest batch cost,
					-- which created inventory value with no matching journal entry.
					-- The batch cost is now computed in SP_SaveProductionRecipeDetails BEFORE the
					-- PU leg posts and passed in as the PU line's UnitPrice, so FN_GetAveragePrice
					-- blends it into the running moving weighted average like any other receipt.

					--IF(@TransactionType = 'PI' ) --AND @IsAutoProduction =1 COMMENT BY NIVESH 2025-06-20
					--BEGIN


						
					--	SELECT StockItemID,  NewAveragePrice ,NewQuantity
					--	FROM StockTransactionDetails 
					--	WHERE StockTransactionHeaderID = @ReferenceID

					--	UPDATE StockTransactionDetails
					--	SET NewAveragePrice = (ISNULL((SELECT SUM(UnitPrice*Quantity) FROM StockTransactionDetails WHERE StockTransactionHeaderID = @headerid),0) / Quantity) 
					--	/dbo.FN_GetUnitConvertionRate(@PropertyId,TxnUnitID,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,StockItemID))
					--	WHERE StockTransactionHeaderID = @ReferenceID

					--	UPDATE SD
					--	SET SD.AveragePrice = ISNULL((SELECT SUM(UnitPrice*Quantity) FROM StockTransactionDetails WHERE StockTransactionHeaderID = @headerid),0) / STD.Quantity
					--	/dbo.FN_GetUnitConvertionRate(@PropertyId,TxnUnitID,dbo.FN_GetMasterUnitID(@PropertyId,@LocationID,SD.StockItemHeaderID))
					--	FROM StockTransactionDetails STD INNER JOIN StockTransactionHeaders STH ON STD.StockTransactionHeaderID = STH.Id
					--	INNER JOIN StockItemDetails SD ON STH.LocationID = SD.LocationID AND SD.StockItemHeaderID = STD.StockItemID
					--	WHERE STH.ID =  @ReferenceID

					--END


				SELECT @BLOCKCODEID = GLBlockID FROM TransactionTypes
				WHERE  ID=  @TID 


				--select @POSTGL , @GLCOMPCODE , @BLOCKCODEID , @LEVEL1 , @TID //comment by Nivesh 2024-01-31
				SELECT @IsGLEnabled = LO.IsGLEnabled
				FROM StockTransactionHeaders SH
				INNER JOIN Locations LO ON SH.LocationID = LO.Id
				WHERE SH.Id= @StockTransactionHeaderID
			

				IF  (@POSTGL= 1 AND @IsGLEnabled=1)
				BEGIN
					IF (@GLPostType='HTGL' )
					BEGIN

						--select 'docNo',@DocumentNo, @StockTransactionHeaderID //comment by Nivesh 2024-01-31

						DECLARE @XMLDATA XML, @OUTPUTREQ VARCHAR(MAX), @ItemDetailXml XML
						DECLARE @InvoiceLocationCode VARCHAR(120) = ''

						IF @TransactionType IN ('GR','SR','IN','IR','DN','IF','RC','AA','PU','PI','FW','BI')  -- ,'PU','PI' ADDED BY ISURU FOR CHECKING MAPPPING FOR PU,PI 2024-06-28
						-- 'AA', ADDED BY Isuru 2024-05-31 for Mapping check with AA
						--'BI' ADDED BY Isuru 2026-09-03 for mapping checking with BackEnd Invoice
						BEGIN

							IF @TransactionType = 'BI'
							BEGIN

								SELECT @InvoiceLocationCode = ISNULL(L.Code,'')
								FROM StockTransactionHeaders S
								INNER JOIN Locations L ON L.Id = S.InvoiceLocationID
								WHERE S.Id = @StockTransactionHeaderID

							END
							--SELECT StockItemID  
							--FROM StockTransactionDetails
							--where StockTransactionHeaderID= @StockTransactionHeaderID //comment by Nivesh 2024-01-31

							SET @ItemDetailXml =(select StockItemID ITEMID 
							FROM StockTransactionDetails
							where StockTransactionHeaderID= @StockTransactionHeaderID
							FOR XML PATH('ITEMDETAIL'))

							SET @XMLDATA ='
								<MYROOT>
								<HEADER>
								<GLCOMPCODE>' + @GLCOMPCODE + '</GLCOMPCODE>
								<BLOCKCODEID>'+ CONVERT(VARCHAR(MAX),@BLOCKCODEID)+'</BLOCKCODEID>
								<LEVEL1>'+ REPLACE(@LEVEL1, '&', '&amp;') +'</LEVEL1>
								<LOCATIONCODE>'+ REPLACE(@LocationCode, '&', '&amp;') +'</LOCATIONCODE>
								<INVOICELOCATIONCODE>'+ REPLACE(ISNULL(@InvoiceLocationCode,''), '&', '&amp;') +'</INVOICELOCATIONCODE>
								</HEADER>
									<DETAILS>
										'+ CONVERT(VARCHAR(MAX),@ItemDetailXml) +'
									</DETAILS>
								</MYROOT>'

							--SELECT 'GL_POSTING_INTEGRATION_VALIDATION',@StockTransactionHeaderID, @XMLDATA,@OUTPUTREQ //comment by Nivesh 2024-01-31

							--exec GL_POSTING_INTEGRATION_VALIDATION @XMLDATA,@OUTPUTREQ OUTPUT
								
								insert into tempStockTran (XmlDATA)	
								select convert(varchar(max),  @XMLDATA) 

							exec [eFinancials_Accounting].[dbo].GL_POSTING_INTEGRATION_VALIDATION @XMLDATA,@OUTPUTREQ OUTPUT

							

							--Added 2023-09-05 by Isuru for Adding ACCId in Issue Note 
								IF(@TransactionType = 'IN')
								BEGIN

								DECLARE @AccStockItemId INT



									WHILE ((SELECT COUNT(*) FROM #TempAccIdTable ) > 0)
									BEGIN
										SELECT  TOP(1) @AccStockItemId = StockItemID
										FROM #TempAccIdTable

										--SELECT *--COS DEBIT
									UPDATE SD
									SET CostTransactionAccountID = SA.AccID
									FROM [Categlog_vrV2].DBO.StockTransactionHeaders SH
										INNER JOIN StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID 
										INNER JOIN StockItemHeaders SIH ON SD.StockItemID = SIH.Id 
										INNER JOIN Departments D ON SH.DepartmentID = D.Id
										INNER JOIN Categories C ON SIH.CategoryID = C.ID
										INNER JOIN SubCategories SC ON SIH.SubCategoryID = SC.ID
										INNER JOIN SubCategories02 SC2 ON SIH.SubCategory2ID = SC2.ID
										INNER JOIN [eFinancials_Accounting].DBO.Destinity_GLIntegrationAccountMapping GL ON D.Code = GL.Level1 
										AND C.CODE = GL.Level2 AND SC.CODE = GL.Level3 AND SC2.CODE = GL.Level4
										INNER JOIN [eFinancials_Accounting].DBO.accSubAccountRef SA ON GL.AccCode = SA.AccCode
									WHERE GL.BLOCKCODE = 'ISN' AND GL.GLCOMPCODE = @GLCOMPCODE AND SH.TransactionType = 'IN' 
									AND SH.PropertyID = @PROPERTYID --AND ISNULL(SD.CostTransactionAccountID,0) = 0
									AND SD.StockTransactionHeaderID = @StockTransactionHeaderID
									AND SD.StockItemID = @AccStockItemId



									--SELECT *--STOCK CREDIT
									UPDATE SD
									SET PurchaseTransactionAccountID = SA.AccID
									FROM [Categlog_vrV2].DBO.StockTransactionHeaders SH
										INNER JOIN StockTransactionDetails SD ON SH.ID = SD.StockTransactionHeaderID
										INNER JOIN StockItemHeaders SIH ON SD.StockItemID = SIH.Id
										INNER JOIN DBO.Locations D ON SH.LocationID = D.Id
										INNER JOIN Categories C ON SIH.CategoryID = C.ID
										INNER JOIN [eFinancials_Accounting].DBO.Destinity_GLIntegrationAccountMapping GL ON D.Code = GL.Level1 AND C.CODE = GL.Level2 
										INNER JOIN [eFinancials_Accounting].DBO.accSubAccountRef SA ON GL.AccCode = SA.AccCode
									WHERE GL.BLOCKCODE = 'GRN' AND GL.GLCOMPCODE = @GLCOMPCODE AND SH.TransactionType = 'IN' 
									AND SH.PropertyID = @PROPERTYID --AND ISNULL(SD.PurchaseTransactionAccountID,0) = 0
										AND SD.StockTransactionHeaderID = @StockTransactionHeaderID
									AND SD.StockItemID = @AccStockItemId
										

										DELETE TOP(1) FROM #TempAccIdTable
									END

								

								END
								--End



							

							--SELECT 'GL_POSTING_INTEGRATION_VALIDATION',@StockTransactionHeaderID, @XMLDATA,@OUTPUTREQ //comment by Nivesh 2024-01-31
				
						END 

						IF ( @TransactionType = 'PI' )
						BEGIN			
							EXEC [dbo].[PostInventoryProductionToGL] @ReferenceID
						END

						--IF @TransactionType IN ('GR','SR')  
						--BEGIN			
						--	EXEC [PostInventoryGRNToGL] @StockTransactionHeaderID;
						--END

					-----------added-------------------------------
						DECLARE @DocSum DECIMAL(25,10)

						SELECT * INTO #tempGetDocSum FROM 
						#TempAllDetails WHERE Quantity > 0

						SELECT @DocSum = SUM(Quantity * UnitPrice) FROM #tempGetDocSum

						IF @TransactionType IN ('GR','SR') AND @DocSum > 0
						BEGIN			
							--EXEC [PostInventoryGRNToGL] @StockTransactionHeaderID; --Commented by Isuru 2024-10-18 
							EXEC [PostInventoryGRNToGL_New] @StockTransactionHeaderID; -- Added by Isuru 2024-10-18 for use SP to connect GL 
						END

						IF(@TransactionType = 'BI')
						BEGIN
							EXEC [dbo].[PostInventoryBIoGL]	@StockTransactionHeaderID ,'IV'
						END

						
						--added by Isuru 2026-09-18 post the Franchise Return to GL as an AR credit note ('CN' -> DocId 4:
						--AR credited, revenue and tax debited). Mirrors the 'BI' posting above.
						IF(@TransactionType = 'BR')
						BEGIN
							EXEC [dbo].[PostInventoryBRoGL]	@StockTransactionHeaderID ,'CN'
						END
						--end added by Isuru 2026-09-18

					-----------added-------------------------------
					END 
					--ELSE IF @GLPostType='FCGL' 
					--BEGIN
					--	EXEC InsertDoubleEntree  @StockTransactionHeaderID, @LocationID
					--END 
				END 
				END	
				 END

		--Added by Isuru 2024-09-10
		IF(@IsMailNotification=1 and @SkipApproval=0)
		BEGIN
			DECLARE @Email VARCHAR(MAX),@EmailBody VARCHAR(MAX), @CompanyName VARCHAR(200), @LocationName VARCHAR(200), @RequestedUser VARCHAR(200),@TransactionName VARCHAR(MAX)

			DECLARE @mailLocation INT 
			SET @mailLocation = CASE WHEN @TransactionType = 'TO' THEN @TransferLocationID ELSE @LocationID END --Added by Nivesh 2024-11-18 when Transaction is 'Transfer out' then getting location as transferlocation otherwise locaiton

			--sending Tranasctionwise emails 2024-09-27
			EXEC [dbo].[SendTransactionWiseEmailS] @TransactionType,@headerid,@mailLocation,@PROPERTYID,'C'
			--END

			SELECT @TransactionName = Name
			FROM TransactionTypes
			WHERE CODE = @TransactionType

			SELECT @headerid headerid,@TransactionType TransactionType

			SELEct @RequestedUser=CU.UserName, @LocationName=LO.Name,@CompanyName=CO.Name
			FROM GRNApprovalLog GR
			INNER JOIN Locations LO ON LO.ID = GR.LocationId
			INNER JOIN Companies CO ON CO.CompanyID = GR.CompanyId
			INNER JOIN CentralUsers CU ON CU.Id = GR.CreatedUserId
			WHERE GR.ID = @headerid AND TransactionType = @TransactionType


			SELECT @RequestedUser RequestedUser,@LocationName LocationName,@CompanyName CompanyName

			SELECT TOP(1)@Email =  US.Email
			FROM GRNApprovalLog AS GR
			INNER JOIN TransactionTypes TR ON GR.TransactionType = TR.Code
			 INNER JOIN dbo.UserWiseApproveLevels AS UAL ON TR.Id = UAL.TransactionTypeID AND GR.LocationID = UAL.LocationId
			           AND GR.CompanyId = UAL.PropertyId AND GR.ApprovalLevelID = UAL.ApproveLevelID
			    INNER JOIN CentralUsers AS US ON US.Id = GR.UserProfileId
			WHERE GR.TransactionType = @TransactionType AND GR.SendMail = 0  
			AND GR.ID =@headerid
			ORDER BY GR.SeqID ASC;


			SELECT DISTINCT US.Email,GR.UserProfileId
			into #TempEmail
			FROM GRNApprovalLog AS GR
			INNER JOIN TransactionTypes TR ON GR.TransactionType = TR.Code
			 INNER JOIN dbo.UserWiseApproveLevels AS UAL ON TR.Id = UAL.TransactionTypeID AND GR.LocationID = UAL.LocationId
			           AND GR.CompanyId = UAL.PropertyId AND GR.ApprovalLevelID = UAL.ApproveLevelID
			    INNER JOIN CentralUsers AS US ON US.Id = GR.UserProfileId
			WHERE GR.TransactionType = @TransactionType AND GR.SendMail = 0  
			AND GR.ApprovalDocNo= @DocumentNo AND GR.SeqID=1
		


			SET @EmailBody = '<html><body><p>You have to respond a pending approval</p>
					  <table border = 1>
					  <thead>
						  <th  style="width: 20%" >Approval type</th>
						  <th  style="width: 20%" >Document Number</th>
						  <th  style="width: 20%" >Company Name</th>
						  <th  style="width: 20%" >Location Name</th>
						  <th  style="width: 20%" >Requested User</th>
					  </thead>
					  <tbody >
						<tr>
						 <td  style="width: 20%" >'+@TransactionName+'</td>
						 <td  style="width: 20%" >'+@DocumentNo+'</td>
						 <td  style="width: 20%" >'+@CompanyName+'</td>
						 <td  style="width: 20%" >'+@LocationName+'</td>
						 <td  style="width: 20%" >'+@RequestedUser+'</td>
                        </tr>
					  </tbody>
					  </table></html></body>'

			SELECT @Email Email,@DocumentNo DocumentNo,@CompanyName CompanyName,@LocationName LocationName,@RequestedUser RequestedUser

			IF @Email IS NOT NULL OR @Email  <> ''
			BEGIN
			DECLARE @NewEmail VARCHAR(MAX),@NewApprovalUserID INT,@MailSubject VARCHAR(MAX)
				WHILE EXISTS(SELECT 1  FROM #TempEmail)
				BEGIN

					SELECT TOP(1) @NewEmail= EMAIL,@NewApprovalUserID =UserProfileId  FROM #TempEmail

					SELECT @MailSubject = CONCAT(@TransactionName, ' Approval') 

					SELECT @NewEmail NewEmail,@NewApprovalUserID NewApprovalUserID,@EmailBody EmailBody,@MailSubject MailSubject
				
					EXEC [dbo].[SendReuestMail] @NewEmail, @MailSubject, @EmailBody, 2

					;WITH CTE AS (
					SELECT TOP 1 GR.SeqID
					FROM GRNApprovalLog AS GR
					INNER JOIN TransactionTypes TR ON GR.TransactionType = TR.Code
					INNER JOIN dbo.UserWiseApproveLevels AS UAL ON TR.Id = UAL.TransactionTypeID AND GR.LocationID = UAL.LocationId
					AND GR.CompanyId = UAL.PropertyId AND GR.ApprovalLevelID = UAL.ApproveLevelID
					AND GR.ApprovalDocNo = @DocumentNo
					 INNER JOIN CentralUsers AS US ON US.Id = GR.UserProfileId
					WHERE GR.TransactionType = @TransactionType
						AND GR.Status = 'P'
						AND GR.SeqID=1
						AND GR.UserProfileId=@NewApprovalUserID
					ORDER BY GR.SeqID ASC
					)
					UPDATE AL
					SET AL.SendMail = 1
					FROM GRNApprovalLog AS AL
					INNER JOIN CTE ON AL.SeqID = CTE.SeqID
					WHERE AL.ApprovalDocNo =@DocumentNo;
				
					DELETE TOP(1) FROM #TempEmail
				END
				DROP TABLE #TempEmail
			END
	 



		END

		 IF(@IsBudgetGRN = 1 AND @ReferenceID = 0 AND @TransactionType = 'GR')
		BEGIN

		SELECT @GRNTotal = [dbo].[FN_GetGRNTotalValue] (@StockTransactionHeaderID)

			IF EXISTS( SELECT 1 FROM BudgetAllocation WHERE ID = @BudgetID AND Balance < @GRNTotal)
			BEGIN
			SELECT @BalanceBudget =CONVERT(MONEY,BALANCE) FROM BudgetAllocation WHERE ID = @BudgetID 

				SET @InvError2 =  'Budget Balance is '+CONVERT(VARCHAR(50), @BalanceBudget)+'. Please Update Budget.'
				RAISERROR ( @InvError2, 16, 1 );  
				ROLLBACK TRANSACTION
			END



		UPDATE BudgetAllocation
		SET Balance = Balance - @GRNTotal, UtilizeAmount = UtilizeAmount + @GRNTotal
		WHERE ID = @BudgetID
		END
--End

		 
		  -------Added 15/02/2022 check minus values-----
		--IF( SELECT COUNT(*)  FROM #TempAllDetails   WHERE   Quantity < 0 OR UnitPrice < 0) > 0
		-- BEGIN
		--	RAISERROR('Cannot insert minus values for Quantity Or Unit Price ',16,1)
		--	ROLLBACK TRANSACTION
		-- END

		 		
		-------Added 15/02/2022-----

		----------Added by Nivesh 2025-11-07--------------
		INSERT INTO @TempBulkDocNo (DocNo, Id)
		VALUES (@docno,@headerid)

		IF EXISTS( SELECT 1 FROM @TempBulkDocNo)
		BEGIN
			SET @TempBulkDocNoJson = (SELECT * FROM @TempBulkDocNo FOR JSON PATH)
		END
		----------------------------------------------------

		IF(@SkipBeginCommit = 0)
		BEGIN
			COMMIT TRAN; -- Transaction Success!
		END 
		 
		--COMMIT TRAN; -- Transaction Success! Commented by isuru 2024-09-10 for preventing skip roll back transactions
    END TRY

    BEGIN CATCH
			--added by isuru 2026-08-06
		--Reason: unique index UX_STH_SubmitToken blocked a concurrent duplicate; show the same friendly message.
		IF (ERROR_NUMBER() IN (2601, 2627) AND ERROR_MESSAGE() LIKE '%UX_STH_SubmitToken%')
		BEGIN
			IF (@SkipBeginCommit = 0 AND XACT_STATE() <> 0)
				ROLLBACK TRANSACTION;

			DECLARE @DupExistingDoc VARCHAR(50);
			SELECT TOP 1 @DupExistingDoc = DocumentNo
			FROM StockTransactionHeaders
			WHERE SubmitToken = @SubmitToken;

			DECLARE @DupMsg2 VARCHAR(200) =
				'Duplicated records found for selected transaction. Already saved in ' + ISNULL(@DupExistingDoc, '');
			;THROW 50100, @DupMsg2, 1; --added by isuru 2026-08-06  dedicated code 50100 = duplicate submit token
		END
		--end added by isuru 2026-08-06

 
	IF(@SkipBeginCommit = 0 AND @@TRANCOUNT > 0) --modified by isuru 2026-10-02
		BEGIN
			ROLLBACK TRANSACTION
		END 
	--ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);


	SELECT
    @ErrorMessage = ERROR_MESSAGE(),
    @ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE();
	-- RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState); commented by Tharuka 2026-07-28

	 --SELECT
  --  ERROR_NUMBER() AS ErrorNumber,
  --  ERROR_STATE() AS ErrorState,
  --  ERROR_SEVERITY() AS ErrorSeverity,
  --  ERROR_PROCEDURE() AS ErrorProcedure,
  --  ERROR_LINE() AS ErrorLine,
  --  ERROR_MESSAGE() AS ErrorMessage;

	IF XACT_STATE() <> -1 --modified by isuru 2026-10-02
	INSERT INTO [dbo].[InsertStocktransaction_Log](HeaderID,DocumentNo,ErrorProcedure, Response, SysDate)
	VALUES(@StockTransactionHeaderID,@DocumentNo, @ErrorProcedure,@ErrorMessage,GETDATE());

	THROW; -- added by Tharuka 2026-07-28

    END CATCH;

END;

GO

