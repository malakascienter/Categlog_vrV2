

CREATE PROCEDURE [dbo].[GL_POSTING_FO_SALE] (@USERID VARCHAR(MAX))

AS
BEGIN
	SET DATEFORMAT DMY

	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	
	--DECLARE @chargeDate AS DATE --= '02/04/2019'
	----DECLARE @advancedPayment_ReservationPostingTypeId AS INT --= '7'
	----DECLARE @advancedPayment_InhousePostingTypeId AS INT --= '11'
	----DECLARE @advancedPayment_ReservationCancellationPostingTypeId AS INT --= '14'
	----DECLARE @advancedPayment_InHouseCancellationPostingTypeId AS INT --= '12'
	----DECLARE @advancedPayment_RefundPostingTypeId AS INT --= '13'
	--DECLARE @AccAmount AS MONEY = 0.00
	--DECLARE @DAmount AS MONEY = 0.00
	--DECLARE @Jno as varchar(8) = 0
	--DECLARE @rCount as INT = 0
	--DECLARE @user AS VARCHAR(50) = ''
	--DECLARE @InHouseDebtorAcc AS VARCHAR(12) = ''

	--SELECT @InHouseDebtorAcc = InhouseDebtAcc FROM AccMasterSingleCurrencyHo.dbo.Settings

	----SELECT @user = Username FROM Users WHERE id = @USERID
	--SET @user = @USERID	

	----SELECT @chargeDate = CurrentDate, @advancedPayment_ReservationPostingTypeId = AdvancedPayment_ReservationPostingTypeId, @advancedPayment_InhousePostingTypeId = AdvancedPayment_InhousePostingTypeId, @advancedPayment_RefundPostingTypeId = AdvancePaymentRefundId FROM FOSettings
	--SELECT @chargeDate = CurrentDate FROM FOSettings
	----SET @chargeDate = '05/04/2019'


	----SELECT @rCount = COUNT(*) FROM FolioWisePostingBreakUp WHERE CAST(Date AS DATE) = @ChargeDate AND PostingTypeID NOT IN (@advancedPayment_ReservationPostingTypeId, @advancedPayment_InhousePostingTypeId, @advancedPayment_ReservationCancellationPostingTypeId, @advancedPayment_InHouseCancellationPostingTypeId, @advancedPayment_RefundPostingTypeId)
	--SELECT @rCount = COUNT(*) FROM FolioWisePostingBreakUp WHERE CAST(Date AS DATE) = @ChargeDate

	--IF @rCount>0
	--BEGIN
		
	--	select @Jno = right('000000000'+cast(cast(Journals + 1 as int) as varchar(8)),8) from AccMasterSingleCurrencyHO.DBO.Settings

	--	SELECT *, ROW_NUMBER() OVER(PARTITION BY TxnDate ORDER BY TxnDate DESC) AS Line_No 
	--	INTO #TempGLlinkSale
	--	FROM (
	--		-- GET REVENUE
	--		SELECT	@Jno As TxnNo,
	--				'J' As TxnID,
	--				'I' As Modname,
	--				F.AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(F.DATE AS DATE) AS TxnDate,
	--				IIF(SUM(ROUND(F.Amount,2))>0,'C','D') As DrCr,
	--				SUM(ROUND(F.Amount,2)) As AccAmount,
	--				ABS(SUM(ROUND(F.Amount,2))) As Amount,
	--				'Room Sale - '+ RTRIM(LTRIM(P.Name)) As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				'' AS docno,
	--				'CS' As TransType
	--		FROM FolioWisePostingBreakUp F, PostingTypes P
	--		--WHERE CAST(F.Date AS DATE) = @ChargeDate AND F.PostingTypeID NOT IN (@advancedPayment_ReservationPostingTypeId, @advancedPayment_InhousePostingTypeId, @advancedPayment_ReservationCancellationPostingTypeId, @advancedPayment_InHouseCancellationPostingTypeId, @advancedPayment_RefundPostingTypeId) AND F.PostingTypeID = P.Id
	--		WHERE CAST(F.Date AS DATE) = @ChargeDate AND F.PostingTypeID = P.Id
	--		GROUP BY F.AccountCode, CAST(F.DATE AS DATE), P.Name

	--		UNION ALL

	--		-- GET TAXES -> CURRENT
	--		SELECT	@Jno As TxnNo,
	--				'J' As TxnID,
	--				'I' As Modname,
	--				F.AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(F.DATE AS DATE) AS TxnDate,
	--				'C' As DrCr,
	--				SUM(ROUND(F.Amount,2)) As AccAmount,
	--				ABS(SUM(ROUND(F.Amount,2))) As Amount,
	--				'Room Sale - '+ RTRIM(LTRIM(F.TaxName)) As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				'' AS docno,
	--				'CS' As TransType
	--		FROM FoliowiseTaxDetails F
	--		WHERE CAST(F.Date AS DATE) = @ChargeDate
	--		GROUP BY F.AccountCode, CAST(F.DATE AS DATE), F.TaxName

	--		UNION ALL

	--		-- GET TAXES -> HISTORY
	--		SELECT	@Jno As TxnNo,
	--				'J' As TxnID,
	--				'I' As Modname,
	--				F.AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(F.DATE AS DATE) AS TxnDate,
	--				'C' As DrCr,
	--				SUM(ROUND(F.Amount,2)) As AccAmount,
	--				ABS(SUM(ROUND(F.Amount,2))) As Amount,
	--				'Room Sale - '+ RTRIM(LTRIM(F.TaxName)) As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				'' AS docno,
	--				'CS' As TransType
	--		FROM FoliowiseTaxDetailsHistory F
	--		WHERE CAST(F.Date AS DATE) = @ChargeDate
	--		GROUP BY F.AccountCode, CAST(F.DATE AS DATE), F.TaxName
	--	) X
		
	--	SELECT @AccAmount = SUM(Amount) FROM #TempGLlinkSale WHERE drcr = 'C'

	--	UPDATE #TempGLlinkSale SET AccAmount = @AccAmount

	--	SELECT @DAmount = IIF(SUM(Amount) IS NULL,0,SUM(Amount)) FROM #TempGLlinkSale WHERE drcr = 'D'

	--	--SELECT * FROM #TempGLlinkSale

	--	--INSERT REVENUE & TAXES ENTRIES
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,TransType, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	SELECT *, SUBSTRING(AccCode,1,2) MainClasscode, SUBSTRING(AccCode,3,2) SubClasscode, SUBSTRING(AccCode,5,4) MainAccCode, SUBSTRING(AccCode,9,4) SubAccCode, GETDATE() FROM #TempGLlinkSale

	--	--INSERT INHOUSEDEBTOR ENTRY
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,Transtype, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	VALUES (@Jno,'J','I',@InHouseDebtorAcc,'00','0000','','F','',@ChargeDate,'D',@AccAmount,(@AccAmount-@DAmount),'Room Sale',@user,'001','','CS', 1, SUBSTRING(@InHouseDebtorAcc,1,2), SUBSTRING(@InHouseDebtorAcc,3,2), SUBSTRING(@InHouseDebtorAcc,5,4), SUBSTRING(@InHouseDebtorAcc,9,4), GETDATE())

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Journals = Journals + 1
	--END


	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	

END

GO

