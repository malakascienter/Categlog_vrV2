
-- ============================================================
-- 4. Discounts_M_Select_ById : return DiscountTierArrayJson
--    (full body - only the Tier line is new)
-- ============================================================

CREATE PROCEDURE [dbo].[Discounts_M_Select_ById] --1
@Id INT,
@PropertyId INT
AS
BEGIN
	SELECT
	[Id],
	[Code],
	[Description], 	CONVERT(varchar(20),[TimeFrom],100) AS [TimeFrom], CONVERT(varchar(20),[TimeTo],100) AS [TimeTo]	,
	DateFrom,
	[DateTo],
	[Percentage],
	IsPercentage,
	[IsAutoApply],
	[IsAuthorization],
	[IsDay],
	[SysDate],
	[ValidationModesId] AS ValidationMode,
	(SELECT TOP(1) Code FROM ValidationModes WHERE ID = [ValidationModesId]) AS ValidationModeCode,
	[DiscountType],
	[IsNeedRemark],
	[IsValidatePayType],
	CASE IsPercentage WHEN 1 THEN Percentage ELSE DiscountValue END AS DiscountValue,
	--[DiscountValue],
	[IsActive],
	[CreatedUserId],
	[CreatedDateTime],
	[UpdatedUserId],
	[UpdatedDateTime],
	[OutletListJson] AS OutletJson,
	(SELECT MenuItemID as ItemCode FROM DiscountDetails WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) AS MenuItemsJson,
	[DaysJson] AS DiscountDaysJson,
	(SELECT Code, ItemTypeCode FROM DiscountItemType WHERE Code = DiscountHeader.Code FOR JSON AUTO) as MenuItemsTypesJson,
	(SELECT Code, CategoryCode FROM DiscountItemCategory WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountItemCategoryJson,
	[IsItemWiseDiscount],
	IsApplyAllItems,
	MinimumAmount,
	MaximumDiscount,
	(SELECT Code, BinNumber FROM DiscountBinNumbers WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountBinNumbersJson,
	(SELECT Code, PayType FROM DiscountPayment WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountItemPaymentArrayJson,
	(SELECT Code, MemberCode FROM [DiscountMember] WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountMemberArrayJson,
	(SELECT Code, MenuItemID as ItemCode,IsBuyItem,IsDiscountItem,DiscountPercentage,DiscountValue FROM DiscountDetails WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountBuyNGetNArrayJson,
	BuyQuantity as BuyItemQty,
	FreeQuantity as DiscountItemQty,
	(SELECT Code, ChannelCode FROM [DiscountChannel] WHERE Code = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountChannelArrayJson,
	(SELECT DiscountCode AS Code, CustomerGroupId FROM [DiscountCustomerGroup] WHERE DiscountCode = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountCustomerGroupArrayJson,
	(SELECT DiscountCode AS Code, TierId FROM [DiscountWiseTier] WHERE DiscountCode = DiscountHeader.Code AND PropertyId = DiscountHeader.PropertyId  FOR JSON AUTO) as DiscountTierArrayJson
	from DiscountHeader where Id=@Id AND PropertyId=@PropertyId
END

GO

