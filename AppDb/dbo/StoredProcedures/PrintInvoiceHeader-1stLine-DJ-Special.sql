--EXEC [PrintInvoiceHeader-1stLine-DJ-Special] 216
CREATE PROCEDURE [dbo].[PrintInvoiceHeader-1stLine-DJ-Special](@InvoiceHeaderID INT=216)
AS 

SET NOCOUNT ON

	DECLARE @InvoiceDetails AS TABLE(SEQ INT,LineTypeID INT,ID INT,Data VARCHAR(MAX))

	DECLARE @FileNo VARCHAR(MAX),@BillNo VARCHAR(MAX),@Date VARCHAR(MAX),@NIC VARCHAR(MAX),@Model VARCHAR(MAX),@TelNo VARCHAR(MAX),@ChassisNo VARCHAR(MAX),@EngineNo VARCHAR(MAX),@Colour VARCHAR(MAX),@TagNo VARCHAR(MAX),@SEQ int = 13,@Gap VARCHAR(max)=':     '

	SELECT @FileNo=IAD.FileNo,@BillNo=IAD.BillNo,@Date=IAD.Date,@NIC=IAD.NIC,@Model=IAD.Model,@TelNo=IAD.TelNo,@ChassisNo=IAD.ChassisNo,@EngineNo=IAD.EngineNo,@Colour=IAD.Colour,@TagNo=IAD.TagNo 
	FROM dbo.InvoiceHeaders IH 
	INNER JOIN dbo.InvoiceDetails ID  ON IH.ID = ID.InvoiceHeaderID
	INNER JOIN dbo.ItemAdditionalDetail IAD ON IH.ID =  IAD.Recipientheaderid
	WHERE IH.ID = @InvoiceHeaderID


	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'{HALFLINE}')
	SET @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES  (@SEQ,17,1,'{FULLLINE}')
	SET @SEQ+=1
	
	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'{12CPI}')
	set @SEQ+=1
	------------------------------------------------------------------------------------------------------------------
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,17,2,@FileNo )

	INSERT into  @InvoiceDetails
	values (@SEQ,17,3,@BillNo )

	INSERT into  @InvoiceDetails
	values (@SEQ,17,4,@Date )

	SET @SEQ+=1
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'{HALFLINE}')
	SET @SEQ+=1

	--------------------------------------------------------------------------------------------------------------------

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,18,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,18,2,@NIC )

	INSERT into  @InvoiceDetails
	values (@SEQ,18,3,@Model )

	INSERT into  @InvoiceDetails
	values (@SEQ,18,4,@TelNo )

	SET @SEQ+=1
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,18,1,'{HALFLINE}')
	SET @SEQ+=1


	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,19,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,19,2,@ChassisNo )

	INSERT into  @InvoiceDetails
	values (@SEQ,19,3,'' )

	INSERT into  @InvoiceDetails
	values (@SEQ,19,4,@EngineNo )

	SET @SEQ+=1
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,19,1,'{HALFLINE}')
	SET @SEQ+=1

	--------------------------------------------------------------------------------------------------------------------
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,20,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,20,2,@Colour )

	INSERT into  @InvoiceDetails
	values (@SEQ,20,3,'' )

	INSERT into  @InvoiceDetails
	values (@SEQ,20,4,@TagNo )

	SET @SEQ+=1
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,20,1,'{HALFLINE}')
	SET @SEQ+=1

	-------------------------------------------------------------------------------------------------------------------
	DECLARE @ClientName VARCHAR(MAX),@Amount VARCHAR(MAX),@AmountInWord VARCHAR(MAX),@CentsInWord VARCHAR(MAX)    

	SELECT @ClientName=C.CustomerName,@Amount=IH.GrossTotal
	FROM dbo.InvoiceHeaders IH 
	INNER JOIN dbo.Customers C ON C.Id = IH.CustomerID
	WHERE IH.ID = @InvoiceHeaderID

	SELECT @AmountInWord = dbo.fnMoneyToEnglish (@Amount)+' Rupees and '
	SELECT @CentsInWord = dbo.fnMoneyToEnglish (PARSENAME(@Amount,1))+' Cents' 

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,21,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,21,2,@ClientName )

	SET @SEQ+=1

	-------------------------------------------------------------------------------------------------------------------
	
	SET @SEQ+=1
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,20,1,'{HALFLINE}')
	SET @SEQ+=1


	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,22,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,22,2,@AmountInWord+@CentsInWord)

	-------------------------------------------------------------------------------------------------------------------

	SET @SEQ+=1
	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,23,1,'{FULLLINE}')
	SET @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,23,1,'')

	INSERT into  @InvoiceDetails
	values (@SEQ,23,2,@Amount)

	SET @SEQ+=1

    -------------------------------------------------------------------------------------------------------------------

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'{FULLLINE}')
	SET @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'{FULLLINE}')
	SET @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,17,1,'{FULLLINE}')
	SET @SEQ+=1
    
	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,17,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,20,1,'{HALFLINE}')
	SET @SEQ+=1
	-------------------------------------------------------------------------------------------------------------------

	INSERT INTO  @InvoiceDetails
	VALUES (@SEQ,24,1,'{HALFLINE}')

	INSERT into  @InvoiceDetails
	values (@SEQ,24,2,@Amount)

	SET @SEQ+=1

-------------------------------------------------------------------------------------------------------------------

	--INSERT into  @InvoiceDetails
	--values (@SEQ,17,1,'{NEWPAGE}')
	--set @SEQ+=1


	DECLARE @x AS XML =
	(
	SELECT SEQ , LineTypeID, (SELECT ID , Data FROM @InvoiceDetails  PrintData WHERE Line.SEQ= PrintData.SEQ and Line.ID= PrintData.ID
							  FOR XML AUTO, type,root('LineContent')
							 )FROM  @InvoiceDetails Line
	FOR XML AUTO,ELEMENTS,ROOT('Bill')
	)

	EXEC [PrintMyBill] @x

GO

