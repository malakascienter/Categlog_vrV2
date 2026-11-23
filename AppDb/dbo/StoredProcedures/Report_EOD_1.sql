--exec [Report_EOD_1] '30/10/2025','B01',1,4
CREATE PROCEDURE [dbo].[Report_EOD_1](          
 @FromDate	VARCHAR(10),        
 @Outlet    VARCHAR(MAX),
 @PropertyId INT,
 @Type INT
)        
AS        
BEGIN         


IF( @Type = 1 )
BEGIN


	DECLARE @NoPax MONEY
	DECLARE @GrossSales MONEY
	DECLARE @NetSales MONEY
	DECLARE @FoodSales MONEY
	DECLARE @BevSales MONEY
	DECLARE @DeliverieSales MONEY
	DECLARE @EventSales MONEY
	DECLARE @ReatilsSales MONEY



	SELECT @NoPax = SUM(pax),
		   @GrossSales = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge+Discount),
		   @NetSales = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge)
		   FROM BillHeader 
		   WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet

	SELECT @FoodSales = SUM(BT.Rate * BT.Qty) 
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 1

	SELECT @BevSales = SUM(BT.Rate * BT.Qty) 
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 2

	SELECT @DeliverieSales = SUM(BT.Rate * BT.Qty) 
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 6

	SELECT @EventSales = SUM(BT.Rate * BT.Qty) 
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 5

	SELECT @ReatilsSales = SUM(BT.Rate * BT.Qty) 
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 4


	SELECT ISNULL(@NoPax,0) AS NoPax,ISNULL(@GrossSales,0) AS GrossSales,ISNULL(@NetSales,0) AS NetSales,ISNULL(@FoodSales,0) AS FoodSales,ISNULL(@BevSales,0) AS BevSales, ISNULL(@DeliverieSales,0) AS DeliverieSales,ISNULL(@EventSales,0) AS EventSales,ISNULL(@ReatilsSales,0) AS ReatilsSales
 

END

