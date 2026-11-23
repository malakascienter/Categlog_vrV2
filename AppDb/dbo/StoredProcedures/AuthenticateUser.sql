
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
--==================================================
-- [dbo].[AuthenticateUser] 'tharanga', '123123', 2

CREATE PROCEDURE [dbo].[AuthenticateUser] --'ARUNA', '123123', 2
@Username NVARCHAR(100),
@Password NVARCHAR(50),
@PropertyId INT
AS
BEGIN
	
		IF EXISTS(SELECT * FROM [Users] WHERE Username = @Username AND PropertyId=@PropertyId AND Password = HASHBYTES('SHA2_256',@Password +CAST(Salt AS NVARCHAR(500))))
		BEGIN
			SELECT * FROM [Users] WHERE Username = @Username AND PropertyId=@PropertyId AND Password = HASHBYTES('SHA2_256',@Password +CAST(Salt AS NVARCHAR(500)))
		END
		ELSE
		BEGIN
			SELECT 0 AS Id
		END
	END

GO

