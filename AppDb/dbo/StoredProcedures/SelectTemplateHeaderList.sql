-- [dbo].[SelectTemplateHeaderList] 1
CREATE PROCEDURE [dbo].[SelectTemplateHeaderList] (@PropertyID INT=1)
AS
BEGIN

	SELECT	TemplateHeaderID,Name TemplateName,IsActive 
	FROM	RequestTemplateHeader
	WHERE PropertyId = @PropertyID 
	AND ISNULL(IsHouseKeepingAPI,0) = 1
	ORDER BY Name

END

GO

