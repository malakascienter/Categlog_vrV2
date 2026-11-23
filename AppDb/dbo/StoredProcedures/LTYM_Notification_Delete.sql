
CREATE   PROCEDURE [dbo].[LTYM_Notification_Delete]
    @MemberId INT,
    @Id       BIGINT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYM_MemberNotifications
    SET    IsDeleted = 1
    WHERE  Id = @Id AND MemberId = @MemberId AND IsDeleted = 0;
END

GO

