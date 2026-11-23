-- =============================================
-- Author:		Nivesh
-- Create date: 2025-03-25
-- Description:	Get transaction column configuration
-- =============================================
-- SP_CommonTransactionColumnConfiguration 2

CREATE PROCEDURE [dbo].[SP_CommonTransactionColumnConfiguration] 
	@TransactionID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Id,TransactionID, ColumnData AS ColumnDataJson,ColumnDetailData AS ColumnDetailDataJson,reportName,Action,ActionTitle,IsActive FROM
	CommonTransactionColumnData WHERE TransactionID =@TransactionID
END

GO

