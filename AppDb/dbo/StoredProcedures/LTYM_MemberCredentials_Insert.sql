
CREATE   PROCEDURE [dbo].[LTYM_MemberCredentials_Insert]
    @MemberId     INT,
    @Email        VARCHAR(150),
    @PasswordHash NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberCredentials WHERE MemberId = @MemberId)
            THROW 52001, 'This member already has a portal account.', 1;

        IF EXISTS (SELECT 1 FROM dbo.LTYM_MemberCredentials WHERE Email = @Email)
            THROW 52002, 'This email address is already registered.', 1;

        INSERT INTO dbo.LTYM_MemberCredentials (MemberId, Email, PasswordHash, IsVerified)
        VALUES (@MemberId, @Email, @PasswordHash, 1);

        SELECT SCOPE_IDENTITY() AS Id;
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END

GO