IF( @Type = 2 )
BEGIN

    DECLARE @GrossSales_2 MONEY
	DECLARE @PeakHour_2 VARCHAR(100)
	DECLARE @PeakHourSale_2 MONEY
	DECLARE @AvgDineinBillValue_2 MONEY
	DECLARE @AvgTakeAwayBillValue_2 MONEY
	DECLARE @CurrMonthFirstDate_2 DATETIME
	DECLARE @ReportDate_2 DATETIME
	DECLARE @CurrYearFirstDate_2 DATETIME
	DECLARE @MTD_2 MONEY
	DECLARE @YTD_2 MONEY
	DECLARE @CurrYearFirstDate DATE
	DECLARE @MTD_2_Tar MONEY
	DECLARE @YTD_2_Tar MONEY
	DECLARE @MTD_2_Pre MONEY
	DECLARE @YTD_2_Pre MONEY

	

	
	SELECT @GrossSales_2 = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge+Discount)
	FROM BillHeader 
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet

	SELECT @AvgDineinBillValue_2 = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge)/COUNT(OrderNo)
	FROM BillHeader 
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND OrderType = 'R'

	SELECT @AvgTakeAwayBillValue_2 = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge)/COUNT(OrderNo)
	FROM BillHeader 
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND OrderType = 'T'

	SELECT TOP(1) @PeakHour_2 = OrderHOUR,@PeakHourSale_2 = SUM(Sales)
	FROM
	(
		SELECT FORMAT(OrderTime, 'hh tt') AS OrderHOUR,SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) AS Sales
		FROM BillHeader 
		WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet
		GROUP BY OrderTime
	) A
	GROUP BY OrderHOUR
	ORDER BY SUM(Sales) DESC 


	
	
	SET @CurrMonthFirstDate_2=(SELECT DATEADD(m, DATEDIFF(m, 0, CONVERT(datetime,@FromDate,103)), 0))
	SET  @ReportDate_2 =CONVERT(DATETIME,@FromDate,103)

	SET @CurrYearFirstDate = 
		CASE 
			WHEN MONTH(CONVERT(DATETIME,@FromDate,103)) >= 4 
			THEN DATEFROMPARTS(YEAR(CONVERT(DATETIME,@FromDate,103)), 4, 1) 
			ELSE DATEFROMPARTS(YEAR(CONVERT(DATETIME,@FromDate,103)) - 1, 4, 1) 
		END

	SELECT @MTD_2 = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) 
	FROM BillHeader 
	WHERE OrderDate >= CONVERT(DATE,@CurrMonthFirstDate_2,103) 
	AND  OrderDate <= CONVERT(DATE,@ReportDate_2,103) AND Outlet = @Outlet
	--GROUP BY OrderTime

	SELECT @YTD_2 = SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) 
	FROM BillHeader 
	WHERE OrderDate >= CONVERT(DATE,@CurrYearFirstDate,103) 
	AND  OrderDate <= CONVERT(DATE,@ReportDate_2,103) AND Outlet = @Outlet
	--GROUP BY OrderTime


	select @MTD_2_Tar =  SUM(SalesTarget) 
	from POS_SalesTarget
	WHERE Outlet = @Outlet AND MonthNo = MONTH(CONVERT(DATETIME, @FromDate, 103)) AND YearNo = YEAR(CONVERT(DATETIME, @FromDate, 103))

	--select @YTD_2_Tar =  SUM(SalesTarget) 
	--from POS_SalesTarget
	--WHERE Outlet = @Outlet AND YearNo = YEAR(CONVERT(DATETIME, @FromDate, 103)) --AND MonthNo IN ('')

	SELECT @YTD_2_Tar = SUM(SalesTarget) 
	FROM POS_SalesTarget
	WHERE  Outlet = @Outlet AND
	
	(
		(YearNo = YEAR(CONVERT(DATETIME, @FromDate, 103)) AND convert(int,MonthNo) >= 4)
		OR
		(YearNo = CONVERT(INT,(YEAR(CONVERT(DATETIME, @FromDate, 103)))) + 1 AND convert(int,MonthNo)  <= 3)

	)

	
	IF( @MTD_2_Tar != 0 )
	BEGIN

		SET @MTD_2_Pre = (@MTD_2/@MTD_2_Tar)*100 

	END
	ELSE
	BEGIN

		SET @MTD_2_Pre = 0

	END

	IF( @YTD_2_Tar != 0 )
	BEGIN

		SET @YTD_2_Pre = (@YTD_2/@YTD_2_Tar)*100 

	END
	ELSE
	BEGIN

		SET @YTD_2_Pre = 0

	END

	SELECT @FromDate + ' Sale' AS Description,FORMAT(@GrossSales_2, 'N2') as ValueText
	UNION ALL
	SELECT 'Peak Hour' AS Description,@PeakHour_2 as ValueText
	UNION ALL
	SELECT 'Peak HourSale' AS Description,FORMAT(@PeakHourSale_2, 'N2') as ValueText
	UNION ALL
	SELECT 'Avg Dine In Bill Value' AS Description,FORMAT(@AvgDineinBillValue_2, 'N2') as ValueText
	UNION ALL
	SELECT 'Avg Take Out Bill Value' AS Description,FORMAT(@AvgTakeAwayBillValue_2, 'N2') as ValueText
	UNION ALL
	SELECT 'MTD' AS Description,FORMAT(@MTD_2, 'N2') as ValueText
	UNION ALL
	SELECT 'YTD' AS Description,FORMAT(@YTD_2, 'N2') as ValueText
	UNION ALL
	SELECT 'MTD% (sales acheivement against MTD)' AS Description,FORMAT(@MTD_2_Pre, 'N2') as ValueText
	UNION ALL
	SELECT 'YTD% (sales acheivement against YTD)' AS Description,FORMAT(@YTD_2_Pre, 'N2') as ValueText
 

END


IF( @Type = 3 )
BEGIN

SELECT * 
FROM 
(
    SELECT TOP 3  C1.Name AS Classification01,MM.Description AS ItemName,SUM(BT.Qty) AS Qty
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 1
	GROUP BY C1.Name,MM.Description
	ORDER BY SUM(BT.Qty) DESC

) A
UNION ALL
SELECT * 
FROM 
(
    SELECT TOP 3  C1.Name AS Classification01,MM.Description AS ItemName,SUM(BT.Qty) AS Qty
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 2
	GROUP BY C1.Name,MM.Description
	ORDER BY SUM(BT.Qty) DESC

) A
UNION ALL
SELECT * 
FROM 
(
    SELECT TOP 3  C1.Name AS Classification01,MM.Description AS ItemName,SUM(BT.Qty) AS Qty
	FROM BillTrans BT
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_Classification01 C1 ON CC.Classification01Id = C1.Id AND CC.PropertyId = C1.PropertyId
	WHERE OrderDate = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND C1.Id = 4
	GROUP BY C1.Name,MM.Description
	ORDER BY SUM(BT.Qty) DESC

) A

END

