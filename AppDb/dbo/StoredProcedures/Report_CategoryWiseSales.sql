
CREATE PROCEDURE [dbo].[Report_CategoryWiseSales](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN     



	   SELECT        PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq, SUM(ChargeAmount) ChargeAmount
	   INTO #TempBillChargeDetail
       FROM            POS_BillChargeDetail
	   WHERE PropertyId = @PropertyId AND OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
	   AND Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	   GROUP BY  PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq

SELECT  Outlet,Category, SUM(Qty) AS Qty,SUM(Tax) AS Tax,SUM(Total) AS Total,SUM(Value) AS Value
FROM (
	   SELECT    
	   L.description AS Outlet,
	   CASE WHEN C.CatgId = 2 THEN C.Description ELSE 'Other' END AS 'Category',  
	   C.Code AS 'CategoryCode',      
	   SUM(BT.Qty) AS Qty,
	   SUM(BT.NetAmount) AS Value,
	   SUM(ISNULL(TBC.ChargeAmount,0)) AS Tax,
	   SUM(bt.NetAmount+ISNULL(TBC.ChargeAmount,0)) AS Total
	   FROM 
	   BillTrans AS BT 
	   LEFT JOIN #TempBillChargeDetail TBC ON TBC.OrderNo=BT.OrderNo AND BT.PropertyId=TBC.PropertyId and TBC.OrderDate = bt.OrderDate AND TBC.Outlet = BT.Outlet
	   AND BT.MainMenuCode = TBC.MenuItemID AND BT.RefItemCode= TBC.RefItemID AND BT.ItemSeq = TBC.ItemSequence AND BT.SortSeq = TBC.SortSeq
	   INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BT.PropertyId=BH.PropertyId and bh.OrderDate = bt.OrderDate AND BH.Outlet = BT.Outlet
	   INNER JOIN Category AS C ON BT.Category=C.Code  AND C.PropertyId=BT.PropertyId
	   INNER JOIN MainMenu AS MM ON  BT.MainMenuCode=MM.ItemCode  AND MM.PropertyId=BT.PropertyId
	   INNER JOIN POSOrderTypes AS OT ON OT.Code=BT.OrderType AND OT.PropertyId=BT.PropertyId
	   INNER JOIN Location_Ref AS L ON L.code=BT.Outlet  AND L.PropertyId=BT.PropertyId   
   
	   WHERE
	   BT.OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  AND BT.PropertyId=@PropertyId
	   AND L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	   AND BH.MealEntitlement<>'B'
	   AND (
	         BH.Id NOT IN 
					(
						SELECT	BillHeader.Id
						FROM	PayTrans 
							INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
							INNER JOIN BillHeader ON BillHeader.PropertyId = PayTrans.PropertyId AND BillHeader.Outlet = PayTrans.Outlet AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.OrderNo = PayTrans.OrderNo
						WHERE	((NoValue = 1) AND PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
						    AND  PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103) )
							AND (PayTrans.PayCode <> 'BR')  
							AND PayTrans.PropertyId = @PropertyId
					)					
		  )
		
	   group by C.CatgId,C.Description,C.Code,L.description 
     
) A
GROUP BY Outlet,Category

   DROP TABLE #TempBillChargeDetail



END;

GO

