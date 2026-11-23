




CREATE PROCEDURE [dbo].[GL_POSTING_FO_ADVANCE_RECEIVED] (@USERID INT, @DocumentNo VARCHAR(MAX))

AS
BEGIN
	SET DATEFORMAT DMY
	
	--DECLARE @Rno as varchar(8) = 0
	--DECLARE @rCount as INT = 0
	--DECLARE @iCount as INT = 0
	--DECLARE @oCount as INT = 0
	--DECLARE @user AS VARCHAR(50) = ''

	--SELECT	@Rno = Receipts + 1 from AccMasterSingleCurrencyHO.DBO.Settings

	--SELECT @user = Username FROM Users WHERE id = @USERID
	
	
	---- CHECK RESERVATION ADVANCE COUNT
	--SELECT	@rCount = COUNT(*) 
	--FROM	ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId  INNER JOIN
	--		ReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = ReservationHeaders.Id
	--WHERE	(ExtraPostingDetails.IsAdvance = 1) AND DocumentNo = @DocumentNo


	---- CHECK INHOUSE ADVANCE COUNT
	--SELECT	@iCount = COUNT(*) 
	--FROM	ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId  INNER JOIN
	--		InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
	--WHERE	(ExtraPostingDetails.IsAdvance = 1) AND DocumentNo = @DocumentNo

	---- CHECK CHEKCED OUT ADVANCE COUNT
	--SELECT	@oCount = COUNT(*) 
	--FROM	ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId  INNER JOIN
	--		CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id
	--WHERE	(ExtraPostingDetails.IsAdvance = 1) AND DocumentNo = @DocumentNo
	
	
	
	---- FOR RESERVATION ADVANCES START
	--IF @rCount>0
	--BEGIN

	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno, ReservationNo, TransType, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime, FCAmount, exRate, TrCurr)
		
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY DRCR ORDER BY DRCR DESC) + @Rno as int) as varchar(8)),8)  AS TxnNo,
	--			'R' As TxnId,
	--			'H' As Modname,
	--			AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			'' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			TxnDate,
	--			DRCR As DrCr,
	--			SUM(Amount) AS Amount,
	--			SUM(AccAmount) AS AccAmount,
	--			'Advance Received for Advance No: '+RTRIM(LTRIM(DocumentNo))+ ' And Reservation No: '+RTRIM(LTRIM(ReservationNo)) As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			RTRIM(LTRIM(DocumentNo)) As DocNo,
	--			RTRIM(LTRIM(ReservationNo)) As ReservationNo,
	--			'AR' As TransType,
	--			Line_No,
	--			MainClassCode, 
	--			SubClassCode, 
	--			MainAccCode, 
	--			SubAccCode,
	--			GETDATE() AS logtime,
	--			FCAmount,
	--			ExRate,
	--			TrCurr
	--	FROM (

	--			SELECT	ExtraPostingSettlements.AccountCode As AccCode,
	--					ExtraPostingSettlements.AccountCode As SAccCode,
	--					substring(ExtraPostingDetails.AccountCode,1,2) As MainClassCode,
	--					substring(ExtraPostingDetails.AccountCode,3,2) As SubClassCode,
	--					substring(ExtraPostingDetails.AccountCode,5,4) As MainAccCode,
	--					substring(ExtraPostingDetails.AccountCode,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) As Amount, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) AS AccAmount,
	--					ExtraPostingDetails.DRCR AS DRCR,
	--					RTRIM(LTRIM(ReservationHeaders.ReservationNo)) As ReservationNo,
	--					RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					1 AS Line_No,
	--					ExtraPostingDetails.AmountFC AS FCAmount,
	--					ExtraPostingDetails.ConvertionRate AS ExRate,
	--					Currencies.ISOCode AS TrCurr
	--			FROM    ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId INNER JOIN
	--					ReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = ReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			WHERE   (ExtraPostingDetails.IsAdvance = 1) --AND (ExtraPostingDetails.DocumentNo = 'ADV0000049')

	--			UNION ALL

	--			SELECT	'' As AccCode,
	--					ExtraPostingSettlements.AccountCode As SAccCode,
	--					substring(ExtraPostingSettlements.AccountCode,1,2) As MainClassCode,
	--					substring(ExtraPostingSettlements.AccountCode,3,2) As SubClassCode,
	--					substring(ExtraPostingSettlements.AccountCode,5,4) As MainAccCode,
	--					substring(ExtraPostingSettlements.AccountCode,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) As Amount, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) AS AccAmount,
	--					'D' AS DRCR,
	--					RTRIM(LTRIM(ReservationHeaders.ReservationNo)) As ReservationNo,
	--					RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					2 AS Line_No,
	--					ExtraPostingDetails.AmountFC AS FCAmount,
	--					ExtraPostingDetails.ConvertionRate AS ExRate,
	--					Currencies.ISOCode AS TrCurr
	--			FROM    ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId INNER JOIN
	--					ReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = ReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			WHERE   (ExtraPostingDetails.IsAdvance = 1) --AND (ExtraPostingDetails.DocumentNo = 'ADV0000049')
	--	) X

	--	WHERE DocumentNo = @DocumentNo
	--	GROUP BY	AccCode, SAccCode, MainClassCode, SubClassCode, MainAccCode, SubAccCode, TxnDate, Amount, AccAmount, DrCr, X.ReservationNo, X.DocumentNo,X.Line_No, X.FCAmount, X.ExRate, X.TrCurr
	--	ORDER BY	TxnNo, DRCR

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Receipts = Receipts + @rCount

	--END
	---- FOR RESERVATION ADVANCES END
		
	
	---- FOR INHOUSE ADVANCES START
	--IF @iCount>0
	--BEGIN

	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno, ReservationNo, ResInvoiceNo, TransType, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime, FCAmount, exRate, TrCurr)
		
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY DRCR ORDER BY DRCR DESC) + @Rno as int) as varchar(8)),8)  AS TxnNo,
	--			'R' As TxnId,
	--			'H' As Modname,
	--			AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			'' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			TxnDate,
	--			DRCR As DrCr,
	--			SUM(Amount) AS Amount,
	--			SUM(AccAmount) AS AccAmount,
	--			'Advance Received for Advance No: '+RTRIM(LTRIM(DocumentNo))+ ', Reservation No: '+RTRIM(LTRIM(ReservationNo))+ ' And GRC No: '+RTRIM(LTRIM(GRCNo)) As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			RTRIM(LTRIM(DocumentNo)) As DocNo,
	--			RTRIM(LTRIM(ReservationNo)) As ReservationNo,
	--			RTRIM(LTRIM(GRCNo)) AS ResInvoiceNo,
	--			'AI' As TransType,
	--			Line_No,
	--			MainClassCode, 
	--			SubClassCode, 
	--			MainAccCode, 
	--			SubAccCode,
	--			GETDATE() AS logtime,
	--			FCAmount, 
	--			exRate, 
	--			TrCurr
	--	FROM (

	--			SELECT	ExtraPostingSettlements.AccountCode As AccCode,
	--					ExtraPostingSettlements.AccountCode As SAccCode,
	--					substring(ExtraPostingDetails.AccountCode,1,2) As MainClassCode,
	--					substring(ExtraPostingDetails.AccountCode,3,2) As SubClassCode,
	--					substring(ExtraPostingDetails.AccountCode,5,4) As MainAccCode,
	--					substring(ExtraPostingDetails.AccountCode,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) As Amount, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) AS AccAmount,
	--					ExtraPostingDetails.DRCR AS DRCR,
	--					RTRIM(LTRIM(InhouseReservationHeaders.ReservationNo)) As ReservationNo,
	--					RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					RTRIM(LTRIM(InhouseReservationHeaders.GRCNo)) As GRCNo,
	--					1 AS Line_No,
	--					ExtraPostingDetails.AmountFC AS FCAmount,
	--					ExtraPostingDetails.ConvertionRate AS ExRate,
	--					Currencies.ISOCode AS TrCurr
	--			FROM    ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId INNER JOIN
	--					InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			WHERE   (ExtraPostingDetails.IsAdvance = 1) --AND (ExtraPostingDetails.DocumentNo = 'ADV0000049')

	--			UNION ALL

	--			SELECT	'' As AccCode,
	--					ExtraPostingSettlements.AccountCode As SAccCode,
	--					substring(ExtraPostingSettlements.AccountCode,1,2) As MainClassCode,
	--					substring(ExtraPostingSettlements.AccountCode,3,2) As SubClassCode,
	--					substring(ExtraPostingSettlements.AccountCode,5,4) As MainAccCode,
	--					substring(ExtraPostingSettlements.AccountCode,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) As Amount, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) AS AccAmount,
	--					'D' AS DRCR,
	--					RTRIM(LTRIM(InhouseReservationHeaders.ReservationNo)) As ReservationNo,
	--					RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					RTRIM(LTRIM(InhouseReservationHeaders.GRCNo)) As GRCNo,
	--					2 AS Line_No,
	--					ExtraPostingDetails.AmountFC AS FCAmount,
	--					ExtraPostingDetails.ConvertionRate AS ExRate,
	--					Currencies.ISOCode AS TrCurr
	--			FROM    ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId INNER JOIN
	--					InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			WHERE   (ExtraPostingDetails.IsAdvance = 1) --AND (ExtraPostingDetails.DocumentNo = 'ADV0000049')
	--	) X

	--	WHERE DocumentNo = @DocumentNo
	--	GROUP BY	AccCode, SAccCode, MainClassCode, SubClassCode, MainAccCode, SubAccCode, TxnDate, Amount, AccAmount, DrCr, ReservationNo, DocumentNo, Line_No,GRCNo, X.FCAmount, X.ExRate, X.TrCurr
	--	ORDER BY	TxnNo, DRCR

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Receipts = Receipts + @iCount

	--END
	---- FOR INHOUSE ADVANCES END	


	---- FOR CHECKED OUT ADVANCES START
	--IF @oCount>0
	--BEGIN

	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno, ReservationNo, ResInvoiceNo, TransType, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime, FCAmount, exRate, TrCurr)
		
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY DRCR ORDER BY DRCR DESC) + @Rno as int) as varchar(8)),8)  AS TxnNo,
	--			'R' As TxnId,
	--			'H' As Modname,
	--			AccCode,
	--			'00' AS DeptCode,
	--			'0000' As SuppCode,
	--			'' As txntype,
	--			'F' As Cancel,
	--			'' As DocType,
	--			TxnDate,
	--			DRCR As DrCr,
	--			SUM(Amount) AS Amount,
	--			SUM(AccAmount) AS AccAmount,
	--			'Advance Received for Advance No: '+RTRIM(LTRIM(DocumentNo))+ ', Reservation No: '+RTRIM(LTRIM(ReservationNo))+ ' And GRC No: '+RTRIM(LTRIM(GRCNo)) As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			RTRIM(LTRIM(DocumentNo)) As DocNo,
	--			RTRIM(LTRIM(ReservationNo)) As ReservationNo,
	--			RTRIM(LTRIM(GRCNo)) AS ResInvoiceNo,
	--			'AI' As TransType,
	--			Line_No,
	--			MainClassCode, 
	--			SubClassCode, 
	--			MainAccCode, 
	--			SubAccCode,
	--			GETDATE() AS logtime,
	--			FCAmount, 
	--			exRate, 
	--			TrCurr
	--	FROM (

	--			SELECT	ExtraPostingSettlements.AccountCode As AccCode,
	--					ExtraPostingSettlements.AccountCode As SAccCode,
	--					substring(ExtraPostingDetails.AccountCode,1,2) As MainClassCode,
	--					substring(ExtraPostingDetails.AccountCode,3,2) As SubClassCode,
	--					substring(ExtraPostingDetails.AccountCode,5,4) As MainAccCode,
	--					substring(ExtraPostingDetails.AccountCode,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) As Amount, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) AS AccAmount,
	--					ExtraPostingDetails.DRCR AS DRCR,
	--					RTRIM(LTRIM(CheckedOutReservationHeaders.ReservationNo)) As ReservationNo,
	--					RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					RTRIM(LTRIM(CheckedOutReservationHeaders.GRCNo)) As GRCNo,
	--					1 AS Line_No,
	--					ExtraPostingDetails.AmountFC AS FCAmount,
	--					ExtraPostingDetails.ConvertionRate AS ExRate,
	--					Currencies.ISOCode AS TrCurr
	--			FROM    ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId INNER JOIN
	--					CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			WHERE   (ExtraPostingDetails.IsAdvance = 1) --AND (ExtraPostingDetails.DocumentNo = 'ADV0000049')

	--			UNION ALL

	--			SELECT	'' As AccCode,
	--					ExtraPostingSettlements.AccountCode As SAccCode,
	--					substring(ExtraPostingSettlements.AccountCode,1,2) As MainClassCode,
	--					substring(ExtraPostingSettlements.AccountCode,3,2) As SubClassCode,
	--					substring(ExtraPostingSettlements.AccountCode,5,4) As MainAccCode,
	--					substring(ExtraPostingSettlements.AccountCode,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) As Amount, 
	--					ABS(round(ExtraPostingSettlements.Amount,2)) AS AccAmount,
	--					'D' AS DRCR,
	--					RTRIM(LTRIM(CheckedOutReservationHeaders.ReservationNo)) As ReservationNo,
	--					RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					RTRIM(LTRIM(CheckedOutReservationHeaders.GRCNo)) As GRCNo,
	--					2 AS Line_No,
	--					ExtraPostingDetails.AmountFC AS FCAmount,
	--					ExtraPostingDetails.ConvertionRate AS ExRate,
	--					Currencies.ISOCode AS TrCurr
	--			FROM    ExtraPostingDetails INNER JOIN ExtraPostingSettlements ON ExtraPostingDetails.Id = ExtraPostingSettlements.ExtraPostingId INNER JOIN
	--					CheckedOutReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = CheckedOutReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			WHERE   (ExtraPostingDetails.IsAdvance = 1) --AND (ExtraPostingDetails.DocumentNo = 'ADV0000049')
	--	) X

	--	WHERE DocumentNo = @DocumentNo
	--	GROUP BY	AccCode, SAccCode, MainClassCode, SubClassCode, MainAccCode, SubAccCode, TxnDate, Amount, AccAmount, DrCr, ReservationNo, DocumentNo, Line_No,GRCNo, X.FCAmount, X.ExRate, X.TrCurr
	--	ORDER BY	TxnNo, DRCR

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Receipts = Receipts + @oCount

	--END
	-- FOR CHECKED OUT ADVANCES END
	
END

GO

