/*  Switch a device off on sign-out.

    Scoped to the caller's own devices. Without the ownership check a signed-in
    member could post any token string and silence someone else's phone - the
    token is the only identifier, and tokens are not secret to the person holding
    the device they came from.                                                   */
CREATE PROCEDURE dbo.LTYM_Device_Deactivate
    @MemberId int,
    @Token    nvarchar(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_DeviceToken
                   WHERE TokenChecksum = CHECKSUM(@Token) AND Token = @Token AND MemberId = @MemberId)
    BEGIN
        -- Not an error. Signing out of a device already removed is a normal
        -- thing to do twice, and the member has nothing to fix.
        SELECT Affected = 0;
        RETURN;
    END

    -- Permanent: the member asked, so no retry count applies.
    EXEC dbo.LTYC_DeviceToken_Deactivate @Token = @Token, @Permanent = 1;
END

GO

