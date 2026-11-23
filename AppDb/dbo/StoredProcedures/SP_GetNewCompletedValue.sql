CREATE PROCEDURE [dbo].[SP_GetNewCompletedValue] --2,2,3
	-- Add the parameters for the stored procedure here
	@ProjectId INT,
	@BOQId INT,
	@WorkId INT

AS


BEGIN

		SELECT SUM(dbo.WorkDoneRegistries.CompletedValue) AS 'CompletedValue'
		FROM dbo.WorkDoneRegistries
		WHERE (dbo.WorkDoneRegistries.ProjectID = @ProjectId) AND (dbo.WorkDoneRegistries.BOQID = @BOQId) AND (dbo.WorkDoneRegistries.WorkID) = @WorkId
END

GO

