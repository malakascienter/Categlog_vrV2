-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--Report_Consolidate_Sales '01/07/2020','06/07/2020','S01,s02','2'
CREATE PROCEDURE [dbo].[Report_Consolidate_Sales]
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
AS
BEGIN
	SET NOCOUNT ON;
	seLECT 
	BT.OrderNo
	,L.description AS Outlet
	,IC.Name AS ItemCategory
	--,BT.Category,BT.MainMenuCode
	,BT.Qty
	,BT.Rate
	,BT.ActualPrice
	,BT.Outlet as OutletId
	,CASE
	WHEN BT.BillDisPer<>0 THEN Round((BT.Rate*BT.Qty)*(BT.BillDisPer/100),4)
	WHEN BT.BillDisVal<>0 THEN Round((Bt.BillDisVal),4)
	WHEN BT.ItemDisPer<>0 THEN Round((BT.Rate*BT.Qty)*(BT.ItemDisPer/100),4) 
	WHEN BT.ItemDisVal<>0 THEN Round((Bt.ItemDisVal),4) ELSE 0.0000 END AS Discount
	,BT.NetAmount--,BT.PropertyId as BTprop,MM.PropertyId as MainProp,MM.ItemCategory,IC.PropertyId
	fROM BillTrans aS bt inner join BillHeader BH ON BT.OrderNo = BH.OrderNo AND BT.OrderDate = BH.OrderDate AND BT.Outlet = BH.Outlet AND BT.PropertyId = BH.PropertyId
	INNER JOIN MainMenu AS MM ON MM.ItemCode=BT.MainMenuCode AND MM.PropertyId=BT.PropertyId
	INNER JOIN ItemCategory AS IC ON IC.Id=MM.ItemCategory AND IC.PropertyId=MM.PropertyId
	INNER JOIN Location_Ref AS L ON L.code=BT.Outlet AND L.PropertyId=BT.PropertyId
	--INNER JOIN paytrans P on p.orderno = bt.orderno
	--INNER JOIN paymenttypes T on P.paycode = t.paycode 
	
	where
	BT.PropertyId=@PropertyId AND BT.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND BT.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		AND BT.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,',')) 
		--And (T.novalue <> 1 or T.paycode = 'BR')
		AND BH.MealEntitlement<>'B'
		AND (BT.OrderNo NOT IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >= CONVERT(DATETIME,@FromDate,103) 
		AND  OrderDate <= CONVERT(DATETIME,@ToDate,103) )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)

		order by BT.OrderNo
	
	--select * from BillTrans where OrderNo='R00022'
	--select * from Billheader where OrderNo='R00022'
	--select * from Billheader AS BH where PropertyId=1
	--select * from Category
	--SELECT * from ItemCategory AS IC where PropertyId=1
	--select Round(56.81818,4)

	--select * from MainMenu

	--	select * from Location_Ref



 
END

GO

