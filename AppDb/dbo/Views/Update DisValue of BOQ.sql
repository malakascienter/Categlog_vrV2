
CREATE VIEW dbo.[Update DisValue of BOQ]
AS
SELECT        dbo.BOQSubWorkAllocations.WorkID, dbo.WorkDetails.RateAnalysisHeaderID, dbo.BOQHeaders.Id AS BoqID, dbo.RateAnalysisHeaders.Id AS HeaderID, dbo.RateAnalysisDetails.ProfitMarginVal, 
                         dbo.RateAnalysisDetails.OverheadCostVal, dbo.RateAnalysisDetails.DisValue, dbo.RateAnalysisDetails.Quantity
FROM            dbo.BOQHeaders INNER JOIN
                         dbo.BOQSubWorkAllocations ON dbo.BOQHeaders.Id = dbo.BOQSubWorkAllocations.BOQID INNER JOIN
                         dbo.WorkDetails ON dbo.BOQSubWorkAllocations.WorkID = dbo.WorkDetails.WorkID INNER JOIN
                         dbo.RateAnalysisHeaders ON dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisHeaders.Id INNER JOIN
                         dbo.RateAnalysisDetails ON dbo.RateAnalysisHeaders.Id = dbo.RateAnalysisDetails.RateAnalysisHeaderID
WHERE        (dbo.BOQHeaders.Id = 16) AND (dbo.BOQSubWorkAllocations.WorkID = 12) AND (dbo.WorkDetails.RateAnalysisHeaderID = 7)

GO

