


 CREATE PROCEDURE [dbo].[GetAllUnits] (@CompanyId INT)

AS
BEGIN

	SELECT Id, Name FROM dbo.Units WHERE IsActive = 1 AND CompanyId = @CompanyId


END

GO

