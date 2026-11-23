

CREATE PROCEDURE [dbo].[Sync_spInsertBills]
@PropertyId INT,
@OrderNo VARCHAR(10),
@OrderDate DATETIME,
@Outlet VARCHAR(3),
@HeaderXml VARCHAR(MAX),
@DetailXml VARCHAR(MAX),
@PaymentXml VARCHAR(MAX),
@KotXml VARCHAR(MAX),
@ChargeXml VARCHAR(MAX),
@OpenMenusXml VARCHAR(MAX),
@CustomerDetailsXml VARCHAR(MAX),
@EBillOrderXml VARCHAR(MAX),
@PaymentCurrencyXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tHeaderXml XML, @tDetailXml XML, @tPaymentXml XML, @tKottXmlXml XML, @tChargeXml XML, @tOpenMenu XML, @tCustomerDetailsXml XML, @tEBillOrderXml XML, @tPaymentCurrencyXml XML

INSERT INTO XmlTemp(sXmlH, sXmlD, sXmlP)VALUES(@HeaderXml,@DetailXml,@PaymentXml)

SET @tHeaderXml = REPLACE(@HeaderXml,'encoding="utf-8"','encoding="ISO-8859-9"') 
SET @tDetailXml = @DetailXml
SET @tPaymentXml = @PaymentXml
SET @tKottXmlXml = REPLACE(@KotXml,'encoding="utf-8"','encoding="ISO-8859-9"')
SET @tChargeXml = @ChargeXml
SET @tOpenMenu = REPLACE(@OpenMenusXml,'encoding="utf-8"','encoding="ISO-8859-9"') 
SET @tCustomerDetailsXml = REPLACE(@CustomerDetailsXml,'encoding="utf-8"','encoding="ISO-8859-9"')
SET @tEBillOrderXml = REPLACE(@EBillOrderXml,'encoding="utf-8"','encoding="ISO-8859-9"')
SET @tPaymentCurrencyXml = @PaymentCurrencyXml
BEGIN TRY
	BEGIN TRAN
		DELETE FROM BillHeader WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM BillTrans WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM PayTrans WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM POS_KotBot WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND OutletID = @Outlet AND PropertyId = @PropertyId
		DELETE FROM POS_BillChargeDetail WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM POS_BillOpenMenu WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet AND PropertyId = @PropertyId
		DELETE FROM POS_EBillOrder WHERE OrderNo = @OrderNo AND OrderDate = @OrderDate AND Outlet = @Outlet AND PropertyId = @PropertyId

		INSERT INTO BillHeader
			(PropertyId, OrderNo, OrderDate, OrderTime, TableNo, Waiter, OrderType, Subtotal, Discount, 
			ServiceCharge, TaxType1, TaxVal1, TaxType2, TaxVal2, TaxType3, TaxVal3, TaxType4, TaxVal4, 
			PackingCharge, UserID, Outlet, starttime, endtime, ComputerName, discode, 
			ManagerUserID, DeliveryCharge, pax, DiscRemarks, ReservationNo, POSNo, IsBillDiscount, 
			MemberID, MemberName, ContactNo, CustomerName, DeliveryAddress1, DeliveryAddress2, Landmark, Remark,
			TDL, RoomID, RoomName, GuestProfileID, MealPlanID, MealPlanName, MealEntitlement, AggregatorID, AggregatorPercentage,
			TravelAgentID, TravelAgentName, ComplimentaryID, HotelReservationNo, GuestProfileName, RoomPostingDocNo, RiderID, ComplimentaryRemark,
			FiscalOrderNo, WaiterTipAmount, CustomerCode, LocalCurrencyRates, TourGuideCompaniesId, TourGuideId, TourGuidePer, TourGuideCompaniesPer, CustomerType,
			TaxRemoveRefCode, TaxRemoveRefName, FamilyMemberID, FamilyMemberName, MemberModulCode, ReservationRefNo, OutsideOrderNo, SpecialOrderID, SpecialOrderNo,
			IsBump, OrderBumpTime)

		 SELECT	@PropertyId,
				BillHeader.element.value('@OrderNo','VARCHAR(6)'), 
				CONVERT(VARCHAR(50),BillHeader.element.value('@OrderDate','VARCHAR(30)'),103),
				CONVERT(VARCHAR(50),BillHeader.element.value('@OrderTime','VARCHAR(30)'),103), 
				BillHeader.element.value('@TableNo','VARCHAR(10)'),  
				BillHeader.element.value('@Waiter','VARCHAR(8)'), 
				BillHeader.element.value('@OrderType','VARCHAR(1)'),  
				BillHeader.element.value('@Subtotal','NUMERIC(18,8)'),  
				BillHeader.element.value('@Discount','NUMERIC(18,8)'), 
				BillHeader.element.value('@ServiceCharge','NUMERIC(18,8)'),
				BillHeader.element.value('@TaxType1','VARCHAR(6)'),  
				BillHeader.element.value('@TaxVal1','NUMERIC(18,8)'), 
				BillHeader.element.value('@TaxType2','VARCHAR(6)'),  
				BillHeader.element.value('@TaxVal2','NUMERIC(18,8)'),  
				BillHeader.element.value('@TaxType3','VARCHAR(6)'),  
				BillHeader.element.value('@TaxVal3','NUMERIC(18,8)'),  
				BillHeader.element.value('@TaxType4','VARCHAR(6)'),  
				BillHeader.element.value('@TaxVal4','NUMERIC(18,8)'),  
				BillHeader.element.value('@PackingCharge','NUMERIC(18,8)'),  
				BillHeader.element.value('@UserID','VARCHAR(20)'),  
				BillHeader.element.value('@Outlet','VARCHAR(3)'),
				CONVERT(VARCHAR(50),BillHeader.element.value('@starttime','VARCHAR(30)'),103), 
				CONVERT(VARCHAR(50),BillHeader.element.value('@endtime','VARCHAR(30)'),103),  
				BillHeader.element.value('@ComputerName','VARCHAR(20)'),  
				BillHeader.element.value('@discode','VARCHAR(3)'),  
				BillHeader.element.value('@ManagerUserID','VARCHAR(20)'),  
				BillHeader.element.value('@DeliveryCharge','NUMERIC(18,8)'),  
				BillHeader.element.value('@pax','MONEY'),  
				BillHeader.element.value('@DiscRemarks','VARCHAR(100)'),  
				BillHeader.element.value('@ReservationNo','INT'),  
				BillHeader.element.value('@POSNo','VARCHAR(5)'),  
				BillHeader.element.value('@IsBillDiscount','BIT'),  
				BillHeader.element.value('@MemberID','INT'),  
				BillHeader.element.value('@MemberName','VARCHAR(100)'),  
				BillHeader.element.value('@ContactNo','VARCHAR(15)'),  
				BillHeader.element.value('@CustomerName','VARCHAR(200)'),  
				BillHeader.element.value('@DeliveryAddress1','VARCHAR(50)'),  
				BillHeader.element.value('@DeliveryAddress2','VARCHAR(50)'), 
				BillHeader.element.value('@Landmark','VARCHAR(50)'), 
				BillHeader.element.value('@Remark','VARCHAR(200)'),
				BillHeader.element.value('@TDL','NUMERIC(18,8)'),
				BillHeader.element.value('@RoomID','INT'), 
				BillHeader.element.value('@RoomName','VARCHAR(50)'), 
				BillHeader.element.value('@GuestProfileID','INT'), 
				BillHeader.element.value('@MealPlanID','INT'), 
				BillHeader.element.value('@MealPlanName','VARCHAR(200)'), 
				BillHeader.element.value('@MealEntitlement','VARCHAR(2)'), 
				BillHeader.element.value('@AggregatorID','INT'),
				BillHeader.element.value('@AggregatorPercentage','NUMERIC(18,8)'),
				BillHeader.element.value('@TravelAgentID','INT'), 
				BillHeader.element.value('@TravelAgentName','VARCHAR(200)'), 
				BillHeader.element.value('@ComplimentaryID','INT'), 
				BillHeader.element.value('@HotelReservationNo','VARCHAR(10)'),
				BillHeader.element.value('@GuestProfileName','VARCHAR(500)'),
				BillHeader.element.value('@RoomPostingDocNo','VARCHAR(500)'),
				BillHeader.element.value('@RiderID','INT'),
				BillHeader.element.value('@ComplimentaryRemark','VARCHAR(100)'),
				BillHeader.element.value('@FiscalOrderNo','VARCHAR(100)'),
				BillHeader.element.value('@WaiterTipAmount','NUMERIC(18,8)'),
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
				BillHeader.element.value('@ReservationRefNo','VARCHAR(20)'),
				BillHeader.element.value('@OutsideOrderNo','VARCHAR(20)'),
				BillHeader.element.value('@SpecialOrderID','INT'),
				BillHeader.element.value('@SpecialOrderNo','VARCHAR(50)'),
				BillHeader.element.value('@IsBump','BIT'),
				CONVERT(VARCHAR(50),BillHeader.element.value('@OrderBumpTime','VARCHAR(30)'),103)
		FROM	@tHeaderXml.nodes('/root/Header/BillHeader') AS BillHeader(element)    


		INSERT INTO BillTrans
			(PropertyId, OrderNo, OrderType, OrderDate, OrderTime, Category, MainMenuCode, Qty, Rate, DisCode, DisPerc, ItWiseDiscount, 
			UserID, Outlet, ItemSeq, RefItemCode, SortSeq, IsModifier, ActionID, IsCombo, IsActionable, ActualPrice, ResNetVal, IsInstruction,
			VoucherNo, ItemDisPer, ItemDisVal, BillDisPer, BillDisVal, StockLocation, IsIncludeChargeToPrice, ItemType, 
			DiscountRemark, DiscountAuthUser, DiscountAuthTime, ChargeHeaderID, ComplimentaryID, ComplimentaryRemark,BrandID)
		SELECT	@PropertyId,
				BillTrans.element.value('@OrderNo','VARCHAR(6)'), 
				BillTrans.element.value('@OrderType','VARCHAR(1)'),
				CONVERT(VARCHAR(50),BillTrans.element.value('@OrderDate','VARCHAR(30)'),103),
				CONVERT(VARCHAR(50),BillTrans.element.value('@OrderTime','VARCHAR(30)'),103), 
				BillTrans.element.value('@Category','VARCHAR(4)'), 
				BillTrans.element.value('@MainMenuCode','VARCHAR(4)'),
				BillTrans.element.value('@Qty','NUMERIC(18,8)'), 
				BillTrans.element.value('@Rate','NUMERIC(18,8)'), 
				BillTrans.element.value('@DisCode','VARCHAR(10)'), 
				BillTrans.element.value('@DisPerc','NUMERIC(18,8)'), 
				BillTrans.element.value('@ItWiseDiscount','NUMERIC(18,8)'), 
				BillTrans.element.value('@UserID','VARCHAR(20)'), 
				BillTrans.element.value('@Outlet','VARCHAR(3)'), 
				BillTrans.element.value('@ItemSeq','INT'), 
				BillTrans.element.value('@RefItemCode','VARCHAR(6)'), 
				BillTrans.element.value('@SortSeq','INT'),
				BillTrans.element.value('@IsModifier','BIT'), 
				BillTrans.element.value('@ActionID','INT'), 
				BillTrans.element.value('@IsCombo','BIT'), 
				BillTrans.element.value('@IsActionable','BIT'), 
				BillTrans.element.value('@ActualPrice','NUMERIC(18,8)'), 
				BillTrans.element.value('@ResNetVal','NUMERIC(18,8)'),
				BillTrans.element.value('@IsInstruction','BIT'),
				BillTrans.element.value('@VoucherNo','BIGINT'),
				BillTrans.element.value('@ItemDisPer','NUMERIC(18,8)'),
				BillTrans.element.value('@ItemDisVal','NUMERIC(18,8)'),
				BillTrans.element.value('@BillDisPer','NUMERIC(18,8)'),
				BillTrans.element.value('@BillDisVal','NUMERIC(18,8)'),
				BillTrans.element.value('@StockLocation','VARCHAR(10)'),
				BillTrans.element.value('@IsIncludeChargeToPrice','BIT'),
				BillTrans.element.value('@ItemType','VARCHAR(1)'),
				BillTrans.element.value('@DiscountRemark','VARCHAR(200)'),
				BillTrans.element.value('@DiscountAuthUser','VARCHAR(50)'),
				CONVERT(VARCHAR(50),BillTrans.element.value('@DiscountAuthTime','VARCHAR(30)'),103),  
				BillTrans.element.value('@ChargeHeaderID','INT'), 
				BillTrans.element.value('@ComplimentaryID','INT'),  
				BillTrans.element.value('@ComplimentaryRemark','VARCHAR(200)'),
				BillTrans.element.value('@BrandID','INT')
		FROM	@tDetailXml.nodes('/root/Details/BillTrans') AS BillTrans(element)   

		INSERT INTO PayTrans
			(PropertyId, OrderNo, OrderDate, PayCode, Total, Tendered, ActualAmt, Remark, UserID,
			OrderTime, Outlet, ShiftID, RoundingDifference)

		SELECT	@PropertyId,
				PayTrans.element.value('@OrderNo','VARCHAR(6)'),
				CONVERT(VARCHAR(50),PayTrans.element.value('@OrderDate','VARCHAR(30)'),103),
				PayTrans.element.value('@PayCode','VARCHAR(6)'),
				PayTrans.element.value('@Total','NUMERIC(18,8)'), 
				PayTrans.element.value('@Tendered','NUMERIC(18,8)'), 
				PayTrans.element.value('@ActualAmt','NUMERIC(18,8)'), 
				PayTrans.element.value('@Remark','VARCHAR(30)'), 
				PayTrans.element.value('@UserID','VARCHAR(20)'),
				CONVERT(VARCHAR(50),PayTrans.element.value('@OrderTime','VARCHAR(30)'),103),
				PayTrans.element.value('@Outlet','VARCHAR(3)'), 
				PayTrans.element.value('@ShiftID','INT'), 
				PayTrans.element.value('@RoundingDifference','NUMERIC(18,8)')
		FROM	@tPaymentXml.nodes('/root/Payment/PayTrans') AS PayTrans(element)  


		INSERT INTO POS_KotBot
				(PropertyId, KotBotNo, KotBotDateTime, OrderNo, OrderDate, OrderType, TableID, WaiterID, OutletID, PrinterCode, 
				MenuItemID, KOTName, KOTQuantity, VoidQuantity, ItemSequence, SortSeq, IsVoid, VoidDateTime, 
				AuthorizedUser, SysDate, IsServe, ServeTime)

		SELECT	@PropertyId,
				KotBot.element.value('@KotBotNo','VARCHAR(10)'), 
				CONVERT(VARCHAR(50),KotBot.element.value('@KotBotDateTime','VARCHAR(30)'),103),
				KotBot.element.value('@OrderNo','VARCHAR(10)'), 
				CONVERT(VARCHAR(50),KotBot.element.value('@OrderDate','VARCHAR(30)'),103),
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
				CONVERT(VARCHAR(50),KotBot.element.value('@VoidDateTime','VARCHAR(30)'),103),
				KotBot.element.value('@AuthorizedUser','VARCHAR(20)'), 
				CONVERT(VARCHAR(50),KotBot.element.value('@SysDate','VARCHAR(30)'),13),
				KotBot.element.value('@IsServe','BIT'), 
				CONVERT(VARCHAR(50),KotBot.element.value('@ServeTime','VARCHAR(30)'),103)
		FROM	@tKottXmlXml.nodes('/root/KotBot/KotBot') AS KotBot(element)

		------------------------------------------------------------------------------------------------------------------------
		INSERT INTO POS_BillChargeDetail
				(PropertyId, BillChargeDetailID, OrderNo, OrderDate, Outlet, MenuItemID, RefItemID, ItemSequence, SortSeq, 
				ChargeHeaderID, ChargeTypeID, ChargeTypeSequence, ActualPercentage, ChargeAmount)

		SELECT	@PropertyId,
				Charge.element.value('@BillChargeDetailID','INT'), 
				Charge.element.value('@OrderNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),Charge.element.value('@OrderDate','VARCHAR(30)'),103),
				Charge.element.value('@Outlet','VARCHAR(10)'), 
				Charge.element.value('@MenuItemID','VARCHAR(10)'), 
				Charge.element.value('@RefItemID','VARCHAR(10)'),
				Charge.element.value('@ItemSequence','INT'), 
				Charge.element.value('@SortSeq','INT'), 
				Charge.element.value('@ChargeHeaderID','INT'),
				Charge.element.value('@ChargeTypeID','INT'),
				Charge.element.value('@ChargeTypeSequence','INT'),
				Charge.element.value('@ActualPercentage','NUMERIC(18,8)'), 
				Charge.element.value('@ChargeAmount','NUMERIC(18,8)')
		FROM	@tChargeXml.nodes('/root/Charges/ChargeDetail') AS Charge(element)



		INSERT INTO POS_BillOpenMenu
			(PropertyId, OrderNo, OrderDate, Outlet, MenuItemID, MenuName, Rate, Quantity, ItemSequence, SortSeq)
		SELECT	@PropertyId,
				OpenMenu.element.value('@OrderNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),OpenMenu.element.value('@OrderDate','VARCHAR(30)'),103),
				OpenMenu.element.value('@Outlet','VARCHAR(10)'), 
				OpenMenu.element.value('@MenuItemID','VARCHAR(10)'), 
				OpenMenu.element.value('@MenuName','VARCHAR(50)'),
				OpenMenu.element.value('@Rate','NUMERIC(18,8)'), 
				OpenMenu.element.value('@Quantity','NUMERIC(18,8)'), 
				OpenMenu.element.value('@ItemSequence','INT'), 
				OpenMenu.element.value('@SortSeq','INT')	
		FROM	@tOpenMenu.nodes('/root/OpenMenus/OpenMenuItems') AS OpenMenu(element)


		INSERT INTO POS_CustomerDetails
				(PropertyId, OrderNo, TempOrderNo, OrderDate, Outlet, CustomerName, ContactNo, SysDate, CustomerID, LoyaltyCusID, AccountIdAward, AccountIdLoyalty, AvailablePoints, IssuedLoyaltyPoints)
		SELECT	@PropertyId,
				CustomerDetails.element.value('@OrderNo','VARCHAR(10)'),
				CustomerDetails.element.value('@TempOrderNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),CustomerDetails.element.value('@OrderDate','VARCHAR(30)'),103),
				CustomerDetails.element.value('@Outlet','VARCHAR(10)'), 
				CustomerDetails.element.value('@CustomerName','VARCHAR(250)'), 
				CustomerDetails.element.value('@ContactNo','VARCHAR(250)'),
				CONVERT(VARCHAR(50),CustomerDetails.element.value('@SysDate','VARCHAR(30)'),103),
				CustomerDetails.element.value('@CustomerID','VARCHAR(50)'),
				CustomerDetails.element.value('@LoyaltyCusID','VARCHAR(50)'),
				CustomerDetails.element.value('@AccountIdAward','VARCHAR(50)'),
				CustomerDetails.element.value('@AccountIdLoyalty','VARCHAR(50)'),
				CustomerDetails.element.value('@AvailablePoints','NUMERIC(18,8)'), 
				CustomerDetails.element.value('@IssuedLoyaltyPoints','NUMERIC(18,8)')
		FROM	@tCustomerDetailsXml.nodes('/root/Customer/Details') AS CustomerDetails(element)



		INSERT INTO POS_EBillOrder
				(PropertyId, OrderNo, OrderDate, Outlet, EmailAddress, EmailAddressDisplayName)
		SELECT	@PropertyId,
				EBillOrders.element.value('@OrderNo','VARCHAR(10)'),
				CONVERT(VARCHAR(50),EBillOrders.element.value('@OrderDate','VARCHAR(30)'),103),
				EBillOrders.element.value('@Outlet','VARCHAR(10)'), 
				EBillOrders.element.value('@EmailAddress','VARCHAR(500)'), 
				EBillOrders.element.value('@EmailAddress','VARCHAR(500)')
		FROM	@tEBillOrderXml.nodes('/root/EBill/EBillOrders') AS EBillOrders(element)


		INSERT INTO PayTransCurrency
			(PropertyId, Outlet, OrderNo, OrderDate, OrderType, PayType, CurrCode, ConversionRate, CurrAmount, TotalAmount, ActualAmount, LocalCurr, LocalCurrRate, ShiftID)
		SELECT	@PropertyId,
				PayTransCurrency.element.value('@Outlet','VARCHAR(5)'), 
				PayTransCurrency.element.value('@OrderNo','VARCHAR(10)'), 
				CONVERT(VARCHAR(50),PayTransCurrency.element.value('@OrderDate','VARCHAR(30)'),103),
				PayTransCurrency.element.value('@OrderType','VARCHAR(2)'), 
				PayTransCurrency.element.value('@PayType','VARCHAR(5)'),
				PayTransCurrency.element.value('@CurrCode','VARCHAR(5)'), 
				PayTransCurrency.element.value('@ConversionRate','NUMERIC(18,8)'), 
				PayTransCurrency.element.value('@CurrAmount','NUMERIC(18,8)'), 
				PayTransCurrency.element.value('@TotalAmount','NUMERIC(18,8)'), 
				PayTransCurrency.element.value('@ActualAmount','NUMERIC(18,8)'), 
				PayTransCurrency.element.value('@LocalCurr','VARCHAR(5)'), 
				PayTransCurrency.element.value('@LocalCurrRate','NUMERIC(18,8)'), 
				PayTransCurrency.element.value('@ShiftID','BIGINT')
		FROM	@tPaymentCurrencyXml.nodes('/root/Payment/PayTransCurrency') AS PayTransCurrency(element)
                  
		UPDATE	BT SET BT.ItemCost = MM.costprice
		FROM	BillTrans BT INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
		WHERE	BT.PropertyId = @PropertyId AND BT.OrderNo = @OrderNo AND BT.OrderDate = @OrderDate AND BT.Outlet = @Outlet
        
		IF EXISTS(SELECT IsHOBreakTax FROM Location_Ref WHERE IsHOBreakTax = 1)
			BEGIN
				EXEC Sync_spInsertBillChargeDetail @PropertyId, @OrderNo, @OrderDate, @Outlet
			END


		--Update Rounding differance---------------------------------------------------------------------------------
		DECLARE @HeaderAmt NUMERIC(18,8),@PaymentAmt NUMERIC(18,8), @PayCode VARCHAR(5)
		SELECT	@HeaderAmt = ISNULL(SUM(Subtotal + ServiceCharge + TaxVal1 + TaxVal2 + TaxVal3 + TaxVal4),0) 
		FROM	BillHeader
		WHERE	PropertyId = @PropertyId AND OrderNo = @OrderNo AND Outlet = @Outlet AND OrderDate = @OrderDate 

		SELECT	@PaymentAmt = ISNULL(SUM(ActualAmt) ,0) 
		FROM	PayTrans
		WHERE	PropertyId = @PropertyId AND OrderNo = @OrderNo AND Outlet = @Outlet AND OrderDate = @OrderDate 

		IF(@HeaderAmt != @PaymentAmt)
		BEGIN
			IF ABS(@HeaderAmt - @PaymentAmt) < 1
				BEGIN
					SET @PayCode = (SELECT TOP(1) PayCode FROM PayTrans WHERE PropertyId = @PropertyId AND OrderNo = @OrderNo AND Outlet = @Outlet AND OrderDate = @OrderDate ORDER BY PayCode)
					UPDATE TOP(1) PayTrans SET ActualAmt = ActualAmt + (@HeaderAmt - @PaymentAmt), RoundingDifference = (@HeaderAmt - @PaymentAmt) WHERE PropertyId = @PropertyId AND OrderNo = @OrderNo AND Outlet = @Outlet AND OrderDate = @OrderDate AND PayCode = @PayCode
				END
		END
		----------------------------------------------------------------------------------------------------------

	COMMIT TRAN 
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	DECLARE @Msg NVARCHAR(200)
	SET @Msg = ERROR_MESSAGE()
	INSERT INTO POS_DatabaseErrorLog (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)	
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),@Msg)
	RAISERROR(@Msg,16,1)
END CATCH

GO

