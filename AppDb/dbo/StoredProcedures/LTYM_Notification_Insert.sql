
CREATE   PROCEDURE [dbo].[LTYM_Notification_Insert]
    @MemberId INT,
    @Title    NVARCHAR(200),
    @Body     NVARCHAR(MAX) = NULL,
    @Type     VARCHAR(20)   = 'SYSTEM'
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.LTYM_MemberNotifications (MemberId, Title, Body, Type)
    VALUES (@MemberId, @Title, @Body, @Type);

    SELECT SCOPE_IDENTITY() AS Id;
END

GO

