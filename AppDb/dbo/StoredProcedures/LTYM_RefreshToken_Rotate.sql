
CREATE   PROCEDURE [dbo].[LTYM_RefreshToken_Rotate]
    @TokenHash    VARCHAR(128),
    @NewTokenHash VARCHAR(128),
    @ExpiresAt    DATETIME2(0),
    @CreatedByIp  VARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @MemberId INT, @RevokedAt DATETIME2(0), @TokenExpires DATETIME2(0);

        SELECT @MemberId     = MemberId,
               @RevokedAt    = RevokedAt,
               @TokenExpires = ExpiresAt
        FROM   dbo.LTYM_RefreshTokens WITH (UPDLOCK, ROWLOCK)
        WHERE  TokenHash = @TokenHash;

        IF @MemberId IS NULL
            THROW 52011, 'Invalid refresh token.', 1;

        IF @RevokedAt IS NOT NULL
        BEGIN
            UPDATE dbo.LTYM_RefreshTokens
            SET    RevokedAt = SYSUTCDATETIME()
            WHERE  MemberId = @MemberId AND RevokedAt IS NULL;

            COMMIT TRANSACTION;
            THROW 52012, 'Refresh token reuse detected; all sessions revoked.', 1;
        END

        IF @TokenExpires <= SYSUTCDATETIME()
            THROW 52013, 'Refresh token has expired.', 1;

        UPDATE dbo.LTYM_RefreshTokens
        SET    RevokedAt = SYSUTCDATETIME(),
               ReplacedByTokenHash = @NewTokenHash
        WHERE  TokenHash = @TokenHash;

        INSERT INTO dbo.LTYM_RefreshTokens (MemberId, TokenHash, ExpiresAt, CreatedByIp)
        VALUES (@MemberId, @NewTokenHash, @ExpiresAt, @CreatedByIp);

        COMMIT TRANSACTION;

        SELECT @MemberId AS MemberId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

