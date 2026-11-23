CREATE PROCEDURE [dbo].[SP_GetNewWorkValue] --2,3
	-- Add the parameters for the stored procedure here
	@BOQId INT,
	@WorkId INT

AS


BEGIN

		SELECT SUM(dbo.BOQRateanalysisAllocationHeaders.RateQtyInWork * dbo.BOQRateanalysisAllocationHeaders.TotalPrice) AS 'WorkValue'
		FROM dbo.BOQRateanalysisAllocationHeaders
		WHERE (dbo.BOQRateanalysisAllocationHeaders.BOQID = @BOQId) AND (dbo.BOQRateanalysisAllocationHeaders.WorkID) = @WorkId
END

GO

