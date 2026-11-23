-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>

-- [dbo].[SP_New_SaveALLPropertyWiseItems]  -999,4168,2,-999,-999,-999

-- =============================================
create PROCEDURE [dbo].[SP_New_SaveALLPropertyWiseItems] 
    @ItemId INT,
    @UserId INT,
    @PropertyId INT,
    @CategoryId INT,
    @subcategoryID INT,
    @subcategory2ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Input validation
        IF (@PropertyId = 0)
        BEGIN
            RAISERROR('Company ID Invalid, Please Log In Again', 16, 1);
            RETURN;
        END

        IF (@UserId = 0)
        BEGIN
            RAISERROR('User ID Invalid, Please Log In Again', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Locations WHERE CompanyID = @PropertyId AND GroupName = 'MS')
        BEGIN
            RAISERROR('Selected Property does not have a Main Store', 16, 1);
            RETURN;
        END

        DECLARE @CurrentDate DATETIME = GETDATE();
        DECLARE @MainStoreLocationId INT;

        -- Get Main Store Location ID once
        SELECT @MainStoreLocationId = Id 
        FROM Locations 
        WHERE CompanyID = @PropertyId AND GroupName = 'MS';

        -- Insert missing StockItemHeaders in bulk
        INSERT INTO StockItemHeaders (
            CompanyId, LocationId, StockItemCode, PLUCode, ReferanceCode, Barcode, 
            Name, NameOnInvoice, ImageUrl, CategoryID, SubCategoryID, SupplierID, 
            TaxGroupID, CostingMethod, Remarks, IsExpiryDateApplicable, IPAddress, 
            CreatedUserID, LastModUserID, CreatedDate, LastModDate, SubCategory2ID, 
            IsPriceEditable, MaintainPriceHistory, Isbundle, BrandedItem, GenericItemCode, 
            IsMultiplePrices, IsMultipleBarcode, IsAllowDiscount, IsFractionItem, 
            IsSerialNo, IsAllowReturnItem, IsOpenPrice, ChargeHeaderID, IsSellingItem, 
            ERPReferenceCode, IsProductionItem
        )
        SELECT DISTINCT
            @PropertyId,
            @MainStoreLocationId,
            H.StockItemCode,
            H.PLUCode,
            H.ReferanceCode,
            H.Barcode,
            H.Name,
            H.NameOnInvoice,
            H.ImageUrl,
            H.CategoryID,
            H.SubCategoryID,
            H.SupplierID,
            H.TaxGroupID,
            H.CostingMethod,
            H.Remarks,
            ISNULL(H.IsExpiryDateApplicable, 0),
            H.IPAddress,
            @UserId,
            @UserId,
            @CurrentDate,
            @CurrentDate,
            H.SubCategory2ID,
            ISNULL(H.IsPriceEditable, 0),
            H.MaintainPriceHistory,
            ISNULL(H.Isbundle, 0),
            H.BrandedItem,
            H.GenericItemCode,
            ISNULL(H.IsMultiplePrices, 0),
            ISNULL(H.IsMultipleBarcode, 0),
            ISNULL(H.IsAllowDiscount, 0),
            ISNULL(H.IsFractionItem, 0),
            ISNULL(H.IsSerialNo, 0),
            ISNULL(H.IsAllowReturnItem, 0),
            ISNULL(H.IsOpenPrice, 0),
            H.ChargeHeaderID,
            ISNULL(H.IsSellingItem, 0),
            H.ERPReferenceCode,
            ISNULL(H.IsProductionItem, 0)
        FROM StockItemHeaders H WITH (NOLOCK)
        INNER JOIN StockItemDetails D WITH (NOLOCK) ON H.Id = D.StockItemHeaderID
        WHERE NOT EXISTS (
            SELECT 1 
            FROM StockItemHeaders Existing 
            WHERE Existing.StockItemCode = H.StockItemCode 
            AND Existing.CompanyId = @PropertyId
        );

        -- Create temp table to map old codes to new header IDs
        IF OBJECT_ID('tempdb..#NewHeaders') IS NOT NULL
            DROP TABLE #NewHeaders;

        CREATE TABLE #NewHeaders (
            OldStockItemCode VARCHAR(200),
            NewHeaderId INT
        );

        -- Map old codes to new header IDs for items that need details
        INSERT INTO #NewHeaders (OldStockItemCode, NewHeaderId)
        SELECT 
            H.StockItemCode,
            NH.Id
        FROM StockItemHeaders H WITH (NOLOCK)
        INNER JOIN StockItemHeaders NH WITH (NOLOCK) 
            ON H.StockItemCode = NH.StockItemCode 
            AND NH.CompanyId = @PropertyId
        WHERE NOT EXISTS (
            SELECT 1 
            FROM StockItemDetails Existing 
            WHERE Existing.StockItemHeaderID = NH.Id 
            AND Existing.CompanyID = @PropertyId
        );

        -- Get distinct StockItemDetails with only one record per StockItemHeader
        IF OBJECT_ID('tempdb..#DistinctDetails') IS NOT NULL
            DROP TABLE #DistinctDetails;

        SELECT 
            H.StockItemCode,
            D.MasterUnitID, 
            D.PurchasingUnitID, 
            D.MinimumQuantity, 
            D.MaximumQuantity, 
            D.ReOrderLevel, 
            D.ReOrderQuantity, 
            D.ReOrderPeriod,
            ROW_NUMBER() OVER (PARTITION BY H.Id ORDER BY D.Id) as RowNum
        INTO #DistinctDetails
        FROM StockItemHeaders H WITH (NOLOCK)
        INNER JOIN StockItemDetails D WITH (NOLOCK) ON H.Id = D.StockItemHeaderID
        WHERE H.StockItemCode IN (SELECT OldStockItemCode FROM #NewHeaders);

        -- Bulk insert StockItemDetails - ONE RECORD PER HEADER
        INSERT INTO StockItemDetails (
            PropertyID, CompanyID, LocationID, StockItemHeaderID, MasterUnitID, 
            PurchasingUnitID, MinimumQuantity, MaximumQuantity, ReOrderLevel, 
            ReOrderQuantity, ReOrderPeriod, PurchaseAccountID, CostOfSalesAccountID, 
            AveragePrice, SellingPrice, WholesalePrice, IsActive, ReportingUnitID, 
            QuantityInHand, StockItemId, IPAddress, CreatedUserID, LastModUserID, 
            CreatedDate, LastModDate, BatchNo, ProfitMargin, ItemAge
        )
        SELECT DISTINCT
            @PropertyId,
            @PropertyId,
            @MainStoreLocationId,
            NH.NewHeaderId,
            DD.MasterUnitID,
            DD.PurchasingUnitID,
            DD.MinimumQuantity,
            DD.MaximumQuantity,
            DD.ReOrderLevel,
            DD.ReOrderQuantity,
            DD.ReOrderPeriod,
            0,  -- PurchaseAccountID
            0,  -- CostOfSalesAccountID
            0,  -- AveragePrice
            0,  -- SellingPrice
            0,  -- WholesalePrice
            1,  -- IsActive
            1,  -- ReportingUnitID
            0,  -- QuantityInHand
            NH.NewHeaderId,
            '', -- IPAddress
            @UserId,
            @UserId,
            @CurrentDate,
            @CurrentDate,
            NULL, -- BatchNo
            0,    -- ProfitMargin
            0     -- ItemAge
        FROM #NewHeaders NH
        INNER JOIN #DistinctDetails DD ON NH.OldStockItemCode = DD.StockItemCode
        WHERE DD.RowNum = 1;  -- This ensures only ONE record per StockItemHeader

        -- Cleanup
        IF OBJECT_ID('tempdb..#NewHeaders') IS NOT NULL
            DROP TABLE #NewHeaders;
            
        IF OBJECT_ID('tempdb..#DistinctDetails') IS NOT NULL
            DROP TABLE #DistinctDetails;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Cleanup temp tables in case of error
        IF OBJECT_ID('tempdb..#NewHeaders') IS NOT NULL
            DROP TABLE #NewHeaders;
            
        IF OBJECT_ID('tempdb..#DistinctDetails') IS NOT NULL
            DROP TABLE #DistinctDetails;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();  
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();  
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END

GO

