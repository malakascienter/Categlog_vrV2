
CREATE   PROCEDURE [dbo].[LTYM_RefreshToken_Revoke]
    @TokenHash VARCHAR(128)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYM_RefreshTokens
    SET    RevokedAt = SYSUTCDATETIME()
    WHERE  TokenHash = @TokenHash AND RevokedAt IS NULL;
END

GO

