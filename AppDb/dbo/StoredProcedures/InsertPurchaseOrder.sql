
CREATE procedure [dbo].[InsertPurchaseOrder]( @XMLDetails xml)
as 

declare @iDocID int

 	SELECT @XMLDetails xx INTO #XXXXXXXXXX
EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

declare @PropertyID int ,@LocationID int , @DocumentNo varchar(max), @TransactionType char(2), @PoHeaderID bigint, @RequestHeaderID bigint,@userId int

set @TransactionType='PO'

select @PropertyID  =PropertyID  ,@LocationID =LocationID , @RequestHeaderID= RequestHeaderID,@userId = UserProfileID
FROM     OPENXML (@iDocID,'/PurchaseOrder/purchaseOrderHeader',2)
WITH    (PropertyID int ,LocationID int, RequestHeaderID bigint ,UserProfileID int)

set @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,@TransactionType)

IF @DocumentNo IS NULL
BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@TransactionType,1,6)
	set @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID,@LocationID,@TransactionType)
END


update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@TransactionType



insert into PoHeaders
SELECT  PropertyID, LocationID, @DocumentNo PoNo, SupplierID, DocumentDate, Remarks, DocumentStatus, 
UserProfileID, IsDirectPo, IsApproved, DeliveryDate, DeliveryAddressID, PaymentTermsDetailID, UserProfileID , 
 getdate(),CurrencyId,POTypeId
FROM     OPENXML (@iDocID,'/PoHeader',2)
WITH    inv_PoHeader

set @PoHeaderID =SCOPE_IDENTITY()

insert into PODetails (PoHeaderID,  StockItemID, UnitID, UnitPrice, RequestedQuantity, ApprovedQuantity, ReceivedQuantity, Remarks, DiscountValue, DiscountPercentage)
SELECT					  @PoHeaderID,  StockItemID, UnitID, UnitPrice, sum(RequestedQuantity) RequestedQuantity, sum(RequestedQuantity), 0 ReceivedQuantity, Remarks, sum(DiscountValue)DiscountValue, sum(DiscountPercentage)
FROM     OPENXML (@iDocID,'/PoHeader/DetailList/PoDetail',2)
WITH    PODetail
group by PoHeaderID,  StockItemID, UnitID, UnitPrice, Remarks

--------------------------------------------------------------------------------------------------------------------------------------------------------------

insert into PoWisePRs(PoHeaderID,RequestHeaderID,StockItemID,CreatedUserID,LastModUserID,CreatedDate,LastModDate)

SELECT  @PoHeaderID,@RequestHeaderID,StockItemID,@userId,@userId,getdate() logDate1,getdate() logDate2
FROM     OPENXML (@iDocID,'/PoHeader/DetailList/PoDetail',2)
WITH     (PoHeaderID int ,RequestHeaderID int,StockItemID int,UserProfileID1 int,UserProfileID2 int,logDate1 datetime,logDate2 datetime)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
create table #itemList (PODetailID bigint,StockItemID bigint,ItemTotal money)
declare @PODetailID bigint,@StockItemID bigint,@ItemTotal money

insert into #itemList 
select PODetailID,StockItemID,(UnitPrice*RequestedQuantity)-DiscountValue ItemTotal  from  PODetails
where PoHeaderID=@PoHeaderID

create table #TaxTable (TaxTypeId int ,	TaxValue money)

while (select COUNT(*) from #itemList)>0
begin



select top (1) @PODetailID =PODetailID,@StockItemID =StockItemID ,@ItemTotal=ItemTotal
from #itemList
order by PODetailID

insert into #TaxTable
exec [SP_Select_StockItemWiseTaxAmount] @StockItemID,@ItemTotal

insert into POwiseTaxes (PODetailID, StockItemID, TaxTypeID,TaxAmount)
select @PODetailID , @StockItemID, TaxTypeID, TaxValue
from #TaxTable

delete from #TaxTable

delete from #itemList where PODetailID =@PODetailID

end 



-- Insert for Approvel log
exec SP_InsertApprovalLevelForRequest @PropertyID,@locationid ,2,@PoHeaderID

--select * from RequestHeaders
update RequestHeaders
set DocumentStatus = 'C'
where Id = @RequestHeaderID and TransactionTypeCode = 1

select @DocumentNo

GO

