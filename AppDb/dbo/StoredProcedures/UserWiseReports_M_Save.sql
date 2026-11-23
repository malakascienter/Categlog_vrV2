-- =============================================
-- Author:		chiraj
-- Create date: 2020-09-3
-- Description:	<UserWiseReportsSave>
-- =============================================
CREATE PROCEDURE [dbo].[UserWiseReports_M_Save]
@SelectedUserWiseReports NVARCHAR(MAX),
@UserId INT,
@CreatedUserId INT,
@Operation CHAR

AS
BEGIN
	IF @Operation = 'I'
	BEGIN
	  
		DELETE FROM UserWiseReportAccess WHERE UserId = @UserId

		INSERT INTO UserWiseReportAccess(UserId, ReportId, CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime)
		SELECT @UserId, ReportId,@CreatedUserId, GETDATE(),@CreatedUserId, GETDATE()
		FROM OPENJSON(@SelectedUserWiseReports)
		WITH 
		(
			ReportId NVARCHAR(50) '$.ReportId'
		)
	END

END

GO

