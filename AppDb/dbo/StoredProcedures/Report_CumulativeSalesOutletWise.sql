-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT CUMULATIVE SALES OUTLET WISE 
-- =============================================
--exec Report_CumulativeSalesOutletWise '01/01/2018','01/01/2019','R,T,Y,D,I,P'
CREATE PROCEDURE [dbo].[Report_CumulativeSalesOutletWise] (     
 @FromDate VARCHAR(10),    
 @ToDate VARCHAR(10),
 @OrderType VARCHAR(MAX),
 @PropertyId VARCHAR(2)
) AS    
BEGIN     
  
 SELECT SUM(Qty) AS Qty, SUM(NetSales) AS NetSales, Outlet, OrderName, LocCode 
 FROM (    
	  SELECT COUNT(BillHeader.OrderNo) as Qty,SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.TaxVal3+BillHeader.TaxVal4+BillHeader.ServiceCharge) AS NetSales, 
	   Location_Ref.code AS LocCode,Location_Ref.description AS Outlet,  POSOrderTypes.Name AS OrderName       
	  FROM  BillHeader 
	  --INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet    
	  --INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode 
	  INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code  AND BillHeader.PropertyId=Location_Ref.PropertyId
	  INNER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code AND POSOrderTypes.PropertyId=BillHeader.PropertyId
	  WHERE 
	  BillHeader.PropertyId=@PropertyId
	 AND BillHeader.OrderDate >=CONVERT(DATETIME,@Fromdate,103)
		--AND PaymentTypes.NoValue = 0 
		AND BillHeader.OrderDate <=CONVERT(DATETIME,@Todate,103)   
		AND BillHeader.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
		 AND ( BillHeader.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((NoValue = 1) 
								AND PayTrans.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
								AND PayTrans.OrderDate <=CONVERT(DATETIME,@Todate,103)  
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								 )
					
								)
		)
	  GROUP BY  Location_Ref.description, BillHeader.OrderType, POSOrderTypes.Name, Location_Ref.code     

	 -- UNION ALL

	 -- SELECT COUNT(BillHeader.OrderNo) as Qty,SUM(BillHeader.Subtotal) AS NetSales, Location_Ref.code AS LocCode,
		--Location_Ref.description AS Outlet,'Other' AS OrderName        
	 -- FROM  BillHeader 
	 -- --INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet    
	 -- --INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode 
	 -- INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code 
	 -- INNER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code 
	 -- WHERE BillHeader.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
	 --   --AND PaymentTypes.NoValue = 0
		--AND BillHeader.OrderDate <=CONVERT(DATETIME,@Todate,103)   
		--AND BillHeader.OrderType != @OrderType 
	 -- GROUP BY  Location_Ref.description, BillHeader.OrderType , Location_Ref.code
 )MAIN GROUP BY OrderName, Outlet, LocCode    
END;

GO

