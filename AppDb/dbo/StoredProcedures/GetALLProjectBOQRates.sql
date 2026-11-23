
CREATE Procedure [dbo].[GetALLProjectBOQRates]
As
BEGIN

select BRA.Id,BRA.BOQID,BRA.WorkID,BRA.RateQtyInWork,BRA.RateAnalysisID,
CONCAT(PD.ProjectName,'/',BH.BOQCode,'/',BRA.Description) as Description,
BRA.TotalPrice,BRA.Status,BRA.CreateUserId,BRA.CreateDate,BRA.AllocationUserID
from BOQHeaders  as BH
inner join ProjectDetails as PD on BH.ProjectID=PD.Id
inner join BOQRateanalysisAllocationHeaders as BRA on BRA.BOQID=BH.Id
group by   BRA.Id,BRA.BOQID,BRA.WorkID,BRA.RateQtyInWork,BRA.RateAnalysisID,
BRA.TotalPrice,BRA.Status,BRA.CreateUserId,BRA.CreateDate,BRA.AllocationUserID,PD.ProjectName,BH.BOQCode,BRA.Description

END

GO

