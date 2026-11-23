

CREATE procedure [dbo].[GL_POSTING_FE_RESTAURANT_COMPLEMENTARY_ITEMCATEGORY] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))
AS

SET DATEFORMAT DMY 

DECLARE @ServiceChargeAcc VARCHAR(12) = 'SERVICECHARG'
DECLARE @TempTxnNo AS VARCHAR(MAX) = '' 
DECLARE @Count AS INT = 0

DECLARE @ResNetVal DECIMAL(38, 8)
DECLARE @GrandTotal DECIMAL(38, 8)
DECLARE @SubTotal DECIMAL(38, 8)
DECLARE @DIFF DECIMAL(38, 8)

DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'
DECLARE @BLOCKCODE AS VARCHAR(3) = 'OCS'
DECLARE @CompCode AS VARCHAR(3) = NULL
DECLARE @OutletCode AS VARCHAR(3) = 'J01'
DECLARE @TransType AS VARCHAR(2) = 'RC'

--DECLARE @PropertyId AS INT = 1

--SELECT @ServiceChargeAcc = ServiceAcc FROM AccMasterSingleCurrencyHO.dbo.Settings

IF @GLCompCode = '001' BEGIN
	SET @PropertyID = 2
END


SELECT	@PropertyID = Id	FROM	Categlog_vrV2.dbo.Property	WHERE	GLCOMPCODE = @GLCompCode


BEGIN TRY DROP TABLE #TempRestaurantComplementary END TRY
BEGIN CATCH END CATCH


	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------

	DECLARE @NextTempNo AS VARCHAR(12) = ''

	EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_TEMP_NUMBER] @NextTempNo OUTPUT

	SELECT @NextTempNo AS NextTempNo

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------


SELECT *, ROW_NUMBER() OVER(ORDER BY outlet) AS SeqNo1

INTO #TempRestaurantComplementary

FROM (


	SELECT	CAST(BillTrans.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillTrans.Outlet Outlet,
			SUM(ABS(Billtrans.NetAmount)) Amount,
			RTRIM(LTRIM(ItemCategory.Name)) + ' Cost of Sale For Outlet - ' + RTRIM(LTRIM(Location_Ref.description)) AS Narration,
			Destinity_GLIntegrationAccountMapping.AccCode AccCode,
			'C' DRCR,
			'1' SeqNo,
			@TransType TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			@NextTempNo TempTxnNo,
			'R' ModName,
			Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			NULL BSPCode,
			@BLOCKCODE BlockCode
	
	FROM	Categlog_vrV2.dbo.MainMenu
			INNER JOIN Categlog_vrV2.dbo.Location_Ref 
			INNER JOIN Categlog_vrV2.dbo.BillTrans ON Location_Ref.code = BillTrans.Outlet AND Location_Ref.PropertyId = BillTrans.PropertyId 
			INNER JOIN Categlog_vrV2.dbo.BillHeader ON Location_Ref.code = BillHeader.Outlet AND BillTrans.OrderNo = BillHeader.OrderNo AND Location_Ref.PropertyId = BillHeader.PropertyId AND BillTrans.PropertyId = BillHeader.PropertyId ON MainMenu.ItemCode = BillTrans.MainMenuCode AND MainMenu.PropertyId = BillTrans.PropertyId 
			INNER JOIN Categlog_vrV2.dbo.ItemCategory ON MainMenu.ItemCategory = ItemCategory.Id AND MainMenu.PropertyId = ItemCategory.PropertyId 
			INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ItemCategory.Id = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillTrans.OrderDate = @CurrDate)
			AND (BillTrans.OrderNo IN (
				SELECT	PayTrans.OrderNo
				FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND (PayTrans.OrderDate = @CurrDate))
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyID)
				)
				AND Destinity_GLIntegrationAccountMapping.blockcode = 'OCS'
				AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
				AND BillHeader.PropertyId = @PropertyID
				--AND BillTrans.Outlet = @OutletCode
				--AND BillHeader.MemberID = 0

	GROUP BY CAST(BillTrans.OrderDate AS DATE), BillTrans.Outlet, RTRIM(LTRIM(ItemCategory.Name)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(ABS(Billtrans.NetAmount)) > 0

	-- GET EXTRA SALE END


	UNION ALL

	-- GET EXTRA SALE TAXES & SERVICE CHARGE START

	SELECT	CAST(BillHeader.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillHeader.Outlet Outlet,
			SUM(ABS(POS_BillChargeDetail.ChargeAmount)) Amount,
			RTRIM(LTRIM(Gen_ChargeType.Name)) + ' Cost of Sale For Outlet - ' + RTRIM(LTRIM(Location_Ref.description)) AS Narration,
			Destinity_GLIntegrationAccountMapping.AccCode AccCode,
			'C' DRCR,
			'2' SeqNo,
			@TransType TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			@NextTempNo TempTxnNo,
			'R' ModName,
			Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			NULL BSPCode,
			@BLOCKCODE BlockCode
	
	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping INNER JOIN
				Categlog_vrV2..Location_Ref INNER JOIN
				Categlog_vrV2..Gen_ChargeType INNER JOIN
				Categlog_vrV2..POS_BillChargeDetail ON Gen_ChargeType.ChargeTypeID = POS_BillChargeDetail.ChargeTypeID ON Location_Ref.code = POS_BillChargeDetail.Outlet ON 
				eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 = Gen_ChargeType.ChargeTypeID INNER JOIN
				Categlog_vrV2..BillHeader ON POS_BillChargeDetail.OrderNo = BillHeader.OrderNo AND POS_BillChargeDetail.Outlet = BillHeader.Outlet AND POS_BillChargeDetail.PropertyId = BillHeader.PropertyId

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate)
			AND (BillHeader.OrderNo IN (
				SELECT	PayTrans.OrderNo
				FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND (PayTrans.OrderDate = @CurrDate))
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyID)
				)
				AND Destinity_GLIntegrationAccountMapping.blockcode = 'TAXR'
				AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
				AND BillHeader.PropertyId = @PropertyID
				--AND BillTrans.Outlet = @OutletCode
				--AND BillHeader.MemberID = 0

	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(Gen_ChargeType.Name)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(POS_BillChargeDetail.ChargeAmount) > 0
	
	-- GET EXTRA SALE TAXES & SERVICE CHARGE END

	UNION ALL

	-- GET EXTRA SALE SETTLEMENT OTHER START

	SELECT	CAST(BillHeader.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillHeader.Outlet Outlet,
			ROUND(SUM(PayTrans.ActualAmt),2) Amount,
			'Settlement of ' +RTRIM(LTRIM(PaymentTypes.Description)) +' Cost of Sale For Outlet - ' +RTRIM(LTRIM(Location_Ref.description)) AS Narration,
			Destinity_GLIntegrationAccountMapping.AccCode AccCode,
			'D' DRCR,
			'3' SeqNo,
			@TransType TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'B' TxnID,
			@DayEndUserID UserID,
			@NextTempNo TempTxnNo,
			'R' ModName,
			Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			NULL BSPCode,
			@BLOCKCODE BlockCode
	
	FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.BillHeader ON PayTrans.OrderNo = BillHeader.OrderNo AND PayTrans.Outlet = BillHeader.Outlet AND PayTrans.OrderDate = BillHeader.OrderDate
				INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				INNER JOIN Categlog_vrV2.dbo.Location_Ref ON BillHeader.Outlet = Location_Ref.code
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON Categlog_vrV2.dbo.PaymentTypes.Id = Destinity_GLIntegrationAccountMapping.Level1

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate) 
			AND BillHeader.OrderNo IN (
				SELECT	PayTrans.OrderNo 
				FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	(PaymentTypes.NoValue = 1 AND PayTrans.OrderDate = @CurrDate) 
						--AND paytrans.compcode=@CompCode 
						AND PayTrans.PayCode <> 'BR' 
						AND PayTrans.PropertyId = @PropertyID
				)
			AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMTR'
			AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
			AND BillHeader.PropertyId = @PropertyID
			AND PaymentTypes.PropertyId = @PropertyID
			--AND PaymentTypes.CreditCard = 0
			--AND BillHeader.MemberID = 0
			
	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(PaymentTypes.Description)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(PayTrans.ActualAmt) > 0
	                       
	-- GET EXTRA SALE SETTLEMENT OTHER END   


) X


