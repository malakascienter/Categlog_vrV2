--EXEC PrintInvoiceDetails_DJ  	 186	190
CREATE  procedure [dbo].[PrintInvoiceDetails_DJ](@InvoiceHeaderID int=1010)
AS 

SET NOCOUNT ON

DECLARE  @InvoiceDetails AS TABLE (SEQ INT,LineTypeID INT, ID INT, Data VARCHAR(MAX))

DECLARE @Items AS TABLE (ID int identity(1,1),QTY int,StockItemCode VARCHAR(200),Name varchar(500), UnitPrice decimal(18,2),Value decimal(18,2),Discount decimal(18,2))
INSERT INTO @items (QTY,StockItemCode,name,UnitPrice,Value,Discount)
SELECT Ind.QTY,SH.StockItemCode,SH.Name, Ind.UnitPrice + ind.TaxValue UnitPrice,(Ind.UnitPrice + ind.TaxValue)-ind.ItemDiscountValue Value,(Inh.TotalDiscount+Inh.ItemDiscountTotal) Discount    
FROM [dbo].[InvoiceDetails] Ind
INNER JOIN [dbo].[InvoiceHeaders] Inh ON Inh.ID = Ind.InvoiceHeaderID 
INNER JOIN [dbo].[StockItemHeaders] SH
ON sh.Id= Ind.itemID
WHERE InvoiceHeaderID = @InvoiceHeaderID 


declare @ID int ,@Name VARCHAR(500), @QTY int, @UnitPrice decimal(18,2), @SEQ int = 13, @FirstLineLength int, @maxLength int ,@StockItemCode VARCHAR(200),@Value decimal(18,2),@Discount decimal(18,2)

select @FirstLineLength = Length from LineWiseColums
where lineTypeid=15 and ColumnNumber=3

select @maxLength= CharactersPerLine from PrintingCommands
where id=2

--INSERT into  @InvoiceDetails
--values (@SEQ,15,1,'')
--set @SEQ+=1

INSERT into  @InvoiceDetails
values (@SEQ,15,1,'')
set @SEQ+=1


INSERT into  @InvoiceDetails
values (@SEQ,15,1,'')
set @SEQ+=1


while exists(select top (1) id from @Items )
begin
	
	select top (1) @id = id , @Name= Name, @QTY= QTY, @UnitPrice = unitprice,@StockItemCode=StockItemCode,@Value=Value,@Discount=Discount 
	from @Items 
	
	insert into  @InvoiceDetails
	values (@SEQ,15,1,@qty)
	insert into  @InvoiceDetails
	values (@SEQ,15,2,@StockItemCode)
	insert into  @InvoiceDetails
	values (@SEQ,15,3,substring (@Name,1,@FirstLineLength-1))
	insert into  @InvoiceDetails
	values (@SEQ,15,4,@UnitPrice)
	insert into  @InvoiceDetails
	values (@SEQ,15,5,@Discount)
	insert into  @InvoiceDetails
	values (@SEQ,15,6,@Value)
	
	set @SEQ+=1
	

	IF LEN(@Name)> @FirstLineLength
	BEGIN 
		INSERT INTO @InvoiceDetails
		VALUES (@seq,15,1,'')

		INSERT INTO  @InvoiceDetails
		VALUES (@SEQ,15,2,'')

		INSERT INTO  @InvoiceDetails
		VALUES (@SEQ,15,3,SUBSTRING(@Name,@FirstLineLength,@maxLength))
		SET @SEQ+=1
	END 


	DELETE FROM @Items WHERE id =@ID 

	--SELECT * FROM @InvoiceDetails

END 


--SELECT * FROM @InvoiceDetails
--			
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

