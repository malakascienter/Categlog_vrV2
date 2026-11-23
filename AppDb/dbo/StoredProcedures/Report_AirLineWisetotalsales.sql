
CREATE PROCEDURE [dbo].[Report_AirLineWisetotalsales](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         




	 
SELECT Name,sum(Res)as Res ,sum(Bar) as Bar,sum(Res)+sum(Bar) as UsdTot,(sum(Res)+sum(Bar)) as RsTot
FROM (
	SELECT  BillHeader.CustomerName AS Name,
			CASE WHEN MainMenu.itemcategory = 'F' THEN SUM(BillTrans.Qty * BillTrans.Rate) ELSE 0 END AS Res, 
			CASE WHEN MainMenu.itemcategory = 'B' THEN SUM(BillTrans.Qty * BillTrans.Rate) ELSE 0 END AS BAR 
	FROM    BillTrans 
			INNER JOIN BillHeader ON BillTrans.OrderNo = BillHeader.OrderNo 
			INNER JOIN PayTrans ON BillTrans.OrderNo = PayTrans.OrderNo
			INNER JOIN MainMenu ON BillTrans.MainMenuCode = MainMenu.ItemCode and BillTrans.PropertyId = MainMenu.PropertyId
	WHERE   BillHeader.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND BillHeader.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  
	GROUP BY MainMenu.ItemCategory, BillHeader.CustomerName
	) as z 
GROUP BY z.Name


	

END;

GO

