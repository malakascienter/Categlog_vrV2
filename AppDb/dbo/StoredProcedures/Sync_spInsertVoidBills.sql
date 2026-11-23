

CREATE PROCEDURE [dbo].[Sync_spInsertVoidBills]
@PropertyId INT,
@OrderNo VARCHAR(6),
@OrderDate DATETIME,
@Outlet VARCHAR(3),
@HeaderXml VARCHAR(MAX),
@DetailXml VARCHAR(MAX),
@PaymentXml VARCHAR(MAX),
@KotXml VARCHAR(MAX),
@PaymentCurrencyXml VARCHAR(MAX)
AS
SET DATEFORMAT DMY

DECLARE @tHeaderXml XML, @tDetailXml XML, @tPaymentXml XML, @tKottXmlXml XML, @tPaymentCurrencyXml XML

SET @tHeaderXml = REPLACE(@HeaderXml,'encoding="utf-8"','encoding="ISO-8859-9"') 
SET @tDetailXml = @DetailXml
SET @tPaymentXml = @PaymentXml
SET @tKottXmlXml = REPLACE(@KotXml,'encoding="utf-8"','encoding="ISO-8859-9"')
SET @tPaymentCurrencyXml = @PaymentCurrencyXml

DELETE FROM BillHeader WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet
DELETE FROM BillTrans WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet
DELETE FROM PayTrans WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet
DELETE FROM POS_KotBot WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND OutletID = @Outlet

DELETE FROM VoidBillHeader WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet
DELETE FROM VoidBillTrans WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet
DELETE FROM VoidPayTrans WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet

