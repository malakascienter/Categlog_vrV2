-- =============================================
-- Author:		Ravindu
-- Create date: 2025-12-12
-- Description:	Create Grn with multiple PO
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertStockTransactionsMultiple] 
(
    @XMLDetails XML,
    @docno VARCHAR(MAX) OUTPUT,
    @status INT OUTPUT,
    @message VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT,
	@SkipApproval BIT = 0,
	@SkipBeginCommit BIT =0,
	@TempBulkDocNoJson NVARCHAR(MAX) = '' OUTPUT,
	@IsApprovalEnable BIT =0 OUTPUT
)
	
AS
DECLARE @statusIN [INT];
SET @statusIN = 1;
SET @message = '';

SET NOCOUNT ON;
DECLARE @trancount INT;
SET @trancount = @@trancount;

--Added by Isuru 2023-9-20
DECLARE @tempStockTranId INT

insert into tempStockTran (XmlDATA)
select convert(varchar(max),  @XMLDetails) 

select top(1)@tempStockTranId= ID 
from tempStockTran
order by ID desc

BEGIN
    BEGIN TRY
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
		[ReferanceNo] [int],
		[SelectedCUSDECID] [int]
		)

		CREATE TABLE #TempStockTransactionHeader(
		[DocumentNo] [nvarchar](20) ,
		[TransactionType] [nvarchar](2) ,
		[TransactionDate] [date] ,
		[PropertyID] [int] ,
		[LocationID] [int] ,
		[ReferenceNo] [nvarchar](200) ,
		[SupplierID] [int] ,
		[Remarks] [nvarchar](20) ,
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
		[IsAutoTrasferGRN] BIT DEFAULT 0 
		,[InvoiceLocationID] INT DEFAULT 0
		,[IsInvoiceBasedTransaction] BIT DEFAULT 0
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
		[SellingPrice] DECIMAL(18,8),
		[PoHeaederID] [int]
		)

		-- Use to common sp without data
		CREATE TABLE #TempStockItemWiseEXPDateInsSubmit(
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
		[SellingPrice] DECIMAL(18,8),
		[PoHeaederID] [int]
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

        DECLARE @addtionalCostPre DECIMAL(18,6)
        DECLARE @addtionalCostTotal DECIMAL(18,6) =0,
				@addtionalCostAddToCostTrue DECIMAL(18,6) =0, --ADDED BY ISURU
				@addtionalCostAddToCostFalse DECIMAL(18,6)=0, --ADDED BY ISURU
                @txnDate DATETIME,
				@txnDateFromFront DATETIME,
				@SubstractNetValue DECIMAL(18,2),
				@IsSubstractNetTotal BIT = 0;

        SET @addtionalCostPre = 0;
        SET @addtionalCostTotal = 0;

        DECLARE @TransactionType CHAR(2),
                @DocumentNo VARCHAR(MAX),
                @StockTransactionHeaderID BIGINT,
                @PropertyID INT,
                @unitID INT,
                @LocationID INT,
                @Quantity DECIMAL(18,6),
                @AveragePrice DECIMAL(18,6),
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
			    @TransferNoteIsApproval BIT =0 ,
			    @RequestTransactionID INT,
				@StockTransactionID INT,
				@RequestedQty DECIMAL(18,6),
				@RecievedQty DECIMAL(18,6),
				@CreatedDate DATETIME;
 
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
			SellingPrice MONEY 
         )
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

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
				[SellingPrice], 	
				[ReferanceNo],
				[SelectedCUSDECID]
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
				[UnitPrice],
				[ReferanceNo]
				,0
			FROM
            OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2)
            WITH (
			    StockTransactionHeaderID INT,
				StockItemID BIGINT,
				Quantity DECIMAL(18,6),
				UnitPrice DECIMAL(18,6),
				TxnUnitID INT,
				MasterUnitID INT,
				MasterUnitConversion DECIMAL(18,6),
				ReportUnitID INT,
				ReportUnitConversion DECIMAL(18,6),
				DiscountValue DECIMAL(18,6),
				DiscountPercentage DECIMAL(18,6),
				TimeStamp NVARCHAR(256),
				StockMasterQuantity DECIMAL(18,6),
				StockMasterAveragePrice DECIMAL(18,6),
				NewQuantity DECIMAL(18,6),
				NewAveragePrice DECIMAL(18,6),
				Remarks NVARCHAR(MAX),
				UserProfileId INT,
				CostTransactionAccountID INT,
				PurchaseTransactionAccountID INT,
				TxnType NVARCHAR(1),
				BalanceQuantity DECIMAL(18,6),
				ReturnQuantity DECIMAL(18,6),
				ItemUnitPriceInSuppCurrency DECIMAL(18,6),
				IPAddress NVARCHAR(MAX),
				CreatedUserID INT,
				LastModUserID INT,
				CreatedDate DATETIME,
				LastModDate DATETIME,
				TBPHeaderId INT,
				Isserialadded BIT,
				SkipGL BIT,
				BalVal DECIMAL(38,8),
				AccName NVARCHAR(250),
				RequestedGenericItemId INT,
				PhysicalQuantity INT,
				IssuedQuantity DECIMAL(18,6),
				SellingPrice DECIMAL(18,6),
				ReferanceNo INT
			);

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
				[IsAutoTrasferGRN] 
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
				ISNULL([IsAutoTrasferGRN],0) AS IsAutoTrasferGRN
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
				[Remarks] [nvarchar](20) ,
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
				[IsAutoTrasferGRN] BIT 
            );
			
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
			[SellingPrice],
			[PoHeaederID]
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
			[SellingPrice],
			[PoHeaederID]
			FROM
			OPENXML(@iDocID, '/StockTransactionHeader/ItemWiseExpireDates/ItemWiseExpireDates', 2)
			WITH
			(
				PropertyID int,
				LocationID int,
				TransactionID nvarchar(max),
				TransactionType nvarchar(max),
				StockItemID bigint,
				Quantity decimal(18,8),
				BalanceQuantity decimal(18,8),
				EXPDate datetime,
				LogDate datetime,
				BatchNo varchar(200),
				TxnUnitID int,
				StockMasterQty decimal(18,8),
				TransactionDate date,
				MasterUnitID int,
				PhysicalQty decimal(18,8),
				TxnType nvarchar(1),
				SellingPrice decimal(18,8),
				PoHeaederID int
			);

		SELECT * FROM #TempStockItemWiseEXPDateIns;	
			
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

		CREATE TABLE #GroupedItems
		(
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
			[SellingPrice] [decimal](18, 6)
		)

		INSERT INTO #GroupedItems
		(
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
			[SellingPrice]
		)
		SELECT DISTINCT
		    StockTransactionHeaderID ,
		    StockItemID ,
		    SUM(Quantity) AS Quantity  ,
			UnitPrice,
			TxnUnitID  ,
			MasterUnitID ,
			MasterUnitConversion  ,
			ReportUnitID  ,
			ReportUnitConversion ,
			SUM(DiscountValue) DiscountValue  ,
			DiscountPercentage ,
			TimeStamp ,
			StockMasterQuantity  ,
			StockMasterAveragePrice  ,
			 SUM(NewQuantity) AS  NewQuantity ,
			NewAveragePrice  ,
		    '' Remarks  ,
			UserProfileId ,
			CostTransactionAccountID ,
			PurchaseTransactionAccountID  ,
			TxnType ,
			SUM(BalanceQuantity) BalanceQuantity  ,
			ReturnQuantity  ,
			ItemUnitPriceInSuppCurrency,
			IPAddress,
			CreatedUserID,
			LastModUserID  ,
			GETDATE() CreatedDate  ,
			GETDATE() LastModDate  ,
			TBPHeaderId ,
			Isserialadded,
			SkipGL,
			BalVal ,
			AccName ,
			RequestedGenericItemId ,
			PhysicalQuantity ,
			IssuedQuantity,
			0 SellingPrice
		FROM #TempAllDetails
        GROUP BY 
			StockTransactionHeaderID ,
		    StockItemID ,
			UnitPrice,
			TxnUnitID  ,
			MasterUnitID ,
			MasterUnitConversion  ,
			ReportUnitID  ,
			ReportUnitConversion ,
			DiscountPercentage,
			TimeStamp ,
			StockMasterQuantity  ,
			StockMasterAveragePrice  ,
			NewAveragePrice  ,
			UserProfileId ,
			CostTransactionAccountID ,
			PurchaseTransactionAccountID  ,
			TxnType ,
			ReturnQuantity  ,
			ItemUnitPriceInSuppCurrency,
			IPAddress,
			CreatedUserID,
			LastModUserID  ,
			TBPHeaderId ,
			Isserialadded,
			SkipGL,
			BalVal ,
			AccName ,
			RequestedGenericItemId ,
			PhysicalQuantity ,
			IssuedQuantity	

		-- New item details XML
		DECLARE @GroupedItemsXML XML;
		SET @GroupedItemsXML =
        (
           SELECT
				StockTransactionHeaderID AS [StockTransactionHeaderID] ,
				StockItemID  AS [StockItemID],
				Quantity  AS [Quantity],
				UnitPrice AS [UnitPrice],
				TxnUnitID  AS [TxnUnitID],
				MasterUnitID AS [MasterUnitID],
				MasterUnitConversion AS [MasterUnitConversion] ,
				ReportUnitID  AS [ReportUnitID],
				ReportUnitConversion AS [ReportUnitConversion],
				DiscountValue AS [DiscountValue] ,
				DiscountPercentage AS [DiscountPercentage],
				TimeStamp AS [TimeStamp],
				StockMasterQuantity AS [StockMasterQuantity],
				StockMasterAveragePrice AS [StockMasterAveragePrice],
				NewQuantity AS [NewQuantity],
				NewAveragePrice AS [NewAveragePrice],
				Remarks AS [Remarks],
				UserProfileId AS [UserProfileId],
				CostTransactionAccountID AS [CostTransactionAccountID],
				PurchaseTransactionAccountID AS [PurchaseTransactionAccountID],
				TxnType AS [TxnType],
				BalanceQuantity AS [BalanceQuantity] ,
				ReturnQuantity  AS [ReturnQuantity],
				ItemUnitPriceInSuppCurrency AS [ItemUnitPriceInSuppCurrency],
				IPAddress AS [IPAddress],
				CreatedUserID AS [CreatedUserID],
				LastModUserID AS [LastModUserID],
				CreatedDate AS [CreatedDate],
				LastModDate AS [LastModDate],
				TBPHeaderId AS [TBPHeaderId],
				Isserialadded AS [Isserialadded],
				SkipGL AS [SkipGL],
				BalVal AS [BalVal],
				AccName AS [AccName],
				RequestedGenericItemId AS [RequestedGenericItemId],
				PhysicalQuantity AS [PhysicalQuantity],
				IssuedQuantity AS [IssuedQuantity],
				SellingPrice AS [SellingPrice]
           FROM #GroupedItems
           FOR XML PATH('StockTransactionDetail'), ROOT('StockDetailList')
        );

		-- New Header XML
		DECLARE @NewHeaderXML XML;
		SET @NewHeaderXML = 
		(
		  SELECT
				DocumentNo As [DocumentNo],
				TransactionType AS [TransactionType] ,
				TransactionDate AS [TransactionDate],
			    PropertyID AS [PropertyID],
				LocationID AS [LocationID],
				ReferenceNo AS [ReferenceNo] ,
				SupplierID AS [SupplierID],
				Remarks AS [Remarks] ,
				ReferenceID AS [ReferenceID] ,
				DepartmentID AS [DepartmentID] ,
				UserProfileID AS [UserProfileID],
				TransferLocationID AS [TransferLocationID] ,
				TimeStamp AS [TimeStamp]  ,
				TransactionID AS [TransactionID] ,
				Mode AS [Mode] ,
				SuppCurrencyID AS [SuppCurrencyID] ,
				ExchangeRate AS [ExchangeRate] ,
				IPAddress AS [IPAddress] ,
				CreatedUserID AS [CreatedUserID] ,
				LastModUserID AS [LastModUserID] ,
				CreatedDate AS [CreatedDate] ,
				LastModDate AS [LastModDate] ,
				IsPrint AS [IsPrint]  ,
				IsApproved AS [IsApproved] ,
				IsTrasferIn AS [IsTrasferIn] ,
				InvoiceDate AS [InvoiceDate],
				GLDATE AS [GLDATE] ,
				IsDirectIssue AS [IsDirectIssue] ,
				GRNTypeID AS [GRNTypeID] ,
				BudgetID AS [BudgetID] ,
				PaidAmount AS [PaidAmount] ,
				SendMail AS [SendMail]  ,
				IsProdGenerate AS [IsProdGenerate] ,	
				IsProductionPlan AS [IsProductionPlan],
				FileName AS [FileName],
				PaxCount AS [PaxCount],
				SubstractNetValue AS [SubstractNetValue],
				IsAutoTrasferGRN AS [IsAutoTrasferGRN]
				FROM #TempStockTransactionHeader
				FOR XML PATH('StockTransactionHeader'), TYPE
		)

		-- TempStockTransactionwiseCharges as XML
		DECLARE @AdditionalChargesXML XML;
		SET @AdditionalChargesXML =
		(
			SELECT
				AdditionalChargeID AS [Id],
				ChargeAmount       AS [Amount],
				AddedToItemCost    AS [IsAddToItemCost]
			FROM #TempStockTransactionwiseCharges
			FOR XML PATH('AdditionalChargesDetails'),
				 ROOT('AdditionalChargesList'),
				 TYPE
		);

		-- TempStockItemWiseEXPDateIns as XML
		DECLARE @ItemWiseExpireDatesXML XML;
		SET @ItemWiseExpireDatesXML = (
			SELECT
				PropertyID,
				LocationID,
				TransactionID,
				TransactionType,
				StockItemID,
				Quantity,
				BalanceQuantity,
				EXPDate,
				LogDate,
				BatchNo,
				TxnUnitID,
				StockMasterQty,
				TransactionDate,
				MasterUnitID,
				PhysicalQty,
				TxnType,
				SellingPrice
			FROM #TempStockItemWiseEXPDateInsSubmit
			FOR XML PATH('ItemWiseExpireDatesDetail'), ROOT('ItemWiseExpireDatesList')
		);

		-- TempStockItemWiseTemperature as XML
		DECLARE @ItemWiseTemperatureXML XML;
		SET @ItemWiseTemperatureXML = (
			SELECT
				PropertyID,
				LocationID,
				TransactonID,
				TransactionType,
				StockItemID,
				Quantity,
				Temperature,
				LogDate,
				TypeId
			FROM #TempStockItemWiseTemperature
			FOR XML PATH('ItemWiseTemperatureDetail'), ROOT('ItemWiseTemperatureList')
		);

		-- New Details XML
	    DECLARE @NewXMLDetails XML;
		SET @NewXMLDetails =
		(
			SELECT
				@NewHeaderXML.query('/StockTransactionHeader/*'),

				@GroupedItemsXML.query('/StockDetailList/StockTransactionDetail') AS [StockDetailList],

				@AdditionalChargesXML.query('/AdditionalChargesList/AdditionalChargesDetails') AS [AdditionalChargesList],

				@ItemWiseExpireDatesXML.query('/ItemWiseExpireDatesList/ItemWiseExpireDatesDetail') AS [ItemWiseExpireDatesList],

				@ItemWiseTemperatureXML.query('/ItemWiseTemperatureList/ItemWiseTemperatureDetail') AS [ItemWiseTemperatureList]

			FOR XML PATH('StockTransactionHeader'), TYPE
		);
	
		SELECT @NewXMLDetails NewXMLDetails;

		EXEC [dbo].[SP_InsertStockTransactions] 
				@XMLDetails          = @NewXMLDetails,
				@docno               = @docno OUTPUT,
				@status              = @status OUTPUT,
				@message             = @message OUTPUT,
				@headerid            = @headerid OUTPUT,
				@SkipApproval        = 0,
				@SkipBeginCommit     = 0,
				@TempBulkDocNoJson   = @TempBulkDocNoJson OUTPUT,
				@IsApprovalEnable	=  @IsApprovalEnable OUTPUT; 

		SELECT  @headerid AS HeaderID, @docno AS DocumentNo

		SELECT TOP 1
		    @PropertyID       = PropertyID,
			@LocationID       = LocationID,
			@TransactionType  = TransactionType,
			@CreatedUserID    = CreatedUserID 
		FROM #TempStockTransactionHeader

		SET @StockTransactionID = @headerid;
        SET @CreatedDate = GETDATE();

		IF (@TransactionType = 'GR')
		BEGIN
			INSERT INTO RequestWiseTransactions(
			PropertyID, 
			LocationID, 
			TransactionType, 
			RequestTransactionID, 
			StockItemID, 
			StockTransactionID, 
			RequestedQty, 
			RecievedQty, 
			CreatedUserID, 
			CreatedDate,
			Remark
			)
			SELECT DISTINCT @PropertyID,@LocationID,@TransactionType, 
			TP.ReferanceNo RequestTransactionID,TP.StockItemID,
			@StockTransactionID,
			(pd.ApprovedQuantity - ISNULL(pd.ReceivedQuantity,0) ) RequestedQty,
			tp.Quantity,@CreatedUserID,@CreatedDate,TP.Remarks
			FROM #TempAllDetails TP
			INNER JOIN PoDetails PD ON PD.PoHeaderID = TP.ReferanceNo AND TP.StockItemID = PD.StockItemID

			-- Inserting Expire date
			IF EXISTS(SELECT 1 	FROM #TempStockItemWiseEXPDateIns)

			BEGIN 
			    INSERT INTO StockItemWiseEXPDateIns(
				PropertyID,
				LocationID,
				TransactionID,
				TransactionType,
				StockItemID,
				Quantity,
				BalanceQuantity,
				EXPDate,
				LogDate,
				BatchNo,
				TxnUnitID,
				StockMasterQty,
				TransactionDate,
				MasterUnitID,
				PhysicalQty,
				TxnType,
				SellingPrice,
				ReferenceNo
				)
				SELECT
				@PropertyID,
				@LocationID,
				@StockTransactionID,
				@TransactionType,
				StockItemID,
				Quantity,         
				Quantity,   
				EXPDate,            
				GETDATE(),           
				BatchNo,
				TxnUnitID,
				StockMasterQty,
				TransactionDate,
				MasterUnitID,
				PhysicalQty,
				TxnType,
				SellingPrice,
				PoHeaederID   
				FROM #TempStockItemWiseEXPDateIns;
		
			END
			   
			-- END

			SELECT ReferanceNo,StockItemID
			INTO #TempPODetails
			FROM #TempAllDetails

			DECLARE @PoHeaderID BIGINT, @StockItemID BIGINT,@PONO VARCHAR(500)
			,@InvError VARCHAR(MAX)

			select '#TempPODetails',*
			from #TempPODetails


			WHILE EXISTS (SELECT 1 FROM #TempPODetails)
			BEGIN
			
				SELECT TOP (1) @PoHeaderID= ReferanceNo,@StockItemID = StockItemID
				FROM #TempPODetails
				BEGIN

					UPDATE PD
					SET PD.ReceivedQuantity = PD.ReceivedQuantity + TP.Quantity
					FROM #TempAllDetails TP
					INNER JOIN PoDetails PD ON PD.PoHeaderID = TP.ReferanceNo AND TP.StockItemID = PD.StockItemID
					WHERE PD.PoHeaderID = @PoHeaderID 
					AND TP.StockItemID = @StockItemID

					IF(SELECT COUNT(*)
					FROM PoDetails
					WHERE PoHeaderID = @PoHeaderID 
					AND ApprovedQuantity > ReceivedQuantity) = 0 and @TransactionType='GR'
					
					BEGIN
						IF EXISTS (SELECT 1 FROM PoHeaders WHERE ID = @PoHeaderID AND DocumentStatus = 'C')
						BEGIN
							SELECT @PONO  = PoNo
							FROM PoHeaders
							WHERE ID = @PoHeaderID

							SET @InvError =  @PONO + ' - Document Already Completed'
							RAISERROR ( @InvError, 16, 1 );  
							ROLLBACK TRANSACTION
						END
						ELSE
						BEGIN
							UPDATE PoHeaders
							SET DocumentStatus = 'C'
							WHERE Id = @PoHeaderID;
						END
				

				END

				END;

				DELETE TOP (1) FROM #TempPODetails
			END

		END

	    IF (@TransactionType = 'TO')
			BEGIN
				INSERT INTO RequestWiseTransactions(
				PropertyID, 
				LocationID, 
				TransactionType, 
				RequestTransactionID, 
				StockItemID, 
				StockTransactionID, 
				RequestedQty, 
				RecievedQty, 
				CreatedUserID, 
				CreatedDate,
				Remark
				)
				SELECT DISTINCT @PropertyID,@LocationID,@TransactionType, 
				TP.ReferanceNo RequestTransactionID,TP.StockItemID,
				@StockTransactionID,
				(RD.ApprovedQuantity - ISNULL(RD.IssuedQuantity,0) ) RequestedQty,
				TP.Quantity,@CreatedUserID,@CreatedDate,TP.Remarks
				FROM #TempAllDetails TP
				INNER JOIN RequestDetails AS RD ON RD.RequestHeaderID = TP.ReferanceNo AND RD.StockItemID = TP.StockItemID


				SELECT ReferanceNo,StockItemID
				INTO #TempTODetails
				FROM #TempAllDetails

				DECLARE @ToHeaderID BIGINT, @TOStockItemID BIGINT,@TONO VARCHAR(500),@TOInvError VARCHAR(MAX)

				SELECT '#TempTODetails',*
				FROM #TempTODetails

				WHILE EXISTS (SELECT 1 FROM #TempTODetails)
				BEGIN
				     SELECT TOP (1) @ToHeaderID = ReferanceNo,@TOStockItemID = StockItemID
		             FROM #TempTODetails
					 BEGIN
							UPDATE RD
							SET RD.IssuedQuantity = RD.IssuedQuantity + TP.Quantity
							FROM #TempAllDetails TP
							INNER JOIN RequestDetails AS RD ON RD.RequestHeaderID = TP.ReferanceNo AND TP.StockItemID = RD.StockItemID
							WHERE RD.RequestHeaderID = @ToHeaderID 
							AND TP.StockItemID = @TOStockItemID


							IF(SELECT COUNT(*)
							FROM RequestDetails
							WHERE RequestHeaderID = @ToHeaderID 
							AND ApprovedQuantity > IssuedQuantity) = 0 AND @TransactionType='TO'
							BEGIN
							     IF EXISTS (SELECT 1 FROM RequestHeaders WHERE ID = @ToHeaderID AND DocumentStatus = 'C')
									 BEGIN
										  SELECT @TONO = DocumentNo
										  FROM RequestHeaders
										  WHERE Id = @ToHeaderID

										  SET @TOInvError =  @TONO + ' - Document Already Completed'
										  RAISERROR ( @TOInvError, 16, 1 );  
										  ROLLBACK TRANSACTION
									 END
								 ELSE
								    BEGIN
									     UPDATE RequestHeaders
					                     SET DocumentStatus = 'C'
					                     WHERE Id = @ToHeaderID;
									END 			
							END
					 END
					 DELETE TOP (1) FROM #TempTODetails
				END
			END

		IF(@SkipBeginCommit = 0)
		BEGIN
			COMMIT TRAN; -- Transaction Success!
		END 

    END TRY

	BEGIN CATCH
		IF(@SkipBeginCommit = 0)
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
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	END CATCH
END

GO

