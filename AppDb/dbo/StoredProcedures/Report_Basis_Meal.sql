

-- =============================================
-- Author:		Chiraj
-- Create date: 2020-6-30
-- Description:	<Description,,>
-- =============================================
--Report_Basis_Meal '01/07/2020','30/07/2020','S01,S02,S03,S04,S05','2'
CREATE PROCEDURE [dbo].[Report_Basis_Meal] 
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT 
	BT.OrderNo,
	BT.MainMenuCode,
	BT.Qty,
	--CASE
 --   WHEN BT.ResNetVal = 0 THEN (BT.ActualPrice/1)/100
 --   ELSE (BT.ActualPrice/BT.ResNetVal)/100
	--END AS Rate,
	BT.ItemCost AS Rate,
	MM.Description,
	IC.Name AS ItemCategory,
	BH.MealPlanID,
	BH.MealPlanName,
	BH.RoomName,
	Bh.ReservationNo,
	L.description AS Outlet,
	L.code AS OutletCode
	FROM BillTrans AS BT 
	INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BH.PropertyId=BT.PropertyId
	INNER JOIN MainMenu AS MM  ON MM.ItemCode=BT.MainMenuCode ANd  MM.PropertyId=BT.PropertyId
	INNER JOIN ItemCategory AS IC ON IC.Id=MM.ItemCategory AND IC.PropertyId=MM.PropertyId
	INNER JOIN Location_Ref AS L ON L.code=BT.Outlet AND L.PropertyId=BT.PropertyId
	WHERE BT.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
	AND BT.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
	AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND BT.PropertyId=@PropertyId  AND BH.MealEntitlement='B'

END

GO

