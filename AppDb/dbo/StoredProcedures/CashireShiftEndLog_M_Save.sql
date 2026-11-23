 --[dbo].[CashireShiftEndLog_M_Save]27,101
CREATE PROCEDURE [dbo].[CashireShiftEndLog_M_Save]
	@ShiftNo			VARCHAR(10),
	@Outlet				VARCHAR(10),
	@Cashier			VARCHAR(10)	= NULL,
	@UserId				INT	= 0,
	@PaymentTypeList	NVARCHAR(MAX) = NULL,
	@dTypeList			NVARCHAR(MAX) = NULL,
	@ShiftDate			DATETIME,
    @PropertyId			INT
	
AS
BEGIN
	SELECT	dType , nos , PayType, IsCash
	INTO #TempdTypeList
	FROM OPENJSON (@dTypeList)
	WITH (
			dType		VARCHAR(50) '$.dType',
			nos		    INT			'$.nos',
			PayType		VARCHAR(50) '$.PayType',
			IsCash		INT			'$.IsCash'
		)

	SELECT	PayCode , IsCash , value
	INTO	#TempPaymentTypeList
	FROM  OPENJSON (@PaymentTypeList)
	WITH (
			PayCode			VARCHAR(100)  '$.PayCode',
			IsCash		    INT			  '$.IsCash',
			value			NVARCHAR(MAX) '$.value'
		)

	SELECT *
	INTO #TempPaymentTypesAndDinominations
	FROM
	(
		SELECT dType, nos AS dTypeCount, (nos * PayType) AS PhysicalAmount, IsCash, '01' AS PayCode
		FROM #TempdTypeList
		UNION
		SELECT '' AS dType, '' AS dTypeCount, [value] AS PhysicalAmount, IsCash, PayCode
		FROM #TempPaymentTypeList
	) AS X
		 
	SELECT		PayCode, SystemAmount
	INTO		#TempPayTrans
	FROM		CashierSignOffPaymentTypesWiseSystemAmounts
	WHERE		ShiftID = @ShiftNo AND CONVERT(DATE, ShiftDate) = CONVERT(DATE, @ShiftDate) AND Outlet = @Outlet AND PropertyId = @PropertyId

	DECLARE @TempPaymentTypes TABLE
	(
		dType			VARCHAR(10),
		dTypeCount		VARCHAR(10),
		PhysicalAmount	DECIMAL(18,10),
		IsCash			BIT,
		PayCode			VARCHAR(10),
		SystemAmount	DECIMAL(18,10)
	)

	INSERT INTO @TempPaymentTypes(dType,dTypeCount, PhysicalAmount, IsCash, PayCode, SystemAmount)
	SELECT '' ,'' , 0, 1, PayCode, 0
	FROM PaymentTypes 
	WHERE PropertyId = @PropertyId

	DELETE TP
	FROM @TempPaymentTypes TP
	INNER JOIN #TempPaymentTypesAndDinominations TD ON TD.PayCode = TP.PayCode

	INSERT INTO @TempPaymentTypes(dType,dTypeCount, PhysicalAmount, IsCash, PayCode, SystemAmount)
	SELECT dType, dTypeCount, PhysicalAmount, IsCash, PayCode,  0
	FROM #TempPaymentTypesAndDinominations

	UPDATE		TP
	SET			TP.SystemAmount = TD.SystemAmount
	FROM		@TempPaymentTypes TP
	INNER JOIN	#TempPayTrans TD ON TD.PayCode = TP.PayCode 

	DELETE 
	FROM	@TempPaymentTypes
	WHERE	SystemAmount = 0 AND PhysicalAmount = 0

	DELETE 
	FROM [dbo].[CashireShiftEndLog] 
	WHERE ([ShiftNo] = @ShiftNo) AND ([Cashireid] = @Cashier) AND ([Outlet] = @Outlet) AND CONVERT(DATE, sysdate) =  CONVERT(DATE, @ShiftDate) AND PropertyId = @PropertyId

	INSERT INTO [dbo].[CashireShiftEndLog]
			([ShiftNo],[Cashireid],[dType],[nos],[value],[sysdate],[IsCash],[Outlet], PayCode,SystemAmount,PropertyId)
	SELECT	@ShiftNo, @Cashier, dType, dTypeCount, PhysicalAmount, @ShiftDate, IsCash, @Outlet, PayCode, SystemAmount,@PropertyId
	FROM	@TempPaymentTypes 
	ORDER BY PayCode, dTypeCount
	------------------------CashierSignOffUserDetails Insert For Report------------------------------------------

	--GET SPECIAL ORDER ADVANCES TO ADD WITH PHYSICAL CASH AMOUNT--
	DECLARE	@SpecialOrderAd DECIMAL(18,10)

	SET	@SpecialOrderAd = (SELECT top(1) TotCashReceipts FROM CashierSignOffSummaryDetails WHERE ShiftNo = @ShiftNo AND CONVERT(DATE,SystemDate) = CONVERT(DATE,@ShiftDate) AND OutletCode = @Outlet AND PropertyId = @PropertyId)
	--------------------------------------------------------------

	SELECT Description, C.PayCode, SUM([value]) As PhysicalAmount, MAX(SystemAmount)AS SystemAmount , (SUM([value]) - MAX(SystemAmount))As Variance, P.[Description] AS PaymentType
	INTO #TempPaymentDetails
	FROM CashireShiftEndLog C 
	INNER JOIN [dbo].PaymentTypes P ON C.PayCode = P.PayCode  AND C.PropertyId = P.PropertyId
	WHERE  C.ShiftNo = @ShiftNo AND Outlet = @Outlet AND CONVERT(DATE,sysdate) = CONVERT(DATE,@ShiftDate) AND C.PropertyId = @PropertyId AND P.PropertyId = @PropertyId
	GROUP BY Description, C.PayCode

	DECLARE @CashierName VARCHAR(250) = (SELECT [Name] FROM Waiter WHERE Code = @Cashier AND PropertyId = @PropertyId )

	INSERT INTO [dbo].[CashierSignOffPaymentDetails]([Desccription], [SystemAmount], [PhysicalAmount], [Variance],SystemDate,ShiftNo,OutletCode,PropertyId)
	SELECT Description, SystemAmount, PhysicalAmount, Variance, @ShiftDate,@ShiftNo,@Outlet ,@PropertyId
	from #TempPaymentDetails
	WHERE PayCode <> 'AD'

	INSERT INTO CashierVarianceLog([TxnDate], [ShiftId], [Outlet], [CashierID], [Paycode], [PaymentType], [Variance], [Remark], [SysDate], [CashierName],PropertyId)
	SELECT @ShiftDate, @ShiftNo, @Outlet, @Cashier, PayCode, PaymentType, Variance, '', GETDATE(), @CashierName,@PropertyId
	FROM #TempPaymentDetails
	WHERE PayCode <> 'AD'

	DECLARE @OpeningBalance			MONEY,
			@Withrawals				MONEY

	SELECT	@OpeningBalance = OpeningBalance, 
			@Withrawals = Withrawals
	FROM	CashierSignOffSummaryDetails
	WHERE	OutletCode = @Outlet AND ShiftNo = @ShiftNo AND CONVERT(DATETIME, SystemDate, 121) =  CONVERT(DATETIME, @ShiftDate, 121)  AND PropertyId = @PropertyId


	UPDATE	CashierSignOffPaymentDetails
	SET		SystemAmount = (SystemAmount + ISNULL(@SpecialOrderAd, 0)+isnull(@OpeningBalance,0))-isnull(@Withrawals,0),
			Variance = (Variance - ISNULL(@SpecialOrderAd, 0)+isnull(@OpeningBalance,0))-isnull(@Withrawals,0)
	WHERE	ShiftNo = @ShiftNo 
			AND CONVERT(DATE,SystemDate) = CONVERT(DATE,@ShiftDate)
			AND OutletCode = @Outlet
			AND [Desccription] = 'CASH' and PropertyId = @PropertyId

	---------------------------------------END-----------------------------------------------------------

	UPDATE POS_CashierShift
	SET IsManagerSignOff = 1
	WHERE Outlet = @Outlet AND ShiftNo = @ShiftNo AND CONVERT(DATE, ShiftDate) = CONVERT(DATE, @ShiftDate) and PropertyId = @PropertyId

END

GO

