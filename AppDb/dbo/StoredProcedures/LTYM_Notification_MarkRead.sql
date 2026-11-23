
CREATE   PROCEDURE [dbo].[LTYM_Notification_MarkRead]
    @MemberId INT,
    @Id       BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYM_MemberNotifications
    SET    IsRead = 1
    WHERE  Id = @Id AND MemberId = @MemberId AND IsRead = 0;
END

GO

