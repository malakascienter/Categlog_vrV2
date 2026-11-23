-- =============================================
-- Author:		Nivesh
-- Create date: 2025-11-26
-- Description:	Get Speacial Order Transaction Types
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetTransactionType] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		STT.Id,
		STT.Code,
		STT.[Transaction],
		STT.DropdownData,
		STT.IsDropdown
	FROM 
	[dbo].[SPO_TransactionType] STT
END

GO