IF( @Type = 4 )
BEGIN

	--SELECT     
	--	PaymentTypes.Description AS PaymentType,   
	--	SUM(PayTrans.ActualAmt) AS Value   
	--FROM PayTrans --ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet    
	--INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode   and PaymentTypes.PropertyId=PayTrans.PropertyId
	--INNER JOIN Location_Ref ON PayTrans.Outlet = Location_Ref.code    and Location_Ref.propertyid=PayTrans.PropertyId
	--WHERE (PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103))   
	--		AND PayTrans.OrderDate = CONVERT(DATETIME,@FromDate,103) AND PayTrans.Outlet = @Outlet  AND  PayTrans.PropertyId=@PropertyId   
	--GROUP BY PaymentTypes.Description; 

	DECLARE @Advance NUMERIC(18,4)
	SET @Advance = (SELECT ISNULL(SUM(P.Amount),0) FROM ReservationPayment P INNER JOIN Reservation R ON P.ReservationNo = R.ReservationNo WHERE P.Outlet = @Outlet AND  P.PayCode = '01' AND R.IsCancel = 0 AND CONVERT(DATETIME,P.CancelDate,103) = CONVERT(DATETIME,@FromDate,103) AND R.PropertyId = @PropertyId )

	DECLARE  @SkimAmount NUMERIC(18,4)
	SET @SkimAmount = (SELECT SUM(Value) FROM POS_CashSkim WHERE  CONVERT(DATETIME,ShiftDate,103) = CONVERT(DATETIME,@FromDate,103) AND Outlet = @Outlet AND PropertyId = @PropertyId)

	DECLARE @CashFloat_Actual MONEY
	SELECT @CashFloat_Actual = SUM(CashFloat) 
	from POS_CashierShift 
	where CONVERT(DATETIME,ShiftDate,103) = CONVERT(DATETIME,@FromDate,103) and Outlet = @Outlet AND PropertyId = @PropertyId

	DECLARE @Value_CASH_Actual MONEY
	SELECT	@Value_CASH_Actual = SUM(Value)
	FROM	POS_CashireShiftEndLog
	WHERE   PropertyId = @PropertyId AND Outlet = @Outlet 
	AND CONVERT(DATETIME,ShiftDate,103) = CONVERT(DATETIME,@FromDate,103) AND IsCash = 1 

	SELECT PaymentType,System,Actual ,Variance FROM 
	(
		select PaymentType,SUM(System) AS System,SUM(Actual) AS Actual,SUM(Variance) AS Variance FROM
		(
			SELECT	DType AS PaymentType, 
			SystemAmount  AS System, 
			Value AS Actual, 
			SystemAmount - Value AS Variance
			FROM	POS_CashireShiftEndLog
			WHERE   PropertyId = @PropertyId AND Outlet = @Outlet 
			AND CONVERT(DATETIME,ShiftDate,103) = CONVERT(DATETIME,@FromDate,103) AND IsCash = 0 AND IsForeignCurrency = 0

			UNION ALL

			SELECT	DType AS PaymentType,
			SystemAmount AS System, 
			Value AS Actual, 
			SystemAmount - Value AS Variance
			FROM	POS_CashireShiftEndLog
			WHERE   PropertyId = @PropertyId AND Outlet = @Outlet 
			AND CONVERT(DATETIME,ShiftDate,103) = CONVERT(DATETIME,@FromDate,103) AND IsCash = 0 AND IsForeignCurrency = 1
		) B
		GROUP BY PaymentType
	) C
    UNION ALL

	SELECT PaymentType,(System) AS System,Actual ,(Variance) AS Variance
	FROM
	(
	
		SELECT     
			PaymentTypes.Description AS PaymentType,   
			SUM(PayTrans.ActualAmt) + ISNULL(@CashFloat_Actual,0) + ISNULL(@Advance,0) - ISNULL(@SkimAmount,0)  AS System,
			ISNULL(@Value_CASH_Actual,0)  AS Actual,
			(SUM(PayTrans.ActualAmt) + ISNULL(@CashFloat_Actual,0)  + ISNULL(@Advance,0) - ISNULL(@SkimAmount,0)  )  - @Value_CASH_Actual AS Variance
		FROM PayTrans
		INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode   and PaymentTypes.PropertyId=PayTrans.PropertyId
		INNER JOIN Location_Ref ON PayTrans.Outlet = Location_Ref.code    and Location_Ref.propertyid=PayTrans.PropertyId
		WHERE CONVERT(DATETIME,PayTrans.OrderDate,103) = CONVERT(DATETIME,@FromDate,103) AND PayTrans.Outlet = @Outlet  AND  PayTrans.PropertyId=@PropertyId AND PayTrans.PayCode = '01'
		GROUP BY PaymentTypes.Description

	) A


END

END;

GO

