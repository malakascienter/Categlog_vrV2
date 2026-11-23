--====================================================================         
-- Created by	: Nivesh
-- Created date	: 2025-08-27
-- Description	: Item Category-wise Sales Summary report
--=====================================================================  
-- Report_ItemCategoryWiseSalesSummary '01/01/2025', '01/02/2025','001', 1

CREATE PROCEDURE [dbo].[Report_ItemCategoryWiseSalesSummary](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
BEGIN         
	SELECT        PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq, SUM(ChargeAmount) ChargeAmount
	INTO #TempBillChargeDetail_Tax
	FROM            POS_BillChargeDetail
	WHERE PropertyId = @PropertyId AND OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
	AND Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,N',')) AND ChargeTypeID <> 1
	GROUP BY  PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq

	SELECT        PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq, SUM(ChargeAmount) ChargeAmount
	INTO #TempBillChargeDetail_SC
	FROM            POS_BillChargeDetail
	WHERE PropertyId = @PropertyId AND OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)  
	AND Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,N',')) AND ChargeTypeID = 1
	GROUP BY  PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq



	SELECT    
	bh.OrderDate,     
	IC.Name AS ItemCategoryName,    
	L.description AS 'Outlet',
	SUM((bt.Qty*bt.Rate)+ISNULL(TBC.ChargeAmount,0)+ISNULL(TBSC.ChargeAmount,0)) AS SaleValue,
	SUM(bt.NetAmount+ISNULL(TBC.ChargeAmount,0)+ISNULL(TBSC.ChargeAmount,0)) AS NetValue,
	SUM(ISNULL(TBC.ChargeAmount,0)) AS TaxValue,
	SUM(ISNULL(TBSC.ChargeAmount,0)) AS SerChargeValue
	FROM 
	BillTrans AS BT 
	LEFT JOIN #TempBillChargeDetail_Tax TBC ON TBC.OrderNo=BT.OrderNo AND BT.PropertyId=TBC.PropertyId and TBC.OrderDate = bt.OrderDate AND TBC.Outlet = BT.Outlet
	AND BT.MainMenuCode = TBC.MenuItemID AND BT.RefItemCode= TBC.RefItemID AND BT.ItemSeq = TBC.ItemSequence AND BT.SortSeq = TBC.SortSeq
	LEFT JOIN #TempBillChargeDetail_SC TBSC ON TBSC.OrderNo=BT.OrderNo AND BT.PropertyId=TBSC.PropertyId and TBSC.OrderDate = bt.OrderDate AND TBSC.Outlet = BT.Outlet
	AND BT.MainMenuCode = TBSC.MenuItemID AND BT.RefItemCode= TBSC.RefItemID AND BT.ItemSeq = TBSC.ItemSequence AND BT.SortSeq = TBSC.SortSeq
	INNER JOIN BillHeader AS BH ON BH.OrderNo=BT.OrderNo AND BT.PropertyId=BH.PropertyId and bh.OrderDate = bt.OrderDate AND BH.Outlet = BT.Outlet
	INNER JOIN Category AS C ON BT.Category=C.Code  AND C.PropertyId=BT.PropertyId
	INNER JOIN MainMenu AS MM ON  BT.MainMenuCode=MM.ItemCode  AND MM.PropertyId=BT.PropertyId
	INNER JOIN ItemCategory IC ON MM.ItemCategory = IC.Id AND MM.PropertyId = IC.PropertyId
	INNER JOIN POSOrderTypes AS OT ON OT.Code=BT.OrderType AND OT.PropertyId=BT.PropertyId
	INNER JOIN Location_Ref AS L ON L.code=BT.Outlet  AND L.PropertyId=BT.PropertyId   
   
	WHERE
	BT.OrderDate between CONVERT(datetime,@FromDate,103) AND CONVERT(datetime,@ToDate,103)     
	And L.code IN (SELECT * FROM STRING_SPLIT(@Outlet,N','))
	AND BT.PropertyId=@PropertyId
	AND BH.MealEntitlement<>'B'
	AND (BH.Id NOT IN (
	SELECT	BillHeader.Id
	FROM	PayTrans 
	INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
	INNER JOIN BillHeader ON BillHeader.PropertyId = PayTrans.PropertyId AND BillHeader.Outlet = PayTrans.Outlet AND BillHeader.OrderDate = PayTrans.OrderDate AND BillHeader.OrderNo = PayTrans.OrderNo
	WHERE	((NoValue = 1) AND PayTrans.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
	AND  PayTrans.OrderDate <= CONVERT(DATETIME,@ToDate,103) )
	AND (PayTrans.PayCode <> 'BR')  
	AND PayTrans.PropertyId = @PropertyId)
					
	)

	group by bh.OrderDate,IC.Name,L.description

	DROP TABLE #TempBillChargeDetail_Tax
	DROP TABLE #TempBillChargeDetail_SC

END;

GO

