

CREATE PROCEDURE [dbo].[GL_POSTING_FO_EXTRA_POSTINGS_DEBITNOTE] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'

	DECLARE @DrAmt AS MONEY
	
	DECLARE @SegmentID AS INT = 0

	DECLARE @BlockCode AS VARCHAR(4) = 'PMT'


	SELECT @DrAmt = SUM(AMT)
	from (
		SELECT SUM(ISNULL(ABS(ChargeAmount),0)) Amt FROM CreditAndDebitNotesDetails WHERE CreditAndDebitNotesDetails.id IN ( SELECT CreditAndDebitNotesDetails.Id FROM CreditAndDebitNotesDetails INNER JOIN CreditAndDebitNotesWiseTaxes  ON CreditAndDebitNotesDetails.Id = CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId  )  AND IIF(CreditAndDebitNotesDetails.IsAdvance IS NULL,0,CreditAndDebitNotesDetails.IsAdvance) <> 1 AND IIF(CreditAndDebitNotesDetails.IsRefund IS NULL,0,CreditAndDebitNotesDetails.IsRefund) <> 1  AND IIF(CreditAndDebitNotesDetails.IsRebate IS NULL,0,CreditAndDebitNotesDetails.IsRebate) <> 1 AND DocumentNoPrefix <> 'RES' AND DocumentNoPrefix <> 'DIS' AND CAST(ChargeDate AS DATE) = @CurrDate AND CreditAndDebitNotesDetails.CreditOrDebit = 'D' AND CreditAndDebitNotesDetails.propertyID = @PropertyID
		UNION ALL
		SELECT SUM(ISNULL(ABS(Amount),0)) Amt FROM CreditAndDebitNotesWiseTaxes WHERE ExtraPostingDetailId IN ( SELECT CreditAndDebitNotesDetails.Id FROM CreditAndDebitNotesDetails INNER JOIN CreditAndDebitNotesWiseTaxes ON CreditAndDebitNotesDetails.Id = CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId  WHERE	CAST(ChargeDate AS DATE) = @CurrDate  AND IIF(CreditAndDebitNotesDetails.IsAdvance IS NULL,0,CreditAndDebitNotesDetails.IsAdvance) <> 1 AND IIF(CreditAndDebitNotesDetails.IsRefund IS NULL,0,CreditAndDebitNotesDetails.IsRefund) <> 1  AND IIF(CreditAndDebitNotesDetails.IsRebate IS NULL,0,CreditAndDebitNotesDetails.IsRebate) <> 1 AND CreditAndDebitNotesDetails.DocumentNoPrefix <> 'RES' AND CreditAndDebitNotesDetails.DocumentNoPrefix <> 'DIS' AND Amount <> 0 AND CreditAndDebitNotesDetails.CreditOrDebit = 'D' AND CreditAndDebitNotesDetails.propertyID = @PropertyID 
		) 
	)X





	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------

	--DECLARE @NextTempNo AS VARCHAR(12) = ''

	--EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_TEMP_NUMBER] @NextTempNo OUTPUT

	--SELECT @NextTempNo AS NextTempNo

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------



	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, UserID, ModName, SegmentCode, BSPCode, DocumentNo, BlockCode)

	-- GET EXTRA REVENUE
	SELECT		CAST(CreditAndDebitNotesDetails.ChargeDate AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				SUM(ABS(CreditAndDebitNotesDetails.OrginalAmount)) Amount,
				'Extra Posting Bills : DEBIT NOTE' Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				'C' DRCR,
				'1' SeqNo,
				'DN' TransType,
				CreditAndDebitNotesDetails.DocumentNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode AS SegmentCode,
				Companies.BSPCode AS BSPCode,
				CreditAndDebitNotesDetails.RefDocNo AS DocumentNo,
				@BlockCode AS BlockCode
	
	FROM CreditAndDebitNotesDetails INNER JOIN
							Currencies ON Currencies.Id = CreditAndDebitNotesDetails.CurrencyId
							INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON CreditAndDebitNotesDetails.PostingBillType = Destinity_GLIntegrationAccountMapping.Level1
					--INNER JOIN Users ON CreditAndDebitNotesDetails.CreatedUserID = Users.ID
					INNER JOIN CreditAndDebitNotesSettlements ON CreditAndDebitNotesDetails.Id = CreditAndDebitNotesSettlements.ExtraPostingId
					INNER JOIN Companies ON CreditAndDebitNotesSettlements.Companyid = Companies.Id
					
	WHERE CreditAndDebitNotesDetails.id IN (
					SELECT CreditAndDebitNotesDetails.Id
					FROM CreditAndDebitNotesDetails INNER JOIN CreditAndDebitNotesWiseTaxes 
					ON CreditAndDebitNotesDetails.Id = CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId 
					WHERE CreditAndDebitNotesDetails.propertyID = @PropertyID
				)
			
				AND IIF(CreditAndDebitNotesDetails.IsAdvance IS NULL,0,CreditAndDebitNotesDetails.IsAdvance) <> 1 AND IIF(CreditAndDebitNotesDetails.IsRefund IS NULL,0,CreditAndDebitNotesDetails.IsRefund) <> 1 
				AND IIF(CreditAndDebitNotesDetails.IsRebate IS NULL,0,CreditAndDebitNotesDetails.IsRebate) <> 1
				AND DocumentNoPrefix <> 'RES'
				AND DocumentNoPrefix <> 'DIS'
				AND CAST(ChargeDate AS DATE) = @CurrDate
				AND Destinity_GLIntegrationAccountMapping.blockcode LIKE 'PO%'
				AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
				AND CreditAndDebitNotesDetails.CreditOrDebit = 'D'
				AND CreditAndDebitNotesDetails.propertyID = @PropertyID
	GROUP BY CAST(CreditAndDebitNotesDetails.ChargeDate AS DATE), LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12),-- Users.GUID
			eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode,
			CreditAndDebitNotesDetails.DocumentNo, Companies.BSPCode, CreditAndDebitNotesDetails.RefDocNo

	UNION ALL

	-- GET TAXES
	
	SELECT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			SUM(ABS(CreditAndDebitNotesWiseTaxes.Amount)) Amount,
			'Extra Posting Bills : DEBIT NOTE' Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'DN' TransType,
			CreditAndDebitNotesDetails.DocumentNo TempTxnNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			'H' ModName,
			eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode AS SegmentCode,
			Companies.BSPCode AS BSPCode,
			CreditAndDebitNotesDetails.RefDocNo AS DocumentNo,
			@BlockCode AS BlockCode
	
	FROM CreditAndDebitNotesWiseTaxes INNER JOIN
					Currencies ON Currencies.Id = CreditAndDebitNotesWiseTaxes.CurrencyId
					INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON CreditAndDebitNotesWiseTaxes.TaxID = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN CreditAndDebitNotesSettlements ON CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId = CreditAndDebitNotesSettlements.ExtraPostingId
					INNER JOIN Companies ON CreditAndDebitNotesSettlements.Companyid = Companies.Id
					INNER JOIN CreditAndDebitNotesDetails ON CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId = CreditAndDebitNotesDetails.Id

	WHERE ExtraPostingDetailId IN (
			SELECT CreditAndDebitNotesDetails.Id
			FROM CreditAndDebitNotesDetails INNER JOIN CreditAndDebitNotesWiseTaxes ON CreditAndDebitNotesDetails.Id = CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId 
			WHERE	CAST(ChargeDate AS DATE) = @CurrDate
						
					AND IIF(CreditAndDebitNotesDetails.IsAdvance IS NULL,0,CreditAndDebitNotesDetails.IsAdvance) <> 1 AND IIF(CreditAndDebitNotesDetails.IsRefund IS NULL,0,CreditAndDebitNotesDetails.IsRefund) <> 1 
					AND IIF(CreditAndDebitNotesDetails.IsRebate IS NULL,0,CreditAndDebitNotesDetails.IsRebate) <> 1
					AND CreditAndDebitNotesDetails.DocumentNoPrefix <> 'RES'
					AND CreditAndDebitNotesDetails.DocumentNoPrefix <> 'DIS'
					AND Amount <> 0
					AND CreditAndDebitNotesDetails.CreditOrDebit = 'D'
					AND CreditAndDebitNotesDetails.propertyID = @PropertyID
		) AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX'
		AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
	
	GROUP BY LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode,
			CreditAndDebitNotesDetails.DocumentNo, Companies.BSPCode, CreditAndDebitNotesDetails.RefDocNo

	UNION ALL

	-- START DEBIT ENTRY --
	SELECT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			SUM(ABS(CreditAndDebitNotesSettlements.Amount)) Amount,
			'Extra Posting Bills : DEBIT NOTE' Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'3' SeqNo,
			'DN' TransType,
			CreditAndDebitNotesDetails.DocumentNo TempTxnNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			'H' ModName,
			eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode AS SegmentCode,
			Companies.BSPCode AS BSPCode,
			CreditAndDebitNotesDetails.RefDocNo AS DocumentNo,
			@BlockCode AS BlockCode

	FROM	CreditAndDebitNotesSettlements INNER JOIN
					Currencies ON Currencies.Id = CreditAndDebitNotesSettlements.CurrencyId
					INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON CreditAndDebitNotesSettlements.PaymentType = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN CreditAndDebitNotesDetails ON CreditAndDebitNotesSettlements.extrapostingId = CreditAndDebitNotesDetails.id
					INNER JOIN Companies ON CreditAndDebitNotesSettlements.Companyid = Companies.Id

	WHERE	ExtraPostingId IN (
				SELECT CreditAndDebitNotesDetails.Id
				FROM CreditAndDebitNotesDetails INNER JOIN CreditAndDebitNotesWiseTaxes 
					ON CreditAndDebitNotesDetails.Id = CreditAndDebitNotesWiseTaxes.ExtraPostingDetailId 
				WHERE	CAST(ChargeDate AS DATE) = @CurrDate 
						AND IIF(CreditAndDebitNotesDetails.IsAdvance IS NULL,0,CreditAndDebitNotesDetails.IsAdvance) <> 1 AND IIF(CreditAndDebitNotesDetails.IsRefund IS NULL,0,CreditAndDebitNotesDetails.IsRefund) <> 1 
						AND IIF(CreditAndDebitNotesDetails.IsRebate IS NULL,0,CreditAndDebitNotesDetails.IsRebate) <> 1
						AND CreditAndDebitNotesDetails.DocumentNoPrefix <> 'RES'
						AND CreditAndDebitNotesDetails.DocumentNoPrefix <> 'DIS'
						AND CreditAndDebitNotesDetails.CreditOrDebit = 'D'
						AND CreditAndDebitNotesDetails.propertyID = @PropertyID
			)
			AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT'
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
	
	GROUP BY LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode, 
			CreditAndDebitNotesDetails.DocumentNo, Companies.BSPCode, CreditAndDebitNotesDetails.RefDocNo

