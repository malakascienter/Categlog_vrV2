-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-26
-- Description:	Get Speacial Order Approval Types
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetApprovalType] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		[AT].Id,
		[AT].Approval,
		[AT].ApprovalLevel
	FROM [dbo].[SPO_ApprovalType] AS [AT]
	
END

GO

