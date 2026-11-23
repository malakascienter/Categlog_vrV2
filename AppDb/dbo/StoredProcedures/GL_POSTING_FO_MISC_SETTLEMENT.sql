

CREATE PROCEDURE [dbo].[GL_POSTING_FO_MISC_SETTLEMENT] (@USERID VARCHAR(MAX))

AS
BEGIN
	SET DATEFORMAT DMY

	--DECLARE @chargeDate AS DATE
	--DECLARE @Bno as varchar(8) = 0
	--DECLARE @rCount as INT = 0
	--DECLARE @user AS VARCHAR(50) = ''
	--DECLARE @SalesClearingAcc AS VARCHAR(12) = ''

	--SELECT @SalesClearingAcc = CommonDebitAcc FROM AccMasterSingleCurrencyHo.dbo.Settings
	
	----SELECT @user = Username FROM Users WHERE id = @USERID
	--SET @user = @USERID	

	--SELECT @chargeDate = CurrentDate FROM FOSettings
	

	----SELECT @rCount = count(*) FROM ExtraPostingSettlements WHERE ExtraPostingId IN (SELECT ExtraPostingDetails.Id FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	----	WHERE	CAST(ChargeDate AS DATE) = @ChargeDate
	----			--AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	----)	
	
	
	--SELECT @rCount = count(*) FROM(	SELECT PaymentType	FROM ExtraPostingSettlements WHERE ExtraPostingId IN ( SELECT ExtraPostingDetails.Id FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--WHERE	CAST(ChargeDate AS DATE) = @ChargeDate
	--		AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--		AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--		AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--		AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
	--) GROUP BY PaymentType ) X
	
	
	---- GL ENTRY
	--IF @rCount>0
	--BEGIN
		
	--	SELECT @Bno = right('000000000'+cast(cast(SpecialJournals + 1 as int) as varchar(8)),8) from AccMasterSingleCurrencyHO.DBO.Settings
		
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,Transtype, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime, FCAmount, ExRate, TrCurr)
		
	--	-- INSERT SALESCLEARING ENTRY
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY @rCount ORDER BY @rCount DESC) + @Bno as int) as varchar(8)),8)  AS TxnNo,
	--			'B' As TxnID,
	--			'I' As Modname,
	--			@SalesClearingAcc AS AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			'' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			CAST(@chargeDate AS DATE) AS TxnDate,
	--			'C' As DrCr,
	--			ABS(SUM(ROUND(Amount,2))) As AccAmount,
	--			ABS(SUM(ROUND(Amount,2))) As Amount,
	--			'Settlement of Extra Posting Bills' As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			'' AS docno,
	--			'MB' As TransType,
	--			1 AS Line_No,
	--			SUBSTRING(@SalesClearingAcc,1,2) MainClasscode, 
	--			SUBSTRING(@SalesClearingAcc,3,2) SubClasscode, 
	--			SUBSTRING(@SalesClearingAcc,5,4) MainAccCode, 
	--			SUBSTRING(@SalesClearingAcc,9,4) SubAccCode, 
	--			GETDATE() logtime,
	--			ABS(SUM(ROUND(ExtraPostingSettlements.AmountFC,2))) AS FCAmount,
	--			ExtraPostingSettlements.ConvertionRate AS ExRate, 
	--			Currencies.ISOCode AS TrCurr					
	--	FROM	ExtraPostingSettlements INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingSettlements.CurrencyId
	--	WHERE	ExtraPostingId IN (
	--				SELECT ExtraPostingDetails.Id
	--				FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes 
	--					ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--				WHERE	CAST(ChargeDate AS DATE) = @ChargeDate 
	--						AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--						AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--						AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--						AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
	--			)
	--	GROUP BY AccountCode,ConvertionRate,ISOCode

	--	UNION ALL

	--	-- INSERT ACTUAL SETTLEMENT ENTRY
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY @rCount ORDER BY @rCount DESC) + @Bno as int) as varchar(8)),8)  AS TxnNo,
	--			'B' As TxnID,
	--			'I' As Modname,
	--			AccountCode AS AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			'' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			CAST(@chargeDate AS DATE) AS TxnDate,
	--			'D' As DrCr,
	--			ABS(SUM(ROUND(Amount,2))) As AccAmount,
	--			ABS(SUM(ROUND(Amount,2))) As Amount,
	--			'Settlement of Extra Posting Bills' As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			'' AS docno,
	--			'MB' As TransType,
	--			2 AS Line_No,
	--			SUBSTRING(AccountCode,1,2) MainClasscode, 
	--			SUBSTRING(AccountCode,3,2) SubClasscode, 
	--			SUBSTRING(AccountCode,5,4) MainAccCode, 
	--			SUBSTRING(AccountCode,9,4) SubAccCode, 
	--			GETDATE() logtime,
	--			ABS(SUM(ROUND(ExtraPostingSettlements.AmountFC,2))) AS FCAmount,
	--			ExtraPostingSettlements.ConvertionRate AS ExRate, 
	--			Currencies.ISOCode AS TrCurr	
	--	FROM	ExtraPostingSettlements INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingSettlements.CurrencyId
	--	WHERE	ExtraPostingId IN (
	--				SELECT ExtraPostingDetails.Id
	--				FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes 
	--					ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--				WHERE	CAST(ChargeDate AS DATE) = @ChargeDate 
	--						AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--						AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--						AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--						AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
	--			)

	--	GROUP BY AccountCode, ConvertionRate, ISOCode
	--	ORDER BY TxnNo, DRCR
			
	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set SpecialJournals = SpecialJournals + @rCount
	
	--END

END

GO

