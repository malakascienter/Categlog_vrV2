-- [dbo].[PostInventoryGRNToGL] 1

CREATE PROCEDURE [dbo].[PostInventoryGRNToGL](@StockTransactionHeaderID INT)
as


DECLARE @Object AS INT,@TaxTotal MONEY = 0, @InvoiceNo Varchar(max)
DECLARE @ResponseTable AS TABLE(ResponseValue VARCHAR(MAX))
 
DECLARE @ResponseText AS VARCHAR(8000);
DECLARE @RequestLength AS INT, @RequestBody VARCHAR(MAX),   @description VARCHAR(255), @GRNNumber VARCHAR(12), @SupplierName VARCHAR(MAX), @AppUser UNIQUEIDENTIFIER

declare @DocumentNo varchar(50), @SupplierCode varchar(50),@TransType varchar(50), @TxnDate char(10), 
@Total money, @TxnDrList varchar(max)='', @TxnCrList varchar(max)='', @CompanyCode varchar(50), 
@MasterID varchar(50),@TransactionType varchar(10), @docID int, @OPNUmber Varchar(12)


--select * from Suppliers
--ADDED BY ISURUT 2023-02-03
DECLARE @AdditionalCharge MONEY

select @AdditionalCharge = ISNULL(SUM(ST.ChargeAmount),0)
from StockTransactionHeaders h
INNER JOIN StockTransactionwiseCharges ST ON ST.StockTransactionHeaderID = h.Id
INNER JOIN Companies co on co.CompanyID = h.PropertyID 
where  h.ID=@StockTransactionHeaderID
--END


select	@MasterID= c.MasterID, @CompanyCode =c.Code,  @DocumentNo =h.DocumentNo,@SupplierCode=s.BSPCODE, 
		@TxnDate=convert(varchar,h.TransactionDate,102), @TransType= TransactionType, @Total =sum(d.Quantity * d.UnitPrice)- SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END )+@AdditionalCharge,
		@InvoiceNo= isnull(ReferenceNo,''), @TransactionType = TransactionType, @SupplierName= s.Name
from StockTransactionHeaders h
inner join StockTransactionDetails d 
on d.StockTransactionHeaderID=h.id
inner join Suppliers s on s.id = h.supplierid
inner join Companies c on c.CompanyID = h.PropertyID
where h.id= @StockTransactionHeaderID --and TransactionType='GR'
group by h.DocumentNo, h.TransactionDate, h.TransactionType,s.BSPCODE,c.MasterID,c.Code,ReferenceNo,s.Name


SELECT  @AppUser= CU.UniqueId
FROM StockTransactionHeaders SH
INNER JOIN CentralUsers CU ON SH.CreatedUserID = CU.Id
WHERE SH.Id = @StockTransactionHeaderID

IF @TransactionType='GR' 
BEGIN

	SET @GRNNumber=@DocumentNo

	SELECT @OPNUmber = PoNo 
	FROM StockTransactionHeaders S
	INNER JOIN POHeaders P ON p.ID= S.ReferenceID
	WHERE S.ID = @StockTransactionHeaderID

	SET @OPNumber= ISNULL(@OPNumber,'')

END 
ELSE
BEGIN

	SELECT @GRNNumber= GR.DocumentNo FROM StockTransactionHeaders GR
	INNER JOIN StockTransactionHeaders SR ON GR.ID= SR.ReferenceID
	WHERE SR.ID = @StockTransactionHeaderID

	SET @OPNumber=@GRNNumber

END 

 select @GRNNumber

SET @DocID = CASE WHEN @TransactionType='GR' THEN  1 ELSE 5 END 

--set @SupplierCode ='CO00000012'


if @DocumentNo is null
begin
	return 0
end 

declare @TxnList as TABLE ([Id] [int] IDENTITY(1,1) NOT NULL,  AccCode varchar(12), Amount money, DrCr CHAR(1))


INSERT @TxnList (AccCode,Amount,DrCr )



select g.ACCCODE, sum(d.quantity* d.unitprice) - SUM( CASE WHEN D.DiscountValue=0 THEN d.Quantity * d.UnitPrice * d.DiscountPercentage /100 ELSE  D.DiscountValue END ), 'D'
from StockTransactionHeaders h
INNER JOIN	StockTransactionDetails d on d.StockTransactionHeaderID=h.id
INNER JOIN	StockItemHeaders S ON S.ID = D.StockItemID
INNER JOIN	Locations L ON L.ID = H.LocationID
INNER JOIN	Categories C ON C.ID= s.CategoryID
INNER JOIN	[dbo].[Destinity_GLIntegrationAccountMapping] G ON G.BLOCKCODE='GRN'
			AND G.Level1 = L.Code AND G.Level2 = C.Code
