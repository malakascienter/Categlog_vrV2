-- DashboardCommonFormat_M_SelectForDashboardAPI 1

CREATE PROCEDURE [dbo].[DashboardAPI_DashboardAPI_CommonFormat_M_SelectById]
	@ChartId			INT
AS
BEGIN
	SELECT * FROM [dbo].[DashboardAPI_CommonFormat]
	WHERE IsActive=1 AND Id=@ChartId
END

GO

