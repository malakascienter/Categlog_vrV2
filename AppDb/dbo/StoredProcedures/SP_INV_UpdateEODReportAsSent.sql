CREATE PROCEDURE [dbo].[SP_INV_UpdateEODReportAsSent] 
@EodJson VARCHAR(MAX)
AS
BEGIN


	UPDATE INV_EODNotificationDetails
	SET IsMailSend = 1
	WHERE Id = JSON_VALUE(@EodJson, '$.Id')

END

GO

