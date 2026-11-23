-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Reports_M_SelectByUserRoleId]
	@UserRoleId INT,
	@PropertyId	INT
AS
BEGIN	
	SET NOCOUNT ON;

   SELECT Id,UserId,ReportId
	FROM UserWiseReportAccess 	
	WHERE RoleId=@UserRoleId
	END

GO

