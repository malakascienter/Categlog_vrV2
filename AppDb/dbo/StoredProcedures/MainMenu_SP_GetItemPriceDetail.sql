-- =============================================
-- Author:		Nivesh
-- Create date: 2025-12-17
-- Description:	Get Menu Item Detail
-- =============================================
-- MainMenu_SP_GetItemPriceDetail 1, 3
CREATE   PROCEDURE MainMenu_SP_GetItemPriceDetail 
	@PropertyId INT = 0, 
	@priceTypeId INT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @DefaultOutlet VARCHAR(5)
    
	SELECT TOP(1) 
		@DefaultOutlet = code
	FROM location_ref 
	WHERE PropertyId = @PropertyId 
		AND IsDefault = 1

	SELECT DISTINCT 
		MM.ItemCode,
		mm.Description AS ItemName,
		PO.Price,
		FORMAT(GETDATE(), 'yyyy/MM/dd') AS CurrentDate
	FROM MainMenu mm 
	INNER JOIN POS_OutletWiseMenuItemPrice PO ON MM.ItemCode = PO.MenuItemCode AND MM.PropertyId = PO.PropertyId
	WHERE po.OutletCode = @DefaultOutlet 
		AND po.PropertyId = @PropertyId 
		AND mm.PropertyId = @PropertyId 
		AND po.PriceTypeID = @priceTypeId
END

GO

