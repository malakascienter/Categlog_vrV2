--EXEC PrintInvoiceInfoHead  91
CREATE PROCEDURE [dbo].[PrintInvoiceInfoHead](@InvoiceHeaderID INT)
as


SET NOCOUNT ON

DECLARE  @InvoiceDetails as table (SEQ int,LineTypeID int, ID int, Data varchar(max))

declare @ID int ,@InvoiceNo VARCHAR(500), @Date  VARCHAR(500), @Time VARCHAR(500), @SEQ int = 13, @FirstLineLength int, @maxLength int 

select @FirstLineLength = Length from LineWiseColums
where lineTypeid=8 and ColumnNumber=1

select @maxLength= CharactersPerLine from PrintingCommands
where id=2



select @InvoiceNo=ind.InvoiceNo,@Date=CONVERT(DATE, GETDATE()),@Time=RIGHT(CONVERT(VARCHAR,GETDATE(),0),7) 
from [dbo].[InvoiceHeaders] Ind
where Ind.ID = @InvoiceHeaderID 
	
	insert into  @InvoiceDetails
	values (@SEQ,8,1,@InvoiceNo)
	insert into  @InvoiceDetails
	values (@SEQ,8,2,@Date)
	insert into  @InvoiceDetails
	values (@SEQ,8,3,@Time)


	

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

