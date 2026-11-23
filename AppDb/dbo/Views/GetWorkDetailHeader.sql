
CREATE VIEW dbo.GetWorkDetailHeader
AS
SELECT        TOP (100) PERCENT Id, Description, WorkHeaderStatus
FROM            dbo.WorkHeaders
ORDER BY Description DESC

GO

