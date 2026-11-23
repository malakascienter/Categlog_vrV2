create procedure [dbo].[GetStockTransForSerials] @Location INT,@Type varchar(max)
AS
BEGIN 


select st.Id,st.DocumentNo as text from stocktransactionheaders as st 
inner join stocktransactiondetails as sd on st.id= sd.stocktransactionheaderID 
inner join stockitemheaders as sih on sih.id = sd.stockitemid  where st.TransactionType=@Type and st.LocationID=@Location group by st.Id,st.DocumentNo 

 

END

--select * from [dbo].[StockItemWiseAttributes]

--select * from [dbo].[StockItemAttributes]

--select * from stockitemheaders

GO

