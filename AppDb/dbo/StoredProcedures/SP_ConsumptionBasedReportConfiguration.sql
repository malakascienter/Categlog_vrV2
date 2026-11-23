-- =============================================
-- Author:		Nivesh
-- Create date: 2025-08-29
-- Description:	Consumption Based Report Configuration
-- =============================================
-- SP_ConsumptionBasedReportConfiguration 'CR1'

CREATE PROCEDURE [dbo].[SP_ConsumptionBasedReportConfiguration] 
	@Type VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT SR.* , RSC.ReportServerURL, RSC.ReportServerUserName, RSC.ReportServerPassword, RSC.IsCredentials
	FROM SendReport SR
	INNER JOIN ReportServerCredential RSC ON RSC.Id = SR.ReportServerID
	WHERE SR.ReportType = @Type
END

GO

