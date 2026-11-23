--ALTER  procedure [dbo].[SP_InsertStockTransactions]  '<StockTransactionHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>2018-03-12T04:03:45.328Z</CreatedDate><LastModDate>2018-03-12T04:03:45.328Z</LastModDate><Id>0</Id><TransactionType>TO</TransactionType><TransactionDate>2018-03-12T04:03:45.328Z</TransactionDate><PropertyID>2</PropertyID><LocationID>2</LocationID><ReferenceNo>10</ReferenceNo><SupplierID>0</SupplierID><Remarks /><ReferenceID>36</ReferenceID><DepartmentID>0</DepartmentID><UserProfileID>2</UserProfileID><TransferLocationID>1</TransferLocationID><TransactionID>0</TransactionID><SuppCurrencyID>0</SuppCurrencyID><ExchangeRate>0</ExchangeRate><StockDetailList><StockTransactionDetail><IPAddress /><CreatedUserID>2</CreatedUserID><LastModUserID>2</LastModUserID><CreatedDate>2018-03-12T04:03:45.328Z</CreatedDate><LastModDate>2018-03-12T04:03:45.328Z</LastModDate><Id>0</Id><StockTransactionHeaderID>-1</StockTransactionHeaderID><StockItemID>5</StockItemID><Quantity>40</Quantity><UnitPrice>0</UnitPrice><TxnUnitID>2</TxnUnitID><MasterUnitID>0</MasterUnitID><MasterUnitConversion>0</MasterUnitConversion><ReportUnitID>0</ReportUnitID><ReportUnitConversion>0</ReportUnitConversion><DiscountValue>0</DiscountValue><DiscountPercentage>0</DiscountPercentage><TimeStamp>0</TimeStamp><StockMasterQuantity>0</StockMasterQuantity><StockMasterAveragePrice>0</StockMasterAveragePrice><NewQuantity>0</NewQuantity><NewAveragePrice>0</NewAveragePrice><Remarks>td</Remarks><UserProfileId>2</UserProfileId><CostTransactionAccountID>0</CostTransactionAccountID><PurchaseTransactionAccountID>0</PurchaseTransactionAccountID><TxnType>M</TxnType><BalanceQuantity>0</BalanceQuantity><ReturnQuantity>0</ReturnQuantity><ItemUnitPriceInSuppCurrency>0</ItemUnitPriceInSuppCurrency></StockTransactionDetail></StockDetailList></StockTransactionHeader>', 1,-1,''
CREATE  procedure [dbo].[SP_InsertStockTransactions_temp] 
(
	@XMLDetails XML,
	@docno VARCHAR(max) OUTPUT,
	@status INT OUTPUT, 
	@message VARCHAR(20) OUTPUT
)
AS
DECLARE @statusIN[int]
	SET @statusIN = 1;
	SET  @message = ''

INSERT INTO Inputpara  (xmldata ) VALUES (@XMLDetails)

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



BEGIN
BEGIN TRY
BEGIN TRANSACTION
------

--insert into XMLDATALOG (XMLDATA) values (convert(varchar(max),@XMLDetails))

Create table #ItemList
(StockItemID bigint, Quantity money, TxnUnitID int, UnitPrice money,TxnType char(1))

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

--SELECT    TransactionDate,TransactionType,LocationID , PropertyID, ReferenceID, Mode
--FROM     OPENXML (@iDocID,'/StockTransactionHeader',2)
--WITH    ( TransactionType varchar(2), LocationID int , PropertyID int, ReferenceID bigint, Mode char(1), TransactionDate varchar(max))


SELECT    @txnDate = TransactionDate
		, @TransactionType = TransactionType
		, @LocationID = LocationID 
		, @PropertyID = PropertyID
		, @ReferenceID=ReferenceID
		, @Mode =Mode
FROM     OPENXML (@iDocID,'StockTransactionHeader',2)
WITH    ( TransactionType varchar(2), LocationID int , PropertyID int, ReferenceID bigint, Mode char(1), TransactionDate varchar(max))


------------------------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @ExchangeRate MONEY = 0
DECLARE @SuppCurrencyID INT = 0

IF(@TransactionType = 'GR')
BEGIN

	SELECT  @SuppCurrencyID = SuppCurrencyID
	FROM     OPENXML (@iDocID,'/StockTransactionHeader',2)
	WITH    (SuppCurrencyID INT)

	SELECT  @ExchangeRate = (SELECT ExchangeRate FROM CurrencyMasters WHERE Id = @SuppCurrencyID)
	
	
END
------------------------------------------------------------------------------------------------------------------------------------------------------------

set @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,@TransactionType)

IF @DocumentNo IS NULL
BEGIN

	INSERT INTO TransactionTypeWiseNextNumbers (PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@TransactionType,1,6)

	set @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,@TransactionType)

END

update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@TransactionType
PRINT '1'

SELECT @txnDate
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
		, SuppCurrencyID
		, ExchangeRate
		,CreatedUserID
		,LastModUserID
		,CreatedDate
		, LastModDate)
