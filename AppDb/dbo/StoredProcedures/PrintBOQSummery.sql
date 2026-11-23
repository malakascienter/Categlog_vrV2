--[PrintBOQSummery] 67 
CREATE procedure [dbo].[PrintBOQSummery] (@BOQID int )
as



select  p.ProjectName,se.BOQID,se.ID SEC, se.Description , sum(wo.Quantity * wo.Rate+SundryAmount) Amount, 1 SEQ into #TEMPBB
from [dbo].[BOQMainWorkAllocations] se
inner join [dbo].[BOQSubWorkAllocations] wo on se.BOQID= wo.BOQID and se.Id= wo.MainWorkID
INNER JOIN dbo.BOQHeaders B ON B.Id=se.BOQID
INNER JOIN dbo.ProjectDetails p ON p.Id=B.ProjectID

where se.BOQID=@BOQID
Group by se.BOQID,se.ID , se.Description, p.ProjectName   

select * from (

select TT.ProjectName,TT.BOQID,TT.SEC,TT.Description,(TT.Amount) AS Amount,TT.SEQ,Sum(BRD.OverHeadCostVal+BRD.ProfitMarginVal) as OverHeadCostVal,Sum(BRD.OHCPercentage) as OHCPercentage,
 MaterialCost=SUM(case when BRD.ItemType='I' then BRD.UnitPrice*BRD.Quantity Else 0 End) ,
LabourCost=SUM(case when BRD.ItemType='L'  then BRD.UnitPrice*BRD.Quantity Else 0 End)
from #TEMPBB as TT inner join BOQSubWorkAllocations as SWD on TT.SEC=SWD.MainWorkID
inner join WorkDetails as WD  on SWD.Id=WD.WorkId
inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID
inner join BOQRateanalysisAllocationDetails as BRD on BRD.RateID= BRA.RateAnalysisID and BRD.BOQID=TT.BOQID
Group by  TT.ProjectName,TT.BOQID,TT.SEC,TT.Description,TT.Amount,TT.SEQ


--union all 

--select  p.ProjectName,se.BOQID,999, 'Sub Total', sum(wo.Quantity * wo.Rate +SundryAmount) Amount,2 SEQ,0 as OverHeadCostVal,0 as OHCPercentage,0 as MaterialCost,0 as LabourCost
--from [dbo].[BOQMainWorkAllocations] se
--inner join [dbo].[BOQSubWorkAllocations] wo on se.BOQID= wo.BOQID and se.Id= wo.MainWorkID
--INNER JOIN dbo.BOQHeaders B ON B.Id=se.BOQID
--INNER JOIN dbo.ProjectDetails p ON p.Id=B.ProjectID
--where se.BOQID=@BOQID
--Group by se.BOQID, p.ProjectName

--union all 


--select  p.ProjectName,se.BOQID,999, 'Discounts', sum(0*-1) Amount ,3 SEQ
--from [dbo].[BOQMainWorkAllocations] se
--inner join [dbo].[BOQSubWorkAllocations] wo on se.BOQID= wo.BOQID and se.Id= wo.MainWorkID
--INNER JOIN dbo.ProjectDetails p ON p.Id=se.BOQID
--where se.BOQID=@BOQID
--Group by se.BOQID, p.ProjectName


 

--select p.ProjectName,MW.BOQID,999, 'Discounts', sum((((Gross- Discount) - Mw.DiscountValue ) * MW.DiscountPercentage /100) + Mw.DiscountValue + discount)*-1 Amount ,3 SEQ,0 as OverHeadCostVal,0 as OHCPercentage,0 as MaterialCost,0 as LabourCost from (
--select Sw.MainWorkID, sum(rh.Gross- rh.Discount) Gross, sum(((((rh.Gross - rh.Discount) * sw.Quantity ) - DiscountValue) *  DiscountPercentage /100) +DiscountValue + Discount) Discount
--from (
--select RH.WorkID , sum(RateQtyInWork * AfterDiscount) Gross , sum((((RateQtyInWork * AfterDiscount) - DiscountValue ) *  DiscountPercentage/100) + DiscountValue)+ sum(Discount) Discount  from (
--select rd.RateID,sum((rd.unitprice * rd.Quantity)) Gross,sum(round((((rd.unitprice * rd.Quantity)  - rd.DiscountValue) * DiscountPercentage /100) ,2)+ rd.DiscountValue) Discount, sum((rd.unitprice * rd.Quantity)  - round(((rd.unitprice * rd.Quantity)  - rd.DiscountValue) * DiscountPercentage /100,2) - rd.DiscountValue)  AfterDiscount
--from [dbo].[BOQRateanalysisAllocationDetails] rd 
--where rd.BOQID= @BOQID 
--group by rd.RateID) RA
--inner join [BOQRateanalysisAllocationHeaders] rh on rh.RateAnalysisID= RA.RateID
--where rh.BOQID=@BOQID
--group by RH.WorkID  
--) RH inner join BOQSubWorkAllocations SW on sw.ID = RH.WorkID
--where SW.BOQID=@BOQID
--group by Sw.MainWorkID ) sw 
--inner join BOQMainWorkAllocations Mw on mw.ID = sw.MainWorkID
--INNER JOIN dbo.BOQHeaders B ON B.Id=Mw.BOQID
--INNER JOIN dbo.ProjectDetails p ON p.Id=B.ProjectID
--group by p.ProjectName,MW.BOQID
 

--union all

--select  p.ProjectName,se.BOQID,999, 'Tax Total', sum(BRT.UnitPrice*(BT.TaxRate/100)*BTH.RateQtyInWork*wo.Quantity)  ,4 SEQ,0 as OverHeadCostVal,0 as OHCPercentage,0 as MaterialCost,0 as LabourCost
--from [dbo].[BOQMainWorkAllocations] se
--inner join [dbo].[BOQSubWorkAllocations] wo on se.BOQID= wo.BOQID and se.Id= wo.MainWorkID
--INNER JOIN dbo.BOQHeaders B ON B.Id=se.BOQID
--INNER JOIN dbo.ProjectDetails p ON p.Id=B.ProjectID
--INNER JOIN dbo.BOQRateanalysisAllocationHeaders BTH ON BTH.BOQID=se.BOQID
--INNER JOIN dbo.BOQRateanalysisAllocationDetails BRT ON BRT.BOQID=se.BOQID
--INNER JOIN dbo.BoqTaxes BT ON BT.BoqId=se.BOQID AND BT.ItemId=BRT.ItemID
--where se.BOQID=@BOQID
--Group by se.BOQID,p.ProjectName


) x
 order by SEC, SEQ

GO

