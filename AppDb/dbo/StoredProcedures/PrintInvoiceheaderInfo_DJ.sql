--EXEC PrintInvoiceheaderInfo_DJ 190
CREATE PROCEDURE [dbo].[PrintInvoiceheaderInfo_DJ](@InvoiceHeaderID INT=1010)
AS 

SET NOCOUNT ON

DECLARE @InvoiceDetails AS TABLE(SEQ INT,LineTypeID INT,ID INT,Data VARCHAR(MAX))

DECLARE @LocatonName VARCHAR(500),@CustomerName VARCHAR(500),@CashierName VARCHAR(500),@InvoiceNo VARCHAR(500),@Date  VARCHAR(500),@Time VARCHAR(500),@SEQ int = 13,@Gap VARCHAR(max)=':     '

	SELECT @CashierName=UM.UserName,@CustomerName=C.CustomerName  
	FROM [dbo].[InvoiceHeaders] Inh
	INNER JOIN dbo.UserMasters UM ON UM.Id = Inh.CreatedUserID
	INNER JOIN dbo.Customers C ON C.Id = Inh.CustomerID
	WHERE Inh.ID =  @InvoiceHeaderID

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,14,1,'{HALFLINE}')
	SET @SEQ+=1

	--INSERT INTO  @InvoiceDetails
	--VALUES (@SEQ,14,2,'{FULLLINE}')
	--SET @SEQ+=1

	--INSERT INTO  @InvoiceDetails
	--VALUES (@SEQ,14,2,'{FULLLINE}')
	--SET @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES  (@SEQ,14,2,'{FULLLINE}')
	SET @SEQ+=1
	
	INSERT into  @InvoiceDetails
	values (@SEQ,14,2,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,14,2,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,14,2,'{FULLLINE}')
	set @SEQ+=1

	SELECT  @InvoiceNo=ind.InvoiceNo,@Date=CONVERT(DATE, GETDATE()),@Time=RIGHT(CONVERT(VARCHAR,GETDATE(),0),7) 
	FROM [dbo].[InvoiceHeaders] Ind
	WHERE Ind.ID = @InvoiceHeaderID 

	INSERT into  @InvoiceDetails
	values (@SEQ,14,1,'' )

	INSERT into  @InvoiceDetails
	values (@SEQ,14,2,'' )

	INSERT into  @InvoiceDetails
	values (@SEQ,14,3,@InvoiceNo )
	set @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,14,3,'')
	SET @SEQ+=1

--------------------------------------------------------------------------------------------------------------------
	INSERT  INTO   @InvoiceDetails
	VALUES  (@SEQ,14,1,'')

	INSERT  INTO   @InvoiceDetails
	VALUES  (@SEQ,14,2,@CustomerName)

	INSERT  INTO   @InvoiceDetails
	VALUES  (@SEQ,14,3,@Date  )
	SET  @SEQ+=1

-----------------------------------------------------------------
DECLARE @x AS XML =
(
SELECT SEQ , LineTypeID, (SELECT ID , Data FROM @InvoiceDetails  PrintData WHERE Line.SEQ= PrintData.SEQ and Line.ID= PrintData.ID
						  FOR XML AUTO, type,root('LineContent')
						 )FROM  @InvoiceDetails Line
FOR XML AUTO,ELEMENTS,ROOT('Bill')
)

EXEC [PrintMyBill] @x

GO

