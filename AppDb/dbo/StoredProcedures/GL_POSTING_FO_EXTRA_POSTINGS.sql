

CREATE PROCEDURE [dbo].[GL_POSTING_FO_EXTRA_POSTINGS] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'

	DECLARE @DrAmt AS MONEY
	
	DECLARE @SegmentID AS INT = 0


	SELECT @DrAmt = SUM(AMT)
	from (
		SELECT SUM(ISNULL(ABS(ChargeAmount),0)) Amt FROM ExtraPostingDetails WHERE ExtraPostingDetails.id IN ( SELECT ExtraPostingDetails.Id FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes  ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId  )  AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1  AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1 AND DocumentNoPrefix <> 'RES' AND DocumentNoPrefix <> 'DIS' AND CAST(ChargeDate AS DATE) = @CurrDate AND ExtraPostingDetails.propertyID = @PropertyID
		UNION ALL
		SELECT SUM(ISNULL(ABS(Amount),0)) Amt FROM ExtraPostingDetailWiseTaxes WHERE ExtraPostingDetailId IN ( SELECT ExtraPostingDetails.Id FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId  WHERE	CAST(ChargeDate AS DATE) = @CurrDate  AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1  AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1 AND ExtraPostingDetails.DocumentNoPrefix <> 'RES' AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS' AND Amount <> 0 AND ExtraPostingDetails.propertyID = @PropertyID 
		) 
	)X





	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------

	DECLARE @NextTempNo AS VARCHAR(12) = ''

	EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_TEMP_NUMBER] @NextTempNo OUTPUT

	SELECT @NextTempNo AS NextTempNo

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------



	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, UserID, ModName, SegmentCode)

	-- GET EXTRA REVENUE
	SELECT		CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				SUM(ABS(ExtraPostingDetails.OrginalAmount)) Amount,
				'Extra Posting Bills' Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				'C' DRCR,
				'1' SeqNo,
				'MB' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode AS SegmentCode
	
	FROM ExtraPostingDetails INNER JOIN
							Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
							INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.PostingBillType = Destinity_GLIntegrationAccountMapping.Level1
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
	
	WHERE ExtraPostingDetails.id IN (
					SELECT ExtraPostingDetails.Id
					FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes 
					ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
					WHERE ExtraPostingDetails.propertyID = @PropertyID
				)
			
				AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
				AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
				AND ExtraPostingDetails.propertyID = @PropertyID
				AND DocumentNoPrefix <> 'RES'
				AND DocumentNoPrefix <> 'DIS'
				AND CAST(ChargeDate AS DATE) = @CurrDate
				AND Destinity_GLIntegrationAccountMapping.blockcode = 'POM'
				AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
	GROUP BY CAST(ExtraPostingDetails.ChargeDate AS DATE), LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12),-- Users.GUID
			eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode

	UNION ALL

	-- GET TAXES
	
	SELECT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			SUM(ABS(ExtraPostingDetailWiseTaxes.Amount)) Amount,
			'Extra Posting Bills' Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'MB' TransType,
			@NextTempNo TempTxnNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			'H' ModName,
			eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode AS SegmentCode
	
	FROM ExtraPostingDetailWiseTaxes INNER JOIN
					Currencies ON Currencies.Id = ExtraPostingDetailWiseTaxes.CurrencyId
					INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetailWiseTaxes.TaxID = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE ExtraPostingDetailId IN (
			SELECT ExtraPostingDetails.Id
			FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
			WHERE	CAST(ChargeDate AS DATE) = @CurrDate
						
					AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
					AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
					AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
					AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
					AND Amount <> 0
					AND ExtraPostingDetails.propertyID = @PropertyID
		) AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX'
		AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
	
	GROUP BY LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode

	UNION ALL

	-- START DEBIT ENTRY --
	SELECT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			SUM(ABS(ExtraPostingSettlements.Amount)) Amount,
			'Extra Posting Bills' Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'3' SeqNo,
			'MB' TransType,
			@NextTempNo TempTxnNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			'H' ModName,
			eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode AS SegmentCode

	FROM	ExtraPostingSettlements INNER JOIN
					Currencies ON Currencies.Id = ExtraPostingSettlements.CurrencyId
					INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingSettlements.PaymentType = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	ExtraPostingId IN (
				SELECT ExtraPostingDetails.Id
				FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes 
					ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId 
				WHERE	CAST(ChargeDate AS DATE) = @CurrDate 
						AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
						AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
						AND ExtraPostingDetails.DocumentNoPrefix <> 'RES'
						AND ExtraPostingDetails.DocumentNoPrefix <> 'DIS'
						AND ExtraPostingDetails.propertyID = @PropertyID
			)
			AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT'
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
			AND ExtraPostingSettlements.propertyID = @PropertyID
	
	GROUP BY LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode

-- END DEBIT ENTRY --


	---- DrCr Tally

	DECLARE @ACCCODE_DIFF AS VARCHAR(12) = ''
	DECLARE @SegmentID_DIFF AS INT = 0
	DECLARE @DRCR_DIFF AS CHAR(1) = ''
	DECLARE @DIFF DECIMAL(38, 8)

	SELECT @ACCCODE_DIFF = AccCode, @SegmentID_DIFF = SegmentCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE BlockCode = 'RND' AND GLCompCode = @GLCompCode

	SELECT @DIFF = sum(case when drcr='D' then amount else 0 end) - sum(case when drcr='C' then amount else 0 end)
	FROM eFinancials_Accounting.dbo.GL_POSTING
	WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate AND Transtype = 'MB'


	IF ABS(@DIFF) > 0 AND ABS(@DIFF) < 1 BEGIN

		IF @DIFF >= 0 BEGIN
			SET @DRCR_DIFF = 'C'
		END

		ELSE BEGIN
			SET @DRCR_DIFF = 'D'
		END
	
		INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, UserID, ModName, SegmentCode)
		SELECT	CAST(@CurrDate AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' AS DeptCode,
				'00' Outlet,
				ABS(@DIFF) Amount,
				'Rounded-off difference' AS Narration,
				@ACCCODE_DIFF AccCode,
				@DRCR_DIFF DRCR,
				'4' SeqNo,
				'MB' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				@SegmentID_DIFF SegmentCode

	END

	---- DrCr Tally



END

GO

