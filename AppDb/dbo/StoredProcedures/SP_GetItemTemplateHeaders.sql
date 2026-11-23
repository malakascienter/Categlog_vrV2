-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-09
-- Description:	loading Item Template For Common Report View
-- SP_GetItemTemplateHeaders 1
-- =============================================
create PROCEDURE SP_GetItemTemplateHeaders
@PropertyID INT =1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT -999 id,'--ALL--'  text,'Item_Movement_WithTemplate'ReportName, 0 IsReportNameChange
	UNION ALL
	SELECT TemplateHeaderID id,Name text ,'Item_Movement_WithTemplate'ReportName, 0 IsReportNameChange
	FROM RequestTemplateHeader
	WHERE PropertyId = @PropertyID
	AND IsActive = 1
	AND IsHouseKeepingAPI = 0

    
END

GO

