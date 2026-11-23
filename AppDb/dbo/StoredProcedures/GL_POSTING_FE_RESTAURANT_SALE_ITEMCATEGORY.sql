

CREATE procedure [dbo].[GL_POSTING_FE_RESTAURANT_SALE_ITEMCATEGORY] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))
AS


--SET DATEFORMAT DMY  EXEC [GL_POSTING_FE_RESTAURANT_SALE] '22/08/2020' , 'B490B26A-2886-4671-8253-A8644C76660F',2 , '001' 

SET DATEFORMAT DMY 

DECLARE @ServiceChargeAcc VARCHAR(12) = 'SERVICECHARG'
DECLARE @TempTxnNo AS VARCHAR(MAX) = '' 
DECLARE @Count AS INT = 0

DECLARE @ResNetVal DECIMAL(38, 8)
DECLARE @GrandTotal DECIMAL(38, 8)
DECLARE @SubTotal DECIMAL(38, 8)
DECLARE @DRAMT AS MONEY
--DECLARE @DIFF DECIMAL(38, 8)


DECLARE @UserID AS UniqueIdentifier = 'B490B26A-2886-4671-8253-A8644C76660F'
DECLARE @BLOCKCODE AS VARCHAR(3) = 'ORS'
DECLARE @CompCode AS VARCHAR(3) = NULL
DECLARE @OutletCode AS VARCHAR(3) = 'J01'
DECLARE @TransType AS VARCHAR(2) = 'RE'
DECLARE @SalesClearingAcc AS VARCHAR(12) = ''
DECLARE @SalesClearingSegmentCode AS INT = 0


SELECT	@PropertyID = Id	FROM	Categlog_vrV2.dbo.Property	WHERE	GLCOMPCODE = @GLCompCode

BEGIN TRY DROP TABLE #TempRestaurantSaleR END TRY
BEGIN CATCH END CATCH


SELECT @SalesClearingAcc = Acccode, @SalesClearingSegmentCode = segmentcode FROM eFinancials_Accounting..[Destinity_GLIntegrationAccountMapping] WHERE blockcode = 'SLC' AND GLCompCode = @GLCompCode


