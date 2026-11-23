

CREATE procedure [dbo].[GL_POSTING_FE_RESTAURANT_SALE_CREDITCARD] (@CurrDate AS DATE, @DayEndUserID AS UniqueIdentifier, @PropertyID AS INT, @GLCompCode AS VARCHAR(3))
AS


--SET DATEFORMAT DMY  EXEC [GL_POSTING_FE_RESTAURANT_SALE_CREDITCARD] '22/08/2020' , 'B490B26A-2886-4671-8253-A8644C76660F',2 , '001' 

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
DECLARE @BLOCKCODE AS VARCHAR(3) = 'PMT'
DECLARE @CompCode AS VARCHAR(3) = NULL
DECLARE @OutletCode AS VARCHAR(3) = 'J01'
DECLARE @TransType AS VARCHAR(2) = 'CC'
DECLARE @SalesClearingAcc AS VARCHAR(12) = ''
DECLARE @SalesClearingSegmentCode AS INT = 0


SELECT	@PropertyID = Id	FROM	Categlog_vrV2.dbo.Property	WHERE	GLCOMPCODE = @GLCompCode


BEGIN TRY DROP TABLE #TempRestaurantSaleR END TRY
BEGIN CATCH END CATCH


SELECT @SalesClearingAcc = Acccode, @SalesClearingSegmentCode = segmentcode FROM eFinancials_Accounting..[Destinity_GLIntegrationAccountMapping] WHERE blockcode = 'SLC' AND GLCompCode = @GLCompCode


