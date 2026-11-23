-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
CREATE PROCEDURE [dbo].[SPP_GetWorkDetail]
	@workId int
AS
BEGIN
	SELECT W.Id, R.RateCode, W.Quantity, w.Rate
	FROM dbo.WorkDetails as W
	inner join RateAnalysisHeaders as R on W.RateAnalysisHeaderID = R.Id 
	where W.WorkID = @workId
	ORDER BY W.RateAnalysisHeaderID DESC
END

GO

