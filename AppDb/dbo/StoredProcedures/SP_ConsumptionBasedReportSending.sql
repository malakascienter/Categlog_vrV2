-- =============================================
-- Author:		Nivesh
-- Create date: 2025-08-29
-- Description:	Consumption Based Report Sending
-- =============================================
-- SP_ConsumptionBasedReportSending 'CR1',1

CREATE PROCEDURE [dbo].[SP_ConsumptionBasedReportSending] 
	@Type VARCHAR(50),
	@ReportTypeID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   SELECT DISTINCT
   SRN.Id,
   SRN.ReportType,
   SRN.ReportDate,
   SRN.ReportTypeID,
   SRN.ReportData,
   SRN.IsMailSend 
   FROM [dbo].[SendReportNotificationDetail] SRN WITH (NOLOCK)
   WHERE SRN.IsMailSend = 0 AND SRN.ReportType = @Type AND SRN.ReportTypeID = @ReportTypeID
END

GO

