-- 
--SP_InsertPriceShedule '<PriceSheduleHeaders xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>192.168.1.1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-08-10T08:36:48.142Z</CreatedDate><LastModDate>2018-08-10T08:36:48.142Z</LastModDate><Id>0</Id><PropertyID>1</PropertyID><LocationID>1</LocationID><DocNO>12345</DocNO><AffectedDate>0001-01-01T00:00:00</AffectedDate><DocStatus>p</DocStatus><Isapproved>false</Isapproved><ReqType>PL</ReqType><DetailList><PriceSheduleDetails><Id>0</Id><SheduleHeaderD>0</SheduleHeaderD><StockItemID>3</StockItemID><MasterUnit>3</MasterUnit><NewPrice>0</NewPrice></PriceSheduleDetails></DetailList></PriceSheduleHeaders>','',1
CREATE Procedure [dbo].[SP_InsertPriceShedule] (@XMLDetails as XML, @docID VARCHAR(MAX) OUTPUT, @headerid INT OUTPUT )
as
declare @iDocID int


BEGIN TRY
	BEGIN TRANSACTION


declare @ReqType varchar(2), @LocationID int , @PropertyID int, @DocNO varchar(max),@Isapproved BIT,
		@SheduleHeaderD bigint, @TransactionTypeID int, @DocStatus varchar(20), @AffectedDate DATETIME,@LastModUserID int,@CreatedUserID int,
		@StockItemID INT, @MasterUnit INT
		

EXEC sp_xml_preparedocument @iDocID OUTPUT,@XMLDetails


--

SELECT  @ReqType=ReqType,@LocationID =LocationID , @PropertyID=PropertyID,@AffectedDate=AffectedDate
FROM     OPENXML (@iDocID,'/PriceSheduleHeaders',2)
WITH    ( ReqType varchar(2), LocationID int , PropertyID int, AffectedDate DATETIME)


SELECT @StockItemID=StockItemID,@MasterUnit=UnitID
FROM     OPENXML (@iDocID,'/PriceSheduleHeaders/DetailList/PriceSheduleDetails',2)
with   (StockItemID INT,UnitID INT)


select @DocNO= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@ReqType)

IF @DocNO IS NULL
BEGIN
	INSERT INTO TransactionTypeWiseNextNumbers
	(PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
	VALUES (@PropertyID,@LocationID,@ReqType,1,6)
	
select @DocNO= dbo.FN_GetNextDocumentNumber (@PropertyID,@LocationID,@ReqType)

END





 
DECLARE @Prefix VARCHAR(max),@Len INT,@Code VARCHAR(max) 


SELECT @Prefix=Prefix FROM dbo.Locations WHERE Id=@LocationID
SELECT @Code=Code FROM dbo.TransactionTypes WHERE Code=@ReqType

SELECT @Code=CASE 
 WHEN @ReqType='PL' THEN 'PL'
 --WHEN @ReqType='RD' THEN 'DR'
 --WHEN @ReqType='RT' THEN 'TR'
 --WHEN @ReqType='RI' THEN 'IR'

 END 

SELECT LEN(@Prefix)

SELECT @Prefix=SUBSTRING(@Prefix,1,3)

SET @DocNO=@Prefix+'/'+@Code+'/'+@DocNO

--SELECT * FROM TransactionTypeWiseNextNumbers
update TransactionTypeWiseNextNumbers
set NextNumber=NextNumber+1
where locationid=@LocationID and transactionType=@ReqType

select @TransactionTypeID=Id  from TransactionTypes
where code=@ReqType

--select * from TransactionTypes
--update TransactionTypes set code = 'RP' where id =1

insert into PriceSheduleHeaders 
		(PropertyID, LocationID, ReqType, DocNO, AffectedDate, DocStatus, IsApproved,IPAddress,LastModUserID,CreatedUserID,LastModDate,CreatedDate )
SELECT	 PropertyID, LocationID, @ReqType, @DocNO,  @AffectedDate, @DocStatus, 0,'192.168.0.0',LastModUserID,CreatedUserID,GETDATE(),GETDATE()
FROM     OPENXML (@iDocID,'/PriceSheduleHeaders',2)
with PriceSheduleHeaders


select @SheduleHeaderD= SCOPE_IDENTITY()


insert into PriceSheduleDetails (SheduleHeaderD,StockItemID,MasterUnit,NewPrice)
					  SELECT  @SheduleHeaderD,StockItemID,MasterUnit,
					NewPrice
FROM     OPENXML (@iDocID,'/PriceSheduleHeaders/DetailList/PriceSheduleDetails',2)
with PriceSheduleDetails


set @docID=@DocNO
SET @headerid = @SheduleHeaderD
exec dbo.SP_InsertApprovalLevelForRequest  @PropertyID,@LocationID,@TransactionTypeID,@SheduleHeaderD

	COMMIT TRAN -- Transaction Success!
END TRY
BEGIN CATCH
	return CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH



--select  dbo.FN_GetAveragePrice(@PropertyID,@LocationID,@stockItemId,@requestType,0,@unitID,0) 

GO

