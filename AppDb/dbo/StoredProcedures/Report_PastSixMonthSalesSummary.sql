----------------------------------------------------------------------------                  
------Author - Banu                  
------Description - Report Generation of Past Six Month Sales Summary                  
------ALTERd - 17/09/2018                  
----------------------------------------------------------------------------    
---------EXEC  Report_PastSixMonthSalesSummary '001',11,2018,'R'           
CREATE PROCEDURE [dbo].[Report_PastSixMonthSalesSummary]                       
(                      
@Outlet varchar(3),         
@FromMonthNo int,                      
@FromYear int,        
@OrderType VARCHAR(MAX),
@PropertyId VARCHAR(2)
)                      
as                      
begin                     
 SELECT sum(BillTrans.Qty) as Qty,
 MainMenu.Description,
 MainMenu.ItemCode,
 BillTrans.Outlet AS Outlet,
 Category.Description AS Category,                       
   SUM(BillTrans.Qty*BillTrans.Rate) as Value,
  -- (SELECT 
  -- SUM(Subtotal+TaxVal1+TaxVal2+TaxVal3+TaxVal4+ServiceCharge)
  -- FROM BillHeader WHERE PropertyId=@PropertyId AND OrderDate >=  DATEADD(MONTH,-5,CAST((CAST(@FromYear AS varchar) + '/' + CAST(@FromMonthNo AS varchar) + '/01') AS DATETIME)) AND OrderDate <  DATEADD(MONTH,1,CAST((CAST(@FromYear AS varchar) + '/' + CAST(@FromMonthNo AS varchar) + '/01') AS DATETIME)))as Value,
   Category.Code, datename(month,BillTrans.OrderDate) AS Month_Name,      
   Month(BillTrans.OrderDate) AS Month_No,
   YEAR(BillTrans.OrderDate) AS YEAR                            
 FROM BillTrans                       
  LEFT OUTER JOIN MainMenu ON MainMenu.ItemCode = BillTrans.MainMenuCode  AND BillTrans.PropertyId=MainMenu.PropertyId  
  INNER JOIN Category ON MainMenu.Category = Category.Code  AND MainMenu.PropertyId=Category.PropertyId  
  --left join BillHeader ON BillHeader.OrderNo=BillTrans.OrderNo AND BillHeader.PropertyId=BillTrans.PropertyId
 WHERE BillTrans.OrderDate >= DATEADD(MONTH,-5,CAST((CAST(@FromYear AS varchar) + '/' + CAST(@FromMonthNo AS varchar) + '/01') AS DATETIME))                      
 AND BillTrans.OrderDate < DATEADD(MONTH,1,CAST((CAST(@FromYear AS varchar) + '/' + CAST(@FromMonthNo AS varchar) + '/01') AS DATETIME))            
  AND BillTrans.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))        
   AND BillTrans.Outlet = @Outlet   AND BillTrans.PropertyId=@PropertyId                    
 GROUP BY  MainMenu.Description, MainMenu.ItemCode, BillTrans.Outlet, Category.Description, Category.Code,    
 datename(month,BillTrans.OrderDate), Month(BillTrans.OrderDate), YEAR(BillTrans.OrderDate)                      
    ORDER BY Category.Code, MainMenu.ItemCode                  
end;

GO

