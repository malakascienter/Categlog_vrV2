
CREATE PROCEDURE [dbo].[Report_ItemWiseBillDetails](          
 @FromDate	VARCHAR(10),        
 @ToDate	VARCHAR(10),
 @Outlet    VARCHAR(MAX),
 @PropertyId VARCHAR(2)
)        
AS        
	BEGIN         
	
	WITH BillWithTax AS (
		SELECT 
			BH.OrderNo, BH.Outlet, BH.OrderDate, BH.OrderTime, BH.PropertyId, BH.OrderType, BH.Subtotal,
			BH.ServiceCharge, BH.Discount, BH.Waiter,
			BH.TaxVal1 + BH.TaxVal2 + BH.TaxVal3 + BH.TaxVal4 AS Tax,
			BH.Subtotal + BH.ServiceCharge + BH.TaxVal1 + BH.TaxVal2 + BH.TaxVal3 + BH.TaxVal4 AS GrandTotal,BH.AggregatorID,BH.ContactNo
		FROM BillHeader BH WITH (NOLOCK)
		WHERE BH.OrderDate >= CONVERT(DATETIME,@FromDate,103) 
			AND BH.OrderDate <= CONVERT(DATETIME,@ToDate,103) 
		  AND BH.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
		  AND BH.PropertyId = @PropertyId
	)
	SELECT 
		LR.Description AS Outlet,
		B.OrderNo,
		B.OrderDate,
		B.OrderTime,
		MM.ItemCode,
		MM.Description AS ItemName,
		BT.Qty,
		BT.Rate,
		B.Subtotal,
		B.ServiceCharge,
		B.Discount,
		B.Tax,
		B.GrandTotal,
		PP.Description AS PaymentMethod,
		case 
		  when ot.Code = 'G'
			 THEN 
				 case 
					 when B.AggregatorID = 1 THEN 'Uber' 
					 when B.AggregatorID = 2 THEN 'PickMe' 
					 else OT.Name 
				 end
		  else 
		   OT.Name
		end AS OrderType,
		B.ContactNo AS CustomerLoyaltyNumber,
		B.Waiter AS Waiter
	FROM BillWithTax B
	INNER JOIN BillTrans BT WITH (NOLOCK)
		ON B.OrderNo = BT.OrderNo AND B.Outlet = BT.Outlet AND B.OrderDate = BT.OrderDate AND B.PropertyId = BT.PropertyId
	INNER JOIN Location_ref LR WITH (NOLOCK)
		ON B.Outlet = LR.Code AND B.PropertyId = LR.PropertyId
	INNER JOIN MainMenu MM WITH (NOLOCK)
		ON MM.ItemCode = BT.MainMenuCode AND MM.PropertyId = BT.PropertyId
	INNER JOIN PayTrans PT WITH (NOLOCK)
		ON B.OrderNo = PT.OrderNo AND B.Outlet = PT.Outlet AND B.OrderDate = PT.OrderDate AND B.PropertyId = PT.PropertyId
	INNER JOIN PaymentTypes PP WITH (NOLOCK)
		ON PP.PayCode = PT.PayCode AND PP.PropertyId = PT.PropertyId
	INNER JOIN POSOrderTypes OT WITH (NOLOCK)
		ON B.OrderType = OT.Code AND B.PropertyId = OT.PropertyId
	WHERE PT.ActualAmt <> 0 AND BT.PropertyId = @PropertyId AND LR.PropertyId = @PropertyId AND MM.PropertyId = @PropertyId  
	AND PT.PropertyId = @PropertyId AND PP.PropertyId = @PropertyId AND OT.PropertyId = @PropertyId
	ORDER BY LR.Description, B.OrderDate, B.OrderNo, B.OrderTime;

END;

GO

