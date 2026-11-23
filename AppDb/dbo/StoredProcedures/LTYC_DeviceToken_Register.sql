/*  Register or refresh one device.

    A token string identifies a device installation globally, so re-registering
    updates the existing row rather than inserting a duplicate. Three cases, and
    the differences matter:

      - Same token, same member: a refresh. Update LastSeenAt and revive it.
      - Same token, DIFFERENT member: the device was handed over or a second
        person signed in on it. The row MOVES to the new member. Leaving it
        would send the new owner's notifications to the previous member.
      - Reviving a token deactivated by provider rejections resets FailureCount.
        Otherwise a device that failed five times stays one failure from being
        switched off again forever.                                              */
CREATE PROCEDURE dbo.LTYC_DeviceToken_Register
    @MemberId   int,
    @PropertyId int,
    @Platform   varchar(10),
    @Token      nvarchar(500),
    @AuthSecret nvarchar(200) = NULL,
    @P256dhKey  nvarchar(200) = NULL,
    @DeviceName nvarchar(150) = NULL,
    @AppVersion varchar(30)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (NULLIF(LTRIM(RTRIM(@Token)), N'') IS NULL)
        THROW 50410, 'A device token is required.', 1;

    IF (@Platform NOT IN ('IOS','ANDROID','WEB'))
        THROW 50411, 'Platform must be IOS, ANDROID or WEB.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTY_Member WHERE MemberId = @MemberId AND PropertyId = @PropertyId)
        THROW 50412, 'That member does not exist on this property.', 1;

    /*  Matched on the checksum first so the index is used, then on the token
        itself - CHECKSUM collides, and acting on a collision would move some
        other device's row.                                                      */
    DECLARE @TokenId int =
    (
        SELECT TOP (1) TokenId
        FROM   dbo.LTYC_DeviceToken
        WHERE  TokenChecksum = CHECKSUM(@Token) AND Token = @Token
        ORDER BY TokenId
    );

    IF (@TokenId IS NULL)
    BEGIN
        INSERT INTO dbo.LTYC_DeviceToken
            (MemberId, PropertyId, Platform, Token, AuthSecret, P256dhKey, DeviceName, AppVersion, IsActive, LastSeenAt)
        VALUES
            (@MemberId, @PropertyId, @Platform, @Token, @AuthSecret, @P256dhKey, @DeviceName, @AppVersion, 1, SYSUTCDATETIME());

        SET @TokenId = SCOPE_IDENTITY();
    END
    ELSE
    BEGIN
        UPDATE dbo.LTYC_DeviceToken
        SET    MemberId      = @MemberId,
               PropertyId    = @PropertyId,
               Platform      = @Platform,
               AuthSecret    = ISNULL(@AuthSecret, AuthSecret),
               P256dhKey     = ISNULL(@P256dhKey, P256dhKey),
               DeviceName    = ISNULL(@DeviceName, DeviceName),
               AppVersion    = ISNULL(@AppVersion, AppVersion),
               IsActive      = 1,
               FailureCount  = 0,
               DeactivatedAt = NULL,
               LastSeenAt    = SYSUTCDATETIME()
        WHERE  TokenId = @TokenId;
    END

    SELECT TokenId = @TokenId;
END

GO

