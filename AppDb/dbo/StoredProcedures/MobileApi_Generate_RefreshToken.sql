


CREATE PROCEDURE [dbo].[MobileApi_Generate_RefreshToken]

	@NewToken				VARCHAR(MAX),
	@NewRefreshToken		VARCHAR(MAX),
	@AccessToken		VARCHAR(MAX),
	@RefreshToken		VARCHAR(MAX)
 
	
AS
BEGIN	
SET NOCOUNT ON

	Declare @ExDateTime as DATETIME,@RefreshTokenExpairedDate as DATETIME,@UserName	VARCHAR(20)

	SET @ExDateTime = (SELECT DATEADD(hh , 3,  getdate()))
	SET @RefreshTokenExpairedDate = (SELECT DATEADD(hh , 6,  getdate()))

	
	IF EXISTS(SELECT 1 FROM TokenValidateLog WHERE TokenID=@AccessToken AND RefreshTokenID = @RefreshToken)
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM TokenValidateLog WHERE TokenID=@AccessToken AND RefreshTokenID = @RefreshToken and RefreshTokenExpairedDate>getdate())
		BEGIN
			RAISERROR('Refresh Token Invalied',16,1)
			RETURN
		END
	END

	IF NOT EXISTS(SELECT 1 FROM TokenValidateLog WHERE TokenID=@AccessToken AND RefreshTokenID = @RefreshToken)
	BEGIN

		RAISERROR('Refresh Token Invalied',16,1)
		RETURN
	END
	ELSE IF EXISTS(SELECT 1 FROM TokenValidateLog WHERE TokenID=@AccessToken AND RefreshTokenID = @RefreshToken AND IsUsedRefreshTokenToGenarateNewToken = 1)
	BEGIN

		RAISERROR('This refresh Token already used',16,1)
		RETURN
	END

	SELECT @UserName = UserName FROM TokenValidateLog WHERE TokenID=@AccessToken AND RefreshTokenID = @RefreshToken

	UPDATE TokenValidateLog
	SET IsUsedRefreshTokenToGenarateNewToken = 1
	WHERE TokenID=@AccessToken AND RefreshTokenID = @RefreshToken
	
	INSERT INTO TokenValidateLog(TokenID,Sysdate,ExpairedDate,UserName,RefreshTokenID,RefreshTokenExpairedDate)
	SELECT @NewToken,getdate(),@ExDateTime,@UserName,@NewRefreshToken,@RefreshTokenExpairedDate

	SELECT @NewToken AS accessToken,getdate() AS Sysdate,@ExDateTime AS TokenExpiresOn,@UserName AS UserName ,'Valid Token' as Msg,@NewRefreshToken AS RefreshToken,@RefreshTokenExpairedDate AS RefreshTokenExpiresOn


END

GO

