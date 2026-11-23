



CREATE PROCEDURE [dbo].[GL_POSTING_FO_ADVANCE_TRANSFER] (@USERID INT, @ReservationNo VARCHAR(MAX), @IsCancelCheckIn BIT = 0)

AS
BEGIN
	SET DATEFORMAT DMY
	
	--DECLARE @Jno as varchar(8) = 0
	--DECLARE @user AS VARCHAR(50) = ''
	--DECLARE @TAmount AS MONEY = 0.0
	--DECLARE @AAmount AS MONEY = 0.0
	--DECLARE @RAmount AS MONEY = 0.0
	--DECLARE @TAmountFC AS MONEY = 0.0
	--DECLARE @AAmountFC AS MONEY = 0.0
	--DECLARE @RAmountFC AS MONEY = 0.0
	--DECLARE @InHouseDebtorAcc AS VARCHAR(12) = ''
	--DECLARE @AdvanceAcc AS VARCHAR(12) = ''

	--SELECT	@Jno = Journals + 1, @InHouseDebtorAcc = InhouseDebtAcc, @AdvanceAcc = AdvanceAcc from AccMasterSingleCurrencyHO.DBO.Settings
	
	--SELECT	@user = Username FROM Users WHERE id = @USERID
	
	
	---- GET RESERVATION ADVANCE AMOUNT
	--SELECT	@AAmount = ISNULL(SUM(ChargeAmount),0), @AAmountFC = ISNULL(SUM(AmountFC),0)
	--FROM	ExtraPostingDetails INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
	--WHERE	(ExtraPostingDetails.IsAdvance = 1) AND InhouseReservationHeaders.ReservationNo = @ReservationNo
	
	
	---- GET RESERVATION REFUND AMOUNT
	--SELECT	@RAmount = ISNULL(SUM(ChargeAmount),0), @RAmountFC = ISNULL(SUM(AmountFC),0)
	--FROM	ExtraPostingDetails INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id
	--WHERE	(ExtraPostingDetails.IsRefund = 1) AND InhouseReservationHeaders.ReservationNo = @ReservationNo
	
	
	--SET @TAmount = ROUND((@AAmount-@RAmount),2)
	--SET @TAmountFC = ROUND((@AAmountFC-@RAmountFC),2)
	
	
	---- FOR RESERVATION ADVANCE TRANSFER START
	--IF @TAmount>0
	--BEGIN

	--	--INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,docno, ReservationNo, ResInvoiceNo, TransType, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime)
	--	INSERT INTO AccMasterSingleCurrencyHO.DBO.AccTxnDetail (TxnNo,TxnID,Modname,AccCode,DeptCode,SuppCode,txntype,Cancel,DocType,TxnDate,DrCr,AccAmount,Amount,Narration,UserID,CompCode,ReservationNo, ResInvoiceNo, TransType, Line_No, MainClasscode,SubClasscode,MainAccCode,SubAccCode, logtime, FCAmount, ExRate, TrCurr)
		
	--	SELECT	RIGHT('000000000'+cast(cast(ROW_NUMBER() OVER(PARTITION BY DRCR ORDER BY DRCR DESC) + @Jno as int) as varchar(8)),8)  AS TxnNo,
	--			'J' As TxnId,
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
	--			'Trasfer of Advance Received for Reservation No: '+RTRIM(LTRIM(ReservationNo))+ ', GRC No: '+RTRIM(LTRIM(GRCNo))+ IIF (@IsCancelCheckIn = 0,'',' Due to Cancel Check-In') As Narration,
	--			@user As UserID,
	--			'001' As CompCode, 
	--			--RTRIM(LTRIM(DocumentNo)) As DocNo,
	--			RTRIM(LTRIM(ReservationNo)) As ReservationNo,
	--			RTRIM(LTRIM(GRCNo)) AS ResInvoiceNo,
	--			'AT' As TransType,
	--			Line_No,
	--			MainClassCode, 
	--			SubClassCode, 
	--			MainAccCode, 
	--			SubAccCode,
	--			GETDATE() AS logtime,
	--			SUM(FCAmount) AS FCAmount, 
	--			ExRate, 
	--			TrCurr
	--	FROM (

	--			SELECT	@AdvanceAcc As AccCode,
	--					substring(@AdvanceAcc,1,2) As MainClassCode,
	--					substring(@AdvanceAcc,3,2) As SubClassCode,
	--					substring(@AdvanceAcc,5,4) As MainAccCode,
	--					substring(@AdvanceAcc,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(@TAmount,2)) As Amount, 
	--					ABS(round(@TAmount,2)) AS AccAmount,
	--					--'D' AS DRCR,
	--					IIF(@IsCancelCheckIn = 0,'D','C') AS DRCR,
	--					RTRIM(LTRIM(InhouseReservationHeaders.ReservationNo)) As ReservationNo,
	--					--RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					RTRIM(LTRIM(InhouseReservationHeaders.GRCNo)) As GRCNo,
	--					1 AS Line_No,
	--					ABS(round(@TAmountFC,2)) AS FCAmount,
	--					0.0 AS ExRate, 
	--					Currencies.ISOCode AS TrCurr
	--			FROM	ExtraPostingDetails INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			--WHERE	(ExtraPostingDetails.IsAdvance = 1 OR ExtraPostingDetails.IsRefund = 1) --AND InhouseReservationHeaders.ReservationNo = @ReservationNo
	--			WHERE	(ExtraPostingDetails.IsAdvance = 1) --AND InhouseReservationHeaders.ReservationNo = @ReservationNo

	--			UNION ALL

	--			SELECT	@InHouseDebtorAcc As AccCode,
	--					substring(@InHouseDebtorAcc,1,2) As MainClassCode,
	--					substring(@InHouseDebtorAcc,3,2) As SubClassCode,
	--					substring(@InHouseDebtorAcc,5,4) As MainAccCode,
	--					substring(@InHouseDebtorAcc,9,4) As SubAccCode,
	--					CONVERT(DATETIME,CONVERT(VARCHAR(10),ExtraPostingDetails.ChargeDate,103),103) AS TxnDate, 
	--					ABS(round(@TAmount,2)) As Amount, 
	--					ABS(round(@TAmount,2)) AS AccAmount,
	--					--'C' AS DRCR,
	--					IIF(@IsCancelCheckIn = 0,'C','D') AS DRCR,
	--					RTRIM(LTRIM(InhouseReservationHeaders.ReservationNo)) As ReservationNo,
	--					--RTRIM(LTRIM(ExtraPostingDetails.DocumentNo)) As DocumentNo,
	--					RTRIM(LTRIM(InhouseReservationHeaders.GRCNo)) As GRCNo,
	--					2 AS Line_No,
	--					ABS(round(@TAmountFC,2)) AS FCAmount,
	--					0.0 AS ExRate, 
	--					Currencies.ISOCode AS TrCurr
	--			FROM	ExtraPostingDetails INNER JOIN InhouseReservationHeaders ON ExtraPostingDetails.ReservationHeaderId = InhouseReservationHeaders.Id INNER JOIN
	--					Currencies ON Currencies.Id = ExtraPostingDetails.CurrencyId
	--			--WHERE	(ExtraPostingDetails.IsAdvance = 1 OR ExtraPostingDetails.IsRefund = 1) --AND InhouseReservationHeaders.ReservationNo = @ReservationNo
	--			WHERE	(ExtraPostingDetails.IsAdvance = 1) --AND InhouseReservationHeaders.ReservationNo = @ReservationNo
	--	) X

	--	WHERE ReservationNo = @ReservationNo
	--	--GROUP BY	AccCode, MainClassCode, SubClassCode, MainAccCode, SubAccCode, TxnDate, Amount, AccAmount, DrCr, ReservationNo, DocumentNo, Line_No,GRCNo
	--	GROUP BY	AccCode, MainClassCode, SubClassCode, MainAccCode, SubAccCode, TxnDate, Amount, AccAmount, DrCr, ReservationNo, Line_No, GRCNo, X.ExRate, X.TrCurr
	--	ORDER BY	TxnNo, DRCR

	--	UPDATE AccMasterSingleCurrencyHO.DBO.Settings set Journals = Journals + 1

	--END
	---- FOR RESERVATION ADVANCE TRANSFER END	
	
END

GO

