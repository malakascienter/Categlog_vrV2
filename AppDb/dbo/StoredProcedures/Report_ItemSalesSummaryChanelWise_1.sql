
--==============================================================  
-- AUTHOR - CHIRAJ  
-- DESCRIPTION - REPORT GENERATION - ITEM SALES  
-- ALTERD - 19/09/2018  
--=============================================================== 
CREATE PROCEDURE [dbo].[Report_ItemSalesSummaryChanelWise_1]  
  @Outlet VARCHAR(max) ,  
  @FromDate VARCHAR(MAX),  
  @ToDate VARCHAR(MAX),
  @OrderType VARCHAR(1)
  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
 DECLARE @OrderTypeName VARCHAR(20)
SET @OrderTypeName=(SELECT Name FROM POSOrderTypes WHERE Code= @OrderType) 
  SELECT CategoryCode,Category,ItemCode,MainMenu,SUM(MainQty)AS MainQty,SUM(MainVal)AS MainValue,SUM(OtherInQty)AS OtherQty,SUM(OtherInVal)AS OtherValue FROM(  
  SELECT    
   C.Description AS 'Category',  
   C.Code AS 'CategoryCode',      
   MM.ItemCode,  
   MM.Description AS MainMenu,   
   BT.Rate AS 'Price',  
   BT.Qty,     
   L.description AS 'Outlet',  
   CASE WHEN BT.OrderType = @OrderType  THEN @OrderTypeName ELSE 'Other' END AS 'OrderType',  
   CASE WHEN BT.OrderType = @OrderType  THEN SUM(Qty) ELSE 0 END AS MainQty,  
   CASE WHEN BT.OrderType <> @OrderType THEN  SUM(Qty) ELSE 0 END AS OtherInQty,  
   CASE WHEN BT.OrderType = @OrderType  THEN SUM(Qty*BT.Rate) ELSE 0 END AS MainVal,  
   CASE WHEN BT.OrderType <> @OrderType THEN  SUM(Qty*BT.Rate) ELSE 0 END AS OtherInVal      
   FROM BillTrans AS BT INNER JOIN Category AS C ON BT.Category=C.Code  
   INNER JOIN MainMenu AS MM ON  BT.MainMenuCode=MM.ItemCode  
   INNER JOIN POSOrderTypes AS OT ON OT.Code=BT.OrderType  
   INNER JOIN Location_Ref AS L ON L.code=BT.Outlet      
   
   WHERE BT.OrderTime between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
   --WHERE BT.OrderTime between CONVERT(datetime,'01/09/2018 12:00:01 AM',103)  and CONVERT(datetime,'02/09/2018 11:59:59 PM',103)   
   And L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))   
   group by C.Description,C.Code,MM.Description,MM.ItemCode ,BT.OrderType,--,MM.Price,  
   BT.Qty,BT.Rate,    
   L.description   
     
   --order by MM.ItemCode ASC OFFSET 0 ROWS  
    )as d   
   group by CategoryCode,Category,ItemCode,MainMenu order by CategoryCode,ItemCode ASC  
END

GO

