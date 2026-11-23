-- =============================================
-- Author:		Chiraj
-- Create date: <2020-09-03
-- Description:	select reporrt Acces by user Id
-- =============================================
CREATE PROCEDURE [dbo].[UserWiseReports_M_SelectByUserId]
@UserId		Int
AS
BEGIN	
	SET NOCOUNT ON;

	SELECT Id,UserId,ReportId
	FROM UserWiseReportAccess 	
	WHERE UserId = @UserId	

END

GO

