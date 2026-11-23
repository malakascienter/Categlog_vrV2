--EXEC PrintInvoiceLocation 91
CREATE   procedure [dbo].[PrintInvoiceLocation](@InvoiceHeaderID int=1010)
as


SET NOCOUNT ON

declare  @InvoiceDetails as table (SEQ int,LineTypeID int, ID int, Data varchar(max))
declare @ID int ,@Name VARCHAR(500), @SEQ int = 13



	SELECT @Name= L.Name  
	FROM [dbo].[InvoiceHeaders] IH
	INNER JOIN dbo.Locations L ON L.Id = IH.Location
	WHERE IH.ID = @InvoiceHeaderID


	
	insert into  @InvoiceDetails
	values (@SEQ,9,1,@Name)
	


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

