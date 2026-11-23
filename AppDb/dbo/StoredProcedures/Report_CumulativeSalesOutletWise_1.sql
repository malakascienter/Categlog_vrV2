-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT CUMULATIVE SALES OUTLET WISE 
-- =============================================
CREATE PROCEDURE [dbo].[Report_CumulativeSalesOutletWise_1] (     
 @FromDate VARCHAR(10),    
 @ToDate VARCHAR(10),
 @OrderType CHAR(1)
) AS    
BEGIN     
  
 SELECT SUM(Qty) AS Qty, SUM(NetSales) AS NetSales, Outlet, OrderName, LocCode 
 FROM (    
	  SELECT COUNT(BillHeader.OrderNo) as Qty,SUM(BillHeader.Subtotal) AS NetSales, 
	   Location_Ref.code AS LocCode,Location_Ref.description AS Outlet,  POSOrderTypes.Name AS OrderName       
	  FROM  BillHeader 
	  INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet    
	  INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode 
	  INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code 
	  INNER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code
	  WHERE BillHeader.OrderDate >=CONVERT(DATETIME,@Fromdate,103)
		AND PaymentTypes.NoValue = 0 
		AND BillHeader.OrderDate <=CONVERT(DATETIME,@Todate,103)   
		AND BillHeader.OrderType = @OrderType 
	  GROUP BY  Location_Ref.description, BillHeader.OrderType, POSOrderTypes.Name, Location_Ref.code     

	  UNION ALL

	  SELECT COUNT(BillHeader.OrderNo) as Qty,SUM(BillHeader.Subtotal) AS NetSales, Location_Ref.code AS LocCode,
		Location_Ref.description AS Outlet,'Other' AS OrderName        
	  FROM  BillHeader 
	  INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet    
	  INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode 
	  INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code 
	  INNER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code 
	  WHERE BillHeader.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
	    AND PaymentTypes.NoValue = 0
		AND BillHeader.OrderDate <=CONVERT(DATETIME,@Todate,103)   
		AND BillHeader.OrderType != @OrderType 
	  GROUP BY  Location_Ref.description, BillHeader.OrderType , Location_Ref.code
 )MAIN GROUP BY OrderName, Outlet, LocCode    
END;

GO

