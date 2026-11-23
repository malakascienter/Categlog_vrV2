
CREATE VIEW dbo.ProjectList
AS
SELECT        dbo.ProjectDetails.Id AS 'ProjectID', dbo.ProjectDetails.ProjectName AS 'ProjectName ', dbo.Clients.Id AS 'ClientID', dbo.Clients.Name AS 'ClientName'
FROM            dbo.ProjectDetails INNER JOIN
                         dbo.Clients ON dbo.ProjectDetails.Id = dbo.Clients.Id

GO

