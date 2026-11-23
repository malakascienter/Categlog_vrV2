
CREATE VIEW dbo.getALLrateAnalysisDetails2
AS
SELECT        dbo.RateAnalysisDetails.RateAnalysisHeaderID, dbo.RateAnalysisDetails.ItemHeaderID, dbo.LaborTypeMasterFiles.Description, dbo.LaborTypeMasterFiles.price, dbo.RateAnalysisDetails.SequNo, 
                         dbo.RateAnalysisDetails.Quantity, dbo.RateAnalysisDetails.OverheadCostVal, dbo.RateAnalysisDetails.isDisRate, dbo.RateAnalysisDetails.DisValue, dbo.RateAnalysisDetails.ProfitMarginVal, dbo.RateAnalysisDetails.Id
FROM            dbo.LaborTypeMasterFiles INNER JOIN
                         dbo.RateAnalysisDetails ON dbo.LaborTypeMasterFiles.Id = dbo.RateAnalysisDetails.ItemHeaderID
WHERE        (dbo.RateAnalysisDetails.RateAnalysisHeaderID = 3)

GO

