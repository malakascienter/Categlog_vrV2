
CREATE PROCEDURE [dbo].[SendPOSBackendMain]
    @MailSet VARCHAR(MAX),
    @Subject VARCHAR(MAX),
    @Body VARCHAR(MAX)
AS
BEGIN

		  EXEC msdb.dbo.sp_send_dbmail @profile_name = 'POSBackendMail',
                                 @recipients = @MailSet,
                                 @subject = @Subject,
                                 @body = @Body,
                                 @body_format = 'HTML';


	
	
         
END;

GO

