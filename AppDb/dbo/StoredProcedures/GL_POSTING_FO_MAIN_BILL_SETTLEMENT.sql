
CREATE PROCEDURE [dbo].[GL_POSTING_FO_MAIN_BILL_SETTLEMENT] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))

AS
BEGIN

	SET DATEFORMAT DMY

	DECLARE @BlockCode AS VARCHAR(4) = 'PMT'
	DECLARE @InHouseAccCode AS VARCHAR(12) = ''


	SELECT @InHouseAccCode = AccCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE blockcode = 'INH' AND GLCompCode = @GLCompCode


	-- UPDATE PAYMENT TYPE NULL RECORDS TO ''
	UPDATE PaymentModes SET PaymentType = '' WHERE PaymentType IS NULL


	BEGIN TRY DROP TABLE #TempGL END TRY
	BEGIN CATCH END CATCH
	
	CREATE TABLE #TempGL
	(
		TxnDate	date,	
		compcode	char(4),	
		DeptCode	varchar(3),	
		Outlet	char(3),	
		Amount	money,	
		Narration	varchar(200),	
		AccCode	varchar(12),
		DrCr	varchar(1),	
		SeqNo	bigint,	
		TransType	varchar(2),	
		TempTxnNo	varchar(20),	
		TxnNo	varchar(MAX),	
		TxnID	varchar(1),	
		DocumentNo	varchar(20),	
		ModName	char(1),	
		CurrCode	varchar(5),	
		ExRate	money,	
		FCAmount	money,	
		BSPCode	varchar(10),	
		UserID	uniqueidentifier,	
		BlockCode	varchar(4),	
		SegmentCode	varchar(50),	
		NoPax	int,	
		TourNo	varchar(50),	
		CustName	varchar(200),	
		ArrivalDate	datetime,	
		DepartureDate	datetime,	
		FolioNo	int,	
		VoucherNo	varchar(50),	
		ReservationNo	varchar(50),	
		GroupReservationNo	varchar(50),	
		GRCNo	varchar(50)	
	)
	
	-- INSERT INHOUSE DEBTOR CREDIT ENTRIES - CheckedOutReservationHeaders/InHouseReservationHeaders
	INSERT INTO #TempGL (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, DocumentNo, ModName, CurrCode, ExRate, FCAmount, BSPCode, UserID, BlockCode, SegmentCode, NoPax, TourNo, CustName, ArrivalDate, DepartureDate, FolioNo, VoucherNo, ReservationNo, GroupReservationNo, GRCNo)

	(SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			@InHouseAccCode AS AccCode, 
			'C' AS DrCr, 
			'1' AS SeqNo, 
			CASE WHEN P.PaymentType = 'CC' THEN 'CC' ELSE (CASE WHEN P.PaymentType = 'CR' THEN 'CR' ELSE 'RS' END) END AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			CASE WHEN P.PaymentType = 'CC' THEN M.Level2 ELSE (CASE WHEN P.PaymentType = 'CR' THEN C.BSPCode ELSE NULL END) END AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 InHouseReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			--AND (P.IsCreditCard = 1 OR P.IsDebitCard = 1 OR P.PaymentType = 'CC')
			--AND P.PaymentType = 'CC'
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID

	UNION ALL

	SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			@InHouseAccCode AS AccCode, 
			'C' AS DrCr, 
			'2' AS SeqNo, 
			CASE WHEN P.PaymentType = 'CC' THEN 'CC' ELSE (CASE WHEN P.PaymentType = 'CR' THEN 'CR' ELSE 'RS' END) END AS TransType,  
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			CASE WHEN P.PaymentType = 'CC' THEN M.Level2 ELSE (CASE WHEN P.PaymentType = 'CR' THEN C.BSPCode ELSE NULL END) END AS BSPCode,  
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 CheckedOutReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			--AND (P.IsCreditCard = 1 OR P.IsDebitCard = 1 OR P.PaymentType = 'CC')
			--AND P.PaymentType = 'CC'
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID
	
	)


	-- INSERT SETTLEMENT DEBIT ENTRIES (CREDIT CARD) - CheckedOutReservationHeaders/InHouseReservationHeaders
	INSERT INTO #TempGL (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, DocumentNo, ModName, CurrCode, ExRate, FCAmount, BSPCode, UserID, BlockCode, SegmentCode, NoPax, TourNo, CustName, ArrivalDate, DepartureDate, FolioNo, VoucherNo, ReservationNo, GroupReservationNo, GRCNo)

	(SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			M.AccCode AS AccCode, 
			'D' AS DrCr, 
			'3' AS SeqNo, 
			'CC' AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			M.Level2 AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 InHouseReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			AND P.PaymentType = 'CC'
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID

	UNION ALL

	SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			M.AccCode AS AccCode, 
			'D' AS DrCr, 
			'4' AS SeqNo, 
			'CC' AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			M.Level2 AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 CheckedOutReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			AND P.PaymentType = 'CC'
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID
	
	)

	-- INSERT SETTLEMENT DEBIT ENTRIES (CREDIT) - CheckedOutReservationHeaders/InHouseReservationHeaders
	INSERT INTO #TempGL (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, DocumentNo, ModName, CurrCode, ExRate, FCAmount, BSPCode, UserID, BlockCode, SegmentCode, NoPax, TourNo, CustName, ArrivalDate, DepartureDate, FolioNo, VoucherNo, ReservationNo, GroupReservationNo, GRCNo)

	(SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			M.AccCode AS AccCode, 
			'D' AS DrCr, 
			'5' AS SeqNo, 
			'CR' AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			C.BSPCode AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 InHouseReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			AND P.PaymentType = 'CR'
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID

	UNION ALL

	SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			M.AccCode AS AccCode, 
			'D' AS DrCr, 
			'6' AS SeqNo, 
			'CR' AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			C.BSPCode AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 CheckedOutReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			AND P.PaymentType = 'CR'
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID
	
	)

	-- INSERT SETTLEMENT DEBIT ENTRIES (OTHER) - CheckedOutReservationHeaders/InHouseReservationHeaders
	INSERT INTO #TempGL (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, DocumentNo, ModName, CurrCode, ExRate, FCAmount, BSPCode, UserID, BlockCode, SegmentCode, NoPax, TourNo, CustName, ArrivalDate, DepartureDate, FolioNo, VoucherNo, ReservationNo, GroupReservationNo, GRCNo)

	(SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			M.AccCode AS AccCode, 
			'D' AS DrCr, 
			'7' AS SeqNo, 
			'RS' AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			NULL AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 InHouseReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			AND P.PaymentType NOT IN ('CC','CR')
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID

	UNION ALL

	SELECT	@CurrDate AS TxnDate, 
			@GLCompCode AS compcode, 
			'00' AS DeptCode, 
			'00' AS Outlet, 
			ABS(B.PaidAmount) AS Amount, 
			'Settlement of Room Sales for Invoice No: '+B.INVOICENO+', Reservation No: '+R.ReservationNo+' AND GRC No: '+ R.GRCNo AS Narration, 
			M.AccCode AS AccCode, 
			'D' AS DrCr, 
			'8' AS SeqNo, 
			'RS' AS TransType, 
			CAST(P.ID AS VARCHAR)+B.INVOICENO AS TempTxnNo, 
			'' AS TxnNo, 
			'R' TxnID, 
			B.INVOICENO AS DocumentNo, 
			'H' AS ModName, 
			'LKR' AS CurrCode, 
			1 AS ExRate, 
			0 AS FCAmount, 
			NULL AS BSPCode, 
			@DayEndUserID AS UserID, 
			@BlockCode AS BlockCode, 
			M.Segmentcode AS SegmentCode, 
			R.NoofAdults AS NoPax, 
			ISNULL(R.TourNo,'') AS TourNo, 
			'' AS CustName, 
			R.Arrival AS ArrivalDate, 
			R.Departure AS DepartureDate, 
			'1' AS FolioNo, 
			ISNULL(R.VoucherNo,'') AS VoucherNo, 
			R.ReservationNo AS ReservationNo, 
			R.GroupReservationNo AS GroupReservationNo, 
			R.GRCNo AS GRCNo

	FROM	BillSettlementDetails AS B INNER JOIN
							 CheckedOutReservationHeaders AS R ON B.ReservationHeaderID = R.Id AND B.ReservationNo = R.ReservationNo INNER JOIN
							 PaymentModes AS P ON B.PaymentTypeID = P.Id INNER JOIN
							 eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping AS M ON P.Id = M.Level1 INNER JOIN
							 Companies AS C ON R.AgentId = C.Id

	WHERE	M.blockcode = @BlockCode
			AND M.GLCompCode = @GLCompCode
			AND P.PaymentType NOT IN ('CC','CR')
			AND CAST(B.ChargeDate AS DATE) = @CurrDate
			AND B.PropertyID = @PropertyID
	
	)




	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, DocumentNo, ModName, CurrCode, ExRate, FCAmount, BSPCode, UserID, BlockCode, SegmentCode, NoPax, TourNo, CustName, ArrivalDate, DepartureDate, FolioNo, VoucherNo, ReservationNo, GroupReservationNo, GRCNo)
	SELECT TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, DocumentNo, ModName, CurrCode, ExRate, FCAmount, BSPCode, UserID, BlockCode, SegmentCode, NoPax, TourNo, CustName, ArrivalDate, DepartureDate, FolioNo, VoucherNo, ReservationNo, GroupReservationNo, GRCNo FROM #TempGL
	
	SELECT * FROM #TempGL

	BEGIN TRY DROP TABLE #TempGL END TRY
	BEGIN CATCH END CATCH

END

GO

