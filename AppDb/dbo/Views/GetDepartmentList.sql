
CREATE VIEW dbo.GetDepartmentList
AS
SELECT        TOP (100) PERCENT Id, Name
FROM            dbo.Departments
ORDER BY Name DESC

GO

