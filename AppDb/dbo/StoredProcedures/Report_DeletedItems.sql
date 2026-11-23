-- =============================================
-- Author:		BANU
-- Create date: 21/02/2019
-- Description: Deleted Items Report
-- =============================================
-------EXECUTE Report_DeletedItems '03/04/2022', '03/04/2022', '001,001','1'
CREATE PROCEDURE [dbo].[Report_DeletedItems]
	@FromDate		VARCHAR(20),
	@ToDate			VARCHAR(20),
	@Outlet			VARCHAR(MAX),
	@PropertyId VARCHAR(2)
AS
BEGIN

SELECT  PA.WaiterCode,
		PA.Outlet AS OutletCode, 
		L.description AS Outlet,
		W.Name AS Waiter,
		PA.OrderNo, 
		PA.TempOrderNo, 
		PA.OrderDate, 
		PA.POSNo, 
		PA.ComputerName,
		PA.AccessCode, 
		PA.Remark,
		PA.SysDate,
		PA.UserId
		--[10.17.1.10].
FROM RestaurantPOS.dbo.POS_UserActivityLog as PA
INNER JOIN Waiter AS W ON W.Code=PA.WaiterCode
INNER JOIN Location_Ref AS L ON L.code=PA.Outlet
WHERE PA.AccessCode='DeleteItem' AND
  PA.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND PA.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND PA.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  --AND B.PropertyId=@PropertyId     
		order by OrderNo,PA.orderDate
	--SELECT D.OrderNo AS 'OrdeNo', D.DelDate AS 'DelDate', D.Qty AS 'Qty', D.UserID AS 'UserID',
	--		L.description AS 'OutletDesc', MM.Description AS 'MenuDesc', MM.Price,
	--		CASE D.Status WHEN 'P' THEN 'Printed' ELSE 'Not Printed' END AS 'Status'
	--FROM DeletedItems D
	--INNER JOIN MainMenu MM ON D.MainMenuCode = MM.ItemCode
	--INNER JOIN Location_Ref L ON D.Outlet = L.code
	--WHERE D.DelDate >= CONVERT(DATETIME, @FromDate, 103)
	--	AND D.DelDate <= CONVERT(DATETIME, @ToDate, 103)
	--	AND D.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
END

GO

