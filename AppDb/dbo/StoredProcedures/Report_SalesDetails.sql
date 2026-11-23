
--=================================================================================      
-- AUTHOR - BANU      
-- DESCRIPTION - REPORT GENERATION OF SALES DETAILS      
-- CERATED - 19/09/2018      
--=================================================================================    
--[dbo].[Report_SalesDetails] 'S01','01/07/2020','1/07/2020',2
CREATE PROCEDURE [dbo].[Report_SalesDetails](   
 @Outlet VARCHAR(MAX),
 @FromDate VARCHAR(10),      
 @ToDate VARCHAR(10),
 @PropertyId VARCHAR(2)
)AS      
BEGIN  

 -- SELECT       
 --  Location_Ref.description,      
 --  PaymentTypes.Description AS PaymentType,       
 --  POSOrderTypes.Name AS OrderType,       
 --  BillHeader.OrderNo,  
 --  SUM(BillHeader.Subtotal),     
 --  SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge) AS SubTotal555, 
 -- ROUND((SUM(BillHeader.Subtotal)/SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge+BillHeader.Discount))*( PayTrans.ActualAmt),2) AS  SubTotal,
 -- ROUND((SUM(BillHeader.TaxVal1)/SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge+BillHeader.Discount))*SUM( PayTrans.ActualAmt),2) AS Tax1,      
 --  --SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge)/SUM(BillHeader.TaxVal2) AS Tax2,      
 --  ROUND((SUM(BillHeader.Discount)/SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge+BillHeader.Discount))*SUM( PayTrans.ActualAmt),2) AS Discount, 
 --  SUM(BillHeader.Discount)as disval,
 --  ROUND((SUM(BillHeader.ServiceCharge)/SUM(BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge+BillHeader.Discount))*SUM( PayTrans.ActualAmt),2) AS ServiceCharge  , 
 --  PayTrans.ActualAmt as ActualAmt
 -- FROM BillHeader       
 -- INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet   AND PayTrans.PropertyId=BillHeader.PropertyId     
 -- INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode   AND PaymentTypes.PropertyId=PayTrans.PropertyId    
 -- INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code    AND Location_Ref.PropertyId=BillHeader.PropertyId    
 -- LEFT OUTER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code  AND POSOrderTypes.PropertyId=BillHeader.PropertyId    
 -- WHERE  
 -- BillHeader.PropertyId=@PropertyId 
 -- AND  (BillHeader.OrderDate >= CONVERT(DATETIME,@FromDate,103)) AND         
 -- (BillHeader.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
 -- AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
 ----AND BillHeader.Outlet = CASE WHEN @Outlet='X' THEN BillHeader.Outlet ELSE @Outlet END    
 --AND BillHeader.subtotal>0
 -- GROUP BY BillHeader.OrderNo, POSOrderTypes.Name, PaymentTypes.Description, Location_Ref.description,PayTrans.ActualAmt       
 -- ORDER BY Location_Ref.description ,PaymentTypes.Description,  POSOrderTypes.Name, BillHeader.OrderNo      


   SELECT       
   Location_Ref.description,      
   PaymentTypes.Description AS PaymentType,       
   POSOrderTypes.Name AS OrderType,       
   BillHeader.OrderNo,  
   BillHeader.Subtotal,     
   BillHeader.Subtotal+BillHeader.TaxVal1+BillHeader.TaxVal2+BillHeader.ServiceCharge AS SubTotal555, 
   BillHeader.Subtotal AS  SubTotal,
   BillHeader.TaxVal1 AS Tax1,      
   BillHeader.TaxVal2 AS Tax2,      
    BillHeader.TaxVal3 AS Tax3,      
   BillHeader.Discount AS Discount, 
   BillHeader.Discount as disval,
   BillHeader.ServiceCharge AS ServiceCharge  , 
   PayTrans.ActualAmt as ActualAmt
  FROM BillHeader       
  INNER JOIN PayTrans ON BillHeader.OrderNo = PayTrans.OrderNo AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.Outlet = PayTrans.Outlet   AND PayTrans.PropertyId=BillHeader.PropertyId     
  INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode   AND PaymentTypes.PropertyId=PayTrans.PropertyId    
  INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code    AND Location_Ref.PropertyId=BillHeader.PropertyId    
  LEFT OUTER JOIN POSOrderTypes ON BillHeader.OrderType = POSOrderTypes.Code  AND POSOrderTypes.PropertyId=BillHeader.PropertyId    
  WHERE  
  BillHeader.PropertyId=@PropertyId 
  AND  (BillHeader.OrderDate >= CONVERT(DATETIME,@FromDate,103)) AND         
  (BillHeader.OrderDate <= CONVERT(DATETIME,@ToDate,103))     
  AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
 --AND BillHeader.Outlet = CASE WHEN @Outlet='X' THEN BillHeader.Outlet ELSE @Outlet END    
 AND BillHeader.subtotal>0
  --GROUP BY BillHeader.OrderNo, POSOrderTypes.Name, PaymentTypes.Description, Location_Ref.description,PayTrans.ActualAmt       
  ORDER BY Location_Ref.description ,PaymentTypes.Description,  POSOrderTypes.Name, BillHeader.OrderNo      


END;

GO

