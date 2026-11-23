--====================================================================         
-- AUTHOR - BANU        
-- DESCRIPTION - GENERATION OF REPORT SALES SUMMARY         
-- ALTERD - 02/10/2018        
--=====================================================================     
CREATE PROCEDURE [dbo].[Report_SalesSummary](          
 @FromDate varchar(10),        
 @ToDate varchar(10) ,
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         
 SELECT description AS Outlet,SUM(Subtotal) AS SubTotal,SUM(TaxVal1) AS TaxVal1,SUM(TaxVal2) AS TaxVal2,        
  SUM(ServiceCharge) AS ServiceCharge,SUM(Discount) AS Discount      ,SUM(TaxVal3)  AS TaxVal3  
 FROM BillHeader B         
 LEFT OUTER JOIN Location_Ref L ON B.Outlet = L.code        
 WHERE OrderDate >= CONVERT(DATETIME,@FromDate,103) AND OrderDate <= CONVERT(DATETIME,@ToDate,103)   AND B.PropertyId=@PropertyId      
 AND B.Subtotal>0
 GROUP BY description;        
END;

GO

