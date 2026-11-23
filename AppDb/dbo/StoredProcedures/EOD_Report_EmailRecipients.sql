CREATE PROCEDURE [dbo].[EOD_Report_EmailRecipients] 
@Outlet VARCHAR(5),
@PropertyId INT
AS
BEGIN

	SELECT * 
	FROM ReportSendEmail
	WHERE EODMail = 1 AND IsOutletWiseSend = 0 
	UNION ALL
	SELECT * 
	FROM ReportSendEmail
	WHERE IsOutletWiseSend = 1  AND Outlet = @Outlet  AND EODMail = 1

END

GO

