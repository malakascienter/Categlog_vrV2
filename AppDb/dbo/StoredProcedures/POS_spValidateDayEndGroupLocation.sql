CREATE PROCEDURE [dbo].[POS_spValidateDayEndGroupLocation]
AS

SELECT
(SELECT OutletCode,OutletName ,ShiftNo, CONVERT(DATE,ShiftDate) AS ShiftDate, WaiterName  FROM(
SELECT	L.code AS OutletCode,L.description AS OutletName, S.ShiftNo, S.ShiftDate, W.Name AS WaiterName
FROM	POS_CashierShift AS S INNER JOIN Waiter AS W ON S.WaiterCode = W.Code 
		INNER JOIN Location_Ref L ON S.Outlet = L.code
WHERE	S.IsSignOff = 0 ) X FOR JSON AUTO) AS NotSignOff,

(SELECT	L.code AS OutletCode,L.description AS OutletName,B.OrderNo, CONVERT(DATE,B.OrderDate) AS OrderDate, 'Invoice not uploaded to server' AS Description
FROM	BillHeader B INNER JOIN Location_Ref L ON B.Outlet = L.code WHERE Upload = 0 FOR JSON AUTO) AS NotUploaded,

(SELECT	L.code AS OutletCode,L.description AS OutletName,B.OrderNo, CONVERT(DATE, B.OrderDateTime) AS OrderDate, 'Un settled orders' AS Description
FROM	POS_TempBill B INNER JOIN Location_Ref L ON B.OutletID = L.code GROUP BY B.OrderNo,CONVERT(DATE, B.OrderDateTime),L.code,L.description ORDER BY B.OrderNo FOR JSON AUTO) AS UnSettledOrders

GO

