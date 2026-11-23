--EXEC PrintInvoiceheaderInfo 187
CREATE   procedure [dbo].[PrintInvoiceheaderInfo](@InvoiceHeaderID int=1010)
as


SET NOCOUNT ON

declare  @InvoiceDetails as table (SEQ int,LineTypeID int, ID int, Data varchar(max))

DECLARE  @LocatonName VARCHAR(500),@CashierName VARCHAR(500),@InvoiceNo VARCHAR(500), @Date  VARCHAR(500), @Time VARCHAR(500), @SEQ int = 13  , @Gap VARCHAR(max)=':     '

	SELECT @CashierName=UM.UserName  
	FROM [dbo].[InvoiceDetails] Ind
	INNER JOIN dbo.UserMasters UM ON UM.Id = Ind.CreatedUserID
	WHERE InvoiceHeaderID =  @InvoiceHeaderID

	-- INSERT into  @InvoiceDetails
	--values (@SEQ,7,1,'')
	--set @SEQ+=1

	-- 	INSERT into  @InvoiceDetails
	--values (@SEQ,7,1,'{FULLLINE}')
	--set @SEQ+=1

	
	--INSERT into  @InvoiceDetails
	--values (@SEQ,7,1,'')
	--set @SEQ+=1

	--INSERT into  @InvoiceDetails
	--values (@SEQ,7,1,'{FULLLINE}')
	--set @SEQ+=1
	
	INSERT into  @InvoiceDetails
	values (@SEQ,7,1,'{HALFLINE}')
	set @SEQ+=1


	--insert into  @InvoiceDetails
	--values (@SEQ,7,1,'')
	--set @SEQ+=1

	insert into  @InvoiceDetails
	values (@SEQ,7,1,'{HALFLINE}')
	set @SEQ+=1
	
	INSERT into  @InvoiceDetails
	values (@SEQ,7,1,'{HALFLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,7,1,'{HALFLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,7,1,'{FULLLINE}')
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,7,1,':     ' + @CashierName+ '' )
	set @SEQ+=1

	INSERT into  @InvoiceDetails
	values (@SEQ,7,1,'')
	set @SEQ+=1

--------------------------------------------------------------------------------------------------------------------

	select @InvoiceNo=ind.InvoiceNo,@Date=CONVERT(DATE, GETDATE()),@Time=RIGHT(CONVERT(VARCHAR,GETDATE(),0),7) 
	FROM [dbo].[InvoiceHeaders] Ind
	WHERE Ind.ID = @InvoiceHeaderID 

	insert into  @InvoiceDetails
	values (@SEQ,8,1,':     '+@InvoiceNo + '' )

	insert into  @InvoiceDetails
	values (@SEQ,8,2,@Time)

	insert into  @InvoiceDetails
	values (@SEQ,8,3,@Date  )
	set @SEQ+=1

	--insert into  @InvoiceDetails
	--values (@SEQ,7,1,'')
	--set @SEQ+=1

--------------------------------------------------------------------------------------------------------------------
	SELECT @LocatonName= L.Name  
	FROM [dbo].[InvoiceHeaders] IH
	INNER JOIN dbo.Locations L ON L.Id = IH.Location
	WHERE IH.ID = @InvoiceHeaderID

	insert into  @InvoiceDetails
	values (@SEQ,7,1,':     '+@LocatonName)
	set @SEQ+=1	

	--insert into  @InvoiceDetails
	--values (@SEQ,7,1,'')
	--set @SEQ+=1
---------------------------- -------------------------------------
DECLARE @x AS XML =
(
select SEQ , LineTypeID, (SELECT ID , Data FROM @InvoiceDetails  PrintData WHERE Line.SEQ= PrintData.SEQ and Line.ID= PrintData.ID
						  FOR XML AUTO, type,root('LineContent')
						 )from  @InvoiceDetails Line
FOR XML AUTO,ELEMENTS,ROOT('Bill')
)

exec [PrintMyBill] @x

GO

