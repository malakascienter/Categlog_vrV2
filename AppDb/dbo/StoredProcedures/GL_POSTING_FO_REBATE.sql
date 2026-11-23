

CREATE PROCEDURE [dbo].[GL_POSTING_FO_REBATE] (@USERID INT, @DocumentNo VARCHAR(MAX))

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
	--DECLARE @InhouseDebtAcc AS VARCHAR(12) = ''

	--SELECT	@InhouseDebtAcc = InhouseDebtAcc FROM AccMasterSingleCurrencyHo.dbo.Settings
	
	--SELECT	@user = Username FROM Users WHERE id = @USERID

	--SELECT	@chargeDate = CurrentDate FROM FOSettings
	

	--SELECT	@rCount = COUNT(*) FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--WHERE	CAST(ChargeDate AS DATE) = @ChargeDate 
	--		--AND ExtraPostingDetails.DocumentNoPrefix <> 'INV'
	--		AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--		AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) = 1
	--		AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--		AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
	--		AND ExtraPostingDetails.DocumentNo = @DocumentNo		 
	
	
	--IF @rCount>0
	--BEGIN
		
	--	select @Jno = right('000000000'+cast(cast(Journals + 1 as int) as varchar(8)),8) from AccMasterSingleCurrencyHO.DBO.Settings

	--	SELECT *, ROW_NUMBER() OVER(PARTITION BY TxnDate ORDER BY TxnDate DESC) AS Line_No 
	--	INTO #TempGLlinkSale
	--	FROM (
	--		-- REBATE REVENUE
	--		SELECT	@Jno As TxnNo,
	--				'J' As TxnID,
	--				'H' As Modname,
	--				AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(ChargeDate AS DATE) AS TxnDate,
	--				--IIF(SUM(ROUND(OrginalAmount,2))>0,'D','C') As DrCr,
	--				'D' As DrCr,
	--				--SUM(ROUND(OrginalAmount,2)) As AccAmount,
	--				ABS(SUM(ROUND(OrginalAmount,2))) As AccAmount,
	--				ABS(SUM(ROUND(OrginalAmount,2))) As Amount,
	--				'Rebate - '+LTRIM(RTRIM(FolioText))+ ' For Bill No - '+@DocumentNo As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				@DocumentNo AS docno,
	--				'RE' As TransType,
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
	--		AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) = 1
	--		AND DocumentNoPrefix <> 'RES'
	--		AND DocumentNoPrefix <> 'DIS'
	--		AND ExtraPostingDetails.DocumentNo = @DocumentNo
	--		AND CAST(ChargeDate AS DATE) = @ChargeDate
	--		GROUP BY AccountCode, ChargeDate, LTRIM(RTRIM(FolioText)), ConvertionRate, ISOCode

	--		UNION ALL

	--		-- REBATE TAXES
	--		SELECT	@Jno As TxnNo,
	--				'J' As TxnID,
	--				'H' As Modname,
	--				AccountCode AS AccCode,
	--				'00' AS DeptCode,
	--				'0000' As SuppCode,
	--				'' As txntype,
	--				'F' As Cancel,
	--				'' As DocType,
	--				CAST(@ChargeDate AS DATE) AS TxnDate,
	--				'D' As DrCr,
	--				--SUM(ROUND(Amount,2)) As AccAmount,
	--				ABS(SUM(ROUND(Amount,2))) As AccAmount,
	--				ABS(SUM(ROUND(Amount,2))) As Amount,
	--				'Rebate For Bill No - '+@DocumentNo +' - '+ RTRIM(LTRIM(TaxName)) As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				@DocumentNo AS docno,
	--				'RE' As TransType,
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
	--					AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) = 1
	--					AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--					AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
	--					AND ExtraPostingDetails.DocumentNo = @DocumentNo
	--		)
	--		GROUP BY AccountCode, TaxName, ConvertionRate, ISOCode

	--	) X
		
	--	SELECT @AccAmount = SUM(Amount) FROM #TempGLlinkSale WHERE drcr = 'D'

	--	UPDATE #TempGLlinkSale SET AccAmount = @AccAmount

	--	SELECT @DAmount = IIF(SUM(Amount) IS NULL,0,SUM(Amount)) FROM #TempGLlinkSale WHERE drcr = 'C'


	--	--INSERT REBATE REVENUE & TAXES ENTRIES
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,TransType, FCAmount, ExRate, TrCurr, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	SELECT *, SUBSTRING(AccCode,1,2) MainClasscode, SUBSTRING(AccCode,3,2) SubClasscode, SUBSTRING(AccCode,5,4) MainAccCode, SUBSTRING(AccCode,9,4) SubAccCode, GETDATE() FROM #TempGLlinkSale


	--	--INSERT REBATE INHOUSE DEBTOR ENTRY
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,Transtype, FCAmount, ExRate, TrCurr, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	VALUES (@Jno,'J','H',@InhouseDebtAcc,'00','0000','','F','',@ChargeDate,'C',@AccAmount,(@AccAmount-@DAmount),'Rebate For Bill No - '+@DocumentNo,@user,'001',@DocumentNo,'RE', NULL, NULL, NULL, 1, SUBSTRING(@InhouseDebtAcc,1,2), SUBSTRING(@InhouseDebtAcc,3,2), SUBSTRING(@InhouseDebtAcc,5,4), SUBSTRING(@InhouseDebtAcc,9,4), GETDATE())


	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Journals = Journals + 1
		
	--END


	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	

END

GO

