
--SP_InsertRequest '<RequestHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><Flag>0</Flag><Isprint>false</Isprint><PropertyID>1</PropertyID><LocationID>1</LocationID><DepartmentID>2</DepartmentID><TransferLocation>1</TransferLocation><RequestType>RP</RequestType><DocumentNo>1</DocumentNo><RequestDate>2018-06-25T00:00:00</RequestDate><DocumentStatus>P</DocumentStatus><UserProfileID>1</UserProfileID><JobNo>1</JobNo><IsApproved>false</IsApproved><Remarks>oneday</Remarks><TimeStamp>2018-06-25T05:48:28.814Z</TimeStamp><TransactionTypeCode>PR</TransactionTypeCode><DeliveryDate>2018-06-29T00:00:00</DeliveryDate><DetailList><RequestDetail><Id>0</Id><RequestHeaderID>0</RequestHeaderID><StockItemID>207</StockItemID><UnitID>1</UnitID><RequestedQuantity>12</RequestedQuantity><IssuedQuantity>0</IssuedQuantity><ApprovedQuantity>0</ApprovedQuantity><Remarks>added</Remarks><TimeStamp>2018-06-25T05:48:26.255Z</TimeStamp><UnitPrice>0</UnitPrice><InvAccountID>0</InvAccountID></RequestDetail></DetailList></RequestHeader>','',1


--[dbo].[SP_InsertOrder] '<OrderHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>0</Id><CompanyID>1</CompanyID><LocationID>1</LocationID><DocumentNo>0</DocumentNo><TransType>OR</TransType><CustomerID>476</CustomerID><SalesPersonID>1</SalesPersonID><DocumentDate>2018-07-24T06:37:25.366Z</DocumentDate><PaymentMethodID>0</PaymentMethodID><GrossAmount>29059</GrossAmount><SubDiscountAmount>10</SubDiscountAmount><SubDiscountPercentage>10</SubDiscountPercentage><LineDiscountTotal>10</LineDiscountTotal><TotalDiscount>1017</TotalDiscount><TotalOtherCharges>1000</TotalOtherCharges><TotalTax>5041</TotalTax><NetAmount>33083</NetAmount><Remark /><DocumentStatus>0</DocumentStatus><OrderDetail><OrderDetail><Id>0</Id><OrderHeaderID>0</OrderHeaderID><CompanyID>1</CompanyID><LocationID>1</LocationID><ProductID>7080</ProductID><OrderQty>100</OrderQty><IssueQty>9</IssueQty><BalanceQty>9</BalanceQty><FreeQty>9</FreeQty><BalanceFreeQty>9</BalanceFreeQty><CostPrice>27974</CostPrice><ConvertFactor>9</ConvertFactor><UnitID>1</UnitID><SellingPrice>289.74</SellingPrice><Total>9</Total><TaxGroupID>1</TaxGroupID><TaxValue>50.26</TaxValue><IsPercentageForDiscount>false</IsPercentageForDiscount><ItemDiscountValue>10</ItemDiscountValue><ItemDiscountRate>0</ItemDiscountRate><NetTotal>0</NetTotal><LineNo>9</LineNo></OrderDetail><OrderDetail><Id>0</Id><OrderHeaderID>0</OrderHeaderID><CompanyID>1</CompanyID><LocationID>1</LocationID><ProductID>352</ProductID><OrderQty>100</OrderQty><IssueQty>9</IssueQty><BalanceQty>9</BalanceQty><FreeQty>9</FreeQty><BalanceFreeQty>9</BalanceFreeQty><CostPrice>68</CostPrice><ConvertFactor>9</ConvertFactor><UnitID>1</UnitID><SellingPrice>0.85</SellingPrice><Total>9</Total><TaxGroupID>1</TaxGroupID><TaxValue>0.15</TaxValue><IsPercentageForDiscount>true</IsPercentageForDiscount><ItemDiscountValue>0</ItemDiscountValue><ItemDiscountRate>20</ItemDiscountRate><NetTotal>33000</NetTotal><LineNo>9</LineNo></OrderDetail></OrderDetail></OrderHeader>','',1
CREATE Procedure [dbo].[SP_InsertOrder] (@XMLDetails as XML, @docID VARCHAR(MAX) OUTPUT, @headerid INT OUTPUT )
as
declare @iDocID int


BEGIN TRY
	BEGIN TRANSACTION


