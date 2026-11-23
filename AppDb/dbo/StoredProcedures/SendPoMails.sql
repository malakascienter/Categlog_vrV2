
--[dbo].[SendPoMails] 'thiwankas@scienter.lk','Test mail','<h1>Test mail2 by thivanka</h1>'

CREATE PROCEDURE [dbo].[SendPoMails]
    @MailSet VARCHAR(MAX),
    @Subject VARCHAR(MAX),
    @Body VARCHAR(MAX)
AS
BEGIN
    DECLARE @MailSubject VARCHAR(50) = 'Test Mail Subject',
            @tableHTML VARCHAR(MAX),@x INT;



		  EXEC msdb.dbo.sp_send_dbmail @profile_name = 'ActivitySheets',
                                 @recipients = @MailSet,
                                 @subject = @Subject,
                                 @body = @Body,
                                 @body_format = 'HTML';
	
	
    
END;

GO

