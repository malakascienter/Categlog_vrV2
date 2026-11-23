
CREATE   PROCEDURE [dbo].[LTYM_Settings_Select]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MemberId, Language, EmailNotifications, SmsNotifications, PromoMessages
    FROM   dbo.LTYM_MemberSettings
    WHERE  MemberId = @MemberId;
END

GO

