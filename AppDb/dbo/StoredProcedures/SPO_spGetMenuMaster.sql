
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE     PROCEDURE [dbo].[SPO_spGetMenuMaster]
	@PropertyId INT,
	@OrderTypeId INT,
	@CustomerId INT,
	@OutletCode VARCHAR(5)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CustomerTypeID INT
	DECLARE @OutletDefaultPriceTypeID INT

	SELECT @CustomerTypeID = CustomerTypeID 
	FROM SPO_Customer 
	WHERE Id = @CustomerId AND PropertyId = @PropertyId

	SELECT @OutletDefaultPriceTypeID = PriceTypeID 
	FROM SPO_OrderTypeWiseCustomerWiseOutletWiseDetails 
	WHERE OrderTypeID = @OrderTypeId AND CustomerTypeID = @CustomerTypeID AND OutletCode = @OutletCode


	IF( ISNULL(@OutletDefaultPriceTypeID,0) = 0 )
	BEGIN

		
		SELECT @OutletDefaultPriceTypeID = PriceTypeID 
		FROM SPO_OrderTypeWiseCustomer 
		WHERE OrderTypeID = @OrderTypeId AND CustomerTypeID = @CustomerTypeID

	END

	IF( ISNULL(@OutletDefaultPriceTypeID,0) = 0 )
	BEGIN

		
		SELECT @OutletDefaultPriceTypeID = DefaultPriceTypeId 
		FROM Location_Ref 
		WHERE Code = @OutletCode AND PropertyId = @PropertyId


	END


	SELECT CC.Code AS categoryCode,CC.Description AS categoryName,MM.ItemCode AS itemCode,MM.Description AS itemName,OMP.Price AS price,Setmenu AS IsSetmenuItem
	FROM MainMenu MM 
	INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POS_OutletWiseMenuItems OM ON MM.ItemCode = OM.MenuCode AND MM.PropertyId = OM.PropertyId
	INNER JOIN POS_OutletWiseMenuItemPrice OMP ON MM.ItemCode = OMP.MenuItemCode AND MM.PropertyId = OMP.PropertyId AND OM.OutletCode = OMP.OutletCode
	WHERE MM.PropertyId = @PropertyId AND OM.PropertyId = @PropertyId AND OMP.PropertyId = @PropertyId AND OM.OutletCode = @OutletCode AND OM.PropertyId = @PropertyId
	AND OMP.OutletCode = @OutletCode AND OMP.PropertyId = @PropertyId AND OMP.PriceTypeID = @OutletDefaultPriceTypeID

END

GO

