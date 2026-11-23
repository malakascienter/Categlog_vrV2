
CREATE   PROCEDURE [dbo].[LTYM_Settings_Upsert]
    @MemberId           INT,
    @Language           VARCHAR(10),
    @EmailNotifications BIT,
    @SmsNotifications   BIT,
    @PromoMessages      BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberSettings WHERE MemberId = @MemberId)
        UPDATE dbo.LTYM_MemberSettings
        SET    Language           = @Language,
               EmailNotifications = @EmailNotifications,
               SmsNotifications   = @SmsNotifications,
               PromoMessages      = @PromoMessages,
               UpdatedAt          = SYSUTCDATETIME()
        WHERE  MemberId           = @MemberId;
    ELSE
        INSERT INTO dbo.LTYM_MemberSettings (MemberId, Language, EmailNotifications, SmsNotifications, PromoMessages)
        VALUES (@MemberId, @Language, @EmailNotifications, @SmsNotifications, @PromoMessages);
END

GO