-- END DEBIT ENTRY --


	---- DrCr Tally

	DECLARE @ACCCODE_DIFF AS VARCHAR(12) = ''
	DECLARE @SegmentID_DIFF AS INT = 0

	SELECT @ACCCODE_DIFF = AccCode, @SegmentID_DIFF = SegmentCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE BlockCode = 'RND' AND GLCompCode = @GLCompCode

	
	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, UserID, ModName, SegmentCode, BSPCode, DocumentNo, BlockCode)
	
	SELECT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			'00' Outlet,
			ABS(SUM(case when drcr='D' then amount else 0 end) - SUM(case when drcr='C' then amount else 0 end)) Amount,
			'Rounded-off difference' AS Narration,
			@ACCCODE_DIFF AccCode,
			CASE WHEN (SUM(case when drcr='D' then amount else 0 end) - SUM(case when drcr='C' then amount else 0 end))>=0 THEN 'C' ELSE 'D' END DRCR,
			'4' SeqNo,
			'DN' TransType,
			TempTxnNo AS TempTxnNo,
			'' TxnNo,
			'J' TxnID,
			UserID UserID,
			'H' ModName,
			@SegmentID_DIFF SegmentCode,
			BSPCode AS BSPCode,
			DocumentNo AS DocumentNo,
			@BlockCode AS BlockCode
	
	FROM eFinancials_Accounting.dbo.GL_POSTING
	
	WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate AND Transtype = 'DN'
	
	GROUP BY TempTxnNo, BSPCode, DocumentNo, UserID
	
	HAVING	ABS(sum(case when drcr='D' then amount else 0 end) - sum(case when drcr='C' then amount else 0 end)) > 0 AND
		ABS(sum(case when drcr='D' then amount else 0 end) - sum(case when drcr='C' then amount else 0 end)) < 1
		AND SUM(case when drcr='D' then amount else 0 end) - SUM(case when drcr='C' then amount else 0 end)>=0

	---- DrCr Tally



END

GO

