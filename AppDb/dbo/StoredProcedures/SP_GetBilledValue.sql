--[dbo].[SP_GetBilledValue] 3,2,2,4
CREATE PROCEDURE [dbo].[SP_GetBilledValue] --2,2,3
	-- Add the parameters for the stored procedure here
	@ProjectId INT,
	@BOQId INT,
	@MainWorkId INT,
	@WorkId INT

AS

BEGIN

		SELECT SUM(dbo.BillDetails.amount) AS 'Billed value'
		FROM dbo.BillHeaders INNER JOIN dbo.BillDetails ON
         dbo.BillHeaders.Id = dbo.BillDetails.BillID
		WHERE (dbo.BillHeaders.ProjectID = @ProjectId) AND (dbo.BillDetails.BOQID = @BOQId) AND (dbo.BillDetails.MainWorkID = @MainWorkId) AND (dbo.BillDetails.WokeID = @WorkId)

END

GO

