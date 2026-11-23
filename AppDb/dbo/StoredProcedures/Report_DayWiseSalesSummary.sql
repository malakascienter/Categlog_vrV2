
-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT HOURLY SALES OUTLET WISE COMPARISION 
-- =============================================
-----EXEC  Report_DayWiseSalesSummary 'S01','07/07/2020','07/07/2020' ,'2'
CREATE PROCEDURE [dbo].[Report_DayWiseSalesSummary](  
	@Outlet VARCHAR(3),    
	@FromDate VARCHAR(10),    
	@ToDate VARCHAR(10) , 
	@PropertyId VARCHAR(2)
)    
AS     
BEGIN   
	CREATE TABLE #TempPayTrans(
		TempOrderNo CHAR(6),
		TempOrderDate DATETIME,
		TempPayCode CHAR(2),
		TempTotal MONEY,
		TempActualAmt MONEY,
		TempOutlet VARCHAR(3),
		TempTotalCustomers INT,
		TempDisOrder INT
		
	)


	CREATE TABLE #TempBillHeader(
		
		TempGrossSale VARCHAR(50),
		TempValue MONEY,
		TempOutlet VARCHAR(50),
		TempOrderDate DATETIME,
		TempTotalCustomers INT,
		TempDisOrder INT

	)
	INSERT INTO #TempBillHeader(TempGrossSale,TempValue,TempOutlet,TempOrderDate ,TempTotalCustomers )
	SELECT 'GROSS SALE',SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge),'',OrderDate,COUNT(OrderNo)
	FROM BillHeader  where PropertyId=@PropertyId
	AND(BillHeader.OrderDate >= CONVERT(DATETIME,@FromDate,103))     
		AND (BillHeader.OrderDate <= CONVERT(DATETIME,@ToDate,103))  AND BillHeader.Outlet=@Outlet 
	Group by OrderDate


	--select * from #TempBillHeader

	INSERT INTO #TempPayTrans(TempOrderNo,TempOrderDate,TempPayCode,TempTotal,TempActualAmt,TempOutlet)
	SELECT OrderNo,OrderDate,PayCode,Total,ActualAmt,Outlet
	FROM PayTrans
	WHERE (PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103))     
		AND (PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
		AND PayTrans.Outlet = @Outlet AND PropertyId=@PropertyId;


	SELECT TempGrossSale AS PaymentType,TempValue AS Value, TempOutlet AS Outlet,TempOrderDate AS OrderDate, TempTotalCustomers AS TotalCustomers, 1 TempDisOrder FROM #TempBillHeader 
	UNION
	SELECT PaymentTypes.Description AS PaymentType,			
		SUM(#TempPayTrans.TempActualAmt) AS Value,
		Location_Ref.description AS 'Outlet',
		#TempPayTrans.TempOrderDate AS 'OrderDate'	,
		SUM(Isnull(#TempPayTrans.TempTotalCustomers,0)) AS TempTotalCustomers, 99 TempDisOrder
	FROM #TempPayTrans      
	INNER JOIN PaymentTypes ON #TempPayTrans.TempPayCode = PaymentTypes.PayCode  and PaymentTypes.PropertyId=@PropertyId
	INNER JOIN BillHeader ON #TempPayTrans.TempOrderDate = BillHeader.OrderDate
							AND #TempPayTrans.TempOrderNo = BillHeader.OrderNo
							AND #TempPayTrans.TempOutlet = BillHeader.Outlet   
							AND BillHeader.PropertyId=@PropertyId 
	INNER JOIN Location_Ref ON #TempPayTrans.TempOutlet = Location_Ref.code  AND  Location_Ref.PropertyId=@PropertyId 
	WHERE BillHeader.PropertyId=@PropertyId
	GROUP BY PaymentTypes.Description,Location_Ref.description,#TempPayTrans.TempOrderDate --,#TempBillHeader.TempGrossSale ,#TempBillHeader.TempTotalCustomers
	 order by TempDisOrder
	
	



	DROP TABLE #TempPayTrans  
END;

GO

