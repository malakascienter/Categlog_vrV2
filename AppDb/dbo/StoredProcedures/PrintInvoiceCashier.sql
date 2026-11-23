--EXEC PrintInvoiceCashier 91
CREATE  procedure [dbo].[PrintInvoiceCashier](@InvoiceHeaderID int=1010)
as


SET NOCOUNT ON

declare  @InvoiceDetails as table (SEQ int,LineTypeID int, ID int, Data varchar(max))
declare @ID int ,@CashierName VARCHAR(500), @SEQ int = 13



	SELECT @CashierName=UM.UserName  
	FROM [dbo].[InvoiceDetails] Ind
	INNER JOIN dbo.UserMasters UM ON UM.Id = Ind.CreatedUserID
	WHERE InvoiceHeaderID =  @InvoiceHeaderID
	
	insert into  @InvoiceDetails
	values (@SEQ,7,1,@CashierName)
	


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

