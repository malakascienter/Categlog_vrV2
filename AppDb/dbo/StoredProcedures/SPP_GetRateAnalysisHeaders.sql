
CREATE PROCEDURE SPP_GetRateAnalysisHeaders
	@RateAnalystHeaderID int
AS
BEGIN
	select * from RateAnalysisHeaders where Id = @RateAnalystHeaderID
END

GO

