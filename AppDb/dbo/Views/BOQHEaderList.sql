
CREATE VIEW dbo.BOQHEaderList
AS
SELECT        dbo.BOQHeaders.Id AS 'BOQHeadersID', dbo.BOQHeaders.BOQCode, dbo.ProjectDetails.ProjectName, dbo.Clients.Name AS 'ClientsName'
FROM            dbo.Clients INNER JOIN
                         dbo.ProjectDetails ON dbo.Clients.Id = dbo.ProjectDetails.ClientID INNER JOIN
                         dbo.BOQHeaders ON dbo.ProjectDetails.Id = dbo.BOQHeaders.ProjectID

GO

