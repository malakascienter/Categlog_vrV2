/*  Switch a device off - on sign-out, or after the provider rejects it.

    Deactivated, never deleted: a re-registration revives the same row, and the
    history of why it was switched off survives. @Permanent is what the provider
    uses for an "unregistered" verdict, which no retry will fix.                 */
CREATE PROCEDURE dbo.LTYC_DeviceToken_Deactivate
    @Token      nvarchar(500),
    @Permanent  bit = 0
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYC_DeviceToken
    SET    FailureCount  = CASE WHEN @Permanent = 1 THEN FailureCount ELSE FailureCount + 1 END,
           -- A soft failure only switches the device off once it has failed
           -- repeatedly; one transient rejection must not silence a real device.
           IsActive      = CASE WHEN @Permanent = 1 OR FailureCount + 1 >= 5 THEN 0 ELSE IsActive END,
           DeactivatedAt = CASE WHEN @Permanent = 1 OR FailureCount + 1 >= 5 THEN SYSUTCDATETIME() ELSE DeactivatedAt END
    WHERE  TokenChecksum = CHECKSUM(@Token) AND Token = @Token;

    SELECT Affected = @@ROWCOUNT;
END

GO

