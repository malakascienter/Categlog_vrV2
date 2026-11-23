--[dbo].[SendPoMails] 'thilinif@scienter.lk','Test mail','<h1>Test mail2 by thilini</h1>'
--go
--===================================
--Last Modified by      : Nivesh
--Last Modified date    : 2026-01-08
--===================================
CREATE PROCEDURE [dbo].[SendReuestMail]
    @MailSet VARCHAR(MAX),
    @Subject VARCHAR(MAX),
    @Body VARCHAR(MAX),
	@TxnType INT =0,
	@Attachments NVARCHAR(MAX) = null,
	@b_format VARCHAR(50) = 'HTML',
    @Profile_name sysname ='InventoryMail',
    @mailitem_id  INT = NULL OUTPUT
AS
BEGIN
    DECLARE @MailSubject VARCHAR(50) = 'Test Mail Subject',
            @tableHTML VARCHAR(MAX),@x INT;
	
	--Added by Isuru 2026-05-19 to fix mail server stop issue when using
	DECLARE @mail_status VARCHAR(20);

	DECLARE @tbl TABLE (Status VARCHAR(20));

	INSERT INTO @tbl
	EXEC msdb.dbo.sysmail_help_status_sp;

	SELECT @mail_status = Status FROM @tbl;

	IF (@mail_status <> 'STARTED')
	BEGIN
		EXEC msdb.dbo.sysmail_start_sp;
	END
	--End

	EXEC msdb.dbo.sp_send_dbmail @profile_name = @Profile_name,
                            @recipients = @MailSet,
                            @subject = @Subject,
                            @body = @Body,
                            @body_format = @b_format,
							@file_attachments = @Attachments,
                            @mailitem_id = @mailitem_id OUTPUT;
      
END;

GO

