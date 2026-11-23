--[dbo].[SP_InsertOutSourceLabour] '<OutSourceLabourHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress /><CreatedUserID>4</CreatedUserID><LastModUserID>4</LastModUserID><CreatedDate>2018-05-11T10:31:43.54Z</CreatedDate><LastModDate>2018-05-11T10:31:43.54Z</LastModDate><Id>0</Id><TxnNumber /><PropertyID>1</PropertyID><LocationID>1</LocationID><TransactionType>OL</TransactionType><TxnDate>2018-05-11T00:00:00</TxnDate><ProjectId>3</ProjectId><BOQId>2</BOQId><LaborMasterId>0</LaborMasterId><Amount>2700</Amount><CrNo>0</CrNo><Journals /><Status /><Completed>false</Completed><IsApproved>false</IsApproved><OutSourceLabourDetails><OutSourceLabourDetail><IPAddress /><CreatedUserID>4</CreatedUserID><LastModUserID>4</LastModUserID><CreatedDate>2018-05-11T10:32:27.113Z</CreatedDate><LastModDate>2018-05-11T10:32:27.113Z</LastModDate><Id>0</Id><HedId>0</HedId><DeptId>5</DeptId><LaborTypeId>1</LaborTypeId><LaborUnitId>3</LaborUnitId><Qty>12</Qty><Rate>1200</Rate><Total>0</Total></OutSourceLabourDetail><OutSourceLabourDetail><IPAddress /><CreatedUserID>4</CreatedUserID><LastModUserID>4</LastModUserID><CreatedDate>2018-05-11T10:32:40.096Z</CreatedDate><LastModDate>2018-05-11T10:32:40.096Z</LastModDate><Id>0</Id><HedId>0</HedId><DeptId>1</DeptId><LaborTypeId>2</LaborTypeId><LaborUnitId>3</LaborUnitId><Qty>15</Qty><Rate>1500</Rate><Total>0</Total></OutSourceLabourDetail></OutSourceLabourDetails></OutSourceLabourHeader>','',0

CREATE PROCEDURE [dbo].[SP_InsertOutSourceLabour]
	@XMLDetails as XML, @docID VARCHAR(MAX) OUTPUT, @headerid INT OUTPUT
AS
BEGIN
BEGIN TRY
	BEGIN TRANSACTION
	
declare @iDocID int
declare @BillID int, @LocationID int , @PropertyID int, @DocumentNo varchar(max),@RequestType varchar(3),@TransactionTypeID INT

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails

SELECT  @RequestType=TransactionType,@LocationID =LocationID , @PropertyID=PropertyID
FROM     OPENXML (@iDocID,'/OutSourceLabourHeader',2)
WITH    ( TransactionType varchar(2), LocationID int , PropertyID int)


--handling Document numbers *************************************************************************
select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@RequestType)

IF @DocumentNo IS NULL
BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@RequestType,1,6)
	select @DocumentNo= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@RequestType)
END

update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@RequestType

select @TransactionTypeID=Id  from TransactionTypes
where code=@RequestType

INSERT INTO OutSourceLabourHeaders
           ([TxnNumber],[TxnDate],[ProjectId],[BOQId],[LaborMasterId],[Amount]
           ,[CrNo],[Journals],[Status],[Completed],[IsApproved],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate],[PropertyID],[LocationID],[TransactionType])
select @DocumentNo,[TxnDate],[ProjectId],[BOQId],[LaborMasterId],[Amount]
           ,[CrNo],[Journals],[Status],[Completed],[IsApproved],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate],[PropertyID],[LocationID],[TransactionType]
FROM     OPENXML (@iDocID,'/OutSourceLabourHeader',2)
with OutSourceLabourHeaders

select @BillID= SCOPE_IDENTITY()	

INSERT INTO [dbo].[OutSourceLabourDetails]
           ([HedId],[DeptId],[LaborTypeId],[LaborUnitId],[Qty],[Rate],[Total],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])
select @BillID,[DeptId],[LaborTypeId],[LaborUnitId],[Qty],[Rate],[Total],[IPAddress],[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate]
FROM     OPENXML (@iDocID,'/OutSourceLabourHeader/OutSourceLabourDetails/OutSourceLabourDetail',2)
with OutSourceLabourDetails
	

--Assiugn Header and Doc No
set @docID=@DocumentNo
SET @headerid = @BillID
exec dbo.SP_InsertApprovalLevelForRequest  @PropertyID,@LocationID,@TransactionTypeID,@BillID

	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH

END

GO

