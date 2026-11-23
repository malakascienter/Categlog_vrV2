-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-10-20
-- Description:	Validate before deleting and editiing suppliers from supplierwise items
-- =============================================
CREATE FUNCTION [dbo].[fn_IsPendingPOExists]
(
    @SupplierID INT,
    @LocationID INT,
    @StockItemID INT
)
RETURNS BIT
AS
BEGIN
    DECLARE @Exists BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM PoHeaders PH WITH (NOLOCK)
        INNER JOIN PoDetails PD WITH (NOLOCK) ON PH.Id = PD.PoHeaderID
        WHERE PH.SupplierID = @SupplierID
          AND PH.LocationID = @LocationID
          AND PD.StockItemID = @StockItemID
          AND PH.DocumentStatus = 'P'
		  AND ( PD.ApprovedQuantity - PD.ReceivedQuantity ) > 0
    )
    BEGIN
        SET @Exists = 1;
    END

    RETURN @Exists;
END;

GO

