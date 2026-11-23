CREATE PROCEDURE [dbo].[SP_GetWorkRegistryDetails] --3,1
	-- Add the parameters for the stored procedure here
	--@ProjectID INT,
	--@BOQId INT

AS


BEGIN
	SELECT		 distinct dbo.ProjectDetails.Id as 'ProjectId', dbo.ProjectDetails.ProjectName, dbo.BOQHeaders.Id as 'BOQId', DBO.BOQHeaders.BOQCode,
	dbo.BOQMainWorkAllocations.Id as 'MainWorkId', dbo.BOQMainWorkAllocations.Description 'DescriptionMain',
	dbo.BOQMainWorkAllocations.Id as 'MainWorkID', dbo.BOQSubWorkAllocations.Id as 'WorkId', dbo.BOQSubWorkAllocations.Description as 'DescriptionSub',
	dbo.WorkDoneRegistries.AssessedValue, dbo.WorkDoneRegistries.BilledValue, dbo.WorkDoneRegistries.WorkValue,dbo.WorkDoneRegistries.Value

FROM		dbo.ProjectDetails INNER JOIN dbo.BOQHeaders ON 
	dbo.ProjectDetails.Id = dbo.BOQHeaders.ProjectID INNER JOIN dbo.BOQMainWorkAllocations ON
	dbo.BOQHeaders.Id = dbo.BOQMainWorkAllocations.BOQID INNER JOIN dbo.BOQSubWorkAllocations ON 
	dbo.BOQMainWorkAllocations.Id = dbo.BOQSubWorkAllocations.MainWorkID INNER JOIN dbo.WorkDoneRegistries ON
	dbo.ProjectDetails.Id = dbo.WorkDoneRegistries.ProjectID


--WHERE		(dbo.ProjectDetails.Id = @ProjectID) and (dbo.BOQHeaders.Id = @BOQId) 
END

GO

