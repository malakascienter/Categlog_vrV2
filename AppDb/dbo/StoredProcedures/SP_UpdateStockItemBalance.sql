
CREATE   Procedure [dbo].[SP_UpdateStockItemBalance]
( @PropertyID int, @LocationID int, @StockItemID int ,@TransactionType varchar(3), @Quantity DECIMAL(18,6)  , @unitID int,@AveragePrice DECIMAL(18,6)  = 0)
as

declare @TransactionValues as table
(TransactionType varchar(3),value int)

insert into @TransactionValues values ('GR',1)
insert into @TransactionValues values ('SR',-1)
insert into @TransactionValues values ('TI',1)
insert into @TransactionValues values ('TO',-1)
insert into @TransactionValues values ('RI',1)
--insert into @TransactionValues values ('RO',-1)
insert into @TransactionValues values ('RC',1)
insert into @TransactionValues values ('II',-1)
insert into @TransactionValues values ('IR',1)
insert into @TransactionValues values ('IN',-1)
insert into @TransactionValues values ('AA',1)
insert into @TransactionValues values ('AAM',-1)
insert into @TransactionValues values ('DN',-1)

insert into @TransactionValues values ('PI',-1)
insert into @TransactionValues values ('PU',1)

insert into @TransactionValues values ('IF',-1)
insert into @TransactionValues values ('FW',-1)
insert into @TransactionValues values ('BI',-1)
insert into @TransactionValues values ('BR',1) --Added 2026-09-15 : Franchise Return puts stock back into the issuing location
update dbo.StockItemDetails
set QuantityInHand = QuantityInHand + (@Quantity * (select value from @TransactionValues where TransactionType=@TransactionType)),
AveragePrice=@AveragePrice
where PropertyID=@PropertyID and LocationId =@locationId and StockItemHeaderID=@StockItemID

GO

