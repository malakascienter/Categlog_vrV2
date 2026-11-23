-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-21
-- Description:	Get Report Detail
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetReportDetail] 
	-- Add the parameters for the stored procedure here
	@reportCode varchar(200) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @reportCode = TRIM(@reportCode)
    -- Insert statements for procedure here
	SELECT 
		SOR.Id,
		SOR.ReportCode,
		SOR.DisplayName,
		SOR.ReportName,
		SOR.ReportURL,
		SOR.Active,
		SOR.Parameter
	FROM [dbo].[SpecialOrder_ReportDetail] SOR 
	WHERE TRIM(SOR.ReportCode) = @reportCode

END

GO

