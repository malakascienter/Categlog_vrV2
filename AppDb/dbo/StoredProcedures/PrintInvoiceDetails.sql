--EXEC PrintInvoiceDetails  36	 184
CREATE procedure [dbo].[PrintInvoiceDetails](@InvoiceHeaderID int=1010)
AS 

SET NOCOUNT ON

declare  @InvoiceDetails as table (SEQ int,LineTypeID int, ID int, Data varchar(max))

declare @Items as table (ID int identity(1,1),StockItemCode VARCHAR(200),Name varchar(500), QTY int, UnitPrice decimal(18,2),Value decimal(18,2),Vat decimal(18,2))
insert into @items (StockItemCode,name,QTY,UnitPrice,Value,Vat)

select SH.StockItemCode,SH.Name,Ind.QTY, Ind.UnitPrice + ind.TaxValue UnitPrice,(Ind.UnitPrice + ind.TaxValue)-ind.ItemDiscountValue Value,ind.TaxValue Vat    
from [dbo].[InvoiceDetails] Ind
inner join [dbo].[StockItemHeaders] SH
on sh.Id= Ind.itemID
where InvoiceHeaderID = @InvoiceHeaderID 


declare @ID int ,@Name VARCHAR(500), @QTY int, @UnitPrice decimal(18,2), @SEQ int = 13, @FirstLineLength int, @maxLength int ,@StockItemCode VARCHAR(200),@Value decimal(18,2),@Vat decimal(18,2)

select @FirstLineLength = Length from LineWiseColums
where lineTypeid=10 and ColumnNumber=2

select @maxLength= CharactersPerLine from PrintingCommands
where id=2

INSERT into  @InvoiceDetails
values (@SEQ,7,1,'')
set @SEQ+=1


while exists(select top (1) id from @Items )
begin
	
	select top (1) @id = id , @Name= Name, @QTY= QTY, @UnitPrice = unitprice,@StockItemCode=StockItemCode,@Value=Value,@Vat=Vat 
	from @Items 
	
	insert into  @InvoiceDetails
	values (@SEQ,10,1,@StockItemCode)
	insert into  @InvoiceDetails
	values (@SEQ,10,2,substring (@Name,1,@FirstLineLength-1))
	insert into  @InvoiceDetails
	values (@SEQ,10,3,@qty)
	insert into  @InvoiceDetails
	values (@SEQ,10,4,@UnitPrice)
	insert into  @InvoiceDetails
	values (@SEQ,10,5,@Value)
	insert into  @InvoiceDetails
	values (@SEQ,10,6,@Vat)
	
	set @SEQ+=1
	

	IF LEN(@Name)> @FirstLineLength
	BEGIN 
		INSERT INTO @InvoiceDetails
		VALUES (@seq,10,1,'')

		INSERT INTO  @InvoiceDetails
		VALUES (@SEQ,10,2,SUBSTRING(@Name,@FirstLineLength,@maxLength))
		SET @SEQ+=1
	END 


	DELETE FROM @Items WHERE id =@ID 

	--SELECT * FROM @InvoiceDetails

end
--SELECT * FROM @InvoiceDetails				
-----------------------------------------------------------------
DECLARE @x AS XML =
(
select SEQ , LineTypeID, (SELECT ID , Data FROM @InvoiceDetails  PrintData WHERE Line.SEQ= PrintData.SEQ and Line.ID= PrintData.ID
						  FOR XML AUTO, type,root('LineContent')
						 )from  @InvoiceDetails Line
FOR XML AUTO,ELEMENTS,ROOT('Bill')
)
--SELECT @x
exec [PrintMyBill] @x

GO

