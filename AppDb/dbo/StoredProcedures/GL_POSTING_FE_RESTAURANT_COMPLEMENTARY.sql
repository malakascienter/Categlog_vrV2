



CREATE PROCEDURE [dbo].[GL_POSTING_FE_RESTAURANT_COMPLEMENTARY] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))
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

BEGIN TRY DROP TABLE #TempRestaurantComplementary END TRY
BEGIN CATCH END CATCH

--INSERT INTO AccMasterSingleCurrencyHO.dbo.GL_POSTING_DELETED
--		(TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, USERID, logdatetime, DeletedUSERID)
--SELECT	 TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, TempTxnNo, TxnNo, TxnID, USERID, logdatetime, @UserID
--FROM AccMasterSingleCurrencyHO.dbo.GL_POSTING
--WHERE CompCode = @CompCode AND Outlet = @OutletCode AND CAST(TxnDate AS DATE) = @CurrDate AND TransType = @TransType

--DELETE AccMasterSingleCurrencyHO.dbo.GL_POSTING WHERE CompCode = @CompCode AND Outlet = @OutletCode AND CAST(TxnDate AS DATE) = @CurrDate  AND TransType = @TransType


-- GET RESNETVAL START

--SELECT	@GrandTotal = ROUND(SUM([Subtotal]+[ServiceCharge]+[TaxVal1]+[TaxVal2]+[TaxVal3]+[TaxVal4]),2), @SubTotal = ROUND(SUM([Subtotal]),2)
--FROM	Categlog_vrV2.dbo.BillHeader WHERE	(OrderDate = @CurrDate) AND (LEFT(OrderNo, 1) <> 'F') AND Outlet = @OutletCode AND billheader.compcode=@CompCode

--SET @ResNetVal = @GrandTotal / @SubTotal

-- GET RESNETVAL START


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
			RTRIM(LTRIM(Category.Description)) + ' Cost of Sale For Outlet - ' + RTRIM(LTRIM(Location_Ref.description)) AS Narration,
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
			0 AS FCAmount
	
	FROM	Categlog_vrV2.dbo.BillHeader INNER JOIN
                         Categlog_vrV2.dbo.Location_Ref INNER JOIN
                         eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON Location_Ref.code = eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level1 INNER JOIN
                         Categlog_vrV2.dbo.Category INNER JOIN
                         Categlog_vrV2.dbo.BillTrans ON Category.Code = BillTrans.Category ON eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping.Level2 = Category.Code AND Location_Ref.code = BillTrans.Outlet AND 
                         Location_Ref.PropertyId = BillTrans.PropertyId AND Location_Ref.PropertyId = Category.PropertyId ON BillHeader.Outlet = Location_Ref.code AND BillHeader.OrderNo = BillTrans.OrderNo AND 
                         BillHeader.PropertyId = Location_Ref.PropertyId

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillTrans.OrderDate = @CurrDate)
			AND (BillTrans.OrderNo IN (
				SELECT	PayTrans.OrderNo
				FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND (PayTrans.OrderDate = @CurrDate))
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyID)
				)
				AND Destinity_GLIntegrationAccountMapping.blockcode = 'OCS'
				AND BillHeader.PropertyId = @PropertyID
				--AND BillTrans.Outlet = @OutletCode

	GROUP BY CAST(BillTrans.OrderDate AS DATE), BillTrans.Outlet, RTRIM(LTRIM(Category.Description)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

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
			0 AS FCAmount
	
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
				AND BillHeader.PropertyId = @PropertyID
				--AND BillTrans.Outlet = @OutletCode

	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(Gen_ChargeType.Name)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(POS_BillChargeDetail.ChargeAmount) > 0
	
	-- GET EXTRA SALE TAXES & SERVICE CHARGE END

	UNION ALL

	-- GET EXTRA SALE SETTLEMENT START

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
			0 AS FCAmount
	
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
				AND BillHeader.PropertyId = @PropertyID
			
	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(PaymentTypes.Description)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode

	HAVING SUM(PayTrans.ActualAmt) > 0
	                       
	-- GET EXTRA SALE SETTLEMENT END                      

) X


SELECT @Count = COUNT(*) FROM #TempRestaurantComplementary WHERE CompCode = @GLCompCode AND CAST(TxnDate AS DATE) = @CurrDate

IF @Count > 0 BEGIN

	--SELECT @TempTxnNo = CONVERT(VARCHAR, GETDATE(), 112)+(RIGHT('000'+RTRIM(CONVERT(VARCHAR(3), ROUND(RAND()*1000,0))),3))
	
	INSERT INTO eFinancials_Accounting.dbo.GL_POSTING (TxnDate, compcode, DeptCode, Outlet, Amount, Narration, AccCode, DrCr, SeqNo, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount)
	SELECT TxnDate, compcode, DeptCode, Outlet, ROUND(Amount,2) Amount, Narration, AccCode, DrCr, SeqNo1, TransType, DocumentNo, TxnNo, TxnID, UserID, TempTxnNo, ModName, SegmentCode, CurrCode, ExRate, FCAmount
	FROM #TempRestaurantComplementary
	WHERE CAST(TxnDate AS DATE) = @CurrDate AND CompCode = @GLCompCode
 	

	---- DrCr Tally

	--SELECT @DIFF = SUM(CASE WHEN DrCr = 'D' THEN Amount ELSE Amount * -1 END) FROM AccMasterSingleCurrencyHO.dbo.GL_POSTING
	--WHERE CompCode = @CompCode AND Outlet = @OutletCode AND CAST(TxnDate AS DATE) = @CurrDate AND TransType = @TransType AND TempTxnNo = @TempTxnNo

	--IF @DIFF <= 1 OR @DIFF >= -1 BEGIN

	--	UPDATE AccMasterSingleCurrencyHO.dbo.GL_POSTING
	--	SET AMOUNT = AMOUNT + @DIFF
	--	WHERE CompCode = @CompCode AND Outlet = @OutletCode AND CAST(TxnDate AS DATE) = @CurrDate AND TransType = @TransType 
	--	AND TempTxnNo = @TempTxnNo AND SeqNo = 1 and DrCr = 'C' AND AMOUNT <> 0
		
	--END

	-- DrCr Tally

	--SET @return = @TempTxnNo
END

BEGIN TRY DROP TABLE #TempRestaurantComplementary END TRY
BEGIN CATCH END CATCH


--SET @return = @TempTxnNo

GO

