
-- =============================================
-- Author:		Chiraj
-- ALTER date: 2018-10-10
-- Description:	Get Report Names
-- =============================================
--[dbo].[Report_Select_ReportNames][1]
CREATE PROCEDURE [dbo].[Report_Select_ReportNames]
	
AS
BEGIN	
	SET NOCOUNT ON;
	SELECT RD.ReportID,RD.DisplayName,RD.ReportName,RD.ReportCategory 
	FROM ReportDetails   AS RD 	
	WHERE RD.Active=1 
	ORDER BY RD.ReportID ASC
END

GO

