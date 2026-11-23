CREATE PROCEDURE [dbo].[SP_GetCompletedValue] --2
	-- Add the parameters for the stored procedure here
	@WorkId INT


AS


BEGIN
	--	dbo.WorkHeaders.Id, dbo.RateAnalysisDetails.UnitPrice, dbo.RateAnalysisDetails.Quantity,dbo.WorkDetails.Quantity,
			SELECT SUM((dbo.RateAnalysisDetails.UnitPrice * dbo.RateAnalysisDetails.Quantity) * dbo.WorkDetails.Quantity) as 'CompletedValue'

FROM	dbo.WorkHeaders inner join dbo.WorkDetails on
		dbo.WorkHeaders.Id = dbo.WorkDetails.WorkID inner join 
		dbo.RateAnalysisDetails on 
			dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisDetails.RateAnalysisHeaderID
WHERE	(dbo.WorkDetails.WorkID = @WorkId)
END

GO

