
CREATE VIEW dbo.GetRateCodes
AS
SELECT        TOP (100) PERCENT Id, Description
FROM            dbo.RateAnalysisHeaders
ORDER BY Description DESC

GO