SELECT @Count = COUNT(*) FROM #TempRestaurantComplementary WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate

IF @Count > 0 BEGIN

	---- DrCr Tally

	DECLARE @ACCCODE_DIFF AS VARCHAR(12) = ''
	DECLARE @SegmentID_DIFF AS INT = 0
	DECLARE @DRCR_DIFF AS CHAR(1) = ''

	SELECT @ACCCODE_DIFF = AccCode, @SegmentID_DIFF = SegmentCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE BlockCode = 'RND' AND GLCompCode = @GLCompCode

	SELECT @DIFF = sum(case when drcr='D' then amount else 0 end) - sum(case when drcr='C' then amount else 0 end)
	FROM #TempRestaurantComplementary
	WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate


	IF ABS(@DIFF) > 0 AND ABS(@DIFF) < 1 BEGIN

		IF @DIFF >= 0 BEGIN
			SET @DRCR_DIFF = 'C'
		END

		ELSE BEGIN
			SET @DRCR_DIFF = 'D'
		END
	
		INSERT INTO #TempRestaurantComplementary (TxnDate,CompCode,DeptCode, Outlet,Amount,Narration,AccCode,DRCR,SeqNo,TransType,DocumentNo,TxnNo,TxnID,UserID,TempTxnNo,ModName,SegmentCode,CurrCode,ExRate,FCAmount,BSPCode,BlockCode)
		SELECT	CAST(@CurrDate AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' AS DeptCode,
				'00' Outlet,
				@DIFF Amount,
				'Rounded-off difference' AS Narration,
				@ACCCODE_DIFF AccCode,
				@DRCR_DIFF DRCR,
				'4' SeqNo,
				@TransType TransType,
				@NextTempNo DocumentNo,
				'' TxnNo,
				'B' TxnID,
				@DayEndUserID UserID,
				@NextTempNo TempTxnNo,
				'R' ModName,
				@SegmentID_DIFF SegmentCode,
				'LKR' AS CurrCode,
				1 AS ExRate,
				0 AS FCAmount,
				NULL AS BSPCode,
				@BLOCKCODE AS BlockCode
	END

	---- DrCr Tally

	--SELECT @TempTxnNo = CONVERT(VARCHAR, GETDATE(), 112)+(RIGHT('000'+RTRIM(CONVERT(VARCHAR(3), ROUND(RAND()*1000,0))),3))
	
	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount, BSPCode, Blockcode)
	SELECT TxnDate, compcode, DeptCode, Outlet, ROUND(Amount,2) Amount, Narration, AccCode, DrCr, SeqNo1, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount, BSPCode, Blockcode
	FROM #TempRestaurantComplementary
	WHERE CAST(TxnDate AS DATE) = @CurrDate AND CompCode = @GLCompCode
 	

	--SET @return = @TempTxnNo
END

BEGIN TRY DROP TABLE #TempRestaurantComplementary END TRY
BEGIN CATCH END CATCH


--SET @return = @TempTxnNo

GO

