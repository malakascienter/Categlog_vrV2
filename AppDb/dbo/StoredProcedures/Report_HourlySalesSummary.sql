-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT HOURLY SALES OUTLET WISE COMPARISION 
-- =============================================
-----EXEC  Report_HourlySalesSummary '001','01/09/2018','01/11/2018','','D,R,T','11:00 AM','06:00 PM',3
CREATE PROCEDURE [dbo].[Report_HourlySalesSummary](  
	@Outlet VARCHAR(MAX),    
	@FromDate VARCHAR(10),    
	@ToDate VARCHAR(10),
	@DatePeriods VARCHAR(MAX),
	@OrderType VARCHAR(MAX),  
	@FromTime VARCHAR(10),
	@ToTime VARCHAR(10),
	@TimeInterval INT  ,
	@PropertyId VARCHAR(2)
)    
AS     
BEGIN   
	CREATE TABLE #TempBillHeader(
		TempOrderNo CHAR(6),
		TempOrderDate DATETIME,
		TempOrderTime DATETIME,
		TempOrderType CHAR(1),
		TempSubtotal MONEY,
		TempDiscount MONEY,
		TempTaxVal1 MONEY,
		TempTaxVal2 MONEY,
		TempTaxVal3 MONEY,
		TempTaxVal4 MONEY,
		TempServiceCharge MONEY,
		TempOutlet VARCHAR(3),
		TempTimeInterval VARCHAR(10)
	) 
	  
	INSERT INTO #TempBillHeader(TempOrderNo,TempOrderDate,TempOrderTime,TempOrderType,TempSubtotal,
								TempDiscount,TempTaxVal1,TempTaxVal2,TempTaxVal3,TempTaxVal4,TempServiceCharge,TempOutlet,TempTimeInterval
								)
	SELECT OrderNo,OrderDate,OrderTime,OrderType,SUM(Subtotal),SUM(Discount),SUM(TaxVal1),SUM(TaxVal2),SUM(TaxVal3),SUM(TaxVal4),ServiceCharge,Outlet, 
	CASE @TimeInterval  ------TIME INTERVAL
	WHEN 1 THEN CASE WHEN DATEPART(MINUTE,OrderTime) <= 49 THEN
					RIGHT('0' + CONVERT(VARCHAR,DATEPART(HOUR,OrderTime)),2)+':' + 
						CASE WHEN DATEPART(MINUTE,OrderTime) = 00 THEN '00' 
							WHEN  DATEPART(MINUTE,OrderTime) <= 10 AND  DATEPART(MINUTE,OrderTime) >= 01 THEN '10' 
							WHEN  DATEPART(MINUTE,OrderTime) <= 20 AND  DATEPART(MINUTE,OrderTime) > 10 THEN '20'
							WHEN  DATEPART(MINUTE,OrderTime) <= 30 AND  DATEPART(MINUTE,OrderTime) > 20 THEN '30'
							WHEN  DATEPART(MINUTE,OrderTime) <= 40 AND  DATEPART(MINUTE,OrderTime) > 30 THEN '40'
							WHEN  DATEPART(MINUTE,OrderTime) <= 50 AND  DATEPART(MINUTE,OrderTime) > 40 THEN '50'
							WHEN  DATEPART(MINUTE,OrderTime) <= 59 AND  DATEPART(MINUTE,OrderTime) > 50 THEN '00'
						ELSE '00' END
				ELSE
					RIGHT('0' + CONVERT(VARCHAR,DATEPART(HOUR,OrderTime)+1),2)+':00' END
	WHEN 2 THEN CASE WHEN DATEPART(MINUTE,OrderTime) <= 30 THEN RIGHT('0' + CONVERT(VARCHAR,DATEPART(HOUR,OrderTime)),2)+':30' 
					 ELSE RIGHT('0' + CONVERT(VARCHAR,DATEPART(HOUR,OrderTime)+1),2)+':00' END
	WHEN 3 THEN RIGHT('0' + CONVERT(VARCHAR,DATEPART(HOUR,OrderTime)),2) + ':00' 
	WHEN 4 THEN RIGHT('0'+CONVERT(VARCHAR,DATEPART(DAY,OrderTime)),2)					
	END AS 'PERIOD'
	FROM BillHeader
	WHERE BillHeader.PropertyId=@PropertyId AND(BillHeader.OrderDate >= CONVERT(DATETIME,@FromDate,103))     
		AND (BillHeader.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
		AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		AND BillHeader.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))
		AND CONVERT(TIME,BillHeader.OrderTime,108) >= CONVERT(TIME, @FromTime,108)
		AND CONVERT(TIME,BillHeader.OrderTime,108) <= CONVERT(TIME, @ToTime,108)
		AND (@DatePeriods = 'ALL' OR DATEPART("DD",BillHeader.OrderDate) IN (SELECT * FROM STRING_SPLIT(@DatePeriods,',')))
	GROUP BY  BillHeader.Outlet,DATENAME(WEEKDAY,OrderDate),OrderDate,OrderNo,OrderTime,OrderType,ServiceCharge
	 

	SELECT COUNT(TempOrderNo) AS 'TokenCount',
		CASE @TimeInterval WHEN 1 THEN FORMAT(DATEADD("MI",-10,CONVERT(DATETIME,#TempBillHeader.TempTimeInterval)),'hh:mm tt') +' - '+ FORMAT(CONVERT(DATETIME,#TempBillHeader.TempTimeInterval),'hh:mm tt')
						   WHEN 2 THEN FORMAT(DATEADD("MI",-30,CONVERT(DATETIME,#TempBillHeader.TempTimeInterval)),'hh:mm tt') +' - '+ FORMAT(CONVERT(DATETIME,#TempBillHeader.TempTimeInterval),'hh:mm tt')
						   WHEN 3 THEN FORMAT(CONVERT(DATETIME,#TempBillHeader.TempTimeInterval),'hh:mm tt') +' - '+ FORMAT(DATEADD("HOUR",1,CONVERT(DATETIME,#TempBillHeader.TempTimeInterval)),'hh:mm tt')
						   WHEN 4 THEN #TempBillHeader.TempTimeInterval
						   ELSE  #TempBillHeader.TempTimeInterval
		END  AS 'Period',#TempBillHeader.TempTimeInterval AS 'SortForPeriod',		
		SUM(TempSubtotal + TempTaxVal1 + TempTaxVal2 + TempTaxVal3 + TempTaxVal4+TempServiceCharge) AS 'Sales'    
	FROM #TempBillHeader       
	INNER JOIN Location_Ref ON #TempBillHeader.TempOutlet = Location_Ref.code AND Location_Ref.PropertyId=@PropertyId     
	GROUP BY #TempBillHeader.TempTimeInterval,TempServiceCharge
	ORDER BY #TempBillHeader.TempTimeInterval		   

	DROP TABLE #TempBillHeader  

END;

GO

