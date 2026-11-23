
-- GetCostProvisionSnapShot 274,109
CREATE procedure [dbo].[GetCostProvisionSnapShot] @RateHeaderId INT,@BoqId INT
as 
begin

select c.Name as CategoryName,p.BoqId as BoqId,c.Id as CategoryId,p.RateHeaderId as RateHeaderId,SUM(p.Cost) AS Cost,SUM(p.Cost *P.OHPercentage/100) as OHCost from CostProvisionSnapShot as p  inner join categories as c on p.CategoryId=c.Id where RateHeaderId=@RateHeaderId and BoqId=@BoqId group by p.RateHeaderId,c.Id,c.Name,p.BOQID



--select c.Name as CategoryName,c.Id as CategoryId,p.RateHeaderId as RateHeaderId,sum(p.Cost) as Cost from costprovisions as p  inner join categories as c on p.CategoryId=c.Id where RateHeaderId=@RateHeaderId group by p.RateHeaderId,c.Id,c.Name 


end

GO

