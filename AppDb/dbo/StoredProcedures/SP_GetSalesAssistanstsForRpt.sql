-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-03-11
-- Description:	Loading Sales Assistant for Reports
-- [dbo].[SP_GetSalesAssistanstsForRpt] 1

-- =============================================
create PROCEDURE [dbo].[SP_GetSalesAssistanstsForRpt]
@PropertyID INT =1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT -999  id, '--ALL--' text,'SalesAssistantWiseSalesReport' ReportName, 0 IsReportNameChange
	UNION ALL
	SELECT  ID id, Name text,'SalesAssistantWiseSalesReport' ReportName, 0 IsReportNameChange
	FROM     Retail_SalesAssistant
	WHERE IsActive = 1
	AND PropertyID =@PropertyID
END

GO

