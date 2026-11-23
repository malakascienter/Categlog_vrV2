
CREATE PROCEDURE [dbo].[SP_UserWiseCompany]
	@userId int, @propertyId int = 0
AS
BEGIN
	DECLARE @IsCentralLogin BIT
	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @propertyId 

	IF(@IsCentralLogin = 1)
	BEGIN	
		SELECT UC.PropertyId AS 'id', c.Name AS 'text',c.CompanyType as CompanyType,c.Code 
		FROM [dbo].[CentralUserWiseProperties] AS UC
		INNER JOIN dbo.Companies AS c ON UC.PropertyId = c.CompanyID
		WHERE UserId = @userId
	END
	ELSE 
	BEGIN	
		SELECT UC.CompnayId AS 'id', c.Name AS 'text',c.CompanyType as CompanyType,c.Code 
		FROM dbo.UserWiseCompanies AS UC
		INNER JOIN dbo.Companies AS c ON UC.CompnayId = c.CompanyID
		WHERE UserId = @userId
	END

END

GO

