-- =============================================
-- Author:		chiraj
-- Create date: 2020-6-30
-- Description:	kot bot list
-- =============================================
--[Report_KOT_BOT_List] '26/06/2020','27/06/2020','D01','1'
CREATE PROCEDURE [dbo].[Report_KOT_BOT_List]
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN
	
	SET NOCOUNT ON;
	select 
	BH.MealPlanID,
	BH.MealPlanName ,
	K.OrderNo,
	K.KotBotNo,
	K.WaiterID,
	W.Name AS Waiter,
	TT.TableName AS TableID,
	--K.TableID,
	L.description AS Outlet,
	BH.RoomName,
	K.OrderDate,
	K.KOTName,
	K.KOTQuantity,
	BH.ReservationNo,
	K.KotBotDateTime 	
	from POS_KotBot AS K 
	INNER JOIN POS_TableList TT ON K.TableID = TT.TableID AND K.PropertyId=TT.PropertyId
	INNER JOIN Waiter AS W ON W.Code=K.WaiterID AND K.PropertyId=W.PropertyId
	INNER JOIN BillHeader AS BH ON BH.OrderNo=K.OrderNo AND BH.PropertyId=K.PropertyId
	INNER JOIN Location_Ref AS L ON L.code=K.OutletID AND L.PropertyId=K.PropertyId
	WHERE 
	K.propertyId=@PropertyId and K.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND K.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND K.OutletID IN (SELECT * FROM STRING_SPLIT(@Outlet,','))

END

GO

