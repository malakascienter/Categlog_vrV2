-- =============================================
-- Author:		BANU
-- ALTER date: 12/11/2018
-- Description:	REPORT CUMULATIVE SALES SUMMARY MONTHLY 
-- =============================================
Create PROCEDURE [dbo].[Report_CumulativeSummaryMonthyAllOutlet]          
(        
 @Outlet varchar(max),  
 @FromMonthNo INT,          
 @FromYear INT,      
 @ToMonthNo INT,          
 @ToYear INT ,
 @PropertyId VARCHAR(2)
)          
          
AS        
BEGIN       
 SELECT  SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.TaxVal3+BillHeader.TaxVal4+BillHeader.ServiceCharge) AS NetSales, MONTH(BillHeader.OrderDate) AS Month,YEAR(BillHeader.OrderDate) AS Year  ,Location_Ref.description AS Outlet       
 FROM   BillHeader   INNER JOIN Location_Ref on    BillHeader.Outlet = Location_Ref.code
   WHERE 
   BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
   AND BillHeader.PropertyId=@PropertyId     
   AND BillHeader.OrderDate >= CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@FromMonthNo)+'/'+CONVERT(VARCHAR,@FromYear),103)         
   AND BillHeader.OrderDate < DATEADD(MONTH,1,CONVERT(datetime,'01'+'/'+CONVERT(VARCHAR,@ToMonthNo)+'/'+CONVERT(VARCHAR,@ToYear),103))        
 GROUP BY MONTH(BillHeader.OrderDate), YEAR(BillHeader.OrderDate)   ,Location_Ref.description   
END

GO

