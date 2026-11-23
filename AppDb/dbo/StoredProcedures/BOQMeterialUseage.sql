
CREATE PROCEDURE BOQMeterialUseage (@BOQID  int , @stockHeaderID int)
as

select d.Description ,ih.ID,ih.StockItemCode, ih.Name Description, u.Name Unit, r.UnitPrice Rate , sum(r.Quantity ) Quantity, r.UnitPrice  * sum(r.Quantity )  Amount 
from [dbo].[BOQRateanalysisAllocationDetails] r
inner join [BOQRateanalysisAllocationHeaders] h on h.RateAnalysisID= r.RateID and h.BOQID= R.BOQID
inner join [BOQSubWorkAllocations] d on h.WorkID= d.ID and d.BOQID= h.BOQID
inner join StockItemHeaders ih on ih.[Id]= r.itemid 
inner join Units u on r.Unit= u.Id
where d.BOQID=@BOQID  and ih.Id =@stockHeaderID
group by ih.ID,ih.StockItemCode, ih.Name , u.Name , r.UnitPrice   ,d.Description

GO

