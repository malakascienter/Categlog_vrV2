/*  The member's own registered devices, for a "signed in on" list.

    The token itself is deliberately NOT returned. It is a credential for sending
    to that device, and a settings screen has no use for it.                     */
CREATE PROCEDURE dbo.LTYM_Devices_Select
    @MemberId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TokenId, Platform, DeviceName, AppVersion, LastSeenAt, CreatedDate
    FROM   dbo.LTYC_DeviceToken
    WHERE  MemberId = @MemberId AND IsActive = 1
    ORDER BY ISNULL(LastSeenAt, CreatedDate) DESC;
END

GO