INNER JOIN Companies co on co.CompanyID = h.PropertyID AND G.GLCOMPCODE= CO.Code
where  h.ID=@StockTransactionHeaderID
group by  g.AccCode

--ADDED BY ISURUT 2023-02-03
UNION ALL
select g.ACCCODE, SUM(ST.ChargeAmount), 'D'
from StockTransactionHeaders h
INNER JOIN StockTransactionwiseCharges ST ON ST.StockTransactionHeaderID = h.Id
INNER JOIN	[dbo].[Destinity_GLIntegrationAccountMapping] G ON G.BLOCKCODE='ADD' AND G.Level1 = ST.AdditionalChargeID 
INNER JOIN Companies co on co.CompanyID = h.PropertyID AND G.GLCOMPCODE= CO.Code
where  h.ID=@StockTransactionHeaderID
group by  g.AccCode
PRINT '@StockTransactionHeaderID'
PRINT @StockTransactionHeaderID
delete @TxnList where Amount=0
--END

--select '555555555'
--select * from @TxnList

declare @AccCode varchar(12), @Amount money,@DrCr char(1), @i as int =1
--select * from @TxnList
set @TxnDrList=''

DECLARE @RC INT

SELECT @RC = COUNT(*) FROM @TxnList

print '@RC'
print @RC

--while exists (select top 1 AccCode from @TxnList)
while @RC >0
begin

	--select top (1) @AccCode =AccCode, @Amount = amount, @DrCr= DrCr  
	select  @AccCode =AccCode, @Amount = amount, @DrCr= DrCr
	from @TxnList
	WHERE Id = @RC

	--select @AccCode , @Amount , @DrCr  ,''

	if @TxnDrList <>''
	BEGIN
		SET @TxnDrList+=','
	END 
	SELECT @MasterID
	set @TxnDrList+= '{
 			"ModCrNoteNo":"'+ @GRNNumber +'",
			"MasterID": "'+@MasterID+'",
 			"DocId": '+ convert(varchar, @DocID) +',
 			"SeqNo":'+convert(varchar,@RC)+',
 			"DrAccCode":"'+@AccCode+'",
 			"DrNarration":"GRN :'+@DocumentNo+'",
 			"Amount":'+ convert(varchar,@Amount) +'
 		}'

	--set @i+=1
	--delete from @TxnList 
	--where AccCode=@AccCode and DrCr= @DrCr AND amount =  @Amount

	SET @RC = @RC -1

end 

select '555555555'
select @TxnDrList
--select @TxnDrList TxnDrList

Declare @APTaxList varchar(max)='', @TaxID int, @TaxAmount money , @TaxRate money 

SELECT S.TaxTypeID,T.Rate,Sum(TaxAmount) TaxAmount 
INTO #TaxList
FROM StockTransactionwiseTaxes S
INNER JOIN TaxDetails T ON S.TaxTypeID= T.TaxTypeID
INNER JOIN [dbo].[StockTransactionDetails] D ON D.ID= S.[StockTransactionDetailID]
WHERE StockTransactionHeaderID=@StockTransactionHeaderID
GROUP BY S.TaxTypeID,T.Rate
 
 --SELECT  * FROM #TaxList
 set @APTaxList=''
WHILE EXISTS(SELECT TOP 1 TaxTypeID FROM #TaxList)
BEGIN
	SELECT TOP 1 @TaxID = TaxTypeID, @TaxAmount= TaxAmount, @TaxRate=Rate
	FROM #TaxList


	--select @TaxID , @TaxAmount, @TaxRate


	if @APTaxList <>''
	BEGIN
		SET @APTaxList+=','
	END 

	SET @TaxTotal +=@TaxAmount
    SET @APTaxList += '{
      "MasterID": "'+ @MasterID +'",
      "DocId": '+ convert(varchar, @DocID) +',
      "TaxID": '+convert(varchar, @TaxID)+',
      "TaxRate": '+convert(varchar, @TaxRate)+',
      "TaxAmount": '+convert(varchar, @TaxAmount)+',
      "ModCrNoteNo": "'+@GRNNumber+'"
    }'

	DELETE FROM #TaxList
	WHERE TaxTypeID =@TaxID
 END 

