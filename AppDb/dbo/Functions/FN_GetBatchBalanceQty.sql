-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-02-20
-- Description:	Function to get BalanceQty for Batch Transactions
-- =============================================
CREATE FUNCTION [dbo].[FN_GetBatchBalanceQty]
(@StockItemID INT, @LocationId INT,@BatchNO VARCHAR(MAX),@EXPDateU DATE,@Date DATE = NULL) 
RETURNs DECIMAL(18,8) 
AS
BEGIN
	DECLARE @Balance AS DECIMAL(18,8)

	SELECT TOP (1) @Balance = BalanceQuantity
	FROM StockItemWiseEXPDateIns
	WHERE StockItemID = @StockItemID
	AND LocationID = @LocationId
	AND BatchNo = @BatchNO
	AND CONVERT(DATE,EXPDate) =@EXPDateU 
	AND TransactionDate <= @Date
	ORDER BY TransactionDate DESC,ID DESC 

	
	RETURN isnull(@Balance,0)

END

GO

