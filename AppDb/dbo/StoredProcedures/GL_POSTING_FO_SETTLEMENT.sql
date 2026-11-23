
--EXEC [dbo].[GL_POSTING_FO_SETTLEMENT] 10, 'IN00000069' 
CREATE PROCEDURE [dbo].[GL_POSTING_FO_SETTLEMENT] (@USERID INT, @InvoiceNo VARCHAR(MAX), @isReinstate  BIT = 0)

AS
BEGIN
	SET DATEFORMAT DMY
	
	--DECLARE @chargeDate AS DATE
	--DECLARE @DueDate AS DATE
	--DECLARE @Bno as varchar(8) = 0
	--DECLARE @NextDocNo AS VARCHAR(MAX) = ''
	--DECLARE @user AS VARCHAR(50) = ''
	--DECLARE @InHouseDebtorAcc AS VARCHAR(12) = ''
	--DECLARE @FYear AS VARCHAR(6)
	--DECLARE @rCount as INT = 0
	--DECLARE @dCount as INT = 0
	--DECLARE @cCount as INT = 0
	--DECLARE @ccCount as INT = 0
	--DECLARE @Cr_Pe AS INT = 0
	--DECLARE @DOC_ID AS VARCHAR(2) = ''
	--DECLARE @ChequePayID AS INT = 0
	
	
	--SELECT @InHouseDebtorAcc = InhouseDebtAcc, @FYear = startmonth FROM AccMasterSingleCurrencyHo.dbo.Settings
	
	--SELECT @user = Username FROM Users WHERE id = @USERID

	
	--IF @isReinstate = 0
	--BEGIN
	--	SELECT @chargeDate = SettlementDate FROM BillSettlementDetails WHERE InvoiceNo = @InvoiceNo
	--END
	
	--ELSE
	--BEGIN
	--	SELECT @chargeDate = CurrentDate FROM FOSettings
	--END
	
	
	--SELECT @rCount = COUNT(*) FROM BillSettlementDetails WHERE InvoiceNo = @InvoiceNo  AND CAST(SettlementDate AS DATE) = CAST(@chargeDate AS DATE)
	
	----SELECT @dCount = COUNT(*) FROM BillSettlementDetails INNER JOIN PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id WHERE BillSettlementDetails.InvoiceNo = @InvoiceNo AND CAST(BillSettlementDetails.SettlementDate AS DATE) = CAST(@chargeDate AS DATE) AND PaymentModes.isCredit = 1 AND PaymentModes.PaymentType = 'CR'
	--SELECT @dCount = COUNT(*) FROM BillSettlementDetails INNER JOIN PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id WHERE BillSettlementDetails.InvoiceNo = @InvoiceNo AND CAST(BillSettlementDetails.SettlementDate AS DATE) = CAST(@chargeDate AS DATE) AND PaymentModes.isCredit = 1
	
	--SELECT @ccCount = COUNT(*) FROM BillSettlementDetails INNER JOIN PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id WHERE BillSettlementDetails.InvoiceNo = @InvoiceNo AND CAST(BillSettlementDetails.SettlementDate AS DATE) = CAST(@chargeDate AS DATE) AND PaymentModes.PaymentType = 'CC'
	
	--SELECT @cCount = COUNT(*) FROM BillSettlementDetails INNER JOIN PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id WHERE BillSettlementDetails.InvoiceNo = @InvoiceNo AND CAST(BillSettlementDetails.SettlementDate AS DATE) = CAST(@chargeDate AS DATE) AND PaymentModes.PaymentType = 'CQ'
	
	--SELECT @ChequePayID = id FROM PaymentModes WHERE PaymentType = 'CQ'
	
	
	---- GL ENTRY
	--IF @rCount>0
	--BEGIN
		
	--	SELECT @Bno = right('000000000'+cast(cast(SpecialJournals + 1 as int) as varchar(8)),8) from AccMasterSingleCurrencyHO.DBO.Settings
		
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno,Transtype, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime, ReservationNo, ResInvoiceNo)
		
	--	-- INSERT INHOUSEDEBTOR ENTRY
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY @rCount ORDER BY @rCount DESC) + @Bno as int) as varchar(8)),8)  AS TxnNo,
	--			'B' As TxnID,
	--			'H' As Modname,
	--			@InHouseDebtorAcc AS AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			IIF(@ChequePayID = BillSettlementDetails.PaymentTypeID,'Q','C') As txntype, -- '' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			CAST(@chargeDate AS DATE) AS TxnDate,
	--			IIF (@isReinstate = 0,'C','D') AS DrCr, --'C' As DrCr,
	--			ABS(SUM(ROUND(PaidAmount,2))) As AccAmount,
	--			ABS(SUM(ROUND(PaidAmount,2))) As Amount,
	--			'Settlement of Room Sales for Invoice No - ' +InvoiceNo +' Reservation No - ' +ReservationNo + IIF (@isReinstate = 0,'',' Due to Reinstate') As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			IIF(@ChequePayID = BillSettlementDetails.PaymentTypeID,SUBSTRING(BillSettlementDetails.Remarks,1,8),'') AS docno, -- '' AS docno,
	--			'RS' As TransType,
	--			1 AS Line_No,
	--			SUBSTRING(@InHouseDebtorAcc,1,2) MainClasscode, 
	--			SUBSTRING(@InHouseDebtorAcc,3,2) SubClasscode, 
	--			SUBSTRING(@InHouseDebtorAcc,5,4) MainAccCode, 
	--			SUBSTRING(@InHouseDebtorAcc,9,4) SubAccCode, 
	--			GETDATE() logtime,
	--			ReservationNo AS ReservationNo,
	--			InvoiceNo AS ResInvoiceNo								
	--	FROM	BillSettlementDetails
	--	WHERE InvoiceNo = @InvoiceNo AND CAST(SettlementDate AS DATE) = CAST(@chargeDate AS DATE)
	--	GROUP BY AccountCode, InvoiceNo, ReservationNo, PaymentTypeID, Remarks
		
	--	UNION ALL
		
	--	-- INSERT ACTUAL SETTLEMENT ENTRY
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY @rCount ORDER BY @rCount DESC) + @Bno as int) as varchar(8)),8)  AS TxnNo,
	--			'B' As TxnID,
	--			'H' As Modname,
	--			AccountCode AS AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			IIF(@ChequePayID = BillSettlementDetails.PaymentTypeID,'Q','C') As txntype, -- '' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			CAST(@chargeDate AS DATE) AS TxnDate,
	--			IIF(@isReinstate = 0,'D','C') As DrCr, --'D' As DrCr,
	--			ABS(SUM(ROUND(PaidAmount,2))) As AccAmount,
	--			ABS(SUM(ROUND(PaidAmount,2))) As Amount,
	--			'Settlement of Room Sales for Invoice No - ' +InvoiceNo +' Reservation No - ' +ReservationNo +IIF (@isReinstate = 0,'',' Due to Reinstate') As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			IIF(@ChequePayID = BillSettlementDetails.PaymentTypeID,SUBSTRING(BillSettlementDetails.Remarks,1,8),'') AS docno, -- '' AS docno,
	--			'RS' As TransType,
	--			2 AS Line_No,
	--			SUBSTRING(AccountCode,1,2) MainClasscode, 
	--			SUBSTRING(AccountCode,3,2) SubClasscode, 
	--			SUBSTRING(AccountCode,5,4) MainAccCode, 
	--			SUBSTRING(AccountCode,9,4) SubAccCode, 
	--			GETDATE() logtime,	
	--			ReservationNo AS ReservationNo,
	--			InvoiceNo AS ResInvoiceNo	
	--	FROM	BillSettlementDetails
	--	WHERE InvoiceNo = @InvoiceNo AND CAST(SettlementDate AS DATE) = CAST(@chargeDate AS DATE)
	--	GROUP BY AccountCode, InvoiceNo, ReservationNo, PaymentTypeID, Remarks
	--	ORDER BY TxnNo, DRCR
			
	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set SpecialJournals = SpecialJournals + @rCount
	
	--END
	
	
	---- CHEQUE ENTRY
	--IF @cCount>0
	--BEGIN
		
	--	IF @isReinstate = 0 -- Insert ChequeTxn Entry
	--	BEGIN
		
	--		INSERT INTO AccMasterSingleCurrencyHo.dbo.ChequeTxn (TxnNo, TxnId, ChequeNo, Amount, Bank, BankCode, Cancel, branch, ChqDate, Name, printed, acpayee, Deposit, NameOnChq, DepositNo, DepDate)
	--		SELECT TxnNo, TxnId, DocNo AS ChequeNo, Amount, AccTxnDetail.MainClassCode+AccTxnDetail.SubClassCode+AccTxnDetail.mainAccCode+AccTxnDetail.subAccCode AS Bank, NULL AS BankCode, 'F' Cancel, SubAccName branch, TxnDate AS ChqDate, 'CASH' Name, 'T' AS printed, 0 acpayee, 'F' Deposit, 'CASH' NameOnChq, NULL AS DepositNo, NULL AS DepDate
	--		FROM AccMasterSingleCurrencyHO.DBO.AccTxnDetail INNER JOIN AccMasterSingleCurrencyHO.DBO.SubAccRef ON AccTxnDetail.MainClassCode = SubAccRef.MainClassCode AND AccTxnDetail.SubClassCode = SubAccRef.SubClassCode AND AccTxnDetail.mainAccCode = SubAccRef.MainAccCode AND AccTxnDetail.subAccCode = SubAccRef.SubAccCode
	--		WHERE AccTxnDetail.TxnType = 'Q' AND ResInvoiceNo = @InvoiceNo AND CAST(TxnDate AS DATE) = CAST(@chargeDate AS DATE) AND AccTxnDetail.DrCr = 'D'
		
	--	END
		
	--	ELSE -- Cancel ChequeTxn Entry Due to ReInstate
	--	BEGIN
			
	--		UPDATE AccMasterSingleCurrencyHO.DBO.ChequeTxn SET Cancel = 'T'
	--		WHERE TxnId+TxnNo IN (SELECT TxnId+TxnNo FROM AccMasterSingleCurrencyHo.dbo.AccTxnDetail WHERE AccTxnDetail.TxnType = 'Q' AND ResInvoiceNo = @InvoiceNo AND AccTxnDetail.DrCr = 'D' )
					
	--	END
		
	--END
	
	
	---- DEBTOR CITY LEDGER ENTRY
	--IF @dCount>0
	--BEGIN
	
	--	SELECT	@Cr_Pe = IIF(Companies.CreditPeriod IS NULL,0,Companies.CreditPeriod) FROM BillSettlementDetails INNER JOIN Companies ON BillSettlementDetails.CompanyId = Companies.Id INNER JOIN PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id WHERE BillSettlementDetails.InvoiceNo = @InvoiceNo AND CAST(BillSettlementDetails.SettlementDate AS DATE) = CAST(@chargeDate AS DATE) AND PaymentModes.IsCredit = 1
		
	--	SELECT	@DueDate = DATEADD(DAY, @Cr_Pe, CAST(@chargeDate AS Date) )
	
	
	--	IF @isReinstate = 0  -- INSERT DOC_ID = 1
	--	BEGIN			
						
	--		INSERT INTO AccMasterSingleCurrencyHO.DBO.DEBT (CompCode, DEPTCODE, CUST_CODE, DOC_ID, INVO_NO, DATE1, VAL1, BALance, DOC_NO, DOC_DATE, Narration, REF_NO, SET_ID, userid, cancel, Logtime, FYear, DueDate, SalesRep, ExchangeRate, CurrCode, ArrivalDate, DepartureDate, CustName, tourNO, ContractNo)
			
	--		-- InhouseReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				'1' AS DOC_ID, 
	--				BillSettlementDetails.InvoiceNo AS INVO_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				BillSettlementDetails.PaidAmount AS BALance, 
	--				BillSettlementDetails.InvoiceNo AS DOC_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DOC_DATE, 
	--				'Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+InhouseReservationHeaders.GRCNo AS Narration, 
	--				IIF(InhouseReservationHeaders.VoucherNo IS NULL,'',InhouseReservationHeaders.VoucherNo) AS REF_NO, 
	--				NULL AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(InhouseReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(InhouseReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(InhouseReservationHeaders.TourNo IS NULL,'',InhouseReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					InhouseReservationHeaders ON BillSettlementDetails.ReservationHeaderID = InhouseReservationHeaders.Id INNER JOIN
	--					InHouseReservationProfiles ON BillSettlementDetails.ReservationHeaderID = InHouseReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON InHouseReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.isCredit = 1	
			
	--		UNION ALL
			
	--		-- CheckedOutReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				'1' AS DOC_ID, 
	--				BillSettlementDetails.InvoiceNo AS INVO_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				BillSettlementDetails.PaidAmount AS BALance, 
	--				BillSettlementDetails.InvoiceNo AS DOC_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DOC_DATE, 
	--				'Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+CheckedOutReservationHeaders.GRCNo AS Narration, 
	--				IIF(CheckedOutReservationHeaders.VoucherNo IS NULL,'',CheckedOutReservationHeaders.VoucherNo) AS REF_NO, 
	--				NULL AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(CheckedOutReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(CheckedOutReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(CheckedOutReservationHeaders.TourNo IS NULL,'',CheckedOutReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					CheckedOutReservationHeaders ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationHeaders.Id INNER JOIN
	--					CheckedOutReservationProfiles ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON CheckedOutReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.isCredit = 1	
			
	--	END		
		
	--	ELSE  -- INSERT DOC_ID = 4 OR DOC_ID = 5 FOR REINSTATE
	--	BEGIN
					
	--		SELECT @DOC_ID = CASE WHEN ROUND(VAL1,2) = ROUND(BALANCE,2) THEN '5' ELSE '4' END FROM AccMasterSingleCurrencyHO.DBO.DEBT WHERE CANCEL = 'F' AND INVO_NO = @InvoiceNo AND DOC_ID = '1'
			
	--		SELECT @NextDocNo = DocNo FROM AccMasterSingleCurrencyHO.DBO.DocNos_debtor WHERE DocId = @DOC_ID
			
	--		SET @NextDocNo = right('0000000000'+cast(cast(CAST(@NextDocNo AS INT) + 1 as int) as varchar(10)),10)
			
			
	--		INSERT INTO AccMasterSingleCurrencyHO.DBO.DEBT (CompCode, DEPTCODE, CUST_CODE, DOC_ID, INVO_NO, DATE1, VAL1, BALance, DOC_NO, DOC_DATE, Narration, REF_NO, SET_ID, userid, cancel, Logtime, FYear, DueDate, SalesRep, ExchangeRate, CurrCode, ArrivalDate, DepartureDate, CustName, tourNO, ContractNo)
			
	--		-- InhouseReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				@DOC_ID AS DOC_ID, 
	--				IIF(@DOC_ID = '5', BillSettlementDetails.InvoiceNo, @NextDocNo) AS INVO_NO, 
	--				IIF(@DOC_ID = '5', CAST(BillSettlementDetails.SettlementDate AS DATE), CAST(@chargeDate AS DATE)) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				IIF(@DOC_ID = '5', 0, BillSettlementDetails.PaidAmount) AS BALance, 
	--				@NextDocNo AS DOC_NO, 
	--				CAST(@chargeDate AS DATE) AS DOC_DATE, 
	--				'ReInstate Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+InhouseReservationHeaders.GRCNo+', Invoice No - '+BillSettlementDetails.InvoiceNo AS Narration, 
	--				IIF(InhouseReservationHeaders.VoucherNo IS NULL,'',InhouseReservationHeaders.VoucherNo) AS REF_NO, 
	--				IIF(@DOC_ID = '5', '1', NULL) AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(InhouseReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(InhouseReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(InhouseReservationHeaders.TourNo IS NULL,'',InhouseReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					InhouseReservationHeaders ON BillSettlementDetails.ReservationHeaderID = InhouseReservationHeaders.Id INNER JOIN
	--					InHouseReservationProfiles ON BillSettlementDetails.ReservationHeaderID = InHouseReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON InHouseReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.isCredit = 1
			
	--		UNION ALL
			
	--		-- CheckedOutReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				@DOC_ID AS DOC_ID, 
	--				IIF(@DOC_ID = '5', BillSettlementDetails.InvoiceNo, @NextDocNo) AS INVO_NO, 
	--				IIF(@DOC_ID = '5', CAST(BillSettlementDetails.SettlementDate AS DATE), CAST(@chargeDate AS DATE)) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				IIF(@DOC_ID = '5', 0, BillSettlementDetails.PaidAmount) AS BALance, 
	--				@NextDocNo AS DOC_NO, 
	--				CAST(@chargeDate AS DATE) AS DOC_DATE, 
	--				'ReInstate Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+CheckedOutReservationHeaders.GRCNo+', Invoice No - '+BillSettlementDetails.InvoiceNo AS Narration, 
	--				IIF(CheckedOutReservationHeaders.VoucherNo IS NULL,'',CheckedOutReservationHeaders.VoucherNo) AS REF_NO, 
	--				IIF(@DOC_ID = '5', '1', NULL) AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(CheckedOutReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(CheckedOutReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(CheckedOutReservationHeaders.TourNo IS NULL,'',CheckedOutReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					CheckedOutReservationHeaders ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationHeaders.Id INNER JOIN
	--					CheckedOutReservationProfiles ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON CheckedOutReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.isCredit = 1
			
			
	--		UPDATE AccMasterSingleCurrencyHO.DBO.DEBT SET BALance = CASE WHEN @DOC_ID = '5' THEN 0 ELSE BALance END WHERE CANCEL = 'F' AND INVO_NO = @InvoiceNo AND DOC_ID = '1'
			
	--		UPDATE AccMasterSingleCurrencyHO.DBO.DocNos_debtor SET DocNo = DocNo+1 WHERE DocId = @DOC_ID
			
	--	END
								
	--END
	
		
	---- DEBTOR CREDIT CARD ENTRY
	--IF @ccCount>0
	--BEGIN
	
	--	SELECT @NextDocNo = DocNo FROM AccMasterSingleCurrencyHO.DBO.DocNos_debtor WHERE DocId = '2'
			
	--	--SET @NextDocNo = right('0000000000'+cast(cast(@NextDocNo + 1 as int) as varchar(10)),10)
	--	SET @NextDocNo = right('0000000000'+cast(cast(CAST(@NextDocNo AS INT) + 1 as int) as varchar(10)),10)
	
	
	--	SELECT	@Cr_Pe = IIF(Companies.CreditPeriod IS NULL,0,Companies.CreditPeriod) FROM BillSettlementDetails INNER JOIN Companies ON BillSettlementDetails.CompanyId = Companies.Id INNER JOIN PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id WHERE BillSettlementDetails.InvoiceNo = @InvoiceNo AND CAST(BillSettlementDetails.SettlementDate AS DATE) = CAST(@chargeDate AS DATE) AND PaymentModes.PaymentType = 'CC'
		
	--	SELECT	@DueDate = DATEADD(DAY, @Cr_Pe, CAST(@chargeDate AS Date) )
	
	
	--	IF @isReinstate = 0  -- INSERT DOC_ID = 2
	--	BEGIN			
						
	--		INSERT INTO AccMasterSingleCurrencyHO.DBO.DEBT (CompCode, DEPTCODE, CUST_CODE, DOC_ID, INVO_NO, DATE1, VAL1, BALance, DOC_NO, DOC_DATE, Narration, REF_NO, SET_ID, userid, cancel, Logtime, FYear, DueDate, SalesRep, CreditCardNo, ExchangeRate, CurrCode, ArrivalDate, DepartureDate, CustName, tourNO, ContractNo)
			
	--		-- InhouseReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				'2' AS DOC_ID, 
	--				@NextDocNo AS INVO_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				BillSettlementDetails.PaidAmount AS BALance, 
	--				@NextDocNo AS DOC_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DOC_DATE, 
	--				'Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+InhouseReservationHeaders.GRCNo+', Invoice No - '+BillSettlementDetails.InvoiceNo AS Narration, 
	--				IIF(BillSettlementDetails.InvoiceNo IS NULL,'',BillSettlementDetails.InvoiceNo) AS REF_NO, 
	--				NULL AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				LEFT(IIF(BillSettlementDetails.Remarks IS NULL,'',BillSettlementDetails.Remarks),15) AS CreditCardNo,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(InhouseReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(InhouseReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(InhouseReservationHeaders.TourNo IS NULL,'',InhouseReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					InhouseReservationHeaders ON BillSettlementDetails.ReservationHeaderID = InhouseReservationHeaders.Id INNER JOIN
	--					InHouseReservationProfiles ON BillSettlementDetails.ReservationHeaderID = InHouseReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON InHouseReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.PaymentType = 'CC'
			
	--		UNION ALL
			
	--		-- CheckedOutReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				'2' AS DOC_ID, 
	--				@NextDocNo AS INVO_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				BillSettlementDetails.PaidAmount AS BALance, 
	--				@NextDocNo AS DOC_NO, 
	--				CAST(BillSettlementDetails.SettlementDate AS DATE) AS DOC_DATE, 
	--				'Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+CheckedOutReservationHeaders.GRCNo+', Invoice No - '+BillSettlementDetails.InvoiceNo AS Narration, 
	--				IIF(BillSettlementDetails.InvoiceNo IS NULL,'',BillSettlementDetails.InvoiceNo) AS REF_NO, 
	--				NULL AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				LEFT(IIF(BillSettlementDetails.Remarks IS NULL,'',BillSettlementDetails.Remarks),15) AS CreditCardNo,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(CheckedOutReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(CheckedOutReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(CheckedOutReservationHeaders.TourNo IS NULL,'',CheckedOutReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					CheckedOutReservationHeaders ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationHeaders.Id INNER JOIN
	--					CheckedOutReservationProfiles ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON CheckedOutReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.PaymentType = 'CC'	
			
			
	--		UPDATE AccMasterSingleCurrencyHO.DBO.DocNos_debtor SET DocNo = DocNo+1 WHERE DocId = '2'
			
	--	END		
		
	--	ELSE  -- INSERT DOC_ID = 4 OR DOC_ID = 5 FOR REINSTATE
	--	BEGIN
					
	--		SELECT @DOC_ID = CASE WHEN ROUND(VAL1,2) = ROUND(BALANCE,2) THEN 5 ELSE 4 END FROM AccMasterSingleCurrencyHO.DBO.DEBT WHERE CANCEL = 'F' AND REF_NO = @InvoiceNo AND DOC_ID = '2'
			
	--		SELECT @NextDocNo = DocNo FROM AccMasterSingleCurrencyHO.DBO.DocNos_debtor WHERE DocId = @DOC_ID
			
	--		--SET @NextDocNo = right('0000000000'+cast(cast(@NextDocNo + 1 as int) as varchar(10)),10)
	--		SET @NextDocNo = right('0000000000'+cast(cast(CAST(@NextDocNo AS INT) + 1 as int) as varchar(10)),10)
			
			
	--		INSERT INTO AccMasterSingleCurrencyHO.DBO.DEBT (CompCode, DEPTCODE, CUST_CODE, DOC_ID, INVO_NO, DATE1, VAL1, BALance, DOC_NO, DOC_DATE, Narration, REF_NO, SET_ID, userid, cancel, Logtime, FYear, DueDate, SalesRep, CreditCardNo, ExchangeRate, CurrCode, ArrivalDate, DepartureDate, CustName, tourNO, ContractNo)
			
	--		-- InhouseReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				@DOC_ID AS DOC_ID, 
	--				IIF(@DOC_ID = '5', BillSettlementDetails.InvoiceNo, @NextDocNo) AS INVO_NO, 
	--				IIF(@DOC_ID = '5', CAST(BillSettlementDetails.SettlementDate AS DATE), CAST(@chargeDate AS DATE)) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				IIF(@DOC_ID = '5', 0, BillSettlementDetails.PaidAmount) AS BALance, 
	--				@NextDocNo AS DOC_NO, 
	--				CAST(@chargeDate AS DATE) AS DOC_DATE, 
	--				'ReInstate Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+InhouseReservationHeaders.GRCNo+', Invoice No - '+BillSettlementDetails.InvoiceNo AS Narration, 
	--				IIF(BillSettlementDetails.InvoiceNo IS NULL,'',BillSettlementDetails.InvoiceNo) AS REF_NO, 
	--				IIF(@DOC_ID = '5', '1', NULL) AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				LEFT(IIF(BillSettlementDetails.Remarks IS NULL,'',BillSettlementDetails.Remarks),15) AS CreditCardNo,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(InhouseReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(InhouseReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(InhouseReservationHeaders.TourNo IS NULL,'',InhouseReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					InhouseReservationHeaders ON BillSettlementDetails.ReservationHeaderID = InhouseReservationHeaders.Id INNER JOIN
	--					InHouseReservationProfiles ON BillSettlementDetails.ReservationHeaderID = InHouseReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON InHouseReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.PaymentType = 'CC'
			
	--		UNION ALL
			
	--		-- CheckedOutReservation
	--		SELECT	'001' AS CompCode,
	--				'00' AS DEPTCODE, 
	--				BillSettlementDetails.CompanyId AS CUST_CODE, 
	--				@DOC_ID AS DOC_ID, 
	--				IIF(@DOC_ID = '5', BillSettlementDetails.InvoiceNo, @NextDocNo) AS INVO_NO, 
	--				IIF(@DOC_ID = '5', CAST(BillSettlementDetails.SettlementDate AS DATE), CAST(@chargeDate AS DATE)) AS DATE1, 
	--				BillSettlementDetails.PaidAmount AS VAL1, 
	--				IIF(@DOC_ID = '5', 0, BillSettlementDetails.PaidAmount) AS BALance, 
	--				@NextDocNo AS DOC_NO, 
	--				CAST(@chargeDate AS DATE) AS DOC_DATE, 
	--				'ReInstate Invoice For Reservation No - '+BillSettlementDetails.ReservationNo+', GRC No - '+CheckedOutReservationHeaders.GRCNo+', Invoice No - '+BillSettlementDetails.InvoiceNo AS Narration, 
	--				IIF(BillSettlementDetails.InvoiceNo IS NULL,'',BillSettlementDetails.InvoiceNo) AS REF_NO, 
	--				IIF(@DOC_ID = '5', '1', NULL) AS SET_ID, 
	--				@user AS userid, 
	--				'F' AS cancel, 
	--				GETDATE() AS Logtime, 
	--				@FYear AS FYear, 
	--				CAST(@DueDate AS DATE) AS DueDate, 
	--				'' AS SalesRep,
	--				LEFT(IIF(BillSettlementDetails.Remarks IS NULL,'',BillSettlementDetails.Remarks),15) AS CreditCardNo,
	--				1 AS ExchangeRate, 
	--				'LKR' AS CurrCode, 
	--				CAST(CheckedOutReservationHeaders.Arrival AS DATE) AS ArrivalDate, 
	--				CAST(CheckedOutReservationHeaders.Departure AS DATE) AS DepartureDate, 
	--				IIF(Salutations.Name IS NULL,'',Salutations.Name)+' '+IIF(GuestProfiles.FirstName IS NULL,'',GuestProfiles.FirstName)+' '+IIF(GuestProfiles.MiddleName IS NULL,'',GuestProfiles.MiddleName)+' '+IIF(GuestProfiles.LastName IS NULL,'',GuestProfiles.LastName) AS CustName, 
	--				IIF(CheckedOutReservationHeaders.TourNo IS NULL,'',CheckedOutReservationHeaders.TourNo) AS tourNO, 
	--				'' AS ContractNo
	--		FROM	BillSettlementDetails INNER JOIN 
	--					CheckedOutReservationHeaders ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationHeaders.Id INNER JOIN
	--					CheckedOutReservationProfiles ON BillSettlementDetails.ReservationHeaderID = CheckedOutReservationProfiles.ReservationHeaderId INNER JOIN
	--					GuestProfiles ON CheckedOutReservationProfiles.GuestProfileId = GuestProfiles.Id INNER JOIN
	--					Salutations ON GuestProfiles.SalutationId = Salutations.Id INNER JOIN
	--					PaymentModes ON BillSettlementDetails.PaymentTypeID = PaymentModes.Id
	--		WHERE   (BillSettlementDetails.InvoiceNo = @InvoiceNo) AND PaymentModes.PaymentType = 'CC'
			
			
	--		UPDATE AccMasterSingleCurrencyHO.DBO.DEBT SET BALance = CASE WHEN @DOC_ID = '5' THEN 0 ELSE BALance END WHERE CANCEL = 'F' AND REF_NO = @InvoiceNo AND DOC_ID = '2'
			
	--		UPDATE AccMasterSingleCurrencyHO.DBO.DocNos_debtor SET DocNo = DocNo+1 WHERE DocId = @DOC_ID
			
	--	END
								
	--END		

END

GO

