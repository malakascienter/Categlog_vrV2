

--[dbo].[SPP_Get_BOQVersionForBOQ] 13
CREATE Procedure [dbo].[SPP_Get_BOQVersionForBOQ] @BOQID int

AS
BEGIN



Select Id,ProjectID,BOQDate,Approve,CurrentVersion,isDisRate,DisValue,SundryValue,BOQCode,BOQName,BOQStatus,VersionNo,Finalized,MainBoqId,OHPmaterial,OHPlabour from BOQHeaders Where (MainBoqId=@BOQID AND Finalized=1 AND Approve=1) OR (MainBoqId=@BOQID AND Finalized=0 AND Approve=0)


END

GO

