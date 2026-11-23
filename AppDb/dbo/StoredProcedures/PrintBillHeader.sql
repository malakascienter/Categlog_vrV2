CREATE procedure [dbo].[PrintBillHeader] 
as

declare @x  as xml =(
select SEQ ,1 LineTypeID, (select 1 ID , Data from [dbo].[BillAddressSettings]  PrintData where Line.SEQ= PrintData.SEQ 
FOR XML AUTO, type,root('LineContent')
)  from [BillAddressSettings] Line

for xml Auto ,ELEMENTS , root('Bill')
)


--select @x 
exec [PrintMyBill] @x

GO

