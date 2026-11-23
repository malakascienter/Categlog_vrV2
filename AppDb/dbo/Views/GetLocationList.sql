
CREATE VIEW dbo.GetLocationList
AS
SELECT        TOP (100) PERCENT Id, Name
FROM            dbo.Locations
ORDER BY Name DESC

GO

