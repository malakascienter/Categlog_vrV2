/*  Active devices for one member. The push send path.                           */
CREATE PROCEDURE dbo.LTYC_DeviceToken_SelectForMember
    @MemberId   int,
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TokenId, Platform, Token, AuthSecret, P256dhKey, DeviceName, LastSeenAt
    FROM   dbo.LTYC_DeviceToken
    WHERE  MemberId = @MemberId AND PropertyId = @PropertyId AND IsActive = 1
    ORDER BY ISNULL(LastSeenAt, CreatedDate) DESC;
END

GO

