CREATE PROCEDURE [dbo].[SelectRequestTemplteHeaderList] (@PropertyID INT=1)
AS
BEGIN

	SELECT	TemplateHeaderID,Name TemplateName,IsActive 
	FROM	RequestTemplateHeader
	WHERE PropertyId = @PropertyID
	ORDER BY Name

END

GO

