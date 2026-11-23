--exec [Report_ProductionProfitabilityReport] '01/01/2024','24/04/2024','001,002',1
CREATE PROCEDURE [dbo].[Report_OrderSettlementCurrencyWise](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         




	 
	 select BH.OrderDate,L.description AS Outlet,bh.OrderNo,PTC.CurrCode,P.Description AS PayType,PTC.CurrCode,PTC.ActualAmount
	 from BillHeader BH
	 INNER JOIN PayTrans PT ON BH.OrderNo = PT.OrderNo AND BH.OrderDate = PT.OrderDate AND BH.Outlet = PT.Outlet AND BH.PropertyId = PT.PropertyId
	 INNER JOIN PayTransCurrency PTC ON BH.OrderNo = PTC.OrderNo AND BH.OrderDate = PTC.OrderDate AND BH.Outlet = PTC.Outlet AND BH.PropertyId = PTC.PropertyId
	 INNER JOIN PaymentTypes P ON PT.PayCode = P.PayCode AND PT.PropertyId = P.PropertyId
	 INNER JOIN Location_Ref L ON BH.Outlet = L.code AND BH.PropertyId = L.PropertyId
	 WHERE  BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
			AND BH.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
			AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  
			AND PTC.PayType = 'P'


	

END;

GO

