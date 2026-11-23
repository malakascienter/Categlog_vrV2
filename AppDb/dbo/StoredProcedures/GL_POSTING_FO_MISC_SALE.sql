

CREATE PROCEDURE [dbo].[GL_POSTING_FO_MISC_SALE] (@USERID VARCHAR(MAX))

AS
BEGIN
	SET DATEFORMAT DMY

	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	
	--DECLARE @chargeDate AS DATE
	--DECLARE @AccAmount AS MONEY = 0.00
	--DECLARE @DAmount AS MONEY = 0.00
	--DECLARE @Jno as varchar(8) = 0
	--DECLARE @rCount as INT = 0
	--DECLARE @user AS VARCHAR(50) = ''
	--DECLARE @SalesClearingAcc AS VARCHAR(12) = ''

	--SELECT	@SalesClearingAcc = CommonDebitAcc FROM AccMasterSingleCurrencyHo.dbo.Settings
	
	----SELECT	@user = Username FROM Users WHERE id = @USERID
	--SET @user = @USERID	

	--SELECT	@chargeDate = CurrentDate FROM FOSettings
	

	--SELECT	@rCount = COUNT(*) FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--WHERE	CAST(ChargeDate AS DATE) = @ChargeDate 
	--		--AND ExtraPostingDetails.DocumentNoPrefix <> 'INV'
	--		AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--		AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--		AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--		AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'			 
	
	
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
	--				AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(ChargeDate AS DATE) AS TxnDate,
	--				IIF(SUM(ROUND(OrginalAmount,2))>0,'C','D') As DrCr,
	--				SUM(ROUND(OrginalAmount,2)) As AccAmount,
	--				ABS(SUM(ROUND(OrginalAmount,2))) As Amount,
	--				'Extra Posting Bills' As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				'' AS docno,
	--				'MB' As TransType,
	--				ABS(SUM(ROUND(ExtraPostingDetails.AmountFC,2))) AS FCAmount,
	--				ExtraPostingDetails.ConvertionRate AS ExRate, 
	--				Currencies.ISOCode AS TrCurr	
	--		FROM ExtraPostingDetails INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--		WHERE ExtraPostingDetails.id IN (
	--			SELECT ExtraPostingDetails.Id
	--			FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes 
	--			ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--		)
	--		--AND DocumentNoPrefix <> 'INV'
	--		AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--		AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--		AND DocumentNoPrefix <> 'RES'
	--		AND DocumentNoPrefix <> 'DIS'
	--		AND CAST(ChargeDate AS DATE) = @ChargeDate
	--		GROUP BY AccountCode, ChargeDate, ConvertionRate, ISOCode

	--		UNION ALL

	--		-- GET TAXES
	--		SELECT	@Jno As TxnNo,
	--				'J' As TxnID,
	--				'I' As Modname,
	--				AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(@ChargeDate AS DATE) AS TxnDate,
	--				'C' As DrCr,
	--				SUM(ROUND(Amount,2)) As AccAmount,
	--				ABS(SUM(ROUND(Amount,2))) As Amount,
	--				'Extra Posting Bills - '+ RTRIM(LTRIM(TaxName)) As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				'' AS docno,
	--				'MB' As TransType,
	--				ABS(SUM(ROUND(ExtraPostingDetailWiseTaxes.AmountFC,2))) AS FCAmount,
	--				ExtraPostingDetailWiseTaxes.ConvertionRate AS ExRate, 
	--				Currencies.ISOCode AS TrCurr	
	--		FROM ExtraPostingDetailWiseTaxes INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetailWiseTaxes.CurrencyId
	--		WHERE ExtraPostingDetailId IN (
	--			SELECT ExtraPostingDetails.Id
	--			FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--			WHERE	CAST(ChargeDate AS DATE) = @ChargeDate
	--					--AND ExtraPostingDetails.DocumentNoPrefix <> 'INV'
	--					AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--					AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--					AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--					AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
	--		)
	--		GROUP BY AccountCode, TaxName, ConvertionRate, ISOCode

	--	) X
		
	--	SELECT @AccAmount = SUM(Amount) FROM #TempGLlinkSale WHERE drcr = 'C'

	--	UPDATE #TempGLlinkSale SET AccAmount = @AccAmount

	--	SELECT @DAmount = IIF(SUM(Amount) IS NULL,0,SUM(Amount)) FROM #TempGLlinkSale WHERE drcr = 'D'


	--	--INSERT REVENUE & TAXES ENTRIES
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,TransType, FCAmount, ExRate, TrCurr, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	SELECT *, SUBSTRING(AccCode,1,2) MainClasscode, SUBSTRING(AccCode,3,2) SubClasscode, SUBSTRING(AccCode,5,4) MainAccCode, SUBSTRING(AccCode,9,4) SubAccCode, GETDATE() FROM #TempGLlinkSale

	--	--INSERT SALESCLEARING ENTRY
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,Transtype, FCAmount, ExRate, TrCurr, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	VALUES (@Jno,'J','I',@SalesClearingAcc,'00','0000','','F','',@ChargeDate,'D',@AccAmount,(@AccAmount-@DAmount),'Extra Posting Bills',@user,'001','','MB', NULL, NULL, NULL, 1, SUBSTRING(@SalesClearingAcc,1,2), SUBSTRING(@SalesClearingAcc,3,2), SUBSTRING(@SalesClearingAcc,5,4), SUBSTRING(@SalesClearingAcc,9,4), GETDATE())

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Journals = Journals + 1
	--END


	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	

END

GO

