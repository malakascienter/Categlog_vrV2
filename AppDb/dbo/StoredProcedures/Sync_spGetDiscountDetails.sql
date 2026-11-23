

CREATE PROCEDURE [dbo].[Sync_spGetDiscountDetails]
@PropertyId INT,
@DiscountCode VARCHAR(2)
AS

SELECT	ID, Code, Description, CONVERT(VARCHAR(50),TimeFrom,113) AS TimeFrom, CONVERT(VARCHAR(50),TimeTo,113) AS TimeTo, 
		CONVERT(VARCHAR(50),DateFrom,103) AS DateFrom, CONVERT(VARCHAR(50),DateTo,103) AS DateTo, Percentage, IsAutoApply, IsAuthorization, IsDay,
		ValidationMode, DiscountType, IsNeedRemark, IsValidatePayType, DiscountValue, IsActive, MinInvoiceAmount, MaxDiscountAmount, IsApplyAllItems
FROM	DiscountHeader
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, OrderType, MenuItemID, DiscountPercentage, DiscountValue, BuyQuantity, DiscountQuantity, IsBuyItem, IsDiscountItem
FROM	DiscountDetails
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, PayType
FROM	DiscountPayment
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, DayName
FROM    DiscountDays
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, CategoryCode
FROM    DiscountItemCategory 
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, ItemTypeCode
FROM    DiscountItemType
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, BinNumber
FROM	DiscountBinNumbers
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, MemberCode
FROM	DiscountMember
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

SELECT	Code, Outlet
FROM	DiscountOutlet
WHERE	PropertyId = @PropertyId AND Code = @DiscountCode

GO

