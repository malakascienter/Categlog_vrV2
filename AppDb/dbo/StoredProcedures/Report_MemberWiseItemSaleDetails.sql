----------------------------------------------------------------------------                  
------Author - Dilshan                                                 
----------------------------------------------------------------------------    
---------EXEC  Report_MemberWiseMealTypeSaleDetails '001',11,2018,'R'           
CREATE PROCEDURE [dbo].[Report_MemberWiseItemSaleDetails]                       
(                      
	 @FromDate	VARCHAR(10),        
	 @ToDate	VARCHAR(10),
	 @Outlet    VARCHAR(MAX),
	 @PropertyId VARCHAR(2)
)                      
as                      
begin        

 SELECT 
 BT.Outlet AS Outlet,                     
 IC.Name AS MealType,
 BH.MemberName,
 BH.MemberId,
 SUM(BT.Qty) AS QtyTotal,
 MM.Description AS ItemName
 FROM BillTrans BT    
 INNER JOIN BillHeader BH ON BH.OrderNo = BT.OrderNo AND BH.Outlet = BT.Outlet AND BH.OrderDate = BT.OrderDate AND BH.PropertyId = BT.PropertyId
 INNER JOIN MainMenu MM ON MM.ItemCode = BT.MainMenuCode  AND BT.PropertyId=MM.PropertyId  
 INNER JOIN Category C ON MM.Category = C.Code  AND MM.PropertyId=C.PropertyId  
 INNER JOIN ItemCategory IC ON MM.ItemCategory = IC.Code AND MM.PropertyId = IC.PropertyId
 WHERE BT.OrderDate >= CONVERT(DATETIME,@FromDate,103)        
 AND BT.OrderDate < CONVERT(DATETIME,@ToDate,103)                  
 AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))   
 AND BT.PropertyId=@PropertyId   AND ISNULL(BH.MemberName,'') <> ''       
 GROUP BY  BH.MemberName,BH.MemberId,IC.Name,BT.Outlet, MM.Description
 ORDER BY  BH.MemberId

end;

GO

