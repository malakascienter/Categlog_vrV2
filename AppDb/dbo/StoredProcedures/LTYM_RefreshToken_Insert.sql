
CREATE   PROCEDURE [dbo].[LTYM_RefreshToken_Insert]
    @MemberId    INT,
    @TokenHash   VARCHAR(128),
    @ExpiresAt   DATETIME2(0),
    @CreatedByIp VARCHAR(45) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.LTYM_RefreshTokens (MemberId, TokenHash, ExpiresAt, CreatedByIp)
    VALUES (@MemberId, @TokenHash, @ExpiresAt, @CreatedByIp);
END

GO

