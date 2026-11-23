CREATE PROCEDURE [dbo].[Login]
	@username VARCHAR(max),
	@password VARCHAR(max),
	@companyId INT
AS
BEGIN
	SELECT * FROM dbo.UserMasters AS u
	INNER JOIN UserWiseCompanies AS c ON u.id = c.UserId   
	WHERE UserName = @username AND Password = @password AND c.CompnayId = @companyId
END

GO

