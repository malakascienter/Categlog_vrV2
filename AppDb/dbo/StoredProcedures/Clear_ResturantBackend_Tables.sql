
-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Delete ot truncate tables from Catelogvr2
-- =============================================
--Clear_ResturantBackend_Tables 'T'
--Clear_ResturantBackend_Tables 'D','1'
CREATE PROCEDURE Clear_ResturantBackend_Tables
	@DeleteType  VARCHAR(1),
	@PropertyId INT =0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF(@DeleteType='T')
	BEGIN
		truncate table [dbo].[Category]
		truncate table [dbo].[Category_History]
		truncate table [dbo].[ItemCategory]
		truncate table [dbo].[ItemCategory_History]
		truncate table [dbo].[POSKDSCategory]
		truncate table [dbo].[POSKDSCategory_History]
		truncate table [dbo].[UserWise_Location]
		truncate table [dbo].[ActionButtons]
		truncate table [dbo].[ActionTemplate]
		truncate table [dbo].[AuditTrail_Log]
		truncate table [dbo].[BillHeader]
		truncate table [dbo].[BillTrans]
		truncate table [dbo].[DiscountDetails]
		truncate table [dbo].[DiscountDetails_History]
		truncate table [dbo].[DiscountHeader]
		truncate table [dbo].[DiscountHeader_History]
		truncate table [dbo].[Gen_ChargeGroupDetail]
		truncate table [dbo].[Gen_ChargeGroupHeader]
		truncate table [dbo].[Gen_ChargeGroupHeader_History]
		truncate table [dbo].[Gen_ChargeType]
		truncate table [dbo].[Gen_ChargeType_History]
		truncate table [dbo].[GEN_ErrTable]
		truncate table [dbo].[ItemBreakDown]
		--truncate table [dbo].[ItemCategory]
		truncate table [dbo].[ItemCategory_History]
		truncate table [dbo].[ItemWisePrinters]
		truncate table [dbo].[Location_Ref]
		truncate table [dbo].[MainMenu]
		truncate table [dbo].[MainMenu_History]
		truncate table [dbo].[MenuItemWiseAlternatives]
		truncate table [dbo].[MenuItemWiseAlternatives_History]
		truncate table [dbo].[MenuItemWiseModifier]
		truncate table [dbo].[OutletWisePrinters]
		truncate table [dbo].[OutletwiseMenuItemPrice]
		truncate table [dbo].[OutletwiseMenuItemPrice_History]
		truncate table [dbo].[PaymentTypes]
		truncate table [dbo].[PaymentTypes_History]
		truncate table [dbo].[PayTrans]
		--truncate table [dbo].[POS_AccessCodes]
		truncate table [dbo].[POS_CashierShift]
		truncate table [dbo].[POS_ExecutiveMember]
		truncate table [dbo].[POS_KotBot]
		truncate table [dbo].[POS_OutletWiseMenuItems]
		truncate table [dbo].[POS_UserAccessTemp]
		--truncate table [dbo].[POSItemTypes]
		truncate table [dbo].[POSItemTypes_History]
		--truncate table [dbo].[POSKDSCategory]
		truncate table [dbo].[POSKDSCategory_History]
		--truncate table --[dbo].[POSOrderTypes]
		truncate table [dbo].[PrinterSetup]
		truncate table [dbo].[PrinterSetup_History]
		truncate table [dbo].[RecipeDetails]
		truncate table [dbo].[RecipeHeader]
		truncate table [dbo].[Waiter]
		truncate table [dbo].[Waiter_History]
		truncate table [dbo].[WaiterWiseOutlets]
		truncate table [dbo].[WaiterWiseOutlets_History]
	END
	ELSE IF (@DeleteType='D')
	BEGIN							
		delete from [dbo].[Category]						where propertyId=@propertyId
		delete from [dbo].[Category_History]				where propertyId=@propertyId
		delete from [dbo].[ItemCategory]					where propertyId=@propertyId
		delete from [dbo].[ItemCategory_History]			where propertyId=@propertyId
		delete from [dbo].[POSKDSCategory]					where propertyId=@propertyId
		delete from [dbo].[POSKDSCategory_History]			where propertyId=@propertyId
		delete from [dbo].[UserWise_Location]				--where propertyId=@propertyId
		delete from [dbo].[ActionButtons]					--where propertyId=@propertyId
		delete from [dbo].[ActionTemplate]					where propertyId=@propertyId
		delete from [dbo].[AuditTrail_Log]					where propertyId=@propertyId
		delete from [dbo].[BillHeader]						where propertyId=@propertyId
		delete from [dbo].[BillTrans]						where propertyId=@propertyId
		delete from [dbo].[DiscountDetails]					where propertyId=@propertyId
		delete from [dbo].[DiscountDetails_History]			where propertyId=@propertyId
		delete from [dbo].[DiscountHeader]					where propertyId=@propertyId
		delete from [dbo].[DiscountHeader_History]			where propertyId=@propertyId
		delete from [dbo].[Gen_ChargeGroupDetail]			where propertyId=@propertyId
		delete from [dbo].[Gen_ChargeGroupHeader]			where propertyId=@propertyId
		delete from [dbo].[Gen_ChargeGroupHeader_History]	where propertyId=@propertyId
		delete from [dbo].[Gen_ChargeType]					where propertyId=@propertyId
		delete from [dbo].[Gen_ChargeType_History]			where propertyId=@propertyId
		delete from [dbo].[GEN_ErrTable]					--where propertyId=@propertyId
		delete from [dbo].[ItemBreakDown]					where propertyId=@propertyId
		--delete from [dbo].[ItemCategory]					where propertyId=@propertyId
		delete from [dbo].[ItemCategory_History]			where propertyId=@propertyId
		delete from [dbo].[ItemWisePrinters]				where propertyId=@propertyId
		delete from [dbo].[Location_Ref]					where propertyId=@propertyId
		delete from [dbo].[MainMenu]						where propertyId=@propertyId
		delete from [dbo].[MainMenu_History]				where propertyId=@propertyId
		delete from [dbo].[MenuItemWiseAlternatives]		--where propertyId=@propertyId
		delete from [dbo].[MenuItemWiseAlternatives_History]--where propertyId=@propertyId
		delete from [dbo].[MenuItemWiseModifier]			where propertyId=@PropertyId
		delete from [dbo].[OutletWisePrinters]				--where propertyId=@PropertyId
		delete from [dbo].[OutletwiseMenuItemPrice]			--where propertyId=@PropertyId
		delete from [dbo].[OutletwiseMenuItemPrice_History]	--where propertyId=@PropertyId
		delete from [dbo].[PaymentTypes]					where propertyId=@PropertyId
		delete from [dbo].[PaymentTypes_History]			where propertyId=@PropertyId
		delete from [dbo].[PayTrans]						where propertyId=@PropertyId
		--delete from [dbo].[POS_AccessCodes]				where propertyId=@PropertyId
		delete from [dbo].[POS_CashierShift]				where propertyId=@PropertyId
		delete from [dbo].[POS_ExecutiveMember]				where propertyId=@PropertyId
		delete from [dbo].[POS_KotBot]						where propertyId=@PropertyId
		delete from [dbo].[POS_OutletWiseMenuItems]			where propertyId=@PropertyId
		delete from [dbo].[POS_UserAccessTemp]				where propertyId=@PropertyId
		--delete from [dbo].[POSItemTypes]					where propertyId=@PropertyId
		delete from [dbo].[POSItemTypes_History]			where propertyId=@PropertyId
		--delete from [dbo].[POSKDSCategory]				where propertyId=@PropertyId
		delete from [dbo].[POSKDSCategory_History]			where propertyId=@PropertyId
		--delete from[dbo].[POSOrderTypes]					where propertyId=@PropertyId
		delete from [dbo].[PrinterSetup]					where propertyId=@PropertyId
		delete from [dbo].[PrinterSetup_History]			where propertyId=@PropertyId
		delete from [dbo].[RecipeDetails]					where propertyId=@PropertyId
		delete from [dbo].[RecipeHeader]					where propertyId=@PropertyId
		delete from [dbo].[Waiter]							where propertyId=@PropertyId
		delete from [dbo].[Waiter_History]					where propertyId=@PropertyId
		delete from [dbo].[WaiterWiseOutlets]				--where propertyId=@PropertyId
		delete from [dbo].[WaiterWiseOutlets_History]		--where propertyId=@PropertyId
	END														



END

GO

