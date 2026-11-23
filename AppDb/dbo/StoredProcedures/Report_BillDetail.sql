-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--EXEC Report_BillDetail 'B00285','OLV','2023-09-14',1
CREATE PROCEDURE [dbo].[Report_BillDetail]
	@OrderNo VARCHAR(10),
	@Outlet	 VARCHAR(10),
	@OrderDate VARCHAR(20),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;


	SELECT L.description AS Outlet,BH.OrderDate,BH.OrderTime,BH.Waiter,BH.OrderNo,BH.TableNo,BH.RoomName,BH.GuestProfileName,BT.Qty,M.Description,
	BT.Rate,BH.Subtotal,BH.Discount,BH.NetAmount,BH.ServiceCharge,BH.TaxVal1+BH.TaxVal2+BH.TaxVal3+BH.TaxVal4 as Tax
	FROM BillHeader BH 
	INNER JOIN BillTrans BT 
	ON BH.OrderNo = BT.OrderNo AND BH.Outlet = BT.Outlet AND BH.OrderDate = BT.OrderDate AND BH.PropertyId = BT.PropertyId
	--INNER JOIN PayTrans PT 
	--ON BH.OrderNo = PT.OrderNo AND BH.Outlet = PT.Outlet AND BH.OrderDate = PT.OrderDate AND BH.PropertyId = PT.PropertyId
	INNER JOIN MainMenu M ON BT.MainMenuCode = M.ItemCode  AND M.PropertyId = BT.PropertyId
	INNER JOIN Location_Ref L ON BH.Outlet = L.code AND BH.PropertyId = L.PropertyId
	WHERE BH.OrderNo = @OrderNo AND BH.Outlet = @Outlet AND CONVERT(DATE, BH.OrderDate) = CONVERT(DATE,@OrderDate) 
	AND BH.PropertyId = @PropertyId AND M.IsInstruction = 0


    
END

GO

