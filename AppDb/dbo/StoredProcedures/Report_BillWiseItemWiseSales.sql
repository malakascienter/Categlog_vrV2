
CREATE PROCEDURE [dbo].[Report_BillWiseItemWiseSales](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         

	SELECT L.description AS Outlet,BH.OrderDate,BH.OrderNo,MM.Description AS MenuName,MM.ItemCode ,WW.Name WaiterName,BT.Qty,BT.Rate,BT.Qty * BT.Rate AS Value,BH.MemberName MemberCode
	FROM BillHeader BH WITH(NOLOCK)
	INNER JOIN BillTrans BT WITH(NOLOCK) ON BH.OrderNo = BT.OrderNo  AND BH.OrderDate = bt.OrderDate AND BH.Outlet = BT.Outlet AND BH.PropertyId = BT.PropertyId
	INNER JOIN Location_Ref L ON L.code = BH.Outlet AND L.PropertyId = BH.PropertyId
	INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyID = MM.PropertyId
	INNER JOIN Waiter WW ON WW.Code = BH.Waiter AND WW.PropertyId = BH.PropertyId
	WHERE  BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
			AND BH.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
			AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND BH.PropertyId=@PropertyId   
	

		
END;

GO

