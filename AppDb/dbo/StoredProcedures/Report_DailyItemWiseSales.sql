----------------------------------------------------------------------------                  
------Author - Dilshan                                                 
----------------------------------------------------------------------------    
---------EXEC  Report_DailyItemWiseSales 'DER,DIB,IRD,LOB,MRB,TUT',1,2024,'1', '26,55,4,27,28,29,30,23,31,34,5,6,32,50,39,33,35,36,64,7,60,8,9,57,37,10,63,38,11,66,40,41,12,42,43,44,56,25,22,13,45,61,46,47,48,20,21,14,15,16,58,67,17,49,18,19,24,51,59,65,52,53,54'   

CREATE PROCEDURE [dbo].[Report_DailyItemWiseSales]                       
(                      
@Outlet VARCHAR(MAX),         
@FromMonthNo int,                      
@FromYear int,        
@PropertyId VARCHAR(2),
@Category VARCHAR(MAX)
)                      
as                      
begin        

 SELECT 
 sum(BillTrans.Qty) as Qty,
 MainMenu.Description,
 MainMenu.ItemCode,
 BillTrans.Outlet AS Outlet,
 Category.Description AS Category,                       
 SUM(BillTrans.Qty*BillTrans.Rate) as Value,
 Category.Code AS CategoryCode, 
 DAY(BillTrans.OrderDate) AS DayNo,
 CAST(YEAR(BillTrans.OrderDate) AS VARCHAR) + ' ' + DATENAME(MONTH, BillTrans.OrderDate)  AS YearMonth                            
 FROM BillTrans                       
  INNER JOIN MainMenu ON MainMenu.ItemCode = BillTrans.MainMenuCode  AND BillTrans.PropertyId=MainMenu.PropertyId  
  INNER JOIN Category ON MainMenu.Category = Category.Code  AND MainMenu.PropertyId=Category.PropertyId  
 WHERE BillTrans.OrderDate >= DATEADD(MONTH,0,CAST((CAST(@FromYear AS varchar) + '/' + CAST(@FromMonthNo AS varchar) + '/01') AS DATETIME))                      
 AND BillTrans.OrderDate < DATEADD(MONTH,1,CAST((CAST(@FromYear AS varchar) + '/' + CAST(@FromMonthNo AS varchar) + '/01') AS DATETIME))                
 AND BillTrans.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))   
 AND BillTrans.PropertyId=@PropertyId      
 AND Category.CatgId IN (SELECT * FROM STRING_SPLIT(@Category,','))   
 GROUP BY  MainMenu.Description, MainMenu.ItemCode, BillTrans.Outlet, Category.Description, Category.Code,    
 DAY(BillTrans.OrderDate), CAST(YEAR(BillTrans.OrderDate) AS VARCHAR) + ' ' + DATENAME(MONTH, BillTrans.OrderDate)            
    ORDER BY  CAST(YEAR(BillTrans.OrderDate) AS VARCHAR) + ' ' + DATENAME(MONTH, BillTrans.OrderDate),DAY(BillTrans.OrderDate)
	

end;

GO