SELECT @DRAMT = ISNULL(SUM(Amount),0)
FROM(

	SELECT	ISNULL(ROUND(SUM(PayTrans.ActualAmt),2),0) Amount
	
	FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.BillHeader ON PayTrans.OrderNo = BillHeader.OrderNo AND PayTrans.Outlet = BillHeader.Outlet AND PayTrans.OrderDate = BillHeader.OrderDate
				INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				INNER JOIN Categlog_vrV2.dbo.Location_Ref ON BillHeader.Outlet = Location_Ref.code
				--INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON Categlog_vrV2.dbo.PaymentTypes.Id = Destinity_GLIntegrationAccountMapping.Level1
				--INNER JOIN Categlog_vrV2.dbo.POS_ExecutiveMember ON Categlog_vrV2.dbo.BillHeader.MemberID = POS_ExecutiveMember.MemberID

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate) 
			AND BillHeader.OrderNo NOT IN (
				SELECT	PayTrans.OrderNo 
				FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	(PaymentTypes.NoValue = 1 AND PayTrans.OrderDate = @CurrDate) 
						--AND paytrans.compcode=@CompCode 
						AND PayTrans.PayCode <> 'BR' 
						AND PayTrans.PropertyId = @PropertyID
				)
			--AND Destinity_GLIntegrationAccountMapping.blockcode = 'PMTR'
			AND BillHeader.PropertyId = @PropertyID
			AND PaymentTypes.PropertyId = @PropertyID
			AND PaymentTypes.CreditCard = 1
			--AND ISNULL(BillHeader.MemberID,'') <> ''

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

		-- GET EXTRA SALE SETTLEMENT CREDIT CARD START

	SELECT	CAST(BillHeader.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillHeader.Outlet Outlet,
			ROUND(SUM(PayTrans.ActualAmt),2) Amount,
			'Settlement of ' +RTRIM(LTRIM(PaymentTypes.Description)) +' For Outlet - ' +RTRIM(LTRIM(Location_Ref.description)) AS Narration,
			Destinity_GLIntegrationAccountMapping.AccCode AccCode,
			'D' DRCR,
			'3' SeqNo,
			'CC' TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'R' TxnID,
			@DayEndUserID UserID,
			CAST(PaymentTypes.ID AS VARCHAR)+BillHeader.ORDERNO TempTxnNo,
			'R' ModName,
			Destinity_GLIntegrationAccountMapping.SegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			Destinity_GLIntegrationAccountMapping.Level2 AS BSPCode,
			'PMT' AS BlockCode
	
	FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.BillHeader ON PayTrans.OrderNo = BillHeader.OrderNo AND PayTrans.Outlet = BillHeader.Outlet AND PayTrans.OrderDate = BillHeader.OrderDate
				INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				INNER JOIN Categlog_vrV2.dbo.Location_Ref ON BillHeader.Outlet = Location_Ref.code
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON Categlog_vrV2.dbo.PaymentTypes.Id = Destinity_GLIntegrationAccountMapping.Level1
				--INNER JOIN Categlog_vrV2.dbo.POS_ExecutiveMember ON Categlog_vrV2.dbo.BillHeader.MemberID = POS_ExecutiveMember.MemberID

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate) 
			AND BillHeader.OrderNo NOT IN (
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
			AND PaymentTypes.CreditCard = 1
			--AND ISNULL(BillHeader.MemberID,'') <> ''
			
	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(PaymentTypes.Description)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode, Destinity_GLIntegrationAccountMapping.Level2, BillHeader.OrderNo, PaymentTypes.ID

	HAVING SUM(PayTrans.ActualAmt) > 0
	                       
	-- GET EXTRA SALE SETTLEMENT CREDIT CARD END  

	UNION ALL

	-- GET SALES CLEARING ENTRY START

	SELECT	CAST(BillHeader.OrderDate AS DATE) TxnDate,
			@GLCompCode CompCode,
			'00' AS DeptCode,
			BillHeader.Outlet Outlet,
			ROUND(SUM(PayTrans.ActualAmt),2) Amount,
			'Outlet Sale' AS Narration,
			@salesclearingacc AccCode,
			'C' DRCR,
			'0' SeqNo,
			'CC' TransType,
			@NextTempNo DocumentNo,
			'' TxnNo,
			'R' TxnID,
			@DayEndUserID UserID,
			CAST(PaymentTypes.ID AS VARCHAR)+BillHeader.ORDERNO TempTxnNo,
			'R' ModName,
			@SalesClearingSegmentCode SegmentCode,
			'LKR' AS CurrCode,
			1 AS ExRate,
			0 AS FCAmount,
			Destinity_GLIntegrationAccountMapping.Level2 AS BSPCode,
			'PMT' AS BlockCode
	
	FROM	Categlog_vrV2.dbo.PayTrans INNER JOIN Categlog_vrV2.dbo.BillHeader ON PayTrans.OrderNo = BillHeader.OrderNo AND PayTrans.Outlet = BillHeader.Outlet AND PayTrans.OrderDate = BillHeader.OrderDate
				INNER JOIN Categlog_vrV2.dbo.PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				INNER JOIN Categlog_vrV2.dbo.Location_Ref ON BillHeader.Outlet = Location_Ref.code
				INNER JOIN eFinancials_Accounting.dbo.Destinity_GLIntegrationAccountMapping ON Categlog_vrV2.dbo.PaymentTypes.Id = Destinity_GLIntegrationAccountMapping.Level1
				--INNER JOIN Categlog_vrV2.dbo.POS_ExecutiveMember ON Categlog_vrV2.dbo.BillHeader.MemberID = POS_ExecutiveMember.MemberID

	WHERE	(BillHeader.MealEntitlement <> 'B') AND (BillHeader.OrderDate = @CurrDate) 
			AND BillHeader.OrderNo NOT IN (
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
			AND PaymentTypes.CreditCard = 1

	GROUP BY CAST(BillHeader.OrderDate AS DATE), BillHeader.Outlet, RTRIM(LTRIM(PaymentTypes.Description)), RTRIM(LTRIM(Location_Ref.description)), Destinity_GLIntegrationAccountMapping.AccCode, Destinity_GLIntegrationAccountMapping.SegmentCode, Destinity_GLIntegrationAccountMapping.Level2, BillHeader.OrderNo, PaymentTypes.ID

	HAVING SUM(PayTrans.ActualAmt) > 0

	-- GET SALES CLEARING ENTRY END

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

