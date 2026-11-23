-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-01
-- Description:	Get common transaction column configuration
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_SP_GetCommonTransactionColumnConfiguration] 
	@TransactionActionID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		SCC.Id,
		SCC.TransactionID,
		SCC.ColumnHeaderData,
		SCC.ColumnDetailData,
		SCC.reportName,
		SCC.[Action],
		SCC.ActionTitle,
		SCC.IsActive,
		SCC.DropdownData,
		SCC.EnableAction
	FROM
	[dbo].[SPO_CommonTransactionColumnConfiguration] SCC
	WHERE SCC.Id = @TransactionActionID
END

GO

