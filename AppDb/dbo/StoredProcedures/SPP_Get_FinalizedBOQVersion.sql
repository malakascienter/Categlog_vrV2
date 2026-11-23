CREATE Procedure [dbo].[SPP_Get_FinalizedBOQVersion] @BOQID int

AS
BEGIN
Select Id,ProjectID,BOQDate,Approve,CurrentVersion,isDisRate,DisValue,SundryValue,BOQCode,BOQName,BOQStatus,VersionNo,Finalized,MainBoqId from BOQHeaders Where MainBoqId=@BOQID AND Finalized=1 AND Approve=1


END

GO

