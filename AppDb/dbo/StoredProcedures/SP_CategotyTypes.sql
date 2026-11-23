CREATE PROCEDURE [dbo].[SP_CategotyTypes]
	@CompanyId INT
AS
BEGIN
	SELECT Id AS id , Name AS text FROM dbo.Categories 
	--WHERE CompanyId = @CompanyId
END

GO

