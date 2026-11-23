

CREATE PROCEDURE [dbo].[GL_POSTING_FO_ROOM_CHARGE] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

--SET DATEFORMAT DMY EXEC [GL_POSTING_FO_ROOM_CHARGE] '26/08/2020', 'B490B26A-2886-4671-8253-A8644C76660F', 8, '001'

AS
BEGIN

	SET DATEFORMAT DMY

	DECLARE @DrAmt AS MONEY
	DECLARE @AccommodationChargeCodeId AS INT


	SELECT @AccommodationChargeCodeId = AccommodationChargeCodeId FROM FOSettings WHERE PropertyID = @PropertyID


	SELECT @DrAmt = ROUND(SUM(AMT),2)
	from (
	SELECT SUM(ISNULL((Amount),0)) Amt FROM FolioWisePostingBreakUp WHERE CAST(FolioWisePostingBreakUp.Date AS DATE) = @CurrDate AND FolioWisePostingBreakUp.PropertyID = @PropertyID
	union all
	SELECT SUM(ISNULL((Amount),0)) Amt FROM InhouseReservationHeaders INNER JOIN
                         FoliowiseTaxDetails INNER JOIN
                         FolioDetails ON FoliowiseTaxDetails.FolioDetailID = FolioDetails.FolioDetailID INNER JOIN
                         FolioHeader ON FolioDetails.FolioHeaderID = FolioHeader.FolioHeaderID ON InhouseReservationHeaders.Id = FolioHeader.ReservationHeaderID  WHERE FoliowiseTaxDetails.Amount <> 0 AND CAST(FoliowiseTaxDetails.Date AS DATE) = @CurrDate AND FolioDetails.ChargeCodeID =  @AccommodationChargeCodeId AND FolioDetails.IsDirectRoomPosting = 1 AND InhouseReservationHeaders.PropertyId = @PropertyID
	union all
	SELECT SUM(ISNULL((Amount),0)) Amt FROM InhouseReservationHeaders INNER JOIN
                         FoliowiseTaxDetailsHistory INNER JOIN
                         FolioDetailsHistory ON FoliowiseTaxDetailsHistory.FolioDetailID = FolioDetailsHistory.FolioDetailID INNER JOIN
                         FolioHeaderHistory ON FolioDetailsHistory.FolioHeaderID = FolioHeaderHistory.FolioHeaderID ON InhouseReservationHeaders.Id = FolioHeaderHistory.ReservationHeaderID  WHERE FoliowiseTaxDetailsHistory.Amount <> 0 AND CAST(FoliowiseTaxDetailsHistory.Date AS DATE) = @CurrDate AND FolioDetailsHistory.ChargeCodeID =  @AccommodationChargeCodeId AND FolioDetailsHistory.IsDirectRoomPosting = 1 AND InhouseReservationHeaders.PropertyId = @PropertyID
	union all
	SELECT SUM(ISNULL((Amount),0)) Amt FROM CheckedOutReservationHeaders INNER JOIN
                         FoliowiseTaxDetailsHistory INNER JOIN
                         FolioDetailsHistory ON FoliowiseTaxDetailsHistory.FolioDetailID = FolioDetailsHistory.FolioDetailID INNER JOIN
                         FolioHeaderHistory ON FolioDetailsHistory.FolioHeaderID = FolioHeaderHistory.FolioHeaderID ON CheckedOutReservationHeaders.Id = FolioHeaderHistory.ReservationHeaderID  WHERE FoliowiseTaxDetailsHistory.Amount <> 0 AND CAST(FoliowiseTaxDetailsHistory.Date AS DATE) = @CurrDate AND FolioDetailsHistory.ChargeCodeID =  @AccommodationChargeCodeId AND FolioDetailsHistory.IsDirectRoomPosting = 1 AND CheckedOutReservationHeaders.PropertyId = @PropertyID
	) x

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------

	DECLARE @NextTempNo AS VARCHAR(12) = ''

	EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_TEMP_NUMBER] @NextTempNo OUTPUT

	SELECT @NextTempNo AS NextTempNo

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------

	IF ISNULL(@DrAmt,0) <> 0 BEGIN

		INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, UserID, ModName,SegmentCode)

		-- START ROOM REVENUE --

		SELECT	CAST(FolioWisePostingBreakUp.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ABS(ROUND(SUM(((FolioWisePostingBreakUp.Amount))),2)) Amount,
				PostingTypes.Name Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				IIF(SUM(FolioWisePostingBreakUp.Amount)>=0,'C','D') DRCR,
				'1' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM	FolioWisePostingBreakUp INNER JOIN
								PostingTypes ON FolioWisePostingBreakUp.PostingTypeId = PostingTypes.Id --AND FolioWisePostingBreakUp.ChargeCodeId = PostingTypes.ChargeCodeId
				--INNER JOIN Users ON FolioWisePostingBreakUp.CreatedUserID = Users.ID
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON FolioWisePostingBreakUp.PostingTypeID = Destinity_GLIntegrationAccountMapping.Level1
		WHERE        CAST(FolioWisePostingBreakUp.Date AS DATE) = @CurrDate AND Destinity_GLIntegrationAccountMapping.blockcode = 'POA' AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
					AND FolioWisePostingBreakUp.PropertyId = @PropertyID

		GROUP BY CAST(FolioWisePostingBreakUp.Date AS DATE), PostingTypes.Name, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode--, Users.GUID
	
		-- END ROOM REVENUE --

		UNION ALL

		-- START FOOD REVENUE --

		SELECT	CAST(FolioWisePostingBreakUp.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ROUND(SUM((FolioWisePostingBreakUp.Amount)),2) Amount,
				PostingTypes.Name Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				IIF(SUM(FolioWisePostingBreakUp.Amount)>0,'C','D') DRCR,
				'1' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM	FolioWisePostingBreakUp INNER JOIN
								PostingTypes ON FolioWisePostingBreakUp.PostingTypeId = PostingTypes.Id --AND FolioWisePostingBreakUp.ChargeCodeId = PostingTypes.ChargeCodeId
				--INNER JOIN Users ON FolioWisePostingBreakUp.CreatedUserID = Users.ID
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON FolioWisePostingBreakUp.PostingTypeID = Destinity_GLIntegrationAccountMapping.Level1
		WHERE        CAST(FolioWisePostingBreakUp.Date AS DATE) = @CurrDate AND Destinity_GLIntegrationAccountMapping.blockcode = 'POF' AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
					AND FolioWisePostingBreakUp.PropertyId = @PropertyID

		GROUP BY CAST(FolioWisePostingBreakUp.Date AS DATE), PostingTypes.Name, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode--, Users.GUID
	
		-- END FOOD REVENUE --

		UNION ALL

		-- START BEVERAGE REVENUE --

		SELECT	CAST(FolioWisePostingBreakUp.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ROUND(SUM((FolioWisePostingBreakUp.Amount)),2) Amount,
				PostingTypes.Name Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				IIF(SUM(FolioWisePostingBreakUp.Amount)>0,'C','D') DRCR,
				'1' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM	FolioWisePostingBreakUp INNER JOIN
								PostingTypes ON FolioWisePostingBreakUp.PostingTypeId = PostingTypes.Id --AND FolioWisePostingBreakUp.ChargeCodeId = PostingTypes.ChargeCodeId
				--INNER JOIN Users ON FolioWisePostingBreakUp.CreatedUserID = Users.ID
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON FolioWisePostingBreakUp.PostingTypeID = Destinity_GLIntegrationAccountMapping.Level1
		WHERE        CAST(FolioWisePostingBreakUp.Date AS DATE) = @CurrDate AND Destinity_GLIntegrationAccountMapping.blockcode = 'POB' AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
					AND FolioWisePostingBreakUp.PropertyId = @PropertyID

		GROUP BY CAST(FolioWisePostingBreakUp.Date AS DATE), PostingTypes.Name, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode--, Users.GUID
	
		-- END BEVERAGE REVENUE --

				UNION ALL

		-- START OTHER REVENUE --

		SELECT	CAST(FolioWisePostingBreakUp.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ROUND(SUM((FolioWisePostingBreakUp.Amount)),2) Amount,
				PostingTypes.Name Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				IIF(SUM(FolioWisePostingBreakUp.Amount)>0,'C','D') DRCR,
				'1' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM	FolioWisePostingBreakUp INNER JOIN
								PostingTypes ON FolioWisePostingBreakUp.PostingTypeId = PostingTypes.Id --AND FolioWisePostingBreakUp.ChargeCodeId = PostingTypes.ChargeCodeId
				--INNER JOIN Users ON FolioWisePostingBreakUp.CreatedUserID = Users.ID
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON FolioWisePostingBreakUp.PostingTypeID = Destinity_GLIntegrationAccountMapping.Level1
		WHERE        CAST(FolioWisePostingBreakUp.Date AS DATE) = @CurrDate AND Destinity_GLIntegrationAccountMapping.blockcode = 'POO' AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
				AND FolioWisePostingBreakUp.PropertyId = @PropertyID

		GROUP BY CAST(FolioWisePostingBreakUp.Date AS DATE), PostingTypes.Name, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode--, Users.GUID
	
		-- END OTHER REVENUE --

		UNION ALL

		-- START TAX (INHOUSE CURRENT) --	
		SELECT 	CAST(FoliowiseTaxDetails.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ROUND(SUM((FoliowiseTaxDetails.Amount)),2) Amount,
				FoliowiseTaxDetails.TaxName Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				'C' DRCR,
				'2' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM InhouseReservationHeaders INNER JOIN
                         FoliowiseTaxDetails INNER JOIN
                         FolioDetails ON FoliowiseTaxDetails.FolioDetailID = FolioDetails.FolioDetailID INNER JOIN
                         FolioHeader ON FolioDetails.FolioHeaderID = FolioHeader.FolioHeaderID ON InhouseReservationHeaders.Id = FolioHeader.ReservationHeaderID	
		--FoliowiseTaxDetails 
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping 
			ON FoliowiseTaxDetails.TaxID = Destinity_GLIntegrationAccountMapping.Level1
		
		WHERE FoliowiseTaxDetails.Amount <> 0 AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX' AND CAST(FoliowiseTaxDetails.Date AS DATE) = @CurrDate
				AND FolioDetails.ChargeCodeID =  @AccommodationChargeCodeId AND FolioDetails.IsDirectRoomPosting = 1 AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
				AND InhouseReservationHeaders.PropertyId = @PropertyID

		GROUP BY CAST(FoliowiseTaxDetails.Date AS DATE), FoliowiseTaxDetails.TaxName, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode

		-- END TAX (INHOUSE CURRENT) --	

		UNION ALL

		-- START TAX (INHOUSE HISTORY) --	
		SELECT 	CAST(FoliowiseTaxDetailsHistory.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ROUND(SUM((FoliowiseTaxDetailsHistory.Amount)),2) Amount,
				FoliowiseTaxDetailsHistory.TaxName Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				'C' DRCR,
				'2' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM InhouseReservationHeaders INNER JOIN
                         FoliowiseTaxDetailsHistory INNER JOIN
                         FolioDetailsHistory ON FoliowiseTaxDetailsHistory.FolioDetailID = FolioDetailsHistory.FolioDetailID INNER JOIN
                         FolioHeaderHistory ON FolioDetailsHistory.FolioHeaderID = FolioHeaderHistory.FolioHeaderID ON InhouseReservationHeaders.Id = FolioHeaderHistory.ReservationHeaderID	
		--FoliowiseTaxDetails 
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping 
			ON FoliowiseTaxDetailsHistory.TaxID = Destinity_GLIntegrationAccountMapping.Level1

		WHERE FoliowiseTaxDetailsHistory.Amount <> 0 AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX' AND CAST(FoliowiseTaxDetailsHistory.Date AS DATE) = @CurrDate
			AND FolioDetailsHistory.ChargeCodeID =  @AccommodationChargeCodeId AND FolioDetailsHistory.IsDirectRoomPosting = 1 AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
			AND InhouseReservationHeaders.PropertyId = @PropertyID

		GROUP BY CAST(FoliowiseTaxDetailsHistory.Date AS DATE), FoliowiseTaxDetailsHistory.TaxName, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode

		-- END TAX (INHOUSE HISTORY) --	

		UNION ALL

		-- START TAX (HISTORY) --	
		SELECT 	CAST(FoliowiseTaxDetailsHistory.Date AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				ROUND(SUM((FoliowiseTaxDetailsHistory.Amount)),2) Amount,
				FoliowiseTaxDetailsHistory.TaxName Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				'C' DRCR,
				'3' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM CheckedOutReservationHeaders INNER JOIN
                         FoliowiseTaxDetailsHistory INNER JOIN
                         FolioDetailsHistory ON FoliowiseTaxDetailsHistory.FolioDetailID = FolioDetailsHistory.FolioDetailID INNER JOIN
                         FolioHeaderHistory ON FolioDetailsHistory.FolioHeaderID = FolioHeaderHistory.FolioHeaderID ON CheckedOutReservationHeaders.Id = FolioHeaderHistory.ReservationHeaderID

		--FoliowiseTaxDetailsHistory 
		INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping 
			ON FoliowiseTaxDetailsHistory.TaxID = Destinity_GLIntegrationAccountMapping.Level1
		
		WHERE FoliowiseTaxDetailsHistory.Amount <> 0 AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAX' AND CAST(FoliowiseTaxDetailsHistory.Date AS DATE) = @CurrDate
			AND FolioDetailsHistory.ChargeCodeID =  @AccommodationChargeCodeId AND FolioDetailsHistory.IsDirectRoomPosting = 1 AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
			AND CheckedOutReservationHeaders.PropertyId = @PropertyID

		GROUP BY CAST(FoliowiseTaxDetailsHistory.Date AS DATE), FoliowiseTaxDetailsHistory.TaxName, LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12), Destinity_GLIntegrationAccountMapping.SegmentCode

		-- END TAX (HISTORY) --	

		UNION ALL

		-- START INHOUSE DEBTOR ENTRY --

		SELECT	CAST(@CurrDate AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' DeptCode,
				'00' Outlet,
				@DrAmt Amount,
				'Room Sale' Narration,
				LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
				'D' DRCR,
				'4' SeqNo,
				'CS' TransType,
				@NextTempNo TempTxnNo,
				'' TxnNo,
				'J' TxnID,
				@DayEndUserID UserID,
				'H' ModName,
				Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode

		FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping 
		WHERE   Destinity_GLIntegrationAccountMapping.blockcode = 'INH' AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode

		-- END INHOUSE DEBTOR ENTRY --
	
	END

	---- DrCr Tally

	DECLARE @ACCCODE_DIFF AS VARCHAR(12) = ''
	DECLARE @SegmentID_DIFF AS INT = 0
	DECLARE @DRCR_DIFF AS CHAR(1) = ''
	DECLARE @DIFF DECIMAL(38, 8)

	SELECT @ACCCODE_DIFF = AccCode, @SegmentID_DIFF = SegmentCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE BlockCode = 'RND' AND GLCompCode = @GLCompCode

	SELECT @DIFF = sum(case when drcr='D' then amount else 0 end) - sum(case when drcr='C' then amount else 0 end)
	FROM eFinancials_Accounting.dbo.GL_POSTING
	WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate AND Transtype = 'CS'
	
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
				'0' SeqNo,
				'CS' TransType,
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

