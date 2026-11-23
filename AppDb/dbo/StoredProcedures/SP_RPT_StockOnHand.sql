-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-06-10
-- Description:	get special stock details for report 

--	dbo.SP_RPT_StockOnHand 1, 1

-- =============================================

CREATE   PROCEDURE dbo.SP_RPT_StockOnHand
    @LocationId INT,
    @PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Location      = L.Name,
        StockItemCode = SH.StockItemCode,
        ItemName      = SH.Name,
        CategoryName  = C.Name,
        CurrentStock  = ISNULL(SD.QuantityInHand, 0),
        Unit          = U.Name,
        ReorderLevel  = ISNULL(SD.ReOrderLevel, 0),
        MinLevel      = ISNULL(SD.MinimumQuantity, 0),
        MaxLevel      = ISNULL(SD.MaximumQuantity, 0),
        StockValue    = ISNULL(SD.QuantityInHand, 0) * ISNULL(SD.AveragePrice, 0),
        Status        = CASE
                            WHEN ISNULL(SD.QuantityInHand, 0) <= 0
                                THEN 'Out of Stock'
                            WHEN ISNULL(SD.QuantityInHand, 0) <= ISNULL(SD.MinimumQuantity, 0)
                                THEN 'Low Stock'
                            ELSE 'Ok'
                        END
    FROM            dbo.StockItemDetails  SD
    INNER JOIN      dbo.StockItemHeaders  SH ON SH.Id        = SD.StockItemHeaderID
    INNER  JOIN     dbo.Locations         L  ON L.Id         = SD.LocationID
    LEFT  JOIN      dbo.Categories        C  ON C.Id         = SH.CategoryID
    LEFT  JOIN      dbo.Units             U  ON U.Id         = SD.MasterUnitID
    
    WHERE (@LocationId = -999 OR SD.LocationID = @LocationId)
          AND ISNULL(SD.IsActive, 1) = 1  
          AND SH.CompanyId = @PropertyID
          
        
    ORDER BY
        C.Name,
        SH.Name;
END

GO

