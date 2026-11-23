
CREATE   PROCEDURE [dbo].[LTYM_Notifications_MarkAllRead]
    @MemberId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYM_MemberNotifications
    SET    IsRead = 1
    WHERE  MemberId = @MemberId AND IsDeleted = 0 AND IsRead = 0;
END

GO

