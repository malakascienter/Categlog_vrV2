--EXECUTE Report_ItemWiseSales '001,002,003,004,005,006,007,008','01/06/2022','15/06/2022',1
CREATE PROCEDURE [dbo].[Report_ItemWiseSales]  
  @Outlet VARCHAR(max) ,  
  @FromDate VARCHAR(MAX),  
  @ToDate VARCHAR(MAX),
  @PropertyId VARCHAR(2)
  
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
	   sum((Qty * Rate) * BillDisPer /100) + sum((Qty * Rate) * ItemDisPer/100) + sum(BillDisVal) + sum(ItemDisVal) as DisPerc,
	   BH.OrderNo,
	   OT.Name AS 'Type',    
	   L.description AS 'Outlet',
	  sum(bt.NetAmount) as NetAmt
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
	   INNER JOIN POSOrderTypes AS OT ON OT.Code=BT.OrderType AND OT.PropertyId=BT.PropertyId
	   INNER JOIN Location_Ref AS L ON L.code=BT.Outlet  AND L.PropertyId=BT.PropertyId   
   
	   WHERE
	   BT.OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
	   And L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	   AND BT.PropertyId=@PropertyId
	   AND (BT.OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((PaymentTypes.NoValue = 1) AND PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
	   group by C.Description,C.Code,MM.Description,MM.ItemCode ,BT.OrderType,
	    L.description ,OT.Name	,   BH.OrderNo,BT.Rate, MM.costprice,BT.Qty--,bt.NetAmount--,BT.BillDisPer,BillDisVal,ItemDisVal,ItemDisPer
 
END

GO

