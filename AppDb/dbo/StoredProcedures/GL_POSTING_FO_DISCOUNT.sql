

CREATE PROCEDURE [dbo].[GL_POSTING_FO_DISCOUNT] (@USERID VARCHAR(MAX), @DocumentNo VARCHAR(MAX), @isReinstate  BIT = 0)

AS
BEGIN
	SET DATEFORMAT DMY

	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	
	--DECLARE @chargeDate AS DATE
	--DECLARE @AccAmount AS MONEY = 0.00
	--DECLARE @CAmount AS MONEY = 0.00
	--DECLARE @Jno as varchar(8) = 0
	--DECLARE @rCount as INT = 0
	--DECLARE @user AS VARCHAR(50) = ''
	--DECLARE @InHouseDebtorAcc AS VARCHAR(12) = ''

	--SELECT	@InHouseDebtorAcc = InhouseDebtAcc FROM AccMasterSingleCurrencyHo.dbo.Settings
	
	--SELECT	@user = Username FROM Users WHERE id = @USERID

	--SELECT	@chargeDate = CurrentDate FROM FOSettings
	

	--SELECT	@rCount = COUNT(*) FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--WHERE	--CAST(ChargeDate AS DATE) = @ChargeDate 
	--		--AND ExtraPostingDetails.DocumentNoPrefix <> 'INV'
	--		--AND 
	--		IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--		AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--		--AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--		AND ExtraPostingDetails.DocumentNoPrefix = 'DIS'			 
	--		AND ExtraPostingDetails.DocumentNo = @DocumentNo
	
	
	--IF @rCount>0
	--BEGIN
		
	--	select @Jno = right('000000000'+cast(cast(Journals + 1 as int) as varchar(8)),8) from AccMasterSingleCurrencyHO.DBO.Settings

	--	SELECT *, ROW_NUMBER() OVER(PARTITION BY TxnDate ORDER BY TxnDate DESC) AS Line_No 
	--	INTO #TempGLlinkSale
	--	FROM (
	--		-- REVERSE REVENUE
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
	--				IIF(@isReinstate = 0,'D','C') As DrCr, -- IIF(SUM(ROUND(OrginalAmount,2))>0,'C','D') As DrCr,
	--				SUM(ROUND(OrginalAmount,2)) As AccAmount,
	--				ABS(SUM(ROUND(OrginalAmount,2))) As Amount,
	--				IIF(@isReinstate = 0,'','Cancellation of ') +'Discount For Document No. ' +@DocumentNo + ' And Ref. Document No. '+RefDocNo As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				@DocumentNo AS docno,
	--				RefDocNo AS ResInvoiceNo,
	--				'DI' As TransType,
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
	--		--AND DocumentNoPrefix <> 'RES'
	--		AND DocumentNoPrefix = 'DIS'
	--		AND DocumentNo = @DocumentNo
	--		--AND CAST(ChargeDate AS DATE) = @ChargeDate
	--		GROUP BY AccountCode, ChargeDate, ConvertionRate, ISOCode, RefDocNo

	--		UNION ALL

	--		-- REVERSE TAXES
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
	--				IIF(@isReinstate = 0,'D','C') As DrCr,
	--				SUM(ROUND(Amount,2)) As AccAmount,
	--				ABS(SUM(ROUND(Amount,2))) As Amount,
	--				IIF(@isReinstate = 0,'','Cancellation of ') +'Discount For Document No. '+@DocumentNo +', ' +RTRIM(LTRIM(TaxName)) As Narration,
	--				@user As UserID,
	--				'001' As CompCode, 
	--				@DocumentNo AS docno,
	--				'' AS ResInvoiceNo,
	--				'DI' As TransType,
	--				ABS(SUM(ROUND(ExtraPostingDetailWiseTaxes.AmountFC,2))) AS FCAmount,
	--				ExtraPostingDetailWiseTaxes.ConvertionRate AS ExRate, 
	--				Currencies.ISOCode AS TrCurr	
	--		FROM ExtraPostingDetailWiseTaxes INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetailWiseTaxes.CurrencyId
	--		WHERE ExtraPostingDetailId IN (
	--			SELECT ExtraPostingDetails.Id
	--			FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
	--			WHERE	--CAST(ChargeDate AS DATE) = @ChargeDate
	--					--AND ExtraPostingDetails.DocumentNoPrefix <> 'INV'
	--					--AND 
	--					IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
	--					AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
	--					--AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
	--					AND ExtraPostingDetails.DocumentNoPrefix = 'DIS'
	--					AND ExtraPostingDetails.DocumentNo = @DocumentNo
	--					AND Amount <> 0
	--		)
	--		GROUP BY AccountCode, TaxName, ConvertionRate, ISOCode

	--	) X
		
	--	SELECT @AccAmount = SUM(Amount) FROM #TempGLlinkSale WHERE drcr = IIF(@isReinstate = 0,'D','C')

	--	UPDATE #TempGLlinkSale SET AccAmount = @AccAmount

	--	SELECT @CAmount = IIF(SUM(Amount) IS NULL,0,SUM(Amount)) FROM #TempGLlinkSale WHERE drcr = IIF(@isReinstate = 0,'C','D')


	--	--INSERT REVERSE REVENUE & REVERSE TAXES ENTRIES
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno, ResInvoiceNo, TransType, FCAmount, ExRate, TrCurr, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	SELECT *, SUBSTRING(AccCode,1,2) MainClasscode, SUBSTRING(AccCode,3,2) SubClasscode, SUBSTRING(AccCode,5,4) MainAccCode, SUBSTRING(AccCode,9,4) SubAccCode, GETDATE() FROM #TempGLlinkSale

	--	--INSERT REVERSE INHOUSEDEBTOR ENTRY
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno, ResInvoiceNo, Transtype, FCAmount, ExRate, TrCurr, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	VALUES (@Jno,'J','H',@InHouseDebtorAcc,'00','0000','','F','',@ChargeDate,IIF(@isReinstate = 0,'C','D'),@AccAmount,(@AccAmount-@CAmount),IIF(@isReinstate = 0,'','Cancellation of ') +'Discount For Document No. '+@DocumentNo, @user,'001',@DocumentNo, '', 'DI', NULL, NULL, NULL, 1, SUBSTRING(@InHouseDebtorAcc,1,2), SUBSTRING(@InHouseDebtorAcc,3,2), SUBSTRING(@InHouseDebtorAcc,5,4), SUBSTRING(@InHouseDebtorAcc,9,4), GETDATE())

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Journals = Journals + 1
	--END


	--begin try drop table #TempGLlinkSale end try
	--begin catch end catch
	

END

GO

