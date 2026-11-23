-- =============================================
-- Author:		Ravindu 
-- Create date: 2026-03-16
-- Description:	Create Token
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SendTokenAPI]
    @Token              VARCHAR(MAX),
    @RefreshToken       VARCHAR(MAX),
    @UserName           VARCHAR(MAX),
    @Password           VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @ExDateTime                 DATETIME,
        @RefreshTokenExpairedDate   DATETIME,
        @PasswordDb                 VARCHAR(20);

    SET @ExDateTime               = DATEADD(HOUR, 3, GETDATE());
    SET @RefreshTokenExpairedDate = DATEADD(HOUR, 6, GETDATE());

    IF (ISNULL(@Password, '') = '' OR ISNULL(@UserName, '') = '')
    BEGIN
        RAISERROR('Invalid User Name or Password', 16, 1);
        RETURN;
    END

    IF (LEN(ISNULL(@Password, '')) > 20 OR LEN(ISNULL(@UserName, '')) > 20)
    BEGIN
        RAISERROR('Username and password must not exceed 20 characters', 16, 1);
        RETURN;
    END

    IF EXISTS (
        SELECT 1 
        FROM SPO_ApiUser 
        WHERE RTRIM(UserName) COLLATE Latin1_General_CS_AS = @UserName COLLATE Latin1_General_CS_AS
    )
    BEGIN

        SELECT @PasswordDb = TRIM(Password)
        FROM SPO_ApiUser 
        WHERE RTRIM(UserName) COLLATE Latin1_General_CS_AS = @UserName COLLATE Latin1_General_CS_AS;

        IF @PasswordDb COLLATE Latin1_General_CS_AS <> @Password COLLATE Latin1_General_CS_AS
        BEGIN
            RAISERROR('Invalid User Name or Password', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        RAISERROR('Invalid User Name or Password', 16, 1);
        RETURN;
    END

    INSERT INTO SPO_TokenValidateLog (
        UserName,
        TokenID,
        Sysdate,
        ExpairedDate,
        RefreshTokenID,
        RefreshTokenExpairedDate,
        IsUsedRefreshTokenToGenarateNewToken
    )
    VALUES (
        @UserName,
        CONVERT(UNIQUEIDENTIFIER, @Token),         
        GETDATE(),
        @ExDateTime,
        CONVERT(UNIQUEIDENTIFIER, @RefreshToken),   
        @RefreshTokenExpairedDate,
        0                                          
    );

    -- Return token response
    SELECT 
        @Token                      AS accessToken,
        GETDATE()                   AS Sysdate,
        @ExDateTime                 AS TokenExpiresOn,
        @UserName                   AS UserName,
        'Valid Token'               AS Msg,
        @RefreshToken               AS RefreshToken,
        @RefreshTokenExpairedDate   AS RefreshTokenExpiresOn;
END

GO

