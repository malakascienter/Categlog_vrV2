--[dbo].[SPP_loadWorkHeaderList] 12,14
CREATE PROCEDURE [dbo].[SPP_loadWorkHeaderList] 
	@boqid varchar(max), @mainWorkId int
AS
BEGIN
	SELECT      BSW.Id, BSW.BOQID, BSW.Description, BSW.DepartmentID, DEPT.Name, WH.Id AS WorkHeaderID, WH.Description AS WordHeaderDes, WH.WorkCode, BSW.Quantity, BSW.Rate, BSW.SeqNo
FROM            dbo.BOQSubWorkAllocations AS BSW INNER JOIN
                         dbo.WorkHeaders AS WH ON BSW.WorkID = WH.Id INNER JOIN
                         dbo.Departments AS DEPT ON BSW.DepartmentID = DEPT.Id
WHERE        (BSW.MainWorkID = @mainWorkId and BSW.BOQID = @boqid)
ORDER BY BSW.SeqNo DESC
END

GO

