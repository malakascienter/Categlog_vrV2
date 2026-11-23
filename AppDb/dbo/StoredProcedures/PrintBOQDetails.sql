-- [dbo].[PrintBOQDetails] 67,1
CREATE  procedure [dbo].[PrintBOQDetails] (@BOQID int, @showMatirials bit )
as
declare @SECMAX INT

select @SECMAX=MAX(r.ID)
from [dbo].[BOQMainWorkAllocations] r
INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
where BOQID=@BOQID



select * from (





select  p.ProjectName,r.BOQID,r.ID SEC, 0 WID, 0 RID, r.Description, '' Unit , null Quantity , null Rate ,null Amount, 1 LineType 
from [dbo].[BOQMainWorkAllocations] r
INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
where BOQID=@BOQID
union all



Select p.ProjectName,r.BOQID, r.MAINWORKID SEC, r.ID WID, 0 RID , r.Description , 'NOS' Unit ,  r.Quantity , (r.Rate+r.SundryAmount ), r.Quantity* (r.Rate+r.SundryAmount ) , 2 LineType
from [dbo].[BOQSubWorkAllocations] r
INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
Inner JOIN [dbo].[BOQRateanalysisAllocationHeaders] h on h.WorkID=r.Id
INNER JOIN BOQRateanalysisAllocationDetails as BRA on h.RateAnalysisID=BRA.RateID and B.Id=BRA.BOQID
where r.BOQID=@BOQID
group by p.ProjectName,r.BOQID,r.MAINWORKID,r.ID,r.Description,r.Quantity,r.Rate,r.SundryAmount

--union all
--select p.ProjectName,h.BOQID, d.MAINWORKID SEC, d.ID WID, h.RateAnalysisID RID , h.Description ,'NOS' Unit ,  h.RateQtyInWork Quantity , (h.totalprice ) Rate, 3 LineType 
--from [dbo].[BOQRateanalysisAllocationHeaders] h
--inner join [BOQSubWorkAllocations] d on d.ID= h.WorkID 
--INNER JOIN dbo.BOQHeaders B ON B.Id=h.BOQID
--INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
--INNER JOIN BOQRateanalysisAllocationDetails as BRA on h.RateAnalysisID=BRA.RateID and B.Id=BRA.BOQID
--where d.BOQID=@BOQID
--group by p.ProjectName,h.BOQID, d.MAINWORKID,d.ID,h.RateAnalysisID,h.Description,h.RateQtyInWork,h.totalprice 



--union all
--select p.ProjectName,r.BOQID, d.MAINWORKID SEC, h.WorkID WID, r.RateID RID , ih.Name Description, u.Name Unit, r.Quantity , r.UnitPrice Rate   , 4 LineType 
--from [dbo].[BOQRateanalysisAllocationDetails] r
--inner join [BOQRateanalysisAllocationHeaders] h on h.RateAnalysisID= r.RateID and h.BOQID= R.BOQID
--inner join [BOQSubWorkAllocations] d on h.WorkID= d.ID and d.BOQID= h.BOQID
--inner join StockItemHeaders ih on ih.[Id]= r.itemid 
--inner join Units u on r.Unit= u.Id
--INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
--INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
--where d.BOQID=@BOQID and @showMatirials= 1 AND r.ItemType='I'
--added by umesh 2019-03-12--
--UNION ALL

--select p.ProjectName,r.BOQID, d.MAINWORKID SEC, h.WorkID WID, r.RateID RID , lt.LabourName Description, u.LaborUnitName Unit, r.Quantity , r.UnitPrice Rate   , 4 LineType 
--from [dbo].[BOQRateanalysisAllocationDetails] r
--inner join [BOQRateanalysisAllocationHeaders] h on h.RateAnalysisID= r.RateID and h.BOQID= R.BOQID
--inner join [BOQSubWorkAllocations] d on h.WorkID= d.ID and d.BOQID= h.BOQID
--inner join dbo.LaborMasters ih on ih.[Id]= r.itemid 
--INNER JOIN dbo.LabourTypes lt ON lt.Id=ih.LaborTypeId
--inner join dbo.LaborUnits u on r.Unit= u.Id
--INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
--INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
--where d.BOQID=@BOQID and @showMatirials= 1 AND r.ItemType='L'

--UNION ALL
--SELECT DISTINCT p.ProjectName,r.BOQID, d.MAINWORKID SEC, h.WorkID WID, r.RateID RID ,'SundryValue' Description, u.Name Unit, d.Quantity , d.SundryAmount Rate   , 4 LineType 
--from [dbo].[BOQRateanalysisAllocationDetails] r
--inner join [BOQRateanalysisAllocationHeaders] h on h.RateAnalysisID= r.RateID and h.BOQID= R.BOQID
--inner join [BOQSubWorkAllocations] d on h.WorkID= d.ID and d.BOQID= h.BOQID
--inner join StockItemHeaders ih on ih.[Id]= r.itemid 
--inner join Units u on d.UnitID= u.Id
--INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
--INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
--where d.BOQID=@BOQID and @showMatirials= 1 

--UNION ALL
--SELECT p.ProjectName,CPS.BOQID,BSA.MainWorkID AS SEC,BRA.WorkID WID,BRD.RateID RID,c.Name  + '/'+de.Name AS Description,'NOS'AS Unit,1 AS Quantity,CPS.Cost*Percentage/100 as TotalCost,5 LineType from BOQSubWorkAllocations as BSA 
--inner join BOQRateanalysisAllocationHeaders as BRA on BSA.BOQID=BRA.BOQID and BRA.WorkID=BSA.Id
--inner join dbo.BOQRateanalysisAllocationDetails BRD on BRD.BOQID=BRA.BOQID and BRA.RateanalysisID=BRD.RateID
--inner join dbo.BOQHeaders B ON B.Id=BSA.BOQID inner join CostProvisionSnapShot as CPS on CPS.RateHeaderId=BRD.RateId and CPS.BOQID=BRD.BOQID
--INNER JOIN dbo.Categories AS c ON c.Id= CPS.CategoryId 
--INNER JOIN dbo.Departments AS de ON de.Id= BSA.DepartmentID
--WHERE BRA.BOQID=@BOQID AND BRD.ItemType IN('I','P') GROUP BY BSA.DepartmentID,de.Name,c.Name,BRA.WorkID,p.ProjectName,BRD.RateID,BSA.MainWorkID,CPS.RateHeaderId,CPS.Cost,CPS.CategoryId,CPS.Percentage,CPS.BOQID
--union all

--Select p.ProjectName,r.BOQID,@SECMAX+1 SEC,0 WID,0 RID, 'Total' as Description,'NOS',0 as Quantity, sum(r.Rate+r.SundryAmount),4 LineType 
--from [dbo].[BOQSubWorkAllocations] r
--INNER JOIN dbo.BOQHeaders B ON B.Id=r.BOQID
--INNER JOIN dbo.ProjectDetails P ON  P.Id=b.ProjectID
--where BOQID=@BOQID
--group by p.ProjectName,r.BOQID	

) x
order by SEC,WID,RID,LineType

GO

