


-- =============================================
-- Author:		Chiraj
-- ALTER date: 2018-10-10
-- Description:	Get Report Names
-- =============================================
--[dbo].[Report_Select_ReportNames][1]
CREATE PROCEDURE [dbo].[Report_Select_ReportNames_By_UserId]
	@UserId INT,
	@PropertyId	INT
AS
BEGIN	
	SET NOCOUNT ON;
	DECLARE @RoleId INT

	SELECT @RoleId=RoleId  from UserWiseRoles where   UserId=@UserId
	SELECT RD.ReportID,RD.DisplayName,RD.ReportName,RD.ReportCategory 
	FROM ReportDetails   AS RD 
	INNER JoIN [dbo].[UserWiseReportAccess] AS RA ON RA.ReportId=RD.ReportID 
	WHERE RD.Active=1 AND RA.RoleId=@RoleId
	ORDER BY RD.ReportID ASC
END

GO

