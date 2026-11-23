

CREATE PROCEDURE [dbo].[GL_POSTING_FO_ADVANCE_RECEIVED_INHOUSE_GENERAL] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'
	DECLARE @BLOCKCODE AS VARCHAR(3) = 'ADV'
	DECLARE @BLOCKCODECC AS VARCHAR(3) = 'PMT'
	DECLARE @BLOCKCODELEVEL1 AS VARCHAR(3) = 'ADI'
	DECLARE @BLOCKCODELEVEL1R AS VARCHAR(3) = 'ADR'
	DECLARE @ACCCODE AS VARCHAR(12) = ''
	DECLARE @ACCCODER AS VARCHAR(12) = ''
	DECLARE @TransType AS VARCHAR(2) = 'AR'
	DECLARE @PID AS INT = 0
	DECLARE @PIDR AS INT = 0
	DECLARE @SegmentID AS INT = 0
	DECLARE @BaseCurrCode AS INT = 0

	SELECT @PID = AdvancedPayment_InhousePostingTypeId, @PIDR = AdvancedPayment_ReservationPostingTypeId, @BaseCurrCode = BaseCurrencyISO FROM FOSettings WHERE PropertyId = @PropertyID

	SELECT   @ACCCODE =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.AccCode,
			@SegmentID =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode
	FROM            eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping INNER JOIN
								eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks ON 
								eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.BlockCode = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks.BlockCode
	WHERE        (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.BlockCode = @BLOCKCODE) AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 = @BLOCKCODELEVEL1)
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)

	SELECT   @ACCCODER =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.AccCode
	FROM            eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping INNER JOIN
								eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks ON 
								eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.BlockCode = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks.BlockCode
	WHERE        (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.BlockCode = @BLOCKCODE) AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 = @BLOCKCODELEVEL1R)
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)


	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount, BlockCode, BSPCode)


	-------------------------------- START INHOUSE RESERVATION ADVANCES --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', I.Reservation No.: ' +InhouseReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'1' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'R' TxnID,
			@DayEndUserID UserID,
			CAST(PaymentModes.ID AS VARCHAR)+ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			@BLOCKCODECC AS BlockCode,
			Destinity_GLIntegrationAccountMapping.Level2 AS BSPCode
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND ExtraPostingDetails.PostingBillType = @PID --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR'
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND PaymentModes.PaymentType <> 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	UNION ALL	

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', I.Reservation No.: ' +InhouseReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'2' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'R' TxnID,
			@DayEndUserID UserID,
			CAST(PaymentModes.ID AS VARCHAR)+ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			@BLOCKCODECC AS BlockCode,
			Destinity_GLIntegrationAccountMapping.Level2 AS BSPCode
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingSettlements.PaymentType = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT' AND ExtraPostingDetails.PostingBillType = @PID
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
			AND PaymentModes.PaymentType <> 'CC'
			--AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	-------------------------------- END INHOUSE RESERVATION ADVANCES --------------------------------

	UNION ALL

	-------------------------------- START CHECKEDOUT RESERVATION ADVANCES --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', I.Reservation No.: ' +CheckedOutReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'1' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'R' TxnID,
			@DayEndUserID UserID,
			CAST(PaymentModes.ID AS VARCHAR)+ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			@BLOCKCODECC AS BlockCode,
			Destinity_GLIntegrationAccountMapping.Level2 AS BSPCode
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND ExtraPostingDetails.PostingBillType = @PID --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR'
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND PaymentModes.PaymentType <> 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	UNION ALL	

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', I.Reservation No.: ' +CheckedOutReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'2' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'R' TxnID,
			@DayEndUserID UserID,
			CAST(PaymentModes.ID AS VARCHAR)+ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			@BLOCKCODECC AS BlockCode,
			Destinity_GLIntegrationAccountMapping.Level2 AS BSPCode
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingSettlements.PaymentType = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT' AND ExtraPostingDetails.PostingBillType = @PID
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
			AND PaymentModes.PaymentType <> 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	-------------------------------- END CHECKEDOUT RESERVATION ADVANCES --------------------------------


		UNION ALL	

	-------------------------------- START TRANSFER OF ADVANCES (CHECKED IN) --------------------------------

	SELECT DISTINCT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODER,12) AccCode,
			'D' DRCR,
			'1' SeqNo,
			'AT' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			NULL AS BlockCode,
			NULL AS BSPCode
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				--INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE        (ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR' 
			AND InhouseReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
			--AND PaymentModes.PaymentType = 'CC'
			--AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC
			AND ExtraPostingDetails.propertyID = @PropertyID

	UNION ALL

	SELECT DISTINCT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'AT' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			NULL AS BlockCode,
			NULL AS BSPCode
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				--INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE        (ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADI' 
				AND InhouseReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
			--	AND PaymentModes.PaymentType = 'CC'
			--AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC
				AND ExtraPostingDetails.propertyID = @PropertyID

	-------------------------------- END TRANSFER OF ADVANCES (CHECKED IN) --------------------------------

	UNION ALL	

	-------------------------------- START TRANSFER OF ADVANCES (CHECKED OUT) --------------------------------

	SELECT DISTINCT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODER,12) AccCode,
			'D' DRCR,
			'1' SeqNo,
			'AT' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			NULL AS BlockCode,
			NULL AS BSPCode
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				--INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE        (ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR' 
				AND CheckedOutReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
				AND ExtraPostingDetails.propertyID = @PropertyID
			--	AND PaymentModes.PaymentType = 'CC'
			--AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	UNION ALL

	SELECT DISTINCT	CAST(@CurrDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'AT' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount,
			NULL AS BlockCode,
			NULL AS BSPCode
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				--INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE        (ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADI' 
				AND CheckedOutReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
				AND ExtraPostingDetails.propertyID = @PropertyID
			--	AND PaymentModes.PaymentType = 'CC'
			--AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	-------------------------------- END TRANSFER OF ADVANCES (CHECKED OUT) --------------------------------



END

GO

