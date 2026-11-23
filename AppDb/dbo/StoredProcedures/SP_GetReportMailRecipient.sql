-- =============================================
-- Author:		Nivesh
-- Create date: 2025-08-29
-- Description:	SP_Get Report Mail Recipient
-- =============================================
-- SP_GetReportMailRecipient 'CR1'

CREATE PROCEDURE [dbo].[SP_GetReportMailRecipient] 
	@Type VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT * FROM [dbo].[SendReportMailRecipient] WHERE ReportType = @Type
END

GO

