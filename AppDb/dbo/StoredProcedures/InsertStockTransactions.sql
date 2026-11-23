
CREATE procedure [dbo].[InsertStockTransactions]
(
	@XMLDetails xml
)
as
--BEGIN TRY
set dateformat mdy
Declare @iDocID int

declare @addtionalCostPre money
declare @addtionalCostTotal money, @txnDate datetime


set @addtionalCostPre =0
set @addtionalCostTotal =0

declare @TransactionType char(2)
      , @DocumentNo varchar(max)
	  , @StockTransactionHeaderID bigint
	  , @PropertyID int
	  , @unitID int
	  , @LocationID int
	  , @Quantity money
	  , @AveragePrice money
	  , @StockItemID bigint
	  , @unitPrice money
	  , @ReferenceID bigint
	  , @TxnType char(1)
	  , @StockTransactionDetailID bigint
	  , @ItemTotal money
	  , @Mode char(1)

insert into XMLDATALOG (XMLDATA) values (convert(varchar(max),@XMLDetails))


Create table #ItemList
(StockItemID bigint, Quantity money, TxnUnitID int, UnitPrice money,TxnType char(1))

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

SELECT    @txnDate = TransactionDate
		, @TransactionType = TransactionType
		, @LocationID = LocationID 
		, @PropertyID = PropertyID
		, @ReferenceID=ReferenceID
		, @Mode =Mode
FROM     OPENXML (@iDocID,'/StockTransaction/stockTransactionHeader',2)
WITH    ( TransactionType varchar(2), LocationID int , PropertyID int, ReferenceID bigint, Mode char(1), TransactionDate varchar(max))


DECLARE @ExchangeRate MONEY = 0
DECLARE @SuppCurrencyID INT = 0

IF(@TransactionType = 'GR')
BEGIN

	SELECT  @SuppCurrencyID = SuppCurrencyID
	FROM     OPENXML (@iDocID,'/StockTransaction/stockTransactionHeader',2)
	WITH    (SuppCurrencyID INT)

	SELECT  @ExchangeRate = (SELECT ExchangeRate FROM CurrencyDetails WHERE CurrencyID = @SuppCurrencyID)

END
----------------------------------------------------------------------------------------------------------------------------------------------------------

set @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,@TransactionType)
print 'DOC1'
IF @DocumentNo IS NULL
BEGIN

	INSERT INTO TransactionTypeWiseNextNumbers (PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@TransactionType,1,6)

	set @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,@TransactionType)

END

--------------------
update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@TransactionType
print '2'
			  	
INSERT INTO  StockTransactionHeaders 
		( mode
		, DocumentNo
		, TransactionType
		, TransactionDate
		, LocationID
		, PropertyID
		, ReferenceNo
		, SupplierID
		, Remarks
		, ReferenceID
		, DepartmentID
		, UserProfileID
		, TransferLocationID
		, TransactionID
		, SuppCurrencyID --*
		, ExchangeRate) --*
(SELECT  mode
        , @DocumentNo
		, TransactionType
		, @txnDate
		, LocationID
		, PropertyID
		, ReferenceNo
		, SupplierID
		, Remarks
		, ReferenceID
		, DepartmentID
		, UserProfileID
		, TransferLocationID
		, dbo.FN_getTransactionID(TransactionType)
		, SuppCurrencyID
		, @ExchangeRate
		 
FROM     OPENXML (@iDocID,'/StockTransaction/stockTransactionHeader',2)
WITH  StockTransactionHeader) 






declare @StockTransactionwiseChangesID bigint

SELECT @StockTransactionHeaderID=SCOPE_IDENTITY()


	if @TransactionType='GR'
	begin
		INSERT INTO  StockItemWiseEXPDateIn 
		(PropertyID,LocationID, TransactionID, TransactionType, StockItemID, Quantity, BalanceQuantity, EXPDate, LogDate)
		(SELECT  @PropertyID,@LocationID, @StockTransactionHeaderID, 'GR', StockItemID, Quantity, BalanceQuantity, EXPDate, getdate()
		FROM     OPENXML (@iDocID,'/StockTransaction/ExpireDatesList/ExpireDates',2)
		WITH  INV_StockItemWiseEXPDateIn) 

		
		insert into [dbo].[StockTransactionwiseCharges] ([StockTransactionHeaderID],[AdditionalChargeID],[ChargeAmount])
		SELECT  @StockTransactionHeaderID,Id,Amount  
		FROM  OPENXML (@iDocID,'/StockTransaction/stockTransactionHeader',2)
		WITH (Id int,Amount money )

	end

GO

