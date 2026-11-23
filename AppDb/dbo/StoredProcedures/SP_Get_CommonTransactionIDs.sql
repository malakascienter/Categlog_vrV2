-- =============================================
-- Author:		Nivesh
-- Create date: 2025-03-30
-- Description:	Get applicable transactions
-- =============================================
-- SP_Get_CommonTransactionIDs 3
CREATE PROCEDURE [dbo].[SP_Get_CommonTransactionIDs]
@TransactionStatusID INT =1
AS
BEGIN
	SET NOCOUNT ON;

    SELECT TransactionID FROM
	CommonTransactionColumnData
	WHERE IsActive = 1 AND
	Action = CASE WHEN 
	@TransactionStatusID = 1 THEN 'C' -- Completion
	WHEN @TransactionStatusID = 3 THEN 'R' -- Rejection
	ELSE 'A' END -- Approval

END

GO

