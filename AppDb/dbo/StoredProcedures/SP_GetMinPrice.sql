CREATE Procedure [dbo].[SP_GetMinPrice](@locationID int, @stockItemID int)
as

Declare @MinPrice money 

if exists(select * from OpenPrices where locationId=@locationID and itemId=@stockItemID and used=0 )
Begin

	select @MinPrice=sellingprice from OpenPrices where locationId=@locationID and itemId=@stockItemID and used=0
end

else
Begin
	select @MinPrice=averageprice + (averageprice*profitmargin/100) from stockitemdetails  where locationId=@locationID and StockItemHeaderID =@stockItemID 
end

select @MinPrice as Minprice

GO

