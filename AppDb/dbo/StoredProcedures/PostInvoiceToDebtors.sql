CREATE procedure [dbo].[PostInvoiceToDebtors](@InvoiceID int)
as
DECLARE @Object AS INT;
DECLARE @ResponseTable AS TABLE(ResponseValue VARCHAR(MAX))
 
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @RequestLength AS INT, @RequestBody VARCHAR(1000),   @description VARCHAR(255)

declare @BSPCode varchar(50),@InvoiceNo varchar(50), @TxnDate char(10), @Total int

Select @BSPCode  = c.Code,@InvoiceNo =h.InvoiceNo, @TxnDate=convert(varchar, h.InvoiceDate,102), @Total =  p.ActualAmount   
from [dbo].[InvoiceHeaders] h 
inner join [dbo].[InvoicePaymentsDetails] p on p.InvoiceHeaderID= h.ID
inner join Customers c on c.Id= h.CustomerID
where h.ID= @InvoiceID and p.PaymentTypeID= 1

--Select *
--from [dbo].[InvoiceHeaders] h 
--inner join [dbo].[InvoicePaymentsDetails] p on p.InvoiceHeaderID= h.ID
--inner join Customers c on c.Id= h.CustomerID
--where h.ID= @InvoiceID and p.PaymentTypeID= 1

if @bspCode is null
begin
	return 0
end 

set	@BSPCode ='CO00000010'

set @RequestBody='{
	"TxnDate":"'+@TxnDate+'",
	"DocID":"1",
	"ExRate":1,
	"BSPCode":"'+@BSPCode+'",
	"TaxPackID":1,
	"Narration":"Credit Invoice No: '+ @InvoiceNo +'" ,
	"MasterID":"00001",
	"MulComCode":"001",
	"CurCode":"LKR",
	"UserID":"b490b26a-2886-4671-8253-a8644c76660f",
	"CrDataList":[
		{	"SeqNo":1,
			"AccCode":"LICL25260026",
			"Narration":"Credit Invoice no: '+ @InvoiceNo +'",
			"Amount":'+convert(varchar,@Total)+'
		}
		],
		"SegmentList":[
				{
				"SegmentID":1,
				"Amount":'+convert(varchar,@Total)+'
				}
			],
		"DocAmount":'+convert(varchar,@Total)+',
		"ModuleCode":"I"
	
}'
 
 --select   @RequestBody
 
--Code Snippet
Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
Exec sp_OAMethod @Object, 'open', NULL, 'post','http://172.16.3.38:1002/api/OtherModuleReceivablePosting','false'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Accept', 'application/json'
EXEC sp_OAMethod @Object, 'send', NULL, @RequestBody
EXEC sp_OAGetErrorInfo @object, NULL, @ResponseText OUT

		SELECT @ResponseText

INSERT INTO @ResponseTable( ResponseValue ) 
EXEC sp_OAMethod @Object, 'responseText'
EXEC sp_OAGetErrorInfo @object, NULL, @description OUT


select * from @ResponseTable

GO

