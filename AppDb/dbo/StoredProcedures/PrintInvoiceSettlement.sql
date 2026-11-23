CREATE procedure [dbo].[PrintInvoiceSettlement] (@InvoiceHeaderID int=1010)
as
set NoCount ON

declare @InvoicePayment as table (SEQ int, LineTypeID int , ID int, Data varchar(max))
declare @temp as table (ID int identity(1,1), PaymentTypeName varchar(100), TenderdAmount  money)

declare @id int , @TotalValue as money, @PaymentTypeName varchar(100), @TenderdAmount money, @ActualAmount money, @Balance money

select  @TotalValue = NetTotal from [dbo].[InvoiceHeaders] ih where ih.ID = @InvoiceHeaderID


 
insert into @InvoicePayment
values (1,4,1,'Invoice Total:')

insert into @InvoicePayment
values (1,4,2, CONVERT(varchar,@TotalValue , 1))

insert into @InvoicePayment
values (2,1,1,'')

insert into @temp (PaymentTypeName, TenderdAmount)
select   description,  TenderedAmount  from InvoicePaymentsDetails ip 
inner join PaymentTypes p on ip.paymentTypeID= p.id 
where [InvoiceHeaderID]=@InvoiceHeaderID



declare @seq int = 3


while exists(select id from @temp )
begin
	select top (1) @id = id, @PaymentTypeName= PaymentTypeName, @TenderdAmount=TenderdAmount  from @temp

	insert into @InvoicePayment
	values (@seq,4,1,@PaymentTypeName)

	insert into @InvoicePayment
	values (@seq,4,2 ,CONVERT(varchar,@TenderdAmount , 1))

	set @seq+=1

	delete from @temp where id =@id 
end 






set @Balance=0

select   @Balance=  TenderedAmount- ActualAmount  from InvoicePaymentsDetails ip 
inner join PaymentTypes p on ip.paymentTypeID= p.id 
where [InvoiceHeaderID]=@InvoiceHeaderID and Cash= 1

 

if @Balance > 0
begin
	insert into @InvoicePayment
	values (@seq,4,1,'Balance for Cash')
	insert into @InvoicePayment
	values (@seq,4,2, CONVERT(varchar,@Balance , 1))
end 


set @Balance=0

select   @Balance=   ActualAmount  from InvoicePaymentsDetails ip 
inner join PaymentTypes p on ip.paymentTypeID= p.id 
where [InvoiceHeaderID]=@InvoiceHeaderID and Credit= 1

 set @seq+=1

if @Balance > 0
begin
	insert into @InvoicePayment
	values (@seq,4,1,'Credit Balance')
	insert into @InvoicePayment
	values (@seq,4,2, CONVERT(varchar,@Balance , 1))
end 


set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')

set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')

set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, 'IT Provider - www.scienter.lk')


set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')

set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')

set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')

set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')

set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')



set @seq+=1
insert into @InvoicePayment
values (@seq,5,1, '')
declare @x  as xml =(
select SEQ , LineTypeID, (select ID , Data from @InvoicePayment  PrintData where Line.SEQ= PrintData.SEQ and Line.ID= PrintData.ID
FOR XML AUTO, type,root('LineContent')
)  from @InvoicePayment Line

for xml Auto ,ELEMENTS , root('Bill')
)

 
exec [PrintMyBill] @x

GO

