CREATE procedure [dbo].[GetGRNDataForSerial] @Id Int,@Type Varchar(50)
AS
Begin

select sh.Id,h.id as ItemId, StockItemCode,Name,sd.Quantity from stocktransactionheaders as sh 
inner join stocktransactiondetails as sd on sh.id = sd.StockTransactionHeaderID
inner join stockitemheaders as h on sd.stockitemid = h.id  where sh.Transactiontype=@Type and sh.id=@Id and sd.Isserialadded=0

End

--select * from stocktransactiondetails

-- select * from locations 

GO