(
SELECT  @txnType
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
		,CreatedUserID
		,LastModUserID
		,GETDATE()
		,GETDATE()
FROM     OPENXML (@iDocID,'/StockTransactionHeader',2)
WITH  StockTransactionHeaders
) 

PRINT 'r'
declare @StockTransactionwiseChangesID bigint

SELECT @StockTransactionHeaderID=SCOPE_IDENTITY()


	--if @TransactionType='GR'
	--begin
	--	INSERT INTO  StockItemWiseEXPDateIns
	--	(PropertyID,LocationID, TransactionID, TransactionType, StockItemID, Quantity, BalanceQuantity, EXPDate, LogDate)
	--	(SELECT  @PropertyID,@LocationID, @StockTransactionHeaderID, 'GR', StockItemID, Quantity, BalanceQuantity, EXPDate, getdate()
	--	FROM     OPENXML (@iDocID,'/StockTransactionDetails/ExpireDatesList/StockItemWiseEXPDateIns',2)
	--	WITH  INV_StockItemWiseEXPDateIn) 

	--END
    


------------------- Add Aditional Cots -----------------------
----select * from StockTransactionwiseCharges
--select * from AdditionalChargesDetails

--insert into StockTransactionwiseCharges( StockTransactionHeaderID, AdditionalChargeID, ChargeAmount, AddedToItemCost)
--SELECT    @StockTransactionHeaderID, AdditionalChargeID, ChargeAmount,
-- dbo.IsAdditionalChargeAddToItemCost(1)
--		FROM     OPENXML (@iDocID,'/StockTransactionHeaders/AdditionalChargeList/AdditionalChargesDetails',2)
--with StockTransactionwiseCharges

--print 'Addif'

select @addtionalCostTotal=SUM(ChargeAmount)  from StockTransactionwiseCharges
where StockTransactionHeaderID=@StockTransactionHeaderID and AddedToItemCost=1

 

SELECT @addtionalCostPre=(@addtionalCostTotal/sum(UnitPrice*Quantity*1.0000)) * 100.0000  
FROM     OPENXML (@iDocID,'/StockTransactionHeader/StockDetailList/StockTransactionDetail',2)
WITH  StockTransactionDetails

--print '3'
--------------------------------------------------------------

set @addtionalCostPre= isnull(@addtionalCostPre,0)

set @addtionalCostTotal= isnull(@addtionalCostTotal,0)



EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

insert into StockTransactionDetails
		(StockTransactionHeaderID
		, StockItemID
		, Quantity
		, UnitPrice
		, TxnUnitID
		, MasterUnitID
		, MasterUnitConversion
		, ReportUnitID
		, ReportUnitConversion
		, DiscountValue
		, DiscountPercentage
		, StockMasterQuantity
		, StockMasterAveragePrice
		, NewQuantity
		, NewAveragePrice
		, Remarks
		, UserProfileId
		, CostTransactionAccountID
		, PurchaseTransactionAccountID
		, TxnType
		, ItemUnitPriceInSuppCurrency
		,BalanceQuantity
		,ReturnQuantity
		,CreatedUserID
		,LastModUserID
		,CreatedDate
		,LastModDate)
(SELECT   @StockTransactionHeaderID
        , StockItemID
		, case  when @TransactionType ='AA' then  abs( Quantity - dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId)) else Quantity  end 
		, UnitPrice + (UnitPrice *  @addtionalCostPre/100.000)
		, TxnUnitID
		, ISNULL(dbo.FN_GetMasterUnitID(@PropertyID,@LocationID, stockItemId),0) MasterUnitID
		, dbo.FN_GetUnitConvertionRate(@PropertyID,TXNUnitId,dbo.FN_GetMasterUnitID(@PropertyID,@LocationID, stockItemId))
		, ISNULL(dbo.FN_GetReportingUnitID(@PropertyID,@LocationID, stockItemId),0) 
		, dbo.FN_GetUnitConvertionRate( @PropertyID,TXNUnitId,dbo.FN_GetReportingUnitID(@PropertyID,@LocationID, stockItemId))
		, DiscountValue
		, DiscountPercentage
		, dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId) StockMasterQuantity
		, dbo.FN_GetAveragePrice(@PropertyID,@LocationID, stockItemId, @TransactionType,0,txnUnitId,0)
		, dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId) + case when @TransactionType<>'AA' then case when txntype ='P' then 1 else -1 end *  Quantity  else  (  case when (case when Quantity - dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId)>0 then 'P' Else 'M' END )='M' then -1 else 1 end * Quantity) end  NewQuantity
		, dbo.FN_GetAveragePrice(@PropertyID,@LocationID, stockItemId, @TransactionType,Quantity,txnUnitId, UnitPrice + (UnitPrice *  @addtionalCostPre/100.000))
		, Remarks, UserProfileId
		, dbo.FN_GetPurchaseCostOfSalesAccountID(stockItemid, @LocationID) CostTransactionAccountID
		, dbo.FN_GetPurchaseTransactionAccountID (stockItemid, @LocationID) PurchaseTransactionAccountID
		, case when @TransactionType<>'AA' then TxnType else  case when Quantity - dbo.FN_GetStockInHand(@PropertyID,@LocationID, stockItemId)>0 then 'P' Else 'M' END  end 
		, CAST( (CASE WHEN @ExchangeRate <= 0 THEN 0 ELSE (UnitPrice / @ExchangeRate) END)as decimal(18,2))
		,BalanceQuantity
		,ReturnQuantity
		,CreatedUserID
		,LastModUserID
		,CreatedDate
		,LastModDate