select   @GRNNumber GRNNumber,  @InvoiceNO InvoiceNO , @OPNumber OPNumber, @TxnDate TxnDate,@DocID DocID, @SupplierCode SupplierCode

--select @APTaxList APTaxList

SET @APTaxList = isnull(@APTaxList,'')
-- "TotalDocAmt":'+convert(varchar,@Total + @TaxTotal)+',
set @RequestBody=' {
	"TxnDate": "'+@TxnDate+'",
 	"AppUserID":"b490b26a-2886-4671-8253-a8644c76660f",
 	"DrDatalList":['+@TxnDrList+'],
	"APTaxList": ['+ @APTaxList +'],
 	"CrHeaderDataList":[
 				{
 					"ModCrNoteNo":"'+ @GRNNumber +'",
 					"DocId":"'+ convert(varchar, @DocID) +'",
 					"DocDate":"'+ @TxnDate +'",
 					"BSPCode":"'+ Isnull(@SupplierCode,'') +'",
 					"MasterID":"'+@masterID +'",
 					"TotalDocAmt":'+convert(varchar,@Total +@taxTotal)+',
 					"CrNarration":" Supplier - ' + Isnull(@SupplierName,'') +', SuppInvNO: ' + ISNULL(@InvoiceNO, '') +  ', ' +  CASE WHEN @DocID =1 THEN 'GRN' ELSE + 'GRN- '+ @GRNNUmber + ', SRN' END +' - '+ @DocumentNo +' ",
 					"ModProType":"",
					"MFCenter":"",
 					"ModRefNo":"'+ @GRNNumber +'",
					"SuppInvNO":"'+ @InvoiceNO +'",
					"RefNo" : "'+ @OPNumber +'",
 					"UserID":"'+convert(varchar(max),@AppUser)+'",
 					"TransType":0
 					
 				}],

				"APSegmentList":[],
				"ModuleCode":"I",
				"DocID":"'+ convert(varchar, @DocID) +'",
				"TxnCurr":"LKR",
				"ExchangeRate":1,
				"MulComCode":"'+@companyCode+'",
				"CrDrNo":"'+ @DocumentNo +'"
	
 }'
  
 SELECT @TxnDrList TxnDrList, @APTaxList APTaxList, @GRNNumber GRNNumber, convert(varchar, @DocID) DocID, @TxnDate TxnDate, Isnull(@SupplierCode,'') SupplierCode, @masterID masterID ,
convert(varchar,@Total +@taxTotal) Total, Isnull(@SupplierName,'') SupplierName ,  @GRNNUmber GRNNUmber, 
@DocumentNo DocumentNo , @GRNNumber GRNNumber, @InvoiceNO InvoiceNO , @OPNumber OPNumber, convert(varchar, @DocID) DocID ,@companyCode companyCode, @DocumentNo DocumentNo 

 
 --select @TxnDate, '888888888888888888888888888'

 -- "APSegmentList":[{"SegmentID":1,"Amount":'+convert(varchar, @Total )+', "SeqNo": 1}],
select   @RequestBody RequestBody


--Code Snippet
Exec sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;

--Exec sp_OAMethod @Object, 'open', NULL, 'post','http://10.10.20.21:1006/api/OtherModulePosttoAP','false'   
--Exec sp_OAMethod @Object, 'open', NULL, 'post','http://192.168.3.250:8081/api/OtherModulePosttoAP','false' 

EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Content-Type', 'application/json'
EXEC sp_OAMethod @Object, 'setRequestHeader', NULL, 'Accept', 'application/json'



EXEC sp_OAMethod @Object, 'send', NULL, @RequestBody

--SELECT @Object ObjectT
--SELECT @RequestBody RequestBody


EXEC sp_OAGetErrorInfo @object, NULL, @ResponseText OUT
INSERT INTO @ResponseTable( ResponseValue ) 
EXEC sp_OAMethod @Object, 'responseText'
EXEC sp_OAGetErrorInfo @object, NULL, @description OUT

--select  @description , @object , *  from @ResponseTable 
DECLARE @ResponseValue VARCHAR(MAX)

SELECT @ResponseValue = isnull(ResponseValue ,'')
FROM @ResponseTable  

SELECT @ResponseValue ResponseValue,'6555'

--IF (SUBSTRING(@ResponseValue, 2,2) )<>'OK'
--	RAISERROR (@ResponseValue,16,1)

GO

