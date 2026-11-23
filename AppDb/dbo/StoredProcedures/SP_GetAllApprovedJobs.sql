
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--[dbo].[SP_GetAllApprovedJobs] 3
CREATE PROCEDURE [dbo].[SP_GetAllApprovedJobs] 
@ProjectID INT 
AS
BEGIN
	SELECT JH.*,D.Name AS DepartmentName,L.Name AS LocationName FROM dbo.JobHeaders JH INNER JOIN dbo.Departments D ON D.Id=JH.DepartmentID INNER JOIN dbo.Locations L ON L.Id=JH.LocationID WHERE ProjectID=@ProjectID AND Approved=1 AND Complete=0 AND [Status]='P'
END

GO

