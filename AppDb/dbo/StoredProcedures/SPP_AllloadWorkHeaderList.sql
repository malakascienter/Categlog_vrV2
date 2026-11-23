CREATE PROCEDURE [dbo].[SPP_AllloadWorkHeaderList]
AS
BEGIN
	SELECT  DISTINCT  WH.Id, BSW.BOQID, BSW.Description, BSW.DepartmentID, DEPT.Name, WH.Id AS WorkHeaderID, WH.Description AS WordHeaderDes, 0 AS Quantity, 0 AS Rate, BSW.SeqNo,WH.WorkCode
FROM            dbo.BOQSubWorkAllocations AS BSW INNER JOIN
                         dbo.WorkHeaders AS WH ON BSW.WorkID = WH.Id INNER JOIN
                         dbo.Departments AS DEPT ON BSW.DepartmentID = DEPT.Id
ORDER BY BSW.SeqNo DESC

--	SELECT    WH.Id, BSW.BOQID, BSW.Description, BSW.DepartmentID, DEPT.Name, WH.Id AS WorkHeaderID, WH.Description AS WordHeaderDes, BSW.Quantity, BSW.Rate, BSW.SeqNo,WH.WorkCode
--FROM            dbo.BOQSubWorkAllocations AS BSW INNER JOIN
--                         dbo.WorkHeaders AS WH ON BSW.WorkID = WH.Id INNER JOIN
--                         dbo.Departments AS DEPT ON BSW.DepartmentID = DEPT.Id
--ORDER BY BSW.SeqNo DESC
END

GO

