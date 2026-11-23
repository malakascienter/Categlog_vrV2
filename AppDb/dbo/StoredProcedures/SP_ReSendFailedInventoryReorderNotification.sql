-- =============================================
-- Author:		Nivesh
-- Create date: 2026-01-08
-- Description:	Resend Failed Message
-- =============================================
create     PROCEDURE [dbo].[SP_ReSendFailedInventoryReorderNotification]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
---- Email Re Send Start-------------
    DECLARE 
        @EmailQueueID INT,
        @Email NVARCHAR(200),
        @Subject NVARCHAR(300),
        @Body NVARCHAR(MAX),
        @mailitem_id INT,
        @b_format VARCHAR(50),
        @Profile_name SYSNAME,
        @MailStatus NVARCHAR(10);

  -----UPDATE MAIL LOG START---------
    UPDATE IRN
    SET 
        IRN.IsSent = CASE WHEN SA.sent_status = 'sent' THEN 1 ELSE 0 END,
        IRN.SentDate = CASE WHEN SA.sent_status = 'sent' THEN sa.sent_date ELSE NULL END,
        IRN.NotificationStatus = CASE WHEN SA.sent_status = 'sent' THEN 'C' ELSE 'P' END
    FROM msdb.dbo.sysmail_allitems sa
    INNER JOIN [dbo].[InventoryReorderNotificationLog] IRN on IRN.NotificationID = sa.mailitem_id
  -----UPDATE MAIL LOG END---------
  
  -- Pick 50 pending unsent mails in FIFO order0   0000
    DECLARE email_cursor CURSOR FAST_FORWARD FOR
    SELECT TOP 50 
        IRN.NotificationID,
        SA.recipients,
        SA.subject,
        SA.body,
        SA.body_format,
        SP.name
    FROM (
        SELECT 
            NotificationID,
            IsSent,
            SendRequestDate
        FROM
        [dbo].[InventoryReorderNotificationLog]
        GROUP BY NotificationID,IsSent,SendRequestDate
    ) IRN 
    INNER JOIN msdb.dbo.sysmail_allitems sa on IRN.NotificationID = sa.mailitem_id
    INNER JOIN [msdb].[dbo].[sysmail_profile] SP ON SP.profile_id = SA.profile_id
    WHERE ISNULL(IRN.IsSent, 0) = 0
    ORDER BY IRN.SendRequestDate DESC;
     
    OPEN email_cursor;
    FETCH NEXT FROM email_cursor INTO 
        @EmailQueueID,
        @Email,
        @Subject,
        @Body,
        @b_format,
        @Profile_name;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        BEGIN TRY
            SET @b_format = ISNULL(@b_format, 'HTML');
            SET @Profile_name = ISNULL(@Profile_name, '');

            EXEC SendReuestMail 
                @MailSet = @Email,
                @Subject = @Subject,
                @Body = @Body,
                @mailitem_id = @mailitem_id OUTPUT;
            
            WAITFOR DELAY '00:00:10'; -- prevent throttling
            
            -- Get mail status from sysmail
            SELECT @MailStatus = sent_status
            FROM msdb.dbo.sysmail_allitems
            WHERE mailitem_id = @mailitem_id;

            UPDATE [dbo].[InventoryReorderNotificationLog]
            SET 
                IsSent = CASE WHEN @MailStatus = 'sent' THEN 1 ELSE 0 END,
                SentDate = CASE WHEN @MailStatus = 'sent' THEN GETDATE() ELSE NULL END,
                NotificationID = @mailitem_id,
                NotificationStatus = CASE WHEN @MailStatus = 'sent' THEN 'C' ELSE 'P' END
            WHERE Id = @EmailQueueID;

            IF @MailStatus <> 'sent'
            BEGIN
                INSERT INTO dbo.EmailErrorLog (EmailQueueID, Email, ErrorMessage, ErrorDate)
                VALUES (@EmailQueueID, @Email, 'Mail not sent or timed out', GETDATE());
            END
        END TRY
        BEGIN CATCH
            INSERT INTO dbo.EmailErrorLog (EmailQueueID, Email, ErrorMessage, ErrorDate)
            VALUES (@EmailQueueID, @Email, ERROR_MESSAGE(), GETDATE());
        END CATCH;

        

        FETCH NEXT FROM email_cursor INTO 
            @EmailQueueID, @Email, @Subject, @Body, @b_format, @Profile_name;
    END;

    CLOSE email_cursor;
    DEALLOCATE email_cursor;
---- Email Re Send End-------------

END

GO

