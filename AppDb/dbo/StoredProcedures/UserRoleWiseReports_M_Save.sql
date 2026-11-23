-- =============================================
-- Author:		chiraj
-- Create date: 2020-09-3
-- Description:	<UserWiseReportsSave>
-- =============================================
CREATE PROCEDURE [dbo].[UserRoleWiseReports_M_Save]
@SelectedUserRoleWiseReports NVARCHAR(MAX),
@UserRoleId INT,
@CreatedUserId INT,
@Operation CHAR,
@PropertyId INT

AS
BEGIN
	IF @Operation = 'I'
	BEGIN
	  
		DELETE FROM UserWiseReportAccess WHERE RoleId = @UserRoleId

		INSERT INTO UserWiseReportAccess(ReportId,RoleId, CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime)
		SELECT ReportId,@UserRoleId,@CreatedUserId, GETDATE(),@CreatedUserId, GETDATE()
		FROM OPENJSON(@SelectedUserRoleWiseReports)
		WITH 
		(
			ReportId NVARCHAR(50) '$.ReportId'
		)
	END

END

GO

