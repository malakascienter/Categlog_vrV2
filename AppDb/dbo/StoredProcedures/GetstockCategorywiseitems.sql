
-- GetstockCategorywiseitems 3
CREATE PROCEDURE GetstockCategorywiseitems
@CategoryId INT
as
Begin

select sth.id as Id,sth.name as Name,sd.AveragePrice From stockitemheaders sth 
inner join stockitemdetails sd on sth.id=sd.stockitemheaderid
where categoryID=@CategoryId

End

GO

