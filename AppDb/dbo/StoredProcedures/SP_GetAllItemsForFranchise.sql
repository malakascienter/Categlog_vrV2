-- =============================================
-- Author:		Tharuka Sachintha 
-- Create date: 2026-05-22
-- Description:	load the items for franchises


-- SP_GetAllItemsForFranchise 272,1,1,4407

-- =============================================
CREATE   PROCEDURE [dbo].[SP_GetAllItemsForFranchise]
    @Departmentid INT,
    @Locationid   INT,
    @Propertyid   INT,
    @Supplierid   INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Locationid2 INT;

    SELECT @Locationid2 = LO.ID
    FROM   Departments DE
    INNER JOIN Locations LO ON LO.FranchiseDepartmentID = DE.ID
    WHERE  DE.ID = @Departmentid;


    SELECT StockItemHeaderID
    INTO   #TEMP
    FROM   StockItemDetails WHERE LocationId = @Locationid
    INTERSECT
    SELECT StockItemHeaderID
    FROM   StockItemDetails WHERE LocationId = @Locationid2;



     IF (@Supplierid IS NULL)
    BEGIN
        SELECT @Supplierid = SupplierId FROM Companies WHERE CompanyID = @Propertyid;
    END

    SELECT
        SH.ID,
        SH.Name,
        SH.StockItemCode,
        SW.CostPrice                AS UnitPrice,
        SH.CategoryID,
        UN.Id                       AS UnitID,
        UN.Name                     AS UnitName,
        --STK.QuantityInHand          AS QuantityInHand  
        CAST(CASE WHEN CR.Rate > 0 THEN STK.QuantityInHand * CR.Rate -- 2026-09-14 added by Tharuka 
          ELSE STK.QuantityInHand
     END AS DECIMAL(18, 6))  AS QuantityInHand
    FROM StockItemHeaders SH
    INNER JOIN #TEMP                TMP ON TMP.StockItemHeaderID = SH.ID
    INNER JOIN StockItemDetails     SD  ON SD.StockItemHeaderID  = SH.ID
                                       AND SD.LocationID         = @Locationid2
    INNER JOIN SupplierWiseItemDetails SW ON SW.StockItemID      = SH.ID
    AND SW.LocationId      = @Locationid2
    AND SW.SupplierID   = @Supplierid
    INNER JOIN Units                UN  ON UN.ID  = SW.PurchaseUnitID
    -- 2026-09-14 added by Tharuka 
    INNER JOIN StockItemDetails SD1 ON SD1.StockItemHeaderID = SH.ID
                               AND SD1.LocationID        = @Locationid
    CROSS APPLY (SELECT dbo.FN_GetUnitConvertionRate(@Propertyid, SD1.MasterUnitID,
                    ISNULL(SW.PurchaseUnitID, SD1.MasterUnitID)) AS Rate) CR
    -- end 
    CROSS APPLY [dbo].[FN_TV_GetStockInHand](@Propertyid, @Locationid, SH.ID) STK
    WHERE SW.SupplierID = @Supplierid
      AND SW.LocationId = @Locationid2;

END

GO

