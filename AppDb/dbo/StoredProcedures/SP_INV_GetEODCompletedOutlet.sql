
create PROCEDURE [dbo].[SP_INV_GetEODCompletedOutlet]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT * FROM INV_EODNotificationDetails WHERE IsMailSend = 0


END

GO

