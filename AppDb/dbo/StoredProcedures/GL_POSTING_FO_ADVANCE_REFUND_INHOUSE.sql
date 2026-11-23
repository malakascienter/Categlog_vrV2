

CREATE PROCEDURE [dbo].[GL_POSTING_FO_ADVANCE_REFUND_INHOUSE] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'
	DECLARE @BLOCKCODE AS VARCHAR(3) = 'ADV'
	--DECLARE @BLOCKCODELEVEL1 AS VARCHAR(3) = 'ADI'
	--DECLARE @BLOCKCODELEVEL1R AS VARCHAR(3) = 'ADR'
	DECLARE @ACCCODE AS VARCHAR(12) = ''
	DECLARE @ACCCODER AS VARCHAR(12) = ''
	DECLARE @PID AS INT = 0
	DECLARE @PIDR AS INT = 0
	DECLARE @SegmentID AS INT = 0
	DECLARE @BaseCurrCode AS INT = 0

	SELECT @PID = AdvancedPayment_InhousePostingTypeId, @PIDR = AdvancedPayment_ReservationPostingTypeId, @BaseCurrCode = BaseCurrencyISO FROM FOSettings WHERE PropertyId = @PropertyID

	SELECT	@ACCCODE = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.AccCode,
			@SegmentID =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode
	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping
	WHERE	(BlockCode = @BLOCKCODE) AND (Level2 = @PID) AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)

	SELECT   @ACCCODER =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.AccCode
	FROM            eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping
	WHERE	(BlockCode = @BLOCKCODE) AND (Level2 = @PIDR) AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)


	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount)


	-------------------------------- START INHOUSE RESERVATION ADVANCES --------------------------------

	SELECT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo +', Advance Document No.: '+ ExtraPostingDetails.RefDocNo +', I.Reservation No.: ' +InhouseReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'D' DRCR,
			'1' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE	(ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND ExtraPostingDetails.PostingBillType = @PID --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR'
			AND ExtraPostingDetails.propertyID = @PropertyID

	UNION ALL	

	SELECT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo +', Advance Document No.: '+ ExtraPostingDetails.RefDocNo +', I.Reservation No.: ' +InhouseReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingSettlements.PaymentType = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE	(ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT' AND ExtraPostingDetails.PostingBillType = @PID
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)

	-------------------------------- END INHOUSE RESERVATION ADVANCES --------------------------------

	UNION ALL

	-------------------------------- START CHECKEDOUT RESERVATION ADVANCES --------------------------------

	SELECT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo +', Advance Document No.: '+ ExtraPostingDetails.RefDocNo +', I.Reservation No.: ' +CheckedOutReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'D' DRCR,
			'1' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE	(ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND ExtraPostingDetails.PostingBillType = @PID --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR'
			AND ExtraPostingDetails.propertyID = @PropertyID

	UNION ALL	

	SELECT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo +', Advance Document No.: '+ ExtraPostingDetails.RefDocNo +', I.Reservation No.: ' +CheckedOutReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'C' DRCR,
			'2' SeqNo,
			'AR' TransType,
			ExtraPostingDetails.DocumentNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			ExtraPostingDetails.DocumentNo TempTxnNo,
			'H' ModName,
			@SegmentID SegmentCode,
			Currencies.ISOCode AS CurrCode,
			ABS(ExtraPostingDetails.ConvertionRate) AS ExRate,
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM	ExtraPostingDetails 
				INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingSettlements.PaymentType = Destinity_GLIntegrationAccountMapping.Level1
				INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE	(ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT' AND ExtraPostingDetails.PostingBillType = @PID
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)

	-------------------------------- END CHECKEDOUT RESERVATION ADVANCES --------------------------------


		UNION ALL	

	-------------------------------- START TRANSFER OF ADVANCES (CHECKED IN) --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODER,12) AccCode,
			'C' DRCR,
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
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE        (ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR' 
			AND InhouseReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
			AND ExtraPostingDetails.propertyID = @PropertyID

	UNION ALL

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODE,12) AccCode,
			'D' DRCR,
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
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE        (ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADI' 
				AND InhouseReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
				AND ExtraPostingDetails.propertyID = @PropertyID

	-------------------------------- END TRANSFER OF ADVANCES (CHECKED IN) --------------------------------

	UNION ALL	

	-------------------------------- START TRANSFER OF ADVANCES (CHECKED OUT) --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODER,12) AccCode,
			'C' DRCR,
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
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE        (ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR' 
				AND CheckedOutReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
				AND ExtraPostingDetails.propertyID = @PropertyID

	UNION ALL

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingDetails.ChargeAmount) Amount,
			'Transfer of Advance Refund from Document No.: '+ExtraPostingDetails.DocumentNo Narration,
			LEFT(@ACCCODE,12) AccCode,
			'D' DRCR,
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
		    (CASE WHEN ExtraPostingDetails.CurrencyID = @BaseCurrCode THEN 0 ELSE ABS(ExtraPostingDetails.AmountFC) END) AS FCAmount
	
	FROM            ExtraPostingDetails INNER JOIN
							 ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId
					--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ExtraPostingDetails.DocumentNoPrefix = Destinity_GLIntegrationAccountMapping.Level1
					INNER JOIN CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
					--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
	
	WHERE        (ExtraPostingDetails.IsRefund = 1) AND (ExtraPostingDetails.ChargeDate <= @CurrDate) --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADI' 
				AND CheckedOutReservationHeaders.checkedInDate = @CurrDate AND ExtraPostingDetails.PostingBillType = @PIDR
				AND ExtraPostingDetails.propertyID = @PropertyID

	-------------------------------- END TRANSFER OF ADVANCES (CHECKED OUT) --------------------------------



END

GO

