--exec [Report_UserActivityLogForCombineSplite] '01/11/2021','01/11/2023','SPLIT',1
CREATE PROCEDURE [dbo].[Report_UserActivityLogForCombineSplite]  
	@FromDate	  VARCHAR(10),        
	@ToDate		  VARCHAR(10),
	@UserLogType  VARCHAR(50),
	@PropertyId   INT
AS  
BEGIN  
	
	

IF EXISTS( SELECT * FROM Sync_UserLogSettings WHERE IsCombine = 0 AND AccessCode = @UserLogType )
BEGIN

 SELECT L.description AS Outlet,C.OrderNo,C.OrderDateTime,c.NewOrderNo AS RefOrderNo,C.NewOrderDateTime AS RefOrderDate,MM.ItemCode ,MM.Description AS ItemName,C.Quantity,c.Rate,c.Quantity*c.Rate AS Value,C.WaiterID,C.CreateUserID,C.StationID
 FROM [dbo].POS_BillCombineSplitLog C INNER JOIN Location_Ref L ON C.OutletID = L.code AND C.PropertyId = L.PropertyId
 INNER JOIN MainMenu MM ON C.MenuItemID = MM.ItemCode AND C.PropertyId = MM.PropertyId 
 WHERE OrderDateTime BETWEEN  CONVERT(DATETIME,@FromDate,103)   AND  CONVERT(DATETIME,@ToDate,103)  AND c.PropertyId = @PropertyId AND IsCombined = 0

END
ELSE
BEGIN

 SELECT L.description AS Outlet,C.OrderNo AS RefOrderNo,C.OrderDateTime AS RefOrderDate,c.NewOrderNo AS OrderNo,C.NewOrderDateTime AS RefOrderDate,MM.ItemCode ,MM.Description AS ItemName,C.Quantity,c.Rate,c.Quantity*c.Rate AS Value,C.WaiterID,C.CreateUserID,C.StationID
 FROM [dbo].POS_BillCombineSplitLog C INNER JOIN Location_Ref L ON C.OutletID = L.code AND C.PropertyId = L.PropertyId
 INNER JOIN MainMenu MM ON C.MenuItemID = MM.ItemCode AND C.PropertyId = MM.PropertyId 
 WHERE OrderDateTime BETWEEN  CONVERT(DATETIME,@FromDate,103)   AND  CONVERT(DATETIME,@ToDate,103)  AND c.PropertyId = @PropertyId AND IsCombined = 1

	
END


END

GO

