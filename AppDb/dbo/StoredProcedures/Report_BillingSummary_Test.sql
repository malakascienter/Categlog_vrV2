--====================================================================         
-- AUTHOR - BANU        
-- DESCRIPTION - GENERATION OF REPORT BILLING SUMMARY         
-- ALTERD - 02/10/2018        
--=====================================================================  
----   [dbo].[Report_BillingSummary] '04/12/2021','04/12/2021','M05','1'
CREATE PROCEDURE [dbo].[Report_BillingSummary_Test](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         
	 SELECT 
	 B.RoomName,B.HotelReservationNo,L.description AS 'Outlet',
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,2),Subtotal)+CONVERT(DECIMAL(18,4),Discount))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(Subtotal+Discount)
	 END AS 'SubTotal',
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,4),TaxVal1))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(TaxVal1)
	 END AS 'VAT',
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,4),TaxVal2))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(TaxVal2)
	 END AS 'NBT',
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,4),TaxVal3))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(TaxVal3)
	 END AS 'TaxVal3',
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,4),TaxVal4))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(TaxVal4)
	 END AS 'TaxVal4',
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,4),ServiceCharge))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(ServiceCharge)
	 END AS ServiceCharge,	
	 SUM(TDL) AS 'TDL', 
	 CASE 
	 WHEN SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge) != 0 THEN
	 SUM(CONVERT(DECIMAL(18,4),Discount))/SUM(CONVERT(DECIMAL(18,4),Subtotal)+CONVERT(DECIMAL(18,4),TaxVal1)+CONVERT(DECIMAL(18,4),TaxVal2)+CONVERT(DECIMAL(18,4),TaxVal3)+CONVERT(DECIMAL(18,4),TaxVal4)+CONVERT(DECIMAL(18,4),ServiceCharge))*SUM(CONVERT(DECIMAL(18,4),PTN.ActualAmt)) 
	 ELSE SUM(Discount)
	 END AS Discount,
	 B.OrderNo, 
	 B.OrderDate, 
	 B.OrderTime, 
	 W1.Name AS 'WaiterName',  
	 W2.Name AS 'BillByUserName',
	 P.Description AS 'PaymentType', 
	 PO.Name AS 'OrderType'     
	 FROM BillHeader B  
	 INNER JOIN Waiter W1 ON B.Waiter = W1.Code   AND W1.PropertyId=B.PropertyId
	 INNER JOIN Waiter W2 ON B.UserID = W2.Code AND W2.PropertyId=B.PropertyId
	 INNER JOIN PayTrans PTN ON B.OrderNo = PTN.OrderNo AND B.OrderDate = PTN.OrderDate AND B.Outlet = PTN.Outlet
	 INNER JOIN PaymentTypes P ON PTN.PayCode = P.PayCode AND PTN.PropertyId = P.PropertyId   
	 INNER JOIN POSOrderTypes PO ON B.OrderType = PO.Code AND PO.PropertyId=B.PropertyId
	 INNER JOIN Location_Ref L ON B.Outlet = L.code    AND L.PropertyId=B.PropertyId    
	 WHERE B.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND B.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND B.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND B.PropertyId=@PropertyId    
		AND B.Subtotal>0
		AND (P.novalue <> 1 or P.paycode = 'BR')
	 GROUP BY L.description, B.OrderNo, B.OrderDate, B.OrderTime, W1.Name, W2.Name,B.RoomName,B.HotelReservationNo, PO.Name,P.Description    
END;

GO