INSERT INTO VoidBillHeader
	(PropertyId, OrderNo, OrderDate, OrderTime, TableNo, Waiter, OrderType, Subtotal, Discount, 
	ServiceCharge, TaxType1, TaxVal1, TaxType2, TaxVal2, TaxType3, TaxVal3, TaxType4, TaxVal4, 
	PackingCharge, UserID, Outlet, starttime, endtime, ComputerName, discode, 
	ManagerUserID, DeliveryCharge, pax, DiscRemarks, ReservationNo, POSNo, IsBillDiscount, 
    MemberID, MemberName, ContactNo, CustomerName, DeliveryAddress1, DeliveryAddress2, Landmark, Remark,
	TDL, RoomID, RoomName, GuestProfileID, MealPlanID, MealEntitlement, AggregatorID, AggregatorPercentage,
	TravelAgentID, TravelAgentName, ComplimentaryID, HotelReservationNo, VoidUserID, VoidUserDate, VoidRemark,
	FiscalOrderNo, WaiterTipAmount, CustomerCode, LocalCurrencyRates, TourGuideCompaniesId, TourGuideId, TourGuidePer, TourGuideCompaniesPer, CustomerType,
	TaxRemoveRefCode, TaxRemoveRefName, FamilyMemberID, FamilyMemberName, MemberModulCode, ReservationRefNo)

 SELECT	@PropertyId,
		BillHeader.element.value('@OrderNo','VARCHAR(6)'), 
		CONVERT(DATETIME,BillHeader.element.value('@OrderDate','VARCHAR(30)'),103),
		CONVERT(DATETIME,BillHeader.element.value('@OrderTime','VARCHAR(30)'),103), 
		BillHeader.element.value('@TableNo','VARCHAR(10)'),  
		BillHeader.element.value('@Waiter','VARCHAR(8)'), 
		BillHeader.element.value('@OrderType','VARCHAR(1)'),  
		BillHeader.element.value('@Subtotal','MONEY'),  
		BillHeader.element.value('@Discount','MONEY'), 
		BillHeader.element.value('@ServiceCharge','MONEY'),
		BillHeader.element.value('@TaxType1','VARCHAR(6)'),  
		BillHeader.element.value('@TaxVal1','MONEY'), 
		BillHeader.element.value('@TaxType2','VARCHAR(6)'),  
		BillHeader.element.value('@TaxVal2','MONEY'),  
		BillHeader.element.value('@TaxType3','VARCHAR(6)'),  
		BillHeader.element.value('@TaxVal3','MONEY'),  
		BillHeader.element.value('@TaxType4','VARCHAR(6)'),  
		BillHeader.element.value('@TaxVal4','MONEY'),  
		BillHeader.element.value('@PackingCharge','MONEY'),  
		BillHeader.element.value('@UserID','VARCHAR(20)'),  
		BillHeader.element.value('@Outlet','VARCHAR(3)'),
		CONVERT(DATETIME,BillHeader.element.value('@starttime','VARCHAR(30)'),103), 
		CONVERT(DATETIME,BillHeader.element.value('@endtime','VARCHAR(30)'),103),  
		BillHeader.element.value('@ComputerName','VARCHAR(20)'),  
		BillHeader.element.value('@discode','VARCHAR(3)'),  
		BillHeader.element.value('@ManagerUserID','VARCHAR(20)'),  
		BillHeader.element.value('@DeliveryCharge','MONEY'),  
		BillHeader.element.value('@pax','MONEY'),  
		BillHeader.element.value('@DiscRemarks','VARCHAR(100)'),  
		BillHeader.element.value('@ReservationNo','INT'),  
		BillHeader.element.value('@POSNo','VARCHAR(5)'),  
		BillHeader.element.value('@IsBillDiscount','BIT'),  
		BillHeader.element.value('@MemberID','INT'),  
		BillHeader.element.value('@MemberName','VARCHAR(100)'),  
		BillHeader.element.value('@ContactNo','VARCHAR(15)'),  
		BillHeader.element.value('@CustomerName','VARCHAR(50)'),  
		BillHeader.element.value('@DeliveryAddress1','VARCHAR(50)'),  
		BillHeader.element.value('@DeliveryAddress2','VARCHAR(50)'), 
		BillHeader.element.value('@Landmark','VARCHAR(50)'), 
		BillHeader.element.value('@Remark','VARCHAR(200)'),
		BillHeader.element.value('@TDL','MONEY'),
		BillHeader.element.value('@RoomID','INT'), 
		BillHeader.element.value('@RoomName','VARCHAR(50)'), 
		BillHeader.element.value('@GuestProfileID','INT'), 
		BillHeader.element.value('@MealPlanID','INT'), 
		BillHeader.element.value('@MealEntitlement','VARCHAR(2)'), 
		BillHeader.element.value('@AggregatorID','INT'),
		BillHeader.element.value('@AggregatorPercentage','MONEY'),
		BillHeader.element.value('@TravelAgentID','INT'), 
		BillHeader.element.value('@TravelAgentName','VARCHAR(200)'), 
		BillHeader.element.value('@ComplimentaryID','INT'), 
		BillHeader.element.value('@HotelReservationNo','VARCHAR(10)'),
		BillHeader.element.value('@VoidUserID','VARCHAR(20)'), 
		CONVERT(DATETIME,BillHeader.element.value('@VoidUserDate','VARCHAR(30)'),103),   
		BillHeader.element.value('@VoidRemark','VARCHAR(250)'),
		BillHeader.element.value('@FiscalOrderNo','VARCHAR(100)'),
		BillHeader.element.value('@WaiterTipAmount','MONEY'),
		BillHeader.element.value('@CustomerCode','VARCHAR(20)'),
		BillHeader.element.value('@LocalCurrencyRates','NUMERIC(18,8)'),
		BillHeader.element.value('@TourGuideCompaniesID','INT'), 
		BillHeader.element.value('@TourGuideID','INT'),
		BillHeader.element.value('@TourGuidePer','NUMERIC(18,8)'),
		BillHeader.element.value('@TourGuideCompaniesPer','NUMERIC(18,8)'),
		BillHeader.element.value('@CustomerType','VARCHAR(10)'),
		BillHeader.element.value('@TaxRemoveRefCode','VARCHAR(50)'),
		BillHeader.element.value('@TaxRemoveRefName','VARCHAR(250)'), 
		BillHeader.element.value('@FamilyMemberID','INT'), 
		BillHeader.element.value('@FamilyMemberName','VARCHAR(250)'),
		BillHeader.element.value('@MemberModulCode','VARCHAR(20)'),
		BillHeader.element.value('@ReservationRefNo','VARCHAR(20)')
FROM	@tHeaderXml.nodes('/root/Header/BillHeader') AS BillHeader(element)    


