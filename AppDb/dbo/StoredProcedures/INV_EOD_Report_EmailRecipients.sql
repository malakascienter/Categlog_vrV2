-- [dbo].[INV_EOD_Report_EmailRecipients] '001',1,1

CREATE PROCEDURE [dbo].[INV_EOD_Report_EmailRecipients] 
@Outlet VARCHAR(5),
@PropertyId INT,
@LocationID INT
AS
BEGIN

	SELECT * 
	FROM INV_ReportSendEmail
	WHERE  Outlet = @Outlet  AND EODMail = 1 AND LocationID = @LocationID
	AND PropertyID = @PropertyId

END

GO

