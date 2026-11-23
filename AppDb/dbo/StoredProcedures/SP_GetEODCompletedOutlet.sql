
CREATE PROCEDURE SP_GetEODCompletedOutlet
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT * FROM EODNotificationDetails WHERE IsMailSend = 0


END

GO

