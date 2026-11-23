--GetCostProvisions 44
CREATE procedure [dbo].[GetCostProvisions] @RateHeaderId INT
as 
begin

select c.Name as CategoryName,c.Id as CategoryId,p.RateHeaderId as RateHeaderId,sum(p.Cost) as Cost,sum(p.Cost*p.OHPercentage/100) as CostOH from costprovisions as p  inner join categories as c on p.CategoryId=c.Id where RateHeaderId=@RateHeaderId group by p.RateHeaderId,c.Id,c.Name 

end

GO

