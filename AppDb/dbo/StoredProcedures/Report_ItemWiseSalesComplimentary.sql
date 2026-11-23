--EXECUTE Report_ItemWiseSales 'S01,S02,S03,S04,S05','01/08/2020','12/08/2020','R,T,Y,D,I',2
CREATE PROCEDURE [dbo].[Report_ItemWiseSalesComplimentary]  
  @Outlet VARCHAR(max) ,  
  @FromDate VARCHAR(MAX),  
  @ToDate VARCHAR(MAX),
  @PropertyId VARCHAR(2),
  @MealType VARCHAR(MAX)
AS  
BEGIN  
   
	SET NOCOUNT ON;  
	SELECT    
	   C.Description AS 'Category',  
	   C.Code AS 'CategoryCode',      
	   MM.ItemCode,  
	   MM.Description AS MainMenu,   
	   BT.Rate AS 'Price',  
	   MM.costprice AS 'UnitCost',  
	   BT.Qty, 
	   BT.DisPerc,
	   BH.OrderNo,
	   OT.Name AS 'Type',    
	   L.description AS 'Outlet',
	   IT.Name AS MealType
	   --SUM(BT.Qty) AS Qty,SUM(BH.Subtotal+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4+BH.ServiceCharge) AS Value 
	   --CASE WHEN BT.OrderType = @OrderType  THEN @OrderTypeName ELSE 'Other' END AS 'OrderType',  
	   --CASE WHEN BT.OrderType = @OrderType  THEN SUM(Qty) ELSE 0 END AS MainQty,  
	   --CASE WHEN BT.OrderType <> @OrderType THEN  SUM(Qty) ELSE 0 END AS OtherInQty,  
	   --CASE WHEN BT.OrderType = @OrderType  THEN SUM(Qty*BT.Rate) ELSE 0 END AS MainVal,  
	   --CASE WHEN BT.OrderType <> @OrderType THEN  SUM(Qty*BT.Rate) ELSE 0 END AS OtherInVal      
	   FROM 
	   BillTrans AS BT 
	   INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BT.PropertyId=BH.PropertyId
	   INNER JOIN Category AS C ON BT.Category=C.Code  AND C.PropertyId=BT.PropertyId
	   INNER JOIN MainMenu AS MM ON  BT.MainMenuCode=MM.ItemCode  AND MM.PropertyId=BT.PropertyId
	   INNER JOIN ItemCategory IT ON MM.ItemCategory = IT.Id  AND IT.PropertyId = MM.PropertyId
	   INNER JOIN POSOrderTypes AS OT ON OT.Code=BT.OrderType AND OT.PropertyId=BT.PropertyId
	   INNER JOIN Location_Ref AS L ON L.code=BT.Outlet  AND L.PropertyId=BT.PropertyId   
   
	   WHERE
	   BT.OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
	   And L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	   And MM.ItemCategory IN (SELECT * FROM STRING_SPLIT(@MealType,N','))
	   AND BT.PropertyId=@PropertyId
	   AND IT.PropertyId =@PropertyId
	   AND (BT.OrderNo  IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
	   group by C.Description,C.Code,MM.Description,MM.ItemCode ,BT.OrderType,
	    L.description ,OT.Name	,   BH.OrderNo,BT.Rate, MM.costprice,BT.Qty,BT.DisPerc, IT.Name
 
END

GO

