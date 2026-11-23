-- =============================================
-- Author:		BANU
-- ALTER date: 16/11/2018
-- Description:	REPORT CASH RECONSILATION - OUTLET
-- =============================================
-----EXEC  Report_OutletSalesCashRecon 'S01,S02','07/07/2020','2'
CREATE PROCEDURE [dbo].[Report_OutletSalesCashRecon](  
	@Outlet VARCHAR(MAX),    
	@FromDate VARCHAR(10),
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
	SELECT 'GROSS SALE',SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge),L.description,OrderDate,COUNT(OrderNo)
	FROM BillHeader
	INNER JOIN Location_Ref AS L ON L.PropertyId=BillHeader.PropertyId AND L.code=BillHeader.Outlet
	where 
	BillHeader.PropertyId=@PropertyId AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	AND(BillHeader.OrderDate >= CONVERT(DATETIME,@FromDate,103))     		
	Group by OrderDate,L.description


	--select * from #TempBillHeader

	INSERT INTO #TempPayTrans(TempOrderNo,TempOrderDate,TempPayCode,TempTotal,TempActualAmt,TempOutlet)
	SELECT OrderNo,OrderDate,PayCode,Total,ActualAmt,Outlet
	FROM PayTrans
	WHERE (PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103))  
		AND PayTrans.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		AND PropertyId=@PropertyId;


	SELECT TempGrossSale AS PaymentType,TempValue AS Value, TempOutlet AS Outlet, TempTotalCustomers AS TotalCustomers, 1 TempDisOrder FROM #TempBillHeader 
	UNION
	SELECT PaymentTypes.Description AS PaymentType,			
		SUM(#TempPayTrans.TempActualAmt) AS Value,
		Location_Ref.description AS 'Outlet',
		--#TempPayTrans.TempOrderDate AS 'OrderDate'	,
		SUM(Isnull(#TempPayTrans.TempTotalCustomers,0)) AS TempTotalCustomers, 99 TempDisOrder
	FROM #TempPayTrans      
	INNER JOIN PaymentTypes ON #TempPayTrans.TempPayCode = PaymentTypes.PayCode  and PaymentTypes.PropertyId=@PropertyId
	INNER JOIN BillHeader ON #TempPayTrans.TempOrderDate = BillHeader.OrderDate
							AND #TempPayTrans.TempOrderNo = BillHeader.OrderNo
							AND #TempPayTrans.TempOutlet = BillHeader.Outlet   
							AND BillHeader.PropertyId=@PropertyId 
	INNER JOIN Location_Ref ON #TempPayTrans.TempOutlet = Location_Ref.code  AND  Location_Ref.PropertyId=@PropertyId 
	WHERE BillHeader.PropertyId=@PropertyId 
	AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	GROUP BY PaymentTypes.Description,Location_Ref.description,#TempPayTrans.TempOrderDate --,#TempBillHeader.TempGrossSale ,#TempBillHeader.TempTotalCustomers
	 order by TempDisOrder
	
	



	DROP TABLE #TempPayTrans  


	--CREATE TABLE #TempPayTrans(
	--	TempOrderNo CHAR(6),
	--	TempOrderDate DATETIME,
	--	TempPayCode CHAR(2),
	--	TempTotal MONEY,
	--	TempActualAmt MONEY,
	--	TempOutlet VARCHAR(3)
	--)

	--INSERT INTO #TempPayTrans(TempOrderNo,TempOrderDate,TempPayCode,TempTotal,TempActualAmt,TempOutlet)
	--SELECT OrderNo,OrderDate,PayCode,Total,ActualAmt,Outlet 
	--FROM PayTrans
	--WHERE 
	-- PayTrans.PropertyId=@PropertyId AND(PayTrans.OrderDate = CONVERT(DATETIME,@FromDate,103))    
	--	AND PayTrans.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))

	--SELECT PaymentTypes.Description AS PaymentType, (SELECT COUNT(BillHeader.OrderNo)FROM BillHeader WHERE PropertyId=@PropertyId AND OrderDate >= CONVERT(DATETIME,@FromDate,103) ) AS 'TotalCustomers',
	--	SUM(#TempPayTrans.TempActualAmt) AS Value,Location_Ref.description AS 'Outlet',
	--	(SELECT SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) FROM BillHeader WHERE PropertyId=@PropertyId AND OrderDate= CONVERT(DATETIME,@FromDate,103)) AS 'GrossSales'    
	--FROM #TempPayTrans      
	--INNER JOIN PaymentTypes ON #TempPayTrans.TempPayCode = PaymentTypes.PayCode  AND PaymentTypes.PropertyId=@PropertyId
	--INNER JOIN BillHeader ON #TempPayTrans.TempOrderDate = BillHeader.OrderDate AND BillHeader.PropertyId=@PropertyId
	--						AND #TempPayTrans.TempOrderNo = BillHeader.OrderNo
	--						AND #TempPayTrans.TempOutlet = BillHeader.Outlet    
	--INNER JOIN Location_Ref ON #TempPayTrans.TempOutlet = Location_Ref.code AND Location_Ref.PropertyId=@PropertyId     
	--GROUP BY PaymentTypes.Description,Location_Ref.description
	
	--DROP TABLE #TempPayTrans  
END;

GO