SELECT @DRAMT = ISNULL(SUM(Amount),0)
FROM(

	SELECT        ISNULL(ROUND(SUM(ABS(Categlog_vrV2.dbo.BillTrans.NetAmount)), 2),0) AS Amount
	
	FROM	Categlog_vrV2.dbo.MainMenu
			INNER JOIN Categlog_vrV2.dbo.Location_Ref 
			INNER JOIN Categlog_vrV2.dbo.BillTrans ON Location_Ref.code = BillTrans.Outlet AND Location_Ref.PropertyId = BillTrans.PropertyId 
			INNER JOIN Categlog_vrV2.dbo.BillHeader ON Location_Ref.code = BillHeader.Outlet AND BillTrans.OrderNo = BillHeader.OrderNo AND Location_Ref.PropertyId = BillHeader.PropertyId AND BillTrans.PropertyId = BillHeader.PropertyId ON MainMenu.ItemCode = BillTrans.MainMenuCode AND MainMenu.PropertyId = BillTrans.PropertyId 
			INNER JOIN Categlog_vrV2.dbo.ItemCategory ON MainMenu.ItemCategory = ItemCategory.Id AND MainMenu.PropertyId = ItemCategory.PropertyId 
			INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ItemCategory.Id = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1

	WHERE        (Categlog_vrV2.dbo.BillHeader.MealEntitlement <> 'B') AND (Categlog_vrV2.dbo.BillTrans.OrderDate = @CurrDate) AND (Categlog_vrV2.dbo.BillTrans.OrderNo NOT IN
								 (SELECT        PayTrans_1.OrderNo
								   FROM            Categlog_vrV2.dbo.PayTrans AS PayTrans_1 INNER JOIN
															 Categlog_vrV2.dbo.PaymentTypes AS PaymentTypes_1 ON PayTrans_1.PayCode = PaymentTypes_1.PayCode
								   WHERE        (PaymentTypes_1.NoValue = 1) AND (PayTrans_1.OrderDate = @CurrDate) AND (PayTrans_1.PayCode <> 'BR') AND (PayTrans_1.PropertyId = @PropertyID))) AND 
							 (Categlog_vrV2.dbo.BillHeader.PropertyId = @PropertyID) 
							 --AND (PaymentTypes.CreditCard = 1)
						AND Destinity_GLIntegrationAccountMapping.BlockCode = 'ORS'
						AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode

	UNION ALL

	SELECT	ISNULL(ROUND(SUM(ABS(POS_BillChargeDetail.ChargeAmount)),2),0) AS Amount

	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping INNER JOIN
					Categlog_vrV2..Location_Ref INNER JOIN
					Categlog_vrV2..Gen_ChargeType INNER JOIN
					Categlog_vrV2..POS_BillChargeDetail ON Gen_ChargeType.ChargeTypeID = POS_BillChargeDetail.ChargeTypeID ON Location_Ref.code = POS_BillChargeDetail.Outlet ON 
					eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 = Gen_ChargeType.ChargeTypeID INNER JOIN
					Categlog_vrV2..BillHeader ON POS_BillChargeDetail.OrderNo = BillHeader.OrderNo AND POS_BillChargeDetail.Outlet = BillHeader.Outlet AND POS_BillChargeDetail.PropertyId = BillHeader.PropertyId
					--INNER JOIN
					--		 PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo INNER JOIN
					--		 PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate)
				AND (BillHeader.OrderNo NOT IN (
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
					--AND PaymentTypes.CreditCard = 1

) X

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------

	DECLARE @NextTempNo AS VARCHAR(12) = ''

	EXEC eFinancials_Accounting.dbo.[GL_POSTING_GET_TEMP_NUMBER] @NextTempNo OUTPUT

	SELECT @NextTempNo AS NextTempNo

	-------------------------------------------- GET NEXT TEMP NO --------------------------------------------


SELECT *, ROW_NUMBER() OVER(ORDER BY outlet) AS SeqNo1

INTO #TempRestaurantSaleR

FROM (
	-- GET EXTRA SALE START

	SELECT	CAST(BillTrans.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillTrans.Outlet Outlet,
			ROUND(SUM(ABS(Billtrans.NetAmount)),2) Amount,
			RTRIM(LTRIM(ItemCategory.Name)) + ' Sale For Outlet - ' + RTRIM(LTRIM(Location_Ref.description)) AS Narration,
			Destinity_GLIntegrationAccountMapping.AccCode AccCode,
			'C' DRCR,
			'1' SeqNo,
			@TransType TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			@NextTempNo TempTxnNo,
			'R' ModName,
			Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			NULL AS BSPCode,
			@BLOCKCODE AS BlockCode
	
	FROM	Categlog_vrV2.dbo.MainMenu
			INNER JOIN Categlog_vrV2.dbo.Location_Ref 
			INNER JOIN Categlog_vrV2.dbo.BillTrans ON Location_Ref.code = BillTrans.Outlet AND Location_Ref.PropertyId = BillTrans.PropertyId 
			INNER JOIN Categlog_vrV2.dbo.BillHeader ON Location_Ref.code = BillHeader.Outlet AND BillTrans.OrderNo = BillHeader.OrderNo AND Location_Ref.PropertyId = BillHeader.PropertyId AND BillTrans.PropertyId = BillHeader.PropertyId ON MainMenu.ItemCode = BillTrans.MainMenuCode AND MainMenu.PropertyId = BillTrans.PropertyId 
			INNER JOIN Categlog_vrV2.dbo.ItemCategory ON MainMenu.ItemCategory = ItemCategory.Id AND MainMenu.PropertyId = ItemCategory.PropertyId 
			INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON ItemCategory.Id = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level2 AND Location_Ref.code = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillTrans.OrderDate = @CurrDate)
			AND (BillTrans.OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND (PayTrans.OrderDate = @CurrDate))
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyID)
					
				)
				AND Destinity_GLIntegrationAccountMapping.blockcode = 'ORS'
				AND Destinity_GLIntegrationAccountMapping.GLCompCode = @GLCompCode
				AND BillHeader.PropertyId = @PropertyID
				--AND BillTrans.Outlet = @OutletCode
				--AND PaymentTypes.CreditCard = 1

	GROUP BY CAST(BillTrans.OrderDate AS DATE), BillTrans.Outlet, RTRIM(LTRIM(ItemCategory.Name)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(ABS(Billtrans.NetAmount)) > 0

	-- GET EXTRA SALE END


	UNION ALL

	-- GET EXTRA SALE TAXES & SERVICE CHARGE START

	SELECT	CAST(BillHeader.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillHeader.Outlet Outlet,
			ROUND(SUM(ABS(POS_BillChargeDetail.ChargeAmount)),2) Amount,
			RTRIM(LTRIM(Gen_ChargeType.Name)) + ' For Outlet - ' + RTRIM(LTRIM(Location_Ref.description)) AS Narration,
			Destinity_GLIntegrationAccountMapping.AccCode AccCode,
			'C' DRCR,
			'2' SeqNo,
			@TransType TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			@NextTempNo TempTxnNo,
			'R' ModName,
			Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			NULL AS BSPCode,
			@BLOCKCODE AS BlockCode
	
	FROM	eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping INNER JOIN
				Categlog_vrV2..Location_Ref INNER JOIN
				Categlog_vrV2..Gen_ChargeType INNER JOIN
				Categlog_vrV2..POS_BillChargeDetail ON Gen_ChargeType.ChargeTypeID = POS_BillChargeDetail.ChargeTypeID ON Location_Ref.code = POS_BillChargeDetail.Outlet ON 
				eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 = Gen_ChargeType.ChargeTypeID INNER JOIN
				Categlog_vrV2..BillHeader ON POS_BillChargeDetail.OrderNo = BillHeader.OrderNo AND POS_BillChargeDetail.Outlet = BillHeader.Outlet AND POS_BillChargeDetail.PropertyId = BillHeader.PropertyId
				--INNER JOIN
    --                     PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo INNER JOIN
    --                     PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate)
			AND (BillHeader.OrderNo NOT IN (
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
				--AND PaymentTypes.CreditCard = 1

	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(Gen_ChargeType.Name)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(POS_BillChargeDetail.ChargeAmount) > 0
	
	-- GET EXTRA SALE TAXES & SERVICE CHARGE END     

	UNION ALL

	-- GET SALES CLEARING ENTRY START

	SELECT 	@CurrDate TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			'00' Outlet,
			@DRAMT Amount,
			'Outlet Sale' AS Narration,
			@SalesClearingAcc AccCode,
			'D' DRCR,
			'0' SeqNo,
			@TransType TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'J' TxnID,
			@DayEndUserID UserID,
			@NextTempNo TempTxnNo,
			'R' ModName,
			@SalesClearingSegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			NULL AS BSPCode,
			@BLOCKCODE AS BlockCode


) X


SELECT @Count = COUNT(*) FROM #TempRestaurantSaleR WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate

IF @Count > 0 BEGIN

	---- DrCr Tally

	DECLARE @ACCCODE_DIFF AS VARCHAR(12) = ''
	DECLARE @SegmentID_DIFF AS INT = 0
	DECLARE @DRCR_DIFF AS CHAR(1) = ''
	DECLARE @DIFF Money

	SELECT @ACCCODE_DIFF = AccCode, @SegmentID_DIFF = SegmentCode FROM eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping WHERE BlockCode = 'RND' AND GLCompCode = @GLCompCode

	SELECT @DIFF = sum(case when drcr='D' then amount else 0 end) - sum(case when drcr='C' then amount else 0 end)
	FROM #TempRestaurantSaleR
	WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate


	IF ABS(@DIFF) > 0 AND ABS(@DIFF) < 1 BEGIN

		IF @DIFF >= 0 BEGIN
			SET @DRCR_DIFF = 'C'
		END

		ELSE BEGIN
			SET @DRCR_DIFF = 'D'
		END
	
		INSERT INTO #TempRestaurantSaleR (TxnDate,CompCode,DeptCode, Outlet,Amount,Narration,AccCode,DRCR,SeqNo,TransType,DocumentNo,TxnNo,TxnID,UserID,TempTxnNo,ModName,SegmentCode,CurrCode,ExRate,FCAmount,BSPCode,BlockCode)
		SELECT	CAST(@CurrDate AS DATE) TxnDate,
				@GLCompCode CompCode,
				'00' AS DeptCode,
				'00' Outlet,
				ABS(@DIFF) Amount,
				'Rounded-off difference' AS Narration,
				@ACCCODE_DIFF AccCode,
				@DRCR_DIFF DRCR,
				0 AS SeqNo1,
				@TransType TransType,
				@NextTempNo DocumentNo,
				'' TxnNo,
				'J' TxnID,
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
	
	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount, BSPCode, BlockCode)
	SELECT TxnDate, compcode, DeptCode, Outlet, ROUND(Amount,2) Amount, Narration, AccCode, DrCr, ISNULL(SeqNo1,0), TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount, BSPCode, BlockCode
	FROM #TempRestaurantSaleR
	WHERE CAST(TxnDate AS DATE) = @CurrDate AND CompCode = @GLCompCode


	--SET @return = @TempTxnNo
END

BEGIN TRY DROP TABLE #TempRestaurantSaleR END TRY
BEGIN CATCH END CATCH


--SET @return = @TempTxnNo

GO

