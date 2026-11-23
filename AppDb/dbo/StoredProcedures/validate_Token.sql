CREATE PROCEDURE [dbo].[validate_Token]-- 'validate_Token',1
	@token NVARCHAR(MAX)
	--@UserName Varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM TokenValidateLog WHERE TokenID=TRIM(@Token) )
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM TokenValidateLog WHERE TokenID=RTRIM(@Token) and ExpairedDate>getdate())
		BEGIN
			SELECT 0
		END
		ELSE
		BEGIN
			SELECT 1
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END
END

GO

