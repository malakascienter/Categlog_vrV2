-- DashboardAPI_Select_CommonDetailsByPage 'Dashboard'

CREATE PROCEDURE [dbo].[DashboardAPI_Select_CommonDetailsByPage]
	@Page		NVARCHAR(200)
AS
BEGIN
	SELECT * FROM DashboardAPI_CommonFormat WITH(NOLOCK)
	WHERE [Page] = @Page AND IsActive=1
	ORDER BY DisplayOrder
END

GO

