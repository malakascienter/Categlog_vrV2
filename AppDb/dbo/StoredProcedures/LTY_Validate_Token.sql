-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-16
-- Description:	Token Validate 
-- =============================================
CREATE     PROCEDURE [dbo].[LTY_Validate_Token]
	@token NVARCHAR(MAX)
	--@UserName Varchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM LTY_TokenValidateLog WHERE TokenID=TRIM(@Token) )
	BEGIN
		IF NOT EXISTS(SELECT 1 FROM LTY_TokenValidateLog WHERE TokenID=RTRIM(@Token) and ExpairedDate>getdate())
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

