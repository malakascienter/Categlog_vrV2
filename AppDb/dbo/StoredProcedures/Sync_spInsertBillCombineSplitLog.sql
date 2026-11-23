
CREATE PROCEDURE [dbo].[Sync_spInsertBillCombineSplitLog]
@PropertyId INT,
@CombineSplitLogXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tCombineSplitLogXml XML

SET @CombineSplitLogXml = REPLACE(@CombineSplitLogXml,'encoding="utf-8"','encoding="ISO-8859-9"') 
SET @tCombineSplitLogXml = @CombineSplitLogXml


BEGIN TRY
	BEGIN TRAN

		DELETE FROM POS_BillCombineSplitLog WHERE PropertyId = @PropertyId AND ID IN (SELECT CombineSplitLog.element.value('@ID','BIGINT') FROM @tCombineSplitLogXml.nodes('/root/Bill/CombineSplitLog') AS CombineSplitLog(element))

		INSERT INTO POS_BillCombineSplitLog
				(PropertyId, ID, NewOrderNo, NewOrderDateTime, IsCombined, OrderNo, WaiterID, CustomerID, IsBillPrinted, OrderDateTime, OutletID, BaseCurrency, ConvRate, MenuItemID, RefItemID, Category, Name, KOTName, 
                AppOnInvoice, Quantity, Rate, IsComplimentary, IsModifier, PrinterID, ItemSequence, SortSeq, Remarks, ChargeHeaderID, ChargeAmount, ResNetVal, IsIncludeChargeToPrice, IsBillDiscount, DiscountID, ItemDisPer, ItemDisVal, 
                BillDisPer, BillDisVal, DiscountRemark, StationID, CreateUserID, SwapMenuID, ActionID, SubRefItemID, IsCombo, ShiftID, IsNewItems, IsDiscount, IsActionable, ActualPrice, TableID, OrderType, ServiceCharge, TaxAmount1, 
                TaxAmount2, TaxAmount3, TaxAmount4, PrinterCode, KOTQuantity, IsKOTPrint, IsCloseTable)
            
		SELECT	@PropertyId,
				CombineSplitLog.element.value('@ID','BIGINT'),
				CombineSplitLog.element.value('@NewOrderNo','VARCHAR(10)'),
				CONVERT(DATETIME,CombineSplitLog.element.value('@NewOrderDateTime','VARCHAR(30)'),103),
				CombineSplitLog.element.value('@IsCombined','BIT'),
				CombineSplitLog.element.value('@OrderNo','VARCHAR(10)'),
				CombineSplitLog.element.value('@WaiterID','VARCHAR(10)'),
				CombineSplitLog.element.value('@CustomerID','INT'),
				CombineSplitLog.element.value('@IsBillPrinted','BIT'),
				CONVERT(DATETIME,CombineSplitLog.element.value('@OrderDateTime','VARCHAR(30)'),103),
				CombineSplitLog.element.value('@OutletID','VARCHAR(10)'),
				CombineSplitLog.element.value('@BaseCurrency','VARCHAR(3)'),
				CombineSplitLog.element.value('@ConvRate','NUMERIC'),
				CombineSplitLog.element.value('@MenuItemID','VARCHAR(10)'),
				CombineSplitLog.element.value('@RefItemID','VARCHAR(10)'),
				CombineSplitLog.element.value('@Category','VARCHAR(3)'),
				CombineSplitLog.element.value('@Name','VARCHAR(250)'),
				CombineSplitLog.element.value('@KOTName','VARCHAR(250)'),
				CombineSplitLog.element.value('@AppOnInvoice','VARCHAR(250)'),
				CombineSplitLog.element.value('@Quantity','NUMERIC'),
				CombineSplitLog.element.value('@Rate','NUMERIC'),
				CombineSplitLog.element.value('@IsComplimentary','BIT'),
				CombineSplitLog.element.value('@IsModifier','BIT'),
				CombineSplitLog.element.value('@PrinterID','INT'),
				CombineSplitLog.element.value('@ItemSequence','INT'),
				CombineSplitLog.element.value('@SortSeq','INT'),
				CombineSplitLog.element.value('@Remarks','VARCHAR(500)'),
				CombineSplitLog.element.value('@ChargeHeaderID','VARCHAR(20)'),
				CombineSplitLog.element.value('@ChargeAmount','NUMERIC'),
				CombineSplitLog.element.value('@ResNetVal','NUMERIC'),
				CombineSplitLog.element.value('@IsIncludeChargeToPrice','BIT'),
				CombineSplitLog.element.value('@IsBillDiscount','BIT'),
				CombineSplitLog.element.value('@DiscountID','VARCHAR(10)'),
				CombineSplitLog.element.value('@ItemDisPer','NUMERIC'),
				CombineSplitLog.element.value('@ItemDisVal','NUMERIC'),
				CombineSplitLog.element.value('@BillDisPer','NUMERIC'),
				CombineSplitLog.element.value('@BillDisVal','NUMERIC'),
				CombineSplitLog.element.value('@DiscountRemark','VARCHAR(50)'),
				CombineSplitLog.element.value('@StationID','VARCHAR(50)'),
				CombineSplitLog.element.value('@CreateUserID','VARCHAR(20)'),
				CombineSplitLog.element.value('@SwapMenuID','VARCHAR(10)'),
				CombineSplitLog.element.value('@ActionID','INT'),
				CombineSplitLog.element.value('@SubRefItemID','VARCHAR(10)'),
				CombineSplitLog.element.value('@IsCombo','BIT'),
				CombineSplitLog.element.value('@ShiftID','BIGINT'),
				CombineSplitLog.element.value('@IsNewItems','BIT'),
				CombineSplitLog.element.value('@IsDiscount','BIT'),
				CombineSplitLog.element.value('@IsActionable','BIT'),
				CombineSplitLog.element.value('@ActualPrice','NUMERIC'),
				CombineSplitLog.element.value('@TableID','INT'),
				CombineSplitLog.element.value('@OrderType','VARCHAR(1)'),
				CombineSplitLog.element.value('@ServiceCharge','NUMERIC'),
				CombineSplitLog.element.value('@TaxAmount1','NUMERIC'),
				CombineSplitLog.element.value('@TaxAmount2','NUMERIC'),
				CombineSplitLog.element.value('@TaxAmount3','NUMERIC'),
				CombineSplitLog.element.value('@TaxAmount4','NUMERIC'),
				CombineSplitLog.element.value('@PrinterCode','VARCHAR(2)'),
				CombineSplitLog.element.value('@KOTQuantity','NUMERIC'),
				CombineSplitLog.element.value('@IsKOTPrint','BIT'),
				CombineSplitLog.element.value('@IsCloseTable','BIT')
		FROM	@tCombineSplitLogXml.nodes('/root/Bill/CombineSplitLog') AS CombineSplitLog(element)

		



	COMMIT TRAN 
END TRY

BEGIN CATCH
	ROLLBACK TRAN
END CATCH

GO

