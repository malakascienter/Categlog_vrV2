-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-09
-- Description:	loading Item Template For Common Report View
-- [dbo].[SP_GetPrintTopConsumption_Table] 1
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetPrintTopConsumption_Table]
@PropertyID INT =1
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ID id,Name text ,ReportName ReportName, IsReportNameChange IsReportNameChange
	FROM PrintTopConsumption_Table
	

    
END

GO

