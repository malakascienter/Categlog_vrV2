CREATE procedure [dbo].[PrintInvoiceinfo] (@InvoiceHeaderID int=1)
as

SET NOCOUNT ON
declare  @InvoiceDetails as table (SEQ int,LineTypeID int, ID int, Data varchar(max))

declare @InvoiceNumber varchar(50), @Date char(10), @Time varchar(7), @Cashier varchar(50)='Chandima'


Select @InvoiceNumber = InvoiceNo, @Date =convert(char(10),InvoiceDate,103),@Time= Right(convert (varchar,getdate(),100),7) 
from InvoiceHeaders 
where ID= @InvoiceHeaderID 

insert into  @InvoiceDetails
values (1,1,1,'')

insert into  @InvoiceDetails
values (2,2,1,'Inv.No: '+@InvoiceNumber)

insert into  @InvoiceDetails
values (2,2,2,'User : '+@Cashier )

insert into  @InvoiceDetails
values (3,2,1,'Date: '+@date)

insert into  @InvoiceDetails
values (3,2,2,'Time : '+@time)



insert into  @InvoiceDetails
values (4,1,1,'')



-----------------------------------------------------------------
declare @x  as xml =(
select SEQ , LineTypeID, (select ID , Data from  @InvoiceDetails  PrintData where Line.SEQ= PrintData.SEQ and Line.ID= PrintData.ID
FOR XML AUTO, type,root('LineContent')
)  from  @InvoiceDetails Line

for xml Auto ,ELEMENTS , root('Bill')
)


--select @x 
exec [PrintMyBill] @x

GO

