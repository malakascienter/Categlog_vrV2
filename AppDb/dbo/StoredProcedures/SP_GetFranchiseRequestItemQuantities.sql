-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-09-14
-- Description:	get quantity in hand and suggested quantity in franchise lcations 

-- EXEC dbo.SP_GetFranchiseRequestItemQuantities @FranchiseLocationID = 3598, @PropertyID = 1, @DeliveryDate = '2026-09-20', @StockItemID = 1;

-- =============================================

CREATE   PROCEDURE [dbo].[SP_GetFranchiseRequestItemQuantities]
    @FranchiseLocationID INT,
    @PropertyID          INT,
    @DeliveryDate        DATE = NULL,
    @StockItemID         INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @QuantityInHand    DECIMAL(18, 6) = 0,
            @SuggestedQuantity DECIMAL(18, 6) = 0;

    DECLARE @MasterUnitID    INT,
            @PurchaseUnitID  INT,
            @UnitRate        DECIMAL(38, 20),
            @IsUnitConverted BIT = 0;


    DECLARE @SupplierID INT;

    SELECT @SupplierID = SupplierId
    FROM Companies
    WHERE CompanyID = @PropertyID

    IF ISNULL(@FranchiseLocationID, 0) > 0 AND ISNULL(@StockItemID, 0) > 0
    BEGIN
        SET @QuantityInHand = dbo.FN_GetStockInHand(@PropertyID, @FranchiseLocationID, @StockItemID);

        --Added 2026-09-14 - unit conversion (see above)
        SELECT TOP 1 @MasterUnitID = SD.MasterUnitID
        FROM   dbo.StockItemDetails SD
        WHERE  SD.StockItemHeaderID = @StockItemID
               AND SD.LocationID    = @FranchiseLocationID;

        --same row selection as SP_GetItemDetailsForFranchise (location + item)
        SELECT TOP 1 @PurchaseUnitID = SW.PurchaseUnitID
        FROM   dbo.SupplierWiseItemDetails SW
        WHERE  SW.StockItemID    = @StockItemID
               AND SW.LocationId = @FranchiseLocationID
               AND SW.SupplierID = @SupplierID
        ORDER BY SW.LocationId;

        IF ( @MasterUnitID IS NOT NULL
             AND ISNULL(@PurchaseUnitID, 0) > 0
             AND @PurchaseUnitID <> @MasterUnitID )
        BEGIN
            SET @UnitRate = dbo.FN_GetUnitConvertionRate(@PropertyID, @MasterUnitID, @PurchaseUnitID);

            IF ( ISNULL(@UnitRate, -1) > 0 )
            BEGIN
                SET @QuantityInHand  = @QuantityInHand * @UnitRate;
                SET @IsUnitConverted = 1;
            END
            --else: no conversion defined (-1) - quantity stays in the master unit
            --and UnitID below reports the master unit, so the screen is not misled
        END
        --End 2026-09-14
    END

    -------------------------------------------------------------------------
    -- Suggested Qty rule goes here (uses @DeliveryDate, @QuantityInHand).
    -- Placeholder 2026-09-14: always 0.
    SET @SuggestedQuantity = 0;
    --Added by Isuru 2026-09-25 - Suggested Qty = Auto Order Suggestion of the Par Level Report
    --(same formula, dbo.FN_GetParLevelAutoOrderSuggestion): usage of the last 30 days up to today,
    --lead time up to @DeliveryDate (today when not given). The function works in the master unit,
    --so the result is converted to the supplier unit the same way as @QuantityInHand.
    IF ISNULL(@SupplierID, 0) > 0
    BEGIN
        SET @SuggestedQuantity = ISNULL(dbo.FN_GetParLevelAutoOrderSuggestion(
                CONVERT(VARCHAR(10), DATEADD(DAY, -29, CAST(GETDATE() AS DATE)), 23),     --@FromDate: 30 days incl. today
                CONVERT(VARCHAR(10), GETDATE(), 23),                                      --@ToDate: today
                @FranchiseLocationID,
                @SupplierID,
                @PropertyID,
                CONVERT(VARCHAR(10), ISNULL(@DeliveryDate, CAST(GETDATE() AS DATE)), 23), --@DispatchDate
                @StockItemID), 0);

        IF @IsUnitConverted = 1
            SET @SuggestedQuantity = @SuggestedQuantity * @UnitRate;
    END
    --End 2026-09-25
    SELECT  @StockItemID                         AS StockItemID,
            ISNULL(@FranchiseLocationID, 0)      AS FranchiseLocationID,
            CAST(ISNULL(@QuantityInHand, 0) AS DECIMAL(18, 6)) AS QuantityInHand,
            CASE WHEN ISNULL(@SuggestedQuantity, 0) < 0 THEN 0
                 ELSE ISNULL(@SuggestedQuantity, 0) END AS SuggestedQuantity,
            CASE WHEN @IsUnitConverted = 1 THEN @PurchaseUnitID ELSE @MasterUnitID END AS UnitID,
            U.Name                               AS UnitName,
            @IsUnitConverted                     AS IsUnitConverted
    FROM    (SELECT 1 AS One) X
            LEFT JOIN dbo.Units U
                   ON U.Id = CASE WHEN @IsUnitConverted = 1 THEN @PurchaseUnitID ELSE @MasterUnitID END;
    --End 2026-09-14
END

GO

