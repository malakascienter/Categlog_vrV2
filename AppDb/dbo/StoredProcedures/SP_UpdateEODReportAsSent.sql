CREATE PROCEDURE [dbo].[SP_UpdateEODReportAsSent] 
@EodJson VARCHAR(MAX)
AS
BEGIN


	UPDATE EODNotificationDetails
	SET IsMailSend = 1
	WHERE Id = JSON_VALUE(@EodJson, '$.Id')

END

GO

