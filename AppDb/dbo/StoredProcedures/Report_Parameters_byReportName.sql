
-- =============================================
-- Author:		<Author,,Name>
-- ALTER date: <ALTER Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Report_Parameters_byReportName] 
@reportName VARCHAR(100) 
AS
BEGIN
	
	SET NOCOUNT ON;
	--SELECT ParamFromDate,ParamToDate,ParamOutletSingle,ParamOutletMultiple,ParamOrderTypeSingle,
	--ParamOrderTypeMultiple,ParamMonthYear,ParamYearOnly,ParamToYear,ParamToMonth 
	SELECT * FROM ReportDetails 
	Where ReportName=@reportName
   
END

GO

