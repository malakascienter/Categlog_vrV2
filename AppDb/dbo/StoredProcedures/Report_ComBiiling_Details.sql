

CREATE PROCEDURE [dbo].[Report_ComBiiling_Details]
	@FromDate VARCHAR(20),
	@ToDate VARCHAR(20),
	@PropertyId INT,
	@Outlet VARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	 ----CREATE view ViewComBiilingSummary as  
	 --SELECT  
	 ----BillHeader.OrderPrice, 
	 --BillHeader.OrderNo, Location_Ref.description AS Outlet, BillHeader.OrderDate, BillHeader.OrderTime, Waiter.Name,BillHeader.Subtotal,          
	 --(BillHeader.TaxVal1 + BillHeader.TaxVal2 + BillHeader.TaxVal3 + BillHeader.TaxVal4) AS TAX, 
	 --BillHeader.ServiceCharge, BillHeader.Discount,BillHeader.Subtotal + BillHeader.TaxVal1 + BillHeader.TaxVal2 + BillHeader.TaxVal3 + BillHeader.TaxVal4 + BillHeader.ServiceCharge - BillHeader.discount AS GrandTotal,
	 --PaymentTypes.PayCode, PaymentTypes.Description, PayTrans.ActualAmt, BillHeader.UserID, 'A' AS Ord_ID  ,BillHeader.PropertyId,MainMenu.Description AS ItemName,Category.Description as CatName,BillTrans.Qty,
	 --BillTrans.Rate,MainMenu.ItemCode AS ItemCode,Category.Code as CatCode
	 --FROM    Waiter 
	 --RIGHT OUTER JOIN BillHeader ON Waiter.Code = BillHeader.Waiter
	 --INNER JOIN PayTrans  ON BillHeader.PropertyId = PayTrans.PropertyId AND BillHeader.Outlet = PayTrans.Outlet AND BillHeader.OrderDate = PayTrans.OrderDate 
	 --AND BillHeader.OrderNo = PayTrans.OrderNo
	 -- INNER JOIN PaymentTypes  ON PayTrans.PayCode = PaymentTypes.PayCode AND PayTrans.PropertyId = PaymentTypes.PropertyId
	 --INNER JOIN BillTrans  ON BillHeader.PropertyId = BillTrans.PropertyId AND BillHeader.Outlet = BillTrans.Outlet AND BillHeader.OrderDate = BillTrans.OrderDate 
	 --AND BillHeader.OrderNo = BillTrans.OrderNo
	 --INNER JOIN MainMenu ON BillTrans.MainMenuCode = MainMenu.ItemCode AND BillTrans.PropertyId = MainMenu.PropertyId
	 --INNER JOIN Category ON MainMenu.Category = Category.Code AND MainMenu.PropertyId = Category.PropertyId
	 --INNER JOIN Location_Ref ON BillHeader.Outlet = Location_Ref.code AND BillHeader.PropertyId = Location_Ref.PropertyId
	 --WHERE BillHeader.OrderDate BETWEEN   @FromDate AND @ToDate 
	 ----BillHeader.OrderDate>=@FromDate
	 ----AND BillHeader.OrderDate<=@ToDate 
	 ----AND BillHeader.exeCode in (select code from ExecutiveRef)  
	 ----AND LEFT(BillHeader.ORDERNO,1)<>'F' 
	 ----AND PayTrans.PayCode  IN(SELECT PAYCODE FROM PAYMENTTYPES WHERE (NoValue = 1 and PayCode <> '00')) 
	 --AND BillHeader.ComplimentaryID != 0
	 --AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	 --AND BillHeader.PropertyId = @PropertyId


	  --CREATE view ViewComBiilingSummary as  
	 SELECT  
	 --BillHeader.OrderPrice, 
	 BillHeader.OrderNo, BillHeader.Outlet, BillHeader.OrderDate, BillHeader.OrderTime, Waiter.Name,BillHeader.Subtotal,          
	 (BillHeader.TaxVal1 + BillHeader.TaxVal2 + BillHeader.TaxVal3 + BillHeader.TaxVal4) AS TAX, 
	 BillHeader.ServiceCharge, BillHeader.Discount,BillHeader.Subtotal + BillHeader.TaxVal1 + BillHeader.TaxVal2 + BillHeader.TaxVal3 + BillHeader.TaxVal4 + BillHeader.ServiceCharge - BillHeader.discount AS GrandTotal,
	 BillHeader.UserID, 'A' AS Ord_ID  ,BillHeader.PropertyId,MainMenu.Description AS ItemName,Category.Description as CatName,BillTrans.Qty,
	 BillTrans.Rate,MainMenu.ItemCode AS ItemCode,Category.Code as CatCode,CM.ComplimentaryType AS ComplimentaryType,ItemCategory.Name AS ItemCategory
	 FROM    Waiter 
	 RIGHT OUTER JOIN BillHeader ON Waiter.Code = BillHeader.Waiter AND Waiter.PropertyId = BillHeader.PropertyId
	 --INNER JOIN PayTrans  ON BillHeader.PropertyId = PayTrans.PropertyId AND BillHeader.Outlet = PayTrans.Outlet AND BillHeader.OrderDate = PayTrans.OrderDate 
	 --AND BillHeader.OrderNo = PayTrans.OrderNo
	  --INNER JOIN PaymentTypes  ON PayTrans.PayCode = PaymentTypes.PayCode
	 INNER JOIN BillTrans  ON BillHeader.PropertyId = BillTrans.PropertyId AND BillHeader.Outlet = BillTrans.Outlet AND BillHeader.OrderDate = BillTrans.OrderDate 
	 AND BillHeader.OrderNo = BillTrans.OrderNo
	 INNER JOIN MainMenu ON BillTrans.MainMenuCode = MainMenu.ItemCode AND BillTrans.PropertyId = MainMenu.PropertyId
	 INNER JOIN Category ON MainMenu.Category = Category.Code AND Category.PropertyId = MainMenu.PropertyId
	 INNER JOIN ItemCategory ON MainMenu.ItemCategory = ItemCategory.Id AND MainMenu.PropertyId = ItemCategory.PropertyId
	 INNER JOIN POS_ComplimentaryTypes CM ON BillHeader.ComplimentaryID = CM.ID
	 WHERE BillHeader.OrderDate BETWEEN   @FromDate AND @ToDate 
	 --BillHeader.OrderDate>=@FromDate
	 --AND BillHeader.OrderDate<=@ToDate 
	 --AND BillHeader.exeCode in (select code from ExecutiveRef)  
	 --AND LEFT(BillHeader.ORDERNO,1)<>'F' 
	 --AND PayTrans.PayCode  IN(SELECT PAYCODE FROM PAYMENTTYPES WHERE (NoValue = 1 and PayCode <> '00')) 
	 AND BillHeader.ComplimentaryID != 0
	 AND BillHeader.Outlet IN (SELECT * FROM STRING_SPLIT(@Outlet,','))
	 AND BillHeader.PropertyId = @PropertyId
	   AND (BillHeader.OrderNo  IN (
				SELECT	PayTrans.OrderNo
				FROM	PayTrans 
					INNER JOIN PaymentTypes ON PayTrans.PayCode = PaymentTypes.PayCode
				WHERE	((NoValue = 1) AND OrderDate >=@FromDate
		AND  OrderDate <= @ToDate )
					AND (PayTrans.PayCode <> 'BR')  
					AND PayTrans.PropertyId = @PropertyId)
					
				)

END

GO

