


-- =============================================
-- Author:		Banu
-- ALTER date: 29/10/2018
-- Description:	Generate Void Bill Listing Report
-- =============================================
-- [Report_VoidBillListing] 'D01,D02','26/06/2020','27/06/2020' ,1
CREATE PROCEDURE [dbo].[Report_VoidBillListing]
(
	@Outlet VARCHAR(MAX),
	@FromDate VARCHAR(10),
	@ToDate VARCHAR(10),
	@PropertyId VARCHAR(2)
)
AS
BEGIN  
	SELECT V.OrderNo, V.OrderDate, V.OrderTime, L.description AS Outlet, MM.Description AS Item, ISNULL(BH.VoidRemark,'') AS 'Reason', V.Qty, 
	BH.Subtotal + BH.TaxVal1 + BH.TaxVal2 + BH.TaxVal3 + BH.TaxVal4+BH.ServiceCharge AS NetAmount, W.Name AS OrderPlacedByPer, BH.VoidUserID AS VoidByPer, '' AS Remarks, BH.VoidUserDate 'VoidDate'	
	FROM VoidBillTrans V
	INNER JOIN VoidBillHeader BH ON V.OrderNo = BH.OrderNo AND V.Outlet = BH.Outlet AND V.OrderDate = BH.OrderDate AND BH.PropertyId=V.PropertyId
	LEFT OUTER JOIN VoidReasonRef VR ON V.ResNo = VR.Void_code AND VR.PropertyId=V.PropertyId
	INNER JOIN MainMenu MM ON V.MainMenuCode = MM.ItemCode AND MM.PropertyId=V.PropertyId
	INNER JOIN Location_Ref L ON V.Outlet = L.code AND L.PropertyId=V.PropertyId
	INNER JOIN Waiter W ON V.UserID = W.Code AND W.PropertyId=V.PropertyId
	WHERE 
	V.PropertyId=@PropertyId and
	V.OrderDate >= CONVERT(DATETIME,@FromDate, 103) 
		AND V.OrderDate <= CONVERT(DATETIME, @ToDate, 103)
		AND V.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet, ',')) AND V.PropertyId=@PropertyId
END

GO