declare @TransType varchar(2), @LocationID int , @PropertyID int, @DocumentNo varchar(max),
		 @OrderHeaderID bigint, @TransactionTypeID int, @DocumentDate varchar(10),@ProductID varchar(max),@unitID varchar(max)
		

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails


--

SELECT  @TransType=TransType,@LocationID =LocationID , @PropertyID=CompanyID,@DocumentDate=DocumentDate
FROM     OPENXML (@iDocID,'/OrderHeader',2)
WITH    ( TransType varchar(2), LocationID int , CompanyID int , DocumentDate varchar(10) )

select @TransType

SELECT @ProductID=ProductID,@unitID=UnitID
FROM     OPENXML (@iDocID,'/OrderHeader/OrderDetail/OrderDetail',2)
with   (ProductID varchar(max),UnitID varchar(max))


select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@TransType)

select @TransType

IF @DocumentNo IS NULL
BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@TransType,1,6)
END



select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@TransType)

select * from TransactionTypeWiseNextNumbers


 
DECLARE @Prefix VARCHAR(max),@Len INT,@Code VARCHAR(max) 


SELECT @Prefix=Prefix FROM dbo.Locations WHERE Id=@LocationID
SELECT @Code=Code FROM dbo.TransactionTypes WHERE Code=@TransType

SELECT @Code=CASE 
 WHEN @TransType='OR' THEN 'OR'
 --WHEN @RequestType='RD' THEN 'DR'
 --WHEN @RequestType='RT' THEN 'TR'
 --WHEN @RequestType='RI' THEN 'IR'

 END 

SELECT LEN(@Prefix)

SELECT @Prefix=SUBSTRING(@Prefix,1,3)

SET @DocumentNo=@Prefix+'/'+@Code+'/'+@DocumentNo

select @DocumentNo

--SELECT * FROM TransactionTypeWiseNextNumbers
update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@TransType

select @TransactionTypeID=Id  from TransactionTypes
where code=@TransType

--select * from TransactionTypes
--update TransactionTypes set code = 'RP' where id =1
--SELECT * FROM OrderHeaders
insert into OrderHeaders
		(CompanyID, LocationID,DocumentNo, TransType,CustomerID,SalesPersonID, DocumentDate, PaymentMethodID,GrossAmount, SubDiscountAmount, SubDiscountPercentage, LineDiscountTotal,TotalDiscount, TotalOtherCharges,TotalTax,NetAmount,Remark,ReferenceNo,DocumentStatus)
SELECT	 CompanyID, LocationID, @DocumentNo, TransType,CustomerID,SalesPersonID, @DocumentDate, PaymentMethodID,GrossAmount, SubDiscountAmount, SubDiscountPercentage, LineDiscountTotal,TotalDiscount, TotalOtherCharges,TotalTax,NetAmount,Remark,ReferenceNo,DocumentStatus
FROM     OPENXML (@iDocID,'/OrderHeader',2)
with OrderHeaders


select @OrderHeaderID= SCOPE_IDENTITY()

--SELECT * FROM OrderDetails
--SELECT * FROM RequestDetails

insert into OrderDetails(OrderHeaderID, ProductID, OrderQty,
						IssueQty,BalanceQty,ConvertFactor,UnitID,
						SellingPrice,TaxGroupID,TaxValue,IsPercentageForDiscount,ItemDiscountValue,
						ItemDiscountRate , [LineNo], Total,NetTotal)

				SELECT  @OrderHeaderID,  ProductID,OrderQty,
						IssueQty,BalanceQty,ConvertFactor,UnitID,
						SellingPrice,TaxGroupID,TaxValue,IsPercentageForDiscount,ItemDiscountValue,
						ItemDiscountRate,[LineNO],Total,NetTotal

					 
FROM     OPENXML (@iDocID,'/OrderHeader/OrderDetail/OrderDetail',2)
with OrderDetails


set @docID=@DocumentNo
SET @headerid = @OrderHeaderID
exec dbo.SP_InsertApprovalLevelForRequest  @PropertyID,@LocationID,@TransactionTypeID,@OrderHeaderID
SELECT @PropertyID,@LocationID,@TransactionTypeID,@OrderHeaderID

	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH



--select  dbo.FN_GetAveragePrice(@PropertyID,@LocationID,@stockItemId,@requestType,0,@unitID,0) 


--SELECT * FROM ApprovalLogs WHERE TransactionID=40
--SELECT * FROM TransactionTypes



--SELECT * FROM OrderHeaders
--SELECT * FROM OrderDetails

-- select dbo.FN_GetNextDocumentNumber (1,1,'OR')

GO

