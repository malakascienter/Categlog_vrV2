--====================================================================         
-- AUTHOR - BANU        
-- DESCRIPTION - GENERATION OF REPORT BILLING SUMMARY         
-- ALTERD - 02/10/2018        
--=====================================================================  
----   [dbo].[Report_BillingSummary_PaymentTypeWise] '14/06/2023','14/06/2023','EBJ,EMB,VBJ,VBR','24'
CREATE PROCEDURE [dbo].[Report_BillingSummary_PaymentTypeWise](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         

IF OBJECT_ID(N'tempdb..#TempSelectBill') IS NOT NULL
BEGIN
DROP TABLE #TempSelectBill
END
IF OBJECT_ID(N'tempdb..#TempBill') IS NOT NULL
BEGIN
DROP TABLE #TempBill
END

	 CREATE TABLE #TempSelectBill(
			RoomName [varchar](50) NULL,
			HotelReservationNo [varchar](10) NULL,
			Outlet [varchar](30) NULL,
			SubTotal money,
			VAT money,
			NBT money,
			TaxVal3 money,
			TaxVal4 money,
			ServiceCharge money,
			TDL money,
			Discount money,
			OrderNo char(6),
			OrderDate datetime null,
			OrderTime datetime null,
			WaiterName [varchar](150) NULL, 
			BillByUserName [varchar](150) NULL, 
			OrderType [varchar](150) NULL, 
			PaymentType [varchar](150) NULL, 
			ActualAmt money,
			PropertyId INT
		);

	 SELECT 
	 B.RoomName,B.HotelReservationNo,L.code AS 'Outlet',(Subtotal+Discount) AS 'SubTotal',(TaxVal1)AS 'VAT',(TaxVal2) AS 'NBT',
	 (TaxVal3) AS 'TaxVal3',(TaxVal4) AS 'TaxVal4', (ServiceCharge) AS ServiceCharge, (0) AS 'TDL',(Discount) AS Discount, 
	 B.OrderNo, B.OrderDate, B.OrderTime, 
	 ISNULL((SELECT TOP(1) W1.Name FROM Waiter W1 WHERE B.Waiter = W1.Code   AND W1.PropertyId=B.PropertyId),'N/A') AS 'WaiterName',  
	 ISNULL((SELECT TOP(1) W2.Name FROM Waiter W2 WHERE B.UserID = W2.Code AND W2.PropertyId=B.PropertyId),'N/A') AS 'BillByUserName',
	 PO.Name AS 'OrderType',P.Description AS 'PaymentType', 
	 SUM(PTN.ActualAmt) as 'ActualAmt'
	 INTO #TempBill	
	 FROM BillHeader B  
	 --LEFT JOIN Waiter W1 ON B.Waiter = W1.Code   AND W1.PropertyId=B.PropertyId
	 --LEFT JOIN Waiter W2 ON B.UserID = W2.Code AND W2.PropertyId=B.PropertyId
	 INNER JOIN PayTrans PTN ON B.OrderNo = PTN.OrderNo AND B.OrderDate = PTN.OrderDate AND B.Outlet = PTN.Outlet AND B.PropertyId = PTN.PropertyId
	 INNER JOIN PaymentTypes P ON PTN.PayCode = P.PayCode  AND P.PropertyId = PTN.PropertyId
	 INNER JOIN POSOrderTypes PO ON B.OrderType = PO.Code AND PO.PropertyId=B.PropertyId
	 INNER JOIN Location_Ref L ON B.Outlet = L.code    AND L.PropertyId=B.PropertyId    
	 WHERE B.OrderDate >= CONVERT(DATETIME,@FromDate,103) AND B.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
	 AND B.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND B.PropertyId=@PropertyId AND B.Subtotal>0
	 AND (B.OrderNo NOT IN 
		(
	 		SELECT	PayTrans.OrderNo
	 		FROM	PayTrans 
	 		INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
	 		WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
	        AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
			AND (PayTrans.PayCode <> 'BR')  
			AND PayTrans.PropertyId = @PropertyId)					
		)

	 GROUP BY L.code, B.OrderNo, B.OrderDate, B.OrderTime,B.RoomName,B.HotelReservationNo, PO.Name,P.Description ,B.Waiter,B.UserID,B.PropertyId,Subtotal,Discount,TaxVal1,TaxVal2,TaxVal3,TaxVal4,ServiceCharge,TDL
	 Order by B.OrderNo

	  DECLARE @OrderNoT CHAR(6)
	  DECLARE @OrderDateT DateTime
	  DECLARE @OutletT char(3)

	 WHILE EXISTS  (SELECT * FROM #TempBill)
	 BEGIN
	 
	 SELECT TOP 1  @OrderNoT = OrderNo,@OrderDateT = OrderDate,@OutletT = Outlet FROM #TempBill
		
		IF EXISTS( SELECT * FROM #TempSelectBill WHERE OrderNo = @OrderNoT AND OrderDate = @OrderDateT AND Outlet = @OutletT )
		BEGIN
		
		 INSERT INTO #TempSelectBill (RoomName,HotelReservationNo,Outlet,SubTotal,VAT,NBT,TaxVal3,TaxVal4,ServiceCharge,TDL,Discount,OrderNo,OrderDate,OrderTime,WaiterName,
		 BillByUserName,OrderType,PaymentType,ActualAmt,PropertyId)
		 SELECT TOP 1  RoomName,HotelReservationNo,Outlet,0,0,0,0,0,0,0,0,OrderNo,OrderDate,OrderTime,WaiterName,
		 BillByUserName,OrderType,PaymentType,ActualAmt,@PropertyId FROM #TempBill
		
		END
		ELSE
		BEGIN
		
		 INSERT INTO #TempSelectBill (RoomName,HotelReservationNo,Outlet,SubTotal,VAT,NBT,TaxVal3,TaxVal4,ServiceCharge,TDL,Discount,OrderNo,OrderDate,OrderTime,WaiterName,
		 BillByUserName,OrderType,PaymentType,ActualAmt,PropertyId)
		 SELECT TOP 1  RoomName,HotelReservationNo,Outlet,SubTotal,VAT,NBT,TaxVal3,TaxVal4,ServiceCharge,TDL,Discount,OrderNo,OrderDate,OrderTime,WaiterName,
		 BillByUserName,OrderType,PaymentType,ActualAmt,@PropertyId FROM #TempBill
		
		END




		DELETE TOP (1) FROM   #TempBill

	 END 


	 SELECT T.RoomName,T.HotelReservationNo,L.description  AS Outlet,T.SubTotal,T.VAT,T.NBT,T.TaxVal3,T.TaxVal4,T.ServiceCharge,T.TDL,T.Discount,T.OrderNo,T.OrderDate,
	 T.OrderTime,T.WaiterName,T.BillByUserName,T.OrderType,T.PaymentType,T.ActualAmt
	 FROM #TempSelectBill T INNER JOIN Location_Ref L ON T.Outlet = L.Code AND T.PropertyId = L.PropertyId
	 Order by T.OrderNo

IF OBJECT_ID(N'tempdb..#TempSelectBill') IS NOT NULL
BEGIN
DROP TABLE #TempSelectBill
END
IF OBJECT_ID(N'tempdb..#TempBill') IS NOT NULL
BEGIN
DROP TABLE #TempBill
END

END;

GO

