
CREATE   PROCEDURE [dbo].[LTYM_Notifications_UnreadCount]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*)
    FROM   dbo.LTYM_MemberNotifications
    WHERE  MemberId = @MemberId AND IsDeleted = 0 AND IsRead = 0;
END

GO

