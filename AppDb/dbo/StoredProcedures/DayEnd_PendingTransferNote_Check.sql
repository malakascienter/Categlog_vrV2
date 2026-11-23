
CREATE PROCEDURE [dbo].[DayEnd_PendingTransferNote_Check]
@PropertyId INT
AS
BEGIN


DECLARE @TransferNoteValidateDatePeriod INT
SELECT @TransferNoteValidateDatePeriod = TransferNoteValidateDatePeriod FROM Companies WHERE CompanyID = @PropertyId


SELECT DocumentNo,CONVERT(date,CreatedDate) AS DocumentDate
FROM StockTransactionHeaders 
WHERE CONVERT(date,TransactionDate) <= CONVERT(date,GETDATE()) 
AND CONVERT(date,TransactionDate) >= DATEADD(DD, @TransferNoteValidateDatePeriod, GETDATE()) 
AND TransactionType = 'TO' AND PropertyID = @PropertyId AND ReferenceID NOT IN 
(
	SELECT Id
	FROM StockTransactionHeaders 
	WHERE CONVERT(date,TransactionDate) <= CONVERT(date,GETDATE()) 
	AND CONVERT(date,TransactionDate) >= DATEADD(DD, @TransferNoteValidateDatePeriod, GETDATE()) 
	AND TransactionType = 'TI' AND PropertyID = @PropertyId
)

END

GO

