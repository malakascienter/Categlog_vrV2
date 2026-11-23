CREATE PROCEDURE [dbo].[SP_Select_ProjectDetailList]

AS
BEGIN
	SELECT  dbo.ProjectDetails.Id AS ProjectID, dbo.ProjectDetails.ProjectName AS [ProjectName], dbo.Customers.Id AS ClientID, dbo.Customers.CustomerName AS ClientName
	FROM    dbo.ProjectDetails INNER JOIN dbo.Customers ON dbo.ProjectDetails.ClientID = dbo.Customers.Id
END

GO

