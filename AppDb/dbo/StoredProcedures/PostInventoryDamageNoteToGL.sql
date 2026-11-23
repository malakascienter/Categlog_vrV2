

CREATE PROCEDURE [dbo].[PostInventoryDamageNoteToGL](@StockTransactionHeaderID int)
as
DECLARE @Object AS INT;
DECLARE @ResponseTable AS TABLE(ResponseValue VARCHAR(MAX))
 
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @RequestLength AS INT, @RequestBody VARCHAR(1000),   @description VARCHAR(255)

declare @DocumentNo varchar(50),@TransType varchar(50), @TxnDate char(10), @Total int, @TxnDrList varchar(max)='', @TxnCrList varchar(max)=''

select @DocumentNo =h.DocumentNo, @TxnDate=convert(varchar,h.TransactionDate,102), @TransType= TransactionType, @Total =sum(d.Quantity * d.UnitPrice)
from StockTransactionHeaders h
inner join StockTransactionDetails d 
on d.StockTransactionHeaderID=h.id
where h.id= @StockTransactionHeaderID and TransactionType='DN'
group by h.DocumentNo, h.TransactionDate, h.TransactionType

 --select  @DocumentNo

if @DocumentNo is null
begin
	return 0
end 

declare @TxnList as TABLE (AccCode varchar(12), Amount money, DrCr CHAR(1))


INSERT @TxnList (AccCode,Amount,DrCr )
select g.AccCode, sum(d.quantity* d.unitprice), 'D'
from StockTransactionHeaders h
inner join StockTransactionDetails d 
on d.StockTransactionHeaderID=h.id
inner join  GLAccountList g on g.ID = d.CostTransactionAccountID
where  TransactionType='DM' and h.ID=@StockTransactionHeaderID
group by  g.AccCode


INSERT @TxnList (AccCode,Amount,DrCr)
select g.AccCode, sum(d.quantity* d.unitprice), 'C'
from StockTransactionHeaders h
inner join StockTransactionDetails d 
on d.StockTransactionHeaderID=h.id
inner join  GLAccountList g on g.ID = d.PurchaseTransactionAccountID
where  TransactionType='DM' and h.ID=@StockTransactionHeaderID
group by  g.AccCode

declare @AccCode varchar(12), @Amount money,@DrCr char(1), @i as int =1

while exists (select top 1 AccCode from @TxnList)
begin
	select top (1) @AccCode =AccCode, @Amount = amount, @DrCr= DrCr  
	from @TxnList

	if @DrCr='C'
	begin
		set @TxnCrList+= '{
				"TxnDate":"'+@TxnDate+'",
				"BranchCode":"001",
				"Amount":'+ convert(varchar,@Amount) +',
				"AccCode":"'+ @AccCode +'",
				"CrNarration":"Cost of Damage Note :'+ @DocumentNo +'",
				"SeqNo":'+convert(varchar,@i)+'
			},'
	end 
	else
	begin
		
		set @TxnDrList+= '{
				"TxnDate":"'+@TxnDate+'",
				"BranchCode":"001",
				"Amount":'+convert(varchar, @Amount) +',
				"AccCode":"'+ @AccCode +'",
				"DrNarration":"Cost of Damage Note :'+ @DocumentNo +'",
				"SeqNo":'+convert(varchar,@i)+'
			},'

	end 

	set @i+=1
	delete from @TxnList 
	where AccCode=@AccCode and DrCr= @DrCr
end 


set @RequestBody='{
		"TxnId":"J",
		"TxnDate":"'+@TxnDate+'",
		"TotalAmount":'+ convert(varchar,@Total) +',
		"UserID":"b490b26a-2886-4671-8253-a8644c76660f",
		"PayType":"CA",
		"ModName":"I",
		"PaidRec":"",
		"TransType":"' + @TransType + '",
		"AccTypeCode":"",
		"ModRefNo":"' + @DocumentNo + '",
		"TxnCurr":"LKR",
		"ExchangeRate":1,
	
		"TxnDrList":[
		'+ @TxnDrList +
		'
		],

		"TxnCrList":[
		' + @TxnCrList	+ 
		'
		],
		
		"SegmentDataList":[
		{
			"SegmentID":1,
			"Amount":'+ convert(varchar,@Total) +'
			
		}],
		
		"TxnChqList":[
		{
			"ChqNo":"00000000",
			"BankCode":"001"
			
		}],
		
		"MulComCode":"001",
		"MainBranchCode":"001"
	
}'
 
 select   @RequestBody
 
--Code Snippet
Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
Exec sp_OAMethod @Object, 'open', NULL, 'post','http://192.168.1.20:8070/api/OtherModuleGLPosting','false'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Accept', 'application/json'

EXEC sp_OAMethod @Object, 'send', NULL, @RequestBody
EXEC sp_OAGetErrorInfo @object, NULL, @ResponseText OUT
INSERT INTO @ResponseTable( ResponseValue ) 
EXEC sp_OAMethod @Object, 'responseText'
EXEC sp_OAGetErrorInfo @object, NULL, @description OUT


select * from @ResponseTable

GO