INSERT INTO VoidBillTrans
	(PropertyId, OrderNo, OrderType, OrderDate, OrderTime, Category, MainMenuCode, Qty, Rate, DisCode, DisPerc, ItWiseDiscount, 
	UserID, Outlet, ItemSeq, RefItemCode, SortSeq, IsModifier, ActionID, IsCombo, IsActionable, ActualPrice, ResNetVal, IsInstruction,
	VoucherNo, ItemDisPer, ItemDisVal, BillDisPer, BillDisVal, StockLocation, IsIncludeChargeToPrice, ItemType, 
	DiscountRemark, DiscountAuthUser, DiscountAuthTime, ChargeHeaderID, ComplimentaryID, ComplimentaryRemark,BrandID)

SELECT	@PropertyId,
		BillTrans.element.value('@OrderNo','VARCHAR(6)'), 
		BillTrans.element.value('@OrderType','VARCHAR(1)'),
		CONVERT(DATETIME,BillTrans.element.value('@OrderDate','VARCHAR(30)'),103),
		CONVERT(DATETIME,BillTrans.element.value('@OrderTime','VARCHAR(30)'),103), 
		BillTrans.element.value('@Category','VARCHAR(4)'), 
		BillTrans.element.value('@MainMenuCode','VARCHAR(4)'),
		BillTrans.element.value('@Qty','MONEY'), 
		BillTrans.element.value('@Rate','MONEY'), 
		BillTrans.element.value('@DisCode','VARCHAR(10)'), 
		BillTrans.element.value('@DisPerc','MONEY'), 
		BillTrans.element.value('@ItWiseDiscount','MONEY'), 
		BillTrans.element.value('@UserID','VARCHAR(20)'), 
		BillTrans.element.value('@Outlet','VARCHAR(3)'), 
		BillTrans.element.value('@ItemSeq','INT'), 
		BillTrans.element.value('@RefItemCode','VARCHAR(6)'), 
		BillTrans.element.value('@SortSeq','INT'),
		BillTrans.element.value('@IsModifier','BIT'), 
		BillTrans.element.value('@ActionID','INT'), 
		BillTrans.element.value('@IsCombo','BIT'), 
		BillTrans.element.value('@IsActionable','BIT'), 
		BillTrans.element.value('@ActualPrice','MONEY'), 
		BillTrans.element.value('@ResNetVal','MONEY'),
		BillTrans.element.value('@IsInstruction','BIT'),
		BillTrans.element.value('@VoucherNo','BIGINT'),
		BillTrans.element.value('@ItemDisPer','NUMERIC(18,10)'),
		BillTrans.element.value('@ItemDisVal','NUMERIC(18,10)'),
		BillTrans.element.value('@BillDisPer','NUMERIC(18,10)'),
		BillTrans.element.value('@BillDisVal','NUMERIC(18,10)'),
		BillTrans.element.value('@StockLocation','VARCHAR(10)'),
		BillTrans.element.value('@IsIncludeChargeToPrice','BIT'),
		BillTrans.element.value('@ItemType','VARCHAR(1)'),
		BillTrans.element.value('@DiscountRemark','VARCHAR(50)'),
		BillTrans.element.value('@DiscountAuthUser','VARCHAR(50)'),
		CONVERT(VARCHAR(50),BillTrans.element.value('@DiscountAuthTime','VARCHAR(30)'),103),  
		BillTrans.element.value('@ChargeHeaderID','INT'), 
		BillTrans.element.value('@ComplimentaryID','INT'),  
		BillTrans.element.value('@ComplimentaryRemark','VARCHAR(200)'),
		BillTrans.element.value('@BrandID','INT')
FROM	@tDetailXml.nodes('/root/Details/BillTrans') AS BillTrans(element)   

INSERT INTO VoidPayTrans
	(PropertyId, OrderNo, OrderDate, PayCode, Total, Tendered, ActualAmt, Remark, UserID,
	OrderTime, Outlet, ShiftID, RoundingDifference)

SELECT	@PropertyId,
		PayTrans.element.value('@OrderNo','VARCHAR(6)'),
		CONVERT(DATETIME,PayTrans.element.value('@OrderDate','VARCHAR(30)'),103),
		PayTrans.element.value('@PayCode','VARCHAR(6)'),
		PayTrans.element.value('@Total','MONEY'), 
		PayTrans.element.value('@Tendered','MONEY'), 
		PayTrans.element.value('@ActualAmt','MONEY'), 
		PayTrans.element.value('@Remark','VARCHAR(30)'), 
		PayTrans.element.value('@UserID','VARCHAR(20)'),
		CONVERT(DATETIME,PayTrans.element.value('@OrderTime','VARCHAR(30)'),103),
		PayTrans.element.value('@Outlet','VARCHAR(3)'), 
		PayTrans.element.value('@ShiftID','INT'), 
		PayTrans.element.value('@RoundingDifference','MONEY')
