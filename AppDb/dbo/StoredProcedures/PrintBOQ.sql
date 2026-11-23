

CREATE PROCEDURE PrintBOQ (@BOQID int, @showMatirials bit )
as


select * from (
select  BOQID,ID SEC, 0 WID, 0 RID, Description, '' Unit , null Quantity , null Rate , 1 LineType 
from [dbo].[BOQMainWorkAllocations]
where BOQID=@BOQID
union all
Select BOQID, MAINWORKID SEC, ID WID, 0 RID , Description , 'NOS' Unit ,  Quantity , Rate   , 2 LineType 
from [dbo].[BOQSubWorkAllocations]
where BOQID=@BOQID
union all
select h.BOQID, d.MAINWORKID SEC, h.ID WID, h.RateAnalysisID RID , h.Description ,'NOS' Unit ,  h.RateQtyInWork Quantity , h.totalprice Rate   , 3 LineType 
from [dbo].[BOQRateanalysisAllocationHeaders] h
inner join [BOQSubWorkAllocations] d on d.WorkID= h.ID 
where d.BOQID=@BOQID
union all
select r.BOQID, d.MAINWORKID SEC, r.ID WID, r.RateID RID , ih.Name Description, u.Name Unit, r.Quantity , r.UnitPrice Rate   , 4 LineType 
from [dbo].[BOQRateanalysisAllocationDetails] r
inner join [BOQSubWorkAllocations] d on d.WorkID= r.ID 
inner join StockItemHeaders ih on ih.[Id]= r.itemid 
inner join Units u on r.Unit= u.Id
where d.BOQID=@BOQID and @showMatirials= 1

) x
 order by SEC,WID, RID,LineType


-- select * from [BOQRateanalysisAllocationDetails]

GO

