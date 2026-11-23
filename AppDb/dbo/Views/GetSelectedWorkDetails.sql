
CREATE VIEW dbo.GetSelectedWorkDetails
AS
SELECT        dbo.WorkDetails.RateAnalysisHeaderID, dbo.WorkDetails.WorkID, dbo.WorkDetails.Id, dbo.RateAnalysisHeaders.RateCode, dbo.WorkDetails.Quantity, dbo.WorkDetails.Rate
FROM            dbo.WorkDetails INNER JOIN
                         dbo.RateAnalysisHeaders ON dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisHeaders.Id
WHERE        (dbo.WorkDetails.WorkID = 2)

GO