FROM	@tPaymentXml.nodes('/root/Payment/PayTrans') AS PayTrans(element)  


INSERT INTO POS_KotBot
		(PropertyId, KotBotNo, KotBotDateTime, OrderNo, OrderDate, OrderType, TableID, WaiterID, OutletID, PrinterCode, 
		MenuItemID, KOTName, KOTQuantity, VoidQuantity, ItemSequence, SortSeq, IsVoid, VoidDateTime, 
        AuthorizedUser, SysDate, IsServe, ServeTime)

SELECT	@PropertyId,
		KotBot.element.value('@KotBotNo','VARCHAR(10)'), 
		CONVERT(DATETIME,KotBot.element.value('@KotBotDateTime','VARCHAR(30)'),103),
		KotBot.element.value('@OrderNo','VARCHAR(10)'), 
		CONVERT(DATETIME,KotBot.element.value('@OrderDate','VARCHAR(30)'),103),
		KotBot.element.value('@OrderType','VARCHAR(1)'), 
		KotBot.element.value('@TableID','INT'), 
		KotBot.element.value('@WaiterID','VARCHAR(10)'), 
		KotBot.element.value('@OutletID','VARCHAR(10)'), 
		KotBot.element.value('@PrinterCode','VARCHAR(2)'), 
		KotBot.element.value('@MenuItemID','VARCHAR(10)'), 
		KotBot.element.value('@KOTName','VARCHAR(250)'), 
		KotBot.element.value('@KOTQuantity','MONEY'), 
		KotBot.element.value('@VoidQuantity','MONEY'), 
		KotBot.element.value('@ItemSequence','INT'), 
		KotBot.element.value('@SortSeq','INT'), 
		KotBot.element.value('@IsVoid','BIT'), 
		CONVERT(DATETIME,KotBot.element.value('@VoidDateTime','VARCHAR(30)'),103),
		KotBot.element.value('@AuthorizedUser','VARCHAR(20)'), 
		CONVERT(DATETIME,KotBot.element.value('@SysDate','VARCHAR(30)'),103),
		KotBot.element.value('@IsServe','BIT'), 
		CONVERT(DATETIME,KotBot.element.value('@ServeTime','VARCHAR(30)'),103)
FROM	@tKottXmlXml.nodes('/root/KotBot/KotBot') AS KotBot(element)


INSERT INTO VoidPayTransCurrency
		(PropertyId, Outlet, OrderNo, OrderDate, OrderType, PayType, CurrCode, ConversionRate, CurrAmount, TotalAmount, ActualAmount, LocalCurr, LocalCurrRate, ShiftID)
SELECT	@PropertyId,
		PaymentCurrency.element.value('@Outlet','VARCHAR(5)'),
		PaymentCurrency.element.value('@OrderNo','VARCHAR(10)'),
		CONVERT(VARCHAR(50),PaymentCurrency.element.value('@OrderDate','VARCHAR(30)'),103),
		PaymentCurrency.element.value('@OrderType','VARCHAR(2)'), 
		PaymentCurrency.element.value('@PayType','VARCHAR(5)'), 
		PaymentCurrency.element.value('@CurrCode','VARCHAR(3)'), 
		PaymentCurrency.element.value('@ConversionRate','MONEY'), 
		PaymentCurrency.element.value('@CurrAmount','MONEY'), 
		PaymentCurrency.element.value('@TotalAmount','MONEY'), 
		PaymentCurrency.element.value('@ActualAmount','MONEY'), 
		PaymentCurrency.element.value('@LocalCurr','VARCHAR(5)'), 
		PaymentCurrency.element.value('@LocalCurrRate','MONEY'), 
		PaymentCurrency.element.value('@ShiftID','BIGINT')
FROM	@tPaymentCurrencyXml.nodes('/root/Payment/PayTransCurrency') AS PaymentCurrency(element)

GO

