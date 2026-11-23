--==============================================================  
-- AUTHOR - CHIRAJ  
-- DESCRIPTION - REPORT GENERATION - ITEM SALES  
-- ALTERD - 19/09/2018  
--=============================================================== 
--------EXECUTE Report_ItemSalesSummaryChanelWise '001,002,003,004,005,006,007,008','01/06/2022','15/06/2022','R,T,Y,D,I',1,''
CREATE PROCEDURE [dbo].[Report_TotalItemSale]  
  @Outlet VARCHAR(max) ,  
  @FromDate VARCHAR(MAX),  
  @ToDate VARCHAR(MAX),
  @OrderType VARCHAR(MAX),
  @PropertyId VARCHAR(2),
  @MealType VARCHAR(max) = ''
  
AS  
BEGIN  
   
	SET NOCOUNT ON;  
	--DECLARE @OrderTypeName VARCHAR(20)

	--SET @OrderTypeName=(SELECT Name FROM POSOrderTypes WHERE Code= @OrderType) 
  
  --SELECT CategoryCode,Category,ItemCode,MainMenu,SUM(MainQty)AS MainQty,SUM(MainVal)AS MainValue,SUM(OtherInQty)AS OtherQty,SUM(OtherInVal)AS OtherValue FROM(  
	  SELECT    
	   C.Description AS 'Category',  
	   C.Code AS 'CategoryCode',      
	   MM.ItemCode,  
	   MM.Description AS MainMenu,   
	   --BT.Rate AS 'Price',  
	   --BT.Qty, 
	   BH.OrderNo,
	   OT.Name AS 'OrderType',    
	   L.description AS 'Outlet', SUM(Qty) AS Qty,
	   --SUM(BH.Subtotal+BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4+BH.ServiceCharge) AS Value ,
	   SUM(bt.NetAmount) AS Value 
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
	   --WHERE BT.OrderTime between CONVERT(datetime,'01/09/2018 12:00:01 AM',103)  and CONVERT(datetime,'02/09/2018 11:59:59 PM',103)   
	   And L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	   AND BT.OrderType IN (SELECT * FROM STRING_SPLIT(@OrderType,','))   AND BT.PropertyId=@PropertyId
	   AND MM.ItemCategory IN (SELECT * FROM STRING_SPLIT(@MealType,N',')) --AND BH.MealEntitlement<>'B'
	 --  AND (BH.OrderNo NOT IN (
		--		SELECT	PayTrans.OrderNo
		--		FROM	PayTrans 
		--			INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
		--		WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		--AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
		--			AND (PayTrans.PayCode <> 'BR')  
		--			AND PayTrans.PropertyId = @PropertyId)
					
		--		)
		--  AND ( BH.OrderNo NOT IN (
		--						SELECT	PayTrans.OrderNo
		--						FROM	PayTrans 
		--						INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
		--						WHERE	((PaymentTypes.NoValue = 1) 
		--						AND PayTrans.OrderDate >=CONVERT(DATETIME,@Fromdate,103) 
		--						AND PayTrans.OrderDate <=CONVERT(DATETIME,@Todate,103)  
		--						AND (PayTrans.PayCode <> 'BR')  
		--						AND PayTrans.PropertyId = @PropertyId
		--						 )
					
		--						)
		--)

	   group by C.Description,C.Code,MM.Description,MM.ItemCode ,BT.OrderType,--,MM.Price,
	    L.description ,OT.Name	,   BH.OrderNo
     
   --order by MM.ItemCode ASC OFFSET 0 ROWS  
   -- )as d   
   --group by CategoryCode,Category,ItemCode,MainMenu order by CategoryCode,ItemCode ASC  
END

GO

