-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC Report_VoidBillDetail 'A00049','S01','2021-11-10 00:00:00.000',2
CREATE PROCEDURE [dbo].[Report_VoidBillDetail]
	@OrderNo VARCHAR(10),
	@Outlet	 VARCHAR(10),
	@OrderDate VARCHAR(20),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT L.description AS Outlet,BH.OrderDate,BH.OrderTime,BH.Waiter,BH.OrderNo,BH.TableNo,BH.RoomName,BH.GuestProfileName,BT.Qty,M.Description,
	BT.Rate,BH.Subtotal,BH.Discount,BH.NetAmount
	FROM VoidBillHeader BH 
	INNER JOIN VoidBillTrans BT 
	ON BH.OrderNo = BT.OrderNo AND BH.Outlet = BT.Outlet AND BH.OrderDate = BT.OrderDate AND BH.PropertyId = BT.PropertyId
	INNER JOIN VoidPayTrans PT 
	ON BH.OrderNo = PT.OrderNo AND BH.Outlet = PT.Outlet AND BH.OrderDate = PT.OrderDate AND BH.PropertyId = PT.PropertyId
	INNER JOIN MainMenu M ON BT.MainMenuCode = M.ItemCode
	INNER JOIN Location_Ref L ON BH.Outlet = L.code
	WHERE BH.OrderNo = @OrderNo AND BH.Outlet = @Outlet AND CONVERT(DATETIME, BH.OrderDate) = CONVERT(DATETIME,@OrderDate) AND BH.PropertyId = @PropertyId


    
END

GO

