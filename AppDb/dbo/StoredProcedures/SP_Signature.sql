
CREATE PROCEDURE [dbo].[SP_Signature] 
	@transactionType INT 
AS
BEGIN
	SELECT Description FROM dbo.SignaturesReportModels 	
    where TransactionID =  @transactionType
	ORDER BY OrderNum
END

GO

