-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-05-25
-- Description:	Get Cost price for BackEnd Invoice
-- =============================================
CREATE FUNCTION  [dbo].[FN_GetCostPriceBI]
(
    @StockItemID INT,
    @LocationID INT,
    @PropertyID INT,
    @TxnUnitID INT
)
RETURNS DECIMAL(18, 4)
AS
BEGIN
    DECLARE @CostPrice DECIMAL(18, 4)
    DECLARE @SupplierID INT

    -- Get SupplierID
    SELECT @SupplierID = SupplierId
    FROM Companies
    WHERE CompanyID = @PropertyID

    -- Get CostPrice
    SELECT TOP 1 @CostPrice = CostPrice * dbo.FN_GetUnitConvertionRate(@propertyID,@TxnUnitID,PurchaseUnitID) 
    FROM SupplierWiseItemDetails
    WHERE SupplierID = @SupplierID
        AND LocationId = @LocationID
        AND StockItemID = @StockItemID

    RETURN ISNULL(@CostPrice, 0)
END

GO

