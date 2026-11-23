
CREATE PROCEDURE [dbo].[UserWiseIndividualReportAccess_M_Select_ByUrl]

@pageUrl NVARCHAR(250)

AS
BEGIN

	SELECT [Id] AS PageId
	FROM [dbo].[Admin_Nav_AreasWisePages]
	Where [Url] = @pageUrl

END

GO

