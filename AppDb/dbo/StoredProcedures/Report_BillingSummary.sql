--====================================================================         
-- AUTHOR - BANU        
-- DESCRIPTION - GENERATION OF REPORT BILLING SUMMARY         
-- ALTERD - 02/10/2018        
--=====================================================================  
----   [dbo].[Report_BillingSummary] '01/11/2021','01/11/2021','S01','2'
CREATE PROCEDURE [dbo].[Report_BillingSummary](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         
	-- SELECT 
	--B.RoomName,B.HotelReservationNo,L.description AS 'Outlet',SUM(Subtotal+Discount) AS 'SubTotal',SUM(TaxVal1)AS 'VAT',SUM(TaxVal2) AS 'NBT',
	--	SUM(TaxVal3) AS 'TaxVal3',SUM(TaxVal4) AS 'TaxVal4', SUM(ServiceCharge) AS ServiceCharge, SUM(TDL) AS 'TDL', 
	--	SUM(Discount) AS Discount, B.OrderNo, B.OrderDate, B.OrderTime, 
	--	'' 'WaiterName', '' 'BillByUserName',
	--	--W1.Name AS 'WaiterName',  W2.Name AS 'BillByUserName',
	--	--P.Description AS 'PaymentType', 
	--	PO.Name AS 'OrderType'     
	-- FROM BillHeader B  
	-- --INNER JOIN Waiter W1 ON B.Waiter = W1.Code   AND W1.PropertyId=B.PropertyId
	-- --INNER JOIN Waiter W2 ON B.UserID = W2.Code AND W2.PropertyId=B.PropertyId
	-- --INNER JOIN PayTrans PTN ON B.OrderNo = PTN.OrderNo AND B.OrderDate = PTN.OrderDate AND B.Outlet = PTN.Outlet
	-- --INNER JOIN PaymentTypes P ON PTN.PayCode = P.PayCode  
	-- INNER JOIN POSOrderTypes PO ON B.OrderType = PO.Code AND PO.PropertyId=B.PropertyId
	-- INNER JOIN Location_Ref L ON B.Outlet = L.code    AND L.PropertyId=B.PropertyId    
	-- INNER JOIN paytrans P on p.orderno = B.orderno
	-- INNER JOIN paymenttypes T on P.paycode = t.paycode 
	 
	-- WHERE B.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
	--	AND B.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
	--	AND B.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND B.PropertyId=@PropertyId  
	--	AND B.Subtotal>0
	--	And (T.novalue <> 1 or T.paycode = 'BR')
	-- GROUP BY L.description, B.OrderNo, B.OrderDate, B.OrderTime, 
	-- --W1.Name, W2.Name,
	-- B.RoomName,B.HotelReservationNo, PO.Name  
	 

	 SELECT 
	B.RoomName,B.HotelReservationNo,L.description AS 'Outlet',SUM(Subtotal+Discount) AS 'SubTotal',SUM(TaxVal1)AS 'VAT',SUM(TaxVal2) AS 'NBT',
		SUM(0) AS 'TaxVal3',SUM(0) AS 'TaxVal4', SUM(ServiceCharge) AS ServiceCharge, SUM(TaxVal3) AS 'TDL', 
		SUM(Discount) AS Discount, B.OrderNo, B.OrderDate, B.OrderTime, W1.Name AS 'WaiterName',  W2.Name AS 'BillByUserName',
		--P.Description AS 'PaymentType', 
		PO.Name AS 'OrderType'     
		-- change TaxVal3(NBT) and TaxVal2(TaxVal3) column 
	 FROM BillHeader B  
	 INNER JOIN Waiter W1 ON B.Waiter = W1.Code   AND W1.PropertyId=B.PropertyId
	 INNER JOIN Waiter W2 ON B.UserID = W2.Code AND W2.PropertyId=B.PropertyId
	 --INNER JOIN PayTrans PTN ON B.OrderNo = PTN.OrderNo AND B.OrderDate = PTN.OrderDate AND B.Outlet = PTN.Outlet
	 --INNER JOIN PaymentTypes P ON PTN.PayCode = P.PayCode  
	 INNER JOIN POSOrderTypes PO ON B.OrderType = PO.Code AND PO.PropertyId=B.PropertyId
	 INNER JOIN Location_Ref L ON B.Outlet = L.code    AND L.PropertyId=B.PropertyId    
	 WHERE B.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND B.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND B.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND B.PropertyId=@PropertyId   
		--AND B.Subtotal>0
		AND (OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
		--And (p.novalue <> 1 or p.paycode = 'BR')
	 GROUP BY L.description, B.OrderNo, B.OrderDate, B.OrderTime, W1.Name, W2.Name,B.RoomName,B.HotelReservationNo, PO.Name--,P.Description 


END;

GO

