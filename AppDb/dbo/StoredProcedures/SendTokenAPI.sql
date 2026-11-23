


CREATE PROCEDURE [dbo].[SendTokenAPI]

	
	@Token				VARCHAR(MAX),
	@RefreshToken		VARCHAR(MAX),
	@UserName			VARCHAR(20),
	@Password			VARCHAR(20)
 
	
AS
BEGIN	
SET NOCOUNT ON

	Declare @ExDateTime as DATETIME,@RefreshTokenExpairedDate as DATETIME,
	@PasswordDb	VARCHAR(20)

	SET @ExDateTime = (SELECT DATEADD(hh , 3,  getdate()))
	SET @RefreshTokenExpairedDate = (SELECT DATEADD(hh , 6,  getdate()))

	

	IF EXISTS(SELECT 1 FROM ApiUser WHERE RTRIM(UserName)=@UserName)
	BEGIN
		SELECT @PasswordDb=TRIM(Password) FROM ApiUser WHERE RTRIM(UserName)=@UserName
		IF @PasswordDb<>@Password
		BEGIN
			RAISERROR('Invalid User Name or Password',16,1)
			RETURN
		END 
		
	END
	ELSE
	BEGIN
	   RAISERROR('Invalid User Name or Password',16,1);
	   RETURN
	END
	

	INSERT INTO TokenValidateLog(TokenID,Sysdate,ExpairedDate,UserName,RefreshTokenID,RefreshTokenExpairedDate)
	SELECT @Token,getdate(),@ExDateTime,@UserName,@RefreshToken,@RefreshTokenExpairedDate

	SELECT @Token AS accessToken,getdate() AS Sysdate,@ExDateTime AS TokenExpiresOn,@UserName AS UserName ,'Valid Token' as Msg,@RefreshToken AS RefreshToken,@RefreshTokenExpairedDate AS RefreshTokenExpiresOn


END

GO

