

CREATE PROCEDURE [dbo].[GL_POSTING_FO_EXTRA_POSTINGS_DISCOUNT] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'

	DECLARE @DrAmt AS MONEY
	
	DECLARE @SegmentID AS INT = 0
	
	DECLARE @InHouseAccCode AS VARCHAR(12) = ''


	SELECT @InHouseAccCode = AccCode, @SegmentID = SegmentCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE blockcode = 'INH' AND GLCompCode = @GLCompCode


	-- ChargeAmount changed to OrginalAmount on 16/09/2021
	SELECT @DrAmt = ISNULL(SUM(AMT),0)
	from (
			SELECT SUM(ISNULL(ABS(OrginalAmount),0)) Amt FROM ExtraPostingDetails INNER JOIN Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.PostingBillType = Destinity_GLIntegrationAccountMapping.Level1  WHERE ExtraPostingDetails.id IN ( SELECT ExtraPostingDetails.Id FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes  ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId WHERE ExtraPostingDetails.PropertyId = @PropertyID   ) AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1  AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1 AND DocumentNoPrefix <> 'RES' AND DocumentNoPrefix = 'DIS' AND CAST(ChargeDate AS DATE) = @CurrDate AND Destinity_GLIntegrationAccountMapping.blockcode IN ('POA','POF','POB','POO','POM') AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode) AND ExtraPostingDetails.PropertyId = @PropertyID
			UNION ALL
			SELECT SUM(ISNULL(ABS(Amount),0)) Amt FROM ExtraPostingDetailWiseTaxes INNER JOIN Currencies ON Currencies.Id = ExtraPostingDetailWiseTaxes.CurrencyId INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetailWiseTaxes.TaxID = Destinity_GLIntegrationAccountMapping.Level1  WHERE ExtraPostingDetailId IN ( SELECT ExtraPostingDetails.Id FROM ExtraPostingDetails INNER JOIN ExtraPostingDetailWiseTaxes ON ExtraPostingDetails.Id = ExtraPostingDetailWiseTaxes.ExtraPostingDetailId  WHERE	CAST(ChargeDate AS DATE) = @CurrDate  AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1  AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1 AND ExtraPostingDetails.DocumentNoPrefix <> 'RES' AND ExtraPostingDetails.DocumentNoPrefix = 'DIS' AND Amount <> 0 AND ExtraPostingDetails.PropertyId = @PropertyID ) AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX' AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
	)X


	IF @DrAmt>0 BEGIN


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
						SUM(ABS(ExtraPostingDetails.OrginalAmount)) Amount, -- ChargeAmount changed to OrginalAmount on 16/09/2021
						'Extra Posting Bills - Discount' Narration,
						LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
						'D' DRCR,
						'1' SeqNo,
						'DI' TransType,
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
							WHERE ExtraPostingDetails.PropertyId = @PropertyID
						)
			
						AND IIF(ExtraPostingDetails.IsAdvance IS NULL,0,ExtraPostingDetails.IsAdvance) <> 1 AND IIF(ExtraPostingDetails.IsRefund IS NULL,0,ExtraPostingDetails.IsRefund) <> 1 
						AND IIF(ExtraPostingDetails.IsRebate IS NULL,0,ExtraPostingDetails.IsRebate) <> 1
						AND DocumentNoPrefix <> 'RES'
						AND DocumentNoPrefix = 'DIS'
						AND CAST(ChargeDate AS DATE) = @CurrDate
						AND Destinity_GLIntegrationAccountMapping.blockcode IN ('POA','POF','POB','POO','POM')
						AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
						AND ExtraPostingDetails.PropertyId = @PropertyID
			GROUP BY CAST(ExtraPostingDetails.ChargeDate AS DATE), LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12),-- Users.GUID
					eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode

			UNION ALL

			-- GET TAXES
	
			SELECT	CAST(@CurrDate AS DATE) TxnDate,
					@GLCompCode CompCode,
					'00' DeptCode,
					'00' Outlet,
					SUM(ABS(ExtraPostingDetailWiseTaxes.Amount)) Amount,
					'Extra Posting Bills - Discount' Narration,
					LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
					'D' DRCR,
					'2' SeqNo,
					'DI' TransType,
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
							AND ExtraPostingDetails.DocumentNoPrefix = 'DIS'
							AND Amount <> 0
							AND ExtraPostingDetails.PropertyId = @PropertyID
				) AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX'
				AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
	
			GROUP BY LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode

			UNION ALL

			SELECT	CAST(@CurrDate AS DATE) TxnDate,
					@GLCompCode CompCode,
					'00' DeptCode,
					'00' Outlet,
					@DrAmt Amount,
					'Extra Posting Bills - Discount' Narration,
					LEFT(@InHouseAccCode,12) AccCode,
					'C' DRCR,
					'3' SeqNo,
					'DI' TransType,
					@NextTempNo TempTxnNo,
					'' TxnNo,
					'J' TxnID,
					@DayEndUserID UserID,
					'H' ModName,
					@SegmentID AS SegmentCode


		-- END CREDIT ENTRY --
	END

END

GO