FROM     OPENXML (@iDocID,'/StockTransactionHeader/StockDetailList/StockTransactionDetail',2)
WITH  StockTransactionDetails
)




insert into #ItemList
SELECT   *
FROM     OPENXML (@iDocID,'/StockTransactionHeader/StockDetailList/StockTransactionDetail',2)
WITH  #ItemList




create table #TaxTable (TaxTypeId int ,	TaxValue money)

while (select COUNT(*) from #ItemList)>0
begin 	
			select top (1) @StockItemId=StockItemId, @unitID =TxnUnitId, @Quantity= Quantity, @unitPrice=unitPrice ,@txnType = txnType from #ItemList
			order by StockItemId

			declare @TxnCode char(3)

			set @TxnCode =case when @TransactionType+@txnType='AAM' then @TransactionType+@txnType else @TransactionType end 

			set @AveragePrice= dbo.FN_GetAveragePrice(@PropertyID,@LocationID, @stockItemId,@TxnCode,@Quantity,@unitID, @unitPrice)

			DECLARE @NowQuantityInHand VARCHAR(max)

			SELECT @NowQuantityInHand = QuantityInHand FROM dbo.StockItemDetails WHERE PropertyID=@PropertyID and LocationId =@LocationID and StockItemHeaderID=@StockItemID
			
			IF(@NowQuantityInHand > @Quantity)
			BEGIN
			exec SP_UpdateStockItemBalance @PropertyID , @LocationID ,@StockItemID ,@TxnCode, @Quantity, @unitID, @AveragePrice
			
			if @TransactionType in ('SR','IR')
			begin
			   SELECT @ReferenceID 
				update StockTransactionDetails
				set ReturnQuantity = ReturnQuantity+@Quantity
				where StockTransactionHeaderID =@ReferenceID and StockItemID=@StockItemID  
	
			end 
						
			if @TransactionType in('IN','TO')
			BEGIN
				
				UPDATE RequestDetails
				set IssuedQuantity  = IssuedQuantity+@Quantity
				where RequestHeaderID =@ReferenceID and StockItemID=@StockItemID --modified id to StockItemID

				IF ( select sum( ApprovedQuantity -  IssuedQuantity ) from RequestDetails 	where RequestHeaderID =@ReferenceID and StockItemID=@StockItemID  )=0
				begin
				update RequestHeaders
				set DocumentStatus ='C'
				where Id =@ReferenceID
				END 
			END     
			END
            
			ELSE
			BEGIN
			PRINT 'cant issue'
			END
            
						
			if @TransactionType='GR'

			BEGIN           
			
			--sELECT * FROM StockTransactionDetails

				select @StockTransactionDetailID = Id,@ItemTotal=(UnitPrice * Quantity)-DiscountValue   from StockTransactionDetails
				where StockItemID = @StockItemID and StockTransactionHeaderID=@StockTransactionHeaderID

				insert into #TaxTable
				exec [SP_Select_StockItemWiseTaxAmount] @StockItemID,@ItemTotal

				insert into StockTransactionwiseTaxes(StockTransactionDetailID, StockItemID, TaxTypeID, TaxAmount)
				select @StockTransactionDetailID, @StockItemID, TaxTypeID, TaxValue from #TaxTable 

				update PoDetails
				set ReceivedQuantity  = ReceivedQuantity +@Quantity
				where PoHeaderID =@ReferenceID and StockItemID=@StockItemID 
								
				if (select count(*) from PoDetails where PoHeaderID =@ReferenceID and ApprovedQuantity > ReceivedQuantity ) = 0
				
				begin
					update PoHeaders
					set DocumentStatus ='C'
					where Id =@ReferenceID 
				end 
				
			end 

		if @Mode ='M' and @TransactionType='AA'
		begin
		
			exec SP_AjustMonthlyReconcellation  @locationId,@StockItemID,@txnDate , @StockTransactionHeaderID
					
		end 
			delete from #ItemList
			where StockItemId= @StockItemId

end 

--DECLARE @GRNno VARCHAR(max)
select @docno =  DocumentNo FROM dbo.StockTransactionHeaders WHERE Id = @StockTransactionHeaderID
--PRINT @GRNno
--select @DocumentNo  AS DocumentNo, @StockTransactionHeaderID AS StockTransactionHeaderID
--select @DocumentNo 
--+ @StockTransactionHeaderID  

SET @status = @statusIN;

------
END TRY 
BEGIN CATCH
	SET @status = -1;
	SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))	
END CATCH;
END

GO

