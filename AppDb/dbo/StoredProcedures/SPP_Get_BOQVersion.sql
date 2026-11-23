CREATE Procedure [dbo].[SPP_Get_BOQVersion] @BOQID int

AS
BEGIN
Select Id,ProjectID,BOQDate,Approve,CurrentVersion,isDisRate,DisValue,SundryValue,BOQCode,BOQName,BOQStatus,VersionNo,Finalized,MainBoqId,OHPmaterial,OHPlabour from BOQHeaders Where MainBoqId=@BOQID


END

GO

