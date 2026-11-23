--==============================================================  
-- AUTHOR - BANU  
-- DESCRIPTION - REPORT GENERATION - PAYMENT WISE DETAILS  
-- ALTERD - 19/09/2018  
--===============================================================  
CREATE PROCEDURE [dbo].[Report_ItemMoving](          
 @Outlet VARCHAR(MAX),          
 @FromDate DATETIME,          
 @ToDate DATETIME,
 @PropertyId VARCHAR(2)
)AS          
BEGIN  
SELECT SUM(Qty) AS Qty, Description, ItemCode,Price, Category, Cat_Code,OrderCode  FROM (
 SELECT sum(BillTrans.Qty) as Qty, MainMenu.Description, MainMenu.ItemCode,BillTrans.Rate as Price, Category.Description AS Category,Category.Code AS Cat_Code,
 CASE BillTrans.OrderType WHEN 'Y' THEN 1 ELSE 2 END AS OrderCode          
 FROM BillTrans           
 inner join billheader on BillTrans.PropertyId =  billheader.PropertyId AND BillTrans.OrderDate =  billheader.OrderDate AND   BillTrans.Outlet =  billheader.Outlet AND   BillTrans.OrderNo =  billheader.OrderNo 
       INNER JOIN  MainMenu ON MainMenu.ItemCode = BillTrans.MainMenuCode    AND MainMenu.PropertyId=@PropertyId 
   INNER JOIN   Category ON MainMenu.Category = Category.Code     AND Category.PropertyId=@PropertyId              
        WHERE  BillTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103)            
     AND BillTrans.OrderDate <=  CONVERT(DATETIME,@ToDate,103)    AND billheader.MealEntitlement<>'B'         
   And BillTrans.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND BillTrans.PropertyId=@PropertyId    
   AND ( BillTrans.OrderNo NOT IN (
								SELECT	PayTrans.OrderNo
								FROM	PayTrans 
								INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
								WHERE	((PaymentTypes.NoValue = 1) 
								AND PayTrans.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
								AND PayTrans.OrderDate <=CONVERT(DATETIME,@Todate,103)  
								AND (PayTrans.PayCode <> 'BR')  
								AND PayTrans.PropertyId = @PropertyId
								 )
					
								)
		)
 GROUP BY  MainMenu.Description, MainMenu.ItemCode, Category.Description,Category.Code,BillTrans.Outlet, BillTrans.OrderType,BillTrans.Rate      
 )MAIN 
 GROUP BY Description, ItemCode, Category,Price, Cat_Code,OrderCode
END;

GO

