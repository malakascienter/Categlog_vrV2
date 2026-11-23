

CREATE PROCEDURE [dbo].[GL_POSTING_FO_ADVANCE_RECEIVED_RESERVATION_CREDITCARD] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

--SET DATEFORMAT DMY EXEC [GL_POSTING_FO_ADVANCE_RECEIVED_RESERVATION_CREDITCARD] '25/08/2020', 'B490B26A-2886-4671-8253-A8644C76660F', 8, '001'

AS
BEGIN

	SET DATEFORMAT DMY

	--DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'
	DECLARE @BLOCKCODE AS VARCHAR(3) = 'ADV'
	DECLARE @BLOCKCODECC AS VARCHAR(3) = 'PMT'
	DECLARE @BLOCKCODELEVEL1 AS VARCHAR(3) = 'ADR'
	DECLARE @ACCCODE AS VARCHAR(12) = ''
	DECLARE @TransType AS VARCHAR(2) = 'CC'
	DECLARE @PID AS INT = 0
	DECLARE @SegmentID AS INT = 0
	DECLARE @BaseCurrCode AS INT = 0

	SELECT @PID = AdvancedPayment_ReservationPostingTypeId, @BaseCurrCode = BaseCurrencyISO FROM FOSettings WHERE PropertyId = @PropertyID

	SELECT	@ACCCODE =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.AccCode,
			@SegmentID =     eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Segmentcode
	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping INNER JOIN
				eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks ON 
				eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.BlockCode = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMappingBlocks.BlockCode
	WHERE	(eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.BlockCode = @BLOCKCODE) AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 = @BLOCKCODELEVEL1)
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)



	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount, BlockCode, BSPCode)



	-------------------------------- START RESERVATION ADVANCES --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', Reservation No.: ' +ReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'1' SeqNo,
			@TransType AS TransType,
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
				INNER JOIN ReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = ReservationHeaders.Id
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND ExtraPostingDetails.PostingBillType = @PID --AND Destinity_GLIntegrationAccountMapping.blockcode = 'ADR'
			AND PaymentModes.PaymentType = 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC
			AND ExtraPostingDetails.propertyID = @PropertyID

	UNION ALL	

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', Reservation No.: ' +ReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'2' SeqNo,
			@TransType AS TransType,
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
				INNER JOIN ReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = ReservationHeaders.Id
				--INNER JOIN Users ON ExtraPostingDetails.CreatedUserID = Users.ID
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT' AND ExtraPostingDetails.PostingBillType = @PID
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
			AND PaymentModes.PaymentType = 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	-------------------------------- END RESERVATION ADVANCES --------------------------------

	UNION ALL

	-------------------------------- START INHOUSE RESERVATION ADVANCES --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', Reservation No.: ' +InhouseReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'3' SeqNo,
			@TransType AS TransType,
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
			AND PaymentModes.PaymentType = 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	UNION ALL	

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', Reservation No.: ' +InhouseReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'4' SeqNo,
			@TransType AS TransType,
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
				INNER JOIN Currencies ON ExtraPostingDetails.CurrencyID = Currencies.ID
				INNER JOIN PaymentModes  ON ExtraPostingSettlements.PaymentType = PaymentModes.Id 
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON PaymentModes.Id = Destinity_GLIntegrationAccountMapping.Level1
	
	WHERE	(ExtraPostingDetails.IsAdvance = 1) AND (ExtraPostingDetails.ChargeDate = @CurrDate) AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMT' AND ExtraPostingDetails.PostingBillType = @PID
			AND ExtraPostingDetails.propertyID = @PropertyID
			AND (eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode)
			AND PaymentModes.PaymentType = 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	-------------------------------- END INHOUSE RESERVATION ADVANCES --------------------------------

	UNION ALL

	-------------------------------- START CHECKEDOUT RESERVATION ADVANCES --------------------------------

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', Reservation No.: ' +CheckedOutReservationHeaders.ReservationNo AS Narration,
			LEFT(@ACCCODE,12) AccCode,
			'C' DRCR,
			'5' SeqNo,
			@TransType AS TransType,
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
			AND PaymentModes.PaymentType = 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	UNION ALL	

	SELECT DISTINCT	CAST(ExtraPostingDetails.ChargeDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' DeptCode,
			'00' Outlet,
			ABS(ExtraPostingSettlements.Amount) Amount,
			'Advance Received from Document No.: '+ExtraPostingDetails.DocumentNo+', Reservation No.: ' +CheckedOutReservationHeaders.ReservationNo AS Narration,
			LEFT(Destinity_GLIntegrationAccountMapping.AccCode,12) AccCode,
			'D' DRCR,
			'6' SeqNo,
			@TransType AS TransType,
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
			AND PaymentModes.PaymentType = 'CC'
			AND Destinity_GLIntegrationAccountMapping.blockcode = @BLOCKCODECC

	-------------------------------- END CHECKEDOUT RESERVATION ADVANCES --------------------------------

END

GO

