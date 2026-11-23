-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT CUMULATIVE SALES SUMMARY MONTHLY 
-- =============================================
CREATE PROCEDURE [dbo].[Report_CumulativeSummaryMonthy]          
(        
 @Outlet char(3),        
 @FromMonthNo INT,          
 @FromYear INT,      
 @ToMonthNo INT,          
 @ToYear INT ,
 @PropertyId VARCHAR(2)
)          
          
AS        
BEGIN       
 SELECT  SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.TaxVal3+BillHeader.TaxVal4+BillHeader.ServiceCharge) AS NetSales, MONTH(BillHeader.OrderDate) AS Month,YEAR(BillHeader.OrderDate) AS Year         
 FROM   BillHeader      
   WHERE 
   BillHeader.Outlet =@Outlet  
   AND BillHeader.PropertyId=@PropertyId     
   AND BillHeader.OrderDate >= CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromMonthNo)+'/'+CONVERT(VARCHAR,@FromYear),103)         
   AND BillHeader.OrderDate < DATEADD(MONTH,1,CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@ToMonthNo)+'/'+CONVERT(VARCHAR,@ToYear),103))        
  AND ( BillHeader.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((NoValue = 1) 
								AND OrderDate >=  CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromMonthNo)+'/'+CONVERT(VARCHAR,@FromYear),103) 
								AND  OrderDate < DATEADD(MONTH,1,CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@ToMonthNo)+'/'+CONVERT(VARCHAR,@ToYear),103) )
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								AND PayTrans.Outlet =@Outlet )
					
								)
		)
 GROUP BY MONTH(BillHeader.OrderDate), YEAR(BillHeader.OrderDate)        
END

GO

