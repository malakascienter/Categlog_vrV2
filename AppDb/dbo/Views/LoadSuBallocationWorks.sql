
CREATE VIEW dbo.LoadSuBallocationWorks
AS
SELECT        TOP (100) PERCENT BSW.Id, BSW.BOQID, BSW.Description, BSW.DepartmentID, DEPT.Name, WH.Id AS WorkHeaderID, WH.Description AS WordHeaderDes, BSW.Quantity, BSW.Rate, BSW.SeqNo
FROM            dbo.BOQSubWorkAllocations AS BSW INNER JOIN
                         dbo.WorkHeaders AS WH ON BSW.WorkID = WH.Id INNER JOIN
                         dbo.Departments AS DEPT ON BSW.DepartmentID = DEPT.Id
WHERE        (BSW.MainWorkID = 1)
ORDER BY BSW.SeqNo DESC

GO

