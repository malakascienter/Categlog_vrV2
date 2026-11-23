
CREATE   PROCEDURE [dbo].[LTYM_MemberCredentials_UpdatePassword]
    @MemberId     INT,
    @PasswordHash NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE dbo.LTYM_MemberCredentials
        SET    PasswordHash   = @PasswordHash,
               FailedAttempts = 0,
               LockoutEnd     = NULL,
               UpdatedAt      = SYSUTCDATETIME()
        WHERE  MemberId = @MemberId;

        IF @@ROWCOUNT = 0
            THROW 52003, 'No portal account exists for this member.', 1;

        UPDATE dbo.LTYM_RefreshTokens
        SET    RevokedAt = SYSUTCDATETIME()
        WHERE  MemberId = @MemberId AND RevokedAt IS NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

