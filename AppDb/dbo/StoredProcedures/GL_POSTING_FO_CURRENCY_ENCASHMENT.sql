

CREATE PROCEDURE [dbo].[GL_POSTING_FO_CURRENCY_ENCASHMENT] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	DECLARE @BLOCKCODE AS VARCHAR(3) = 'FCE'
	DECLARE @ACCCODE_DR AS VARCHAR(12) = ''
	DECLARE @ACCCODE_CR AS VARCHAR(12) = ''
	DECLARE @SegmentID_DR AS INT = 0
	DECLARE @SegmentID_CR AS INT = 0
	DECLARE @BaseCurrCode AS INT = 0
	DECLARE @BLOCKCODELEVEL1_DR AS VARCHAR(4) = 'CEDR'
	DECLARE @BLOCKCODELEVEL1_CR AS VARCHAR(4) = 'CECR'

	SELECT @BaseCurrCode = BaseCurrencyISO FROM FOSettings WHERE PropertyId = @PropertyID

	SELECT	@ACCCODE_DR = AccCode, @SegmentID_DR = SegmentCode
	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping 
	WHERE	BlockCode = @BLOCKCODE AND GLCompCode = @GLCompCode AND Level1 = @BLOCKCODELEVEL1_DR

	
	SELECT	@ACCCODE_CR = AccCode, @SegmentID_CR = SegmentCode
	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping 
	WHERE	BlockCode = @BLOCKCODE AND GLCompCode = @GLCompCode AND Level1 = @BLOCKCODELEVEL1_CR



	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount)



	-------------------------------- START FOREIGN CURRENCY ENCASHMENT DEBIT ENTRY --------------------------------

	SELECT DISTINCT	CAST(CurrencyEncashment.InvoiceDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(CurrencyEncashment.ConvertedAmount) Amount,
			'Foreign Currency Encashment for Invoice No : '+CurrencyEncashment.invoiceNo AS Narration,
			LEFT(@ACCCODE_DR,12) AccCode,
			'D' DRCR,
			'1' SeqNo,
			'FE' TransType,
			CurrencyEncashment.invoiceNo DocumentNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			CurrencyEncashment.invoiceNo TempTxnNo,
			'H' ModName,
			@SegmentID_DR SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(CurrencyEncashment.ConvertionRate) AS ExRate,
		    (CASE WHEN CurrencyEncashment.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(CurrencyEncashment.Amount) END) AS FCAmount
	
	FROM	CurrencyEncashment INNER JOIN Currencies ON CurrencyEncashment.CurrencyID = Currencies.ID
	
	WHERE	CAST(CurrencyEncashment.InvoiceDate AS DATE) = @CurrDate AND CurrencyEncashment.PropertyId = @PropertyID

	-------------------------------- END FOREIGN CURRENCY ENCASHMENT DEBIT ENTRY --------------------------------

	UNION ALL

	-------------------------------- START FOREIGN CURRENCY ENCASHMENT CREDIT ENTRY --------------------------------

	SELECT DISTINCT	CAST(CurrencyEncashment.InvoiceDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(CurrencyEncashment.ConvertedAmount) Amount,
			'Foreign Currency Encashment for Invoice No : '+CurrencyEncashment.invoiceNo AS Narration,
			LEFT(@ACCCODE_CR,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'FE' TransType,
			CurrencyEncashment.invoiceNo DocumentNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			CurrencyEncashment.invoiceNo TempTxnNo,
			'H' ModName,
			@SegmentID_CR SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(CurrencyEncashment.ConvertionRate) AS ExRate,
		    (CASE WHEN CurrencyEncashment.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(CurrencyEncashment.Amount) END) AS FCAmount
	
	FROM	CurrencyEncashment INNER JOIN Currencies ON CurrencyEncashment.CurrencyID = Currencies.ID
	
	WHERE	CAST(CurrencyEncashment.InvoiceDate AS DATE) = @CurrDate	AND CurrencyEncashment.PropertyId = @PropertyID

	-------------------------------- START FOREIGN CURRENCY ENCASHMENT CREDIT ENTRY --------------------------------

END

GO

