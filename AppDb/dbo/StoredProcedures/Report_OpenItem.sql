
CREATE PROCEDURE [dbo].[Report_OpenItem]  
  @Outlet VARCHAR(max) ,  
  @FromDate VARCHAR(MAX),  
  @ToDate VARCHAR(MAX),
  @PropertyId VARCHAR(2)
AS  
BEGIN  
   
	SET NOCOUNT ON;  
	SELECT    
	   C.Description AS 'Category',     
	   MM.ItemCode,  
	   CASE WHEN PBT.MenuName  = ''  THEN 'Open Item' ELSE PBT.MenuName
	   END AS MainMenu,   
	   BT.Rate AS 'Price',  
	   BT.Qty, 
	   ( (((BT.[Qty]*BT.[Rate])*BT.BillDisPer)/(100)) + (((BT.[Qty]*BT.[Rate])*BT.ItemDisPer)/(100)) +BT.ItemDisVal + BT.BillDisVal  )  AS 'DiscVal',
	   BH.OrderNo,
	   BH.OrderDate,
	   OT.Name AS 'Type',    
	   L.description AS 'Outlet' ,
	   BT.NetAmount
	   FROM 
	   BillTrans AS BT 
	   INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BH.OrderDate = BT.OrderDate AND BH.Outlet = BT.Outlet AND BT.PropertyId=BH.PropertyId
	   INNER JOIN Category AS C ON BT.Category=C.Code  AND C.PropertyId=BT.PropertyId
	   INNER JOIN POS_BillOpenMenu PBT ON BT.OrderNo=PBT.OrderNo AND BT.OrderDate = PBT.OrderDate AND BT.Outlet = PBT.Outlet AND BT.PropertyId=PBT.PropertyId AND BT.MainMenuCode = pbt.MenuItemID 
	   AND BT.ItemSeq = PBT.ItemSequence AND BT.SortSeq = PBT.SortSeq
	   INNER JOIN MainMenu AS MM ON  BT.MainMenuCode=MM.ItemCode  AND MM.PropertyId=BT.PropertyId
	   INNER JOIN POSOrderTypes AS OT ON OT.Code=BT.OrderType AND OT.PropertyId=BT.PropertyId
	   INNER JOIN Location_Ref AS L ON L.code=BT.Outlet  AND L.PropertyId=BT.PropertyId   
   
	   WHERE
	   BT.OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
	   And L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	   AND BT.PropertyId=@PropertyId
	   AND MM.IsOpenItem = 1
	   AND (BT.OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)
	   --group by L.description,BH.OrderNo,BH.OrderDate,OT.Name ,C.Description,MM.ItemCode ,BT.OpenItemDescription, BT.Rate,BT.Qty,BT.DisPerc
 
END

GO

