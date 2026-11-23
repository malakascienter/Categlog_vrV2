-- [dbo].[DayEnd_PendingTransferNoteLocationWise_Check] 1,'t03'

CREATE PROCEDURE [dbo].[DayEnd_PendingTransferNoteLocationWise_Check]
@PropertyId INT,
@Outlet VARCHAR(3)
AS
BEGIN


DECLARE @TransferNoteValidateDatePeriod INT,@LocationID INT,@TxnDate date
SELECT @TransferNoteValidateDatePeriod = TransferNoteValidateDatePeriod FROM Companies WHERE CompanyID = @PropertyId

SELECT @LocationID = StockLocationID,@TxnDate = CurrentDate
FROM Location_Ref
WHERE code = @Outlet

IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS 
WHERE TRANSACTIONTYPE='TO' AND PropertyID =@PropertyID 
AND IsTrasferIn=0 AND TransferLocationID =  @LocationID 
AND TRANSACTIONDATE = @TxnDate)
BEGIN
	SELECT DocumentNo,TransactionDate  AS DocumentDate
	FROM STOCKTRANSACTIONHEADERS 
	WHERE TRANSACTIONTYPE='TO' 
	AND PropertyID =@PropertyID 
	AND IsTrasferIn=0 
	AND TransferLocationID =  @LocationID 
	AND TRANSACTIONDATE = @TxnDate
END


--Comment by dilshan 2026-01-16
--DECLARE @TransferNoteValidateDatePeriod INT
--SELECT @TransferNoteValidateDatePeriod = TransferNoteValidateDatePeriod FROM Companies WHERE CompanyID = @PropertyId


--SELECT DocumentNo,CONVERT(date,CreatedDate) AS DocumentDate
--FROM StockTransactionHeaders 
--WHERE CONVERT(date,TransactionDate) <= CONVERT(date,GETDATE()) 
--AND CONVERT(date,TransactionDate) >= DATEADD(DD, @TransferNoteValidateDatePeriod, GETDATE()) 
--AND TransactionType = 'TO' AND PropertyID = @PropertyId AND ReferenceID NOT IN 
--(
--	SELECT Id
--	FROM StockTransactionHeaders 
--	WHERE CONVERT(date,TransactionDate) <= CONVERT(date,GETDATE()) 
--	AND CONVERT(date,TransactionDate) >= DATEADD(DD, @TransferNoteValidateDatePeriod, GETDATE()) 
--	AND TransactionType = 'TI' AND PropertyID = @PropertyId
--)

	
END

GO

