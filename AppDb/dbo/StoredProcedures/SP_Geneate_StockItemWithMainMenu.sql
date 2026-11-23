CREATE   PROCEDURE [dbo].[SP_Geneate_StockItemWithMainMenu]
    @ItemName VARCHAR(50),
    @ShortName VARCHAR(25),
    @SellingPrice MONEY,
    @UserId INT,
    @PropertyId INT,
	@UnitId int,
	@ProductionLocationId int,
	@InvDeliveryScheduleId int,
	@headerid INT OUTPUT,
	@ProductItemCode VARCHAR(Max) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CategoryID INT = (SELECT TOP 1 CAST(Value AS INT) FROM PB_Settings WHERE Code = 'CATEGORY');
    DECLARE @SubCategoryID INT = (SELECT TOP 1 CAST(Value AS INT) FROM PB_Settings WHERE Code = 'SUBCATEGORY1');
    DECLARE @SubCategory2ID INT = (SELECT TOP 1 CAST(Value AS INT) FROM PB_Settings WHERE Code = 'SUBCATEGORY2');

    DECLARE @ProductXML XML;

    SET @ProductXML = (
        SELECT
            -1 AS Id,
            '-' AS PLUCode,
            @ItemName AS Name,
            CAST(1 AS BIT) AS IsActive,
            'sdsdsd' AS ImageUrl,
            2 AS TaxGroupID,
            CAST(0 AS BIT) AS IsExpiryDateApplicable,
            0 AS MinimumQuantity,
            0 AS MaximumQuantity,
            0 AS ReOrderLevel,
            0 AS ReOrderQuantity,
            0 AS AveragePrice,
            CAST(0 AS BIT) AS IsPriceEditable,
            CAST(0 AS BIT) AS MaintainPriceHistory,
            CAST(0 AS BIT) AS Isbundle,
            CAST(0 AS BIT) AS BrandedItem,
            0 AS LocationID,
            @PropertyId AS PropertyID,
            1 AS ReportingUnitID,
            -1 AS StockItemHeaderID,
            @CategoryID AS CategoryID,
            0 AS ReferanceCode,
            0 AS Barcode,
            @ShortName AS NameOnInvoice,
            @SubCategoryID AS SubCategoryID,
            0 AS SupplierID,
            1 AS CostingMethod,
            'TEST' AS Remarks,
            @UnitId AS MasterUnitID,
            @UnitId AS PurchasingUnitID,
            0 AS ReOrderPeriod,
            0 AS PurchaseAccountID,
            0 AS CostOfSalesAccountID,
            @SellingPrice AS SellingPrice,
            0 AS ProfitMargin,
            0 AS WholesalePrice,
            0 AS QuantityInHand,
            '172.16.1.2' AS IPAddress,
            @SubCategory2ID AS SubCategory2ID,
            NULL AS IsRequestedItem,
            NULL AS RequestedItemId,
            CAST(0 AS BIT) AS CopyToOtherProperties,
            @UserId AS UserId,
            CAST(0 AS BIT) AS IsMultiplePrices,
            CAST(0 AS BIT) AS IsMultipleBarcode,
            CAST(0 AS BIT) AS IsAllowDiscount,
            CAST(0 AS BIT) AS IsFractionItem,
            CAST(0 AS BIT) AS IsSerialNo,
            CAST(0 AS BIT) AS IsAllowReturnItem,
            CAST(0 AS BIT) AS IsOpenPrice,
            1 AS ChargeHeaderID,
            CAST(0 AS BIT) AS IsSellingItem,
            0 AS IsProductionItem,
			0 AS ItemAge,
			'' as ERPReferenceCode,
			0 as DeliveryScheduleId,
			@ProductionLocationId as ProductionLocationId,
			@InvDeliveryScheduleId as DeliveryScheduleId,
            -- Empty ReferencesList
            (SELECT NULL WHERE 1 = 0 FOR XML PATH('ReferencesList'), TYPE),

           -- Attribute List
			(
				SELECT *
				FROM (
					SELECT 16 AS AttributeID, 'DAILY MARKET LIST' AS AttName, NULL AS Remarks, CAST(0 AS BIT) AS Active
					UNION ALL SELECT 20, 'TempApplicable', NULL, 0
					UNION ALL SELECT 22, 'Production Item', NULL, 0
					UNION ALL SELECT 15, 'BARCODE', NULL, 0
					UNION ALL SELECT 19, 'ThresholdValu', NULL, 0
					UNION ALL SELECT 21, 'HOTEL CODE', NULL, 0
				) AS Attributes
				FOR XML PATH('AttributeViewModel'), ROOT('AttributeList'), TYPE
			),


            -- Empty SupplierList
            (SELECT NULL WHERE 1 = 0 FOR XML PATH('SupplierList'), TYPE),

            -- ItemWiseLocation from Locations table
            (
                SELECT 
                    L.Name AS [text],
                    L.Id AS [id]
                FROM Locations L
                WHERE L.PropertyId = @PropertyId
                FOR XML PATH('ItemWiseLocation'), ROOT('ItemWiseLocation'), TYPE
            )
         FOR XML PATH('ProductSaveModel'), TYPE
    )


	--SET @ProductXML = (SELECT
 --   CAST('<?xml version="1.0" encoding="utf-8"?>' +
 --        '<ProductSaveModel xmlns:xsd="http://www.w3.org/2001/XMLSchema" ' +
 --        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' +
 --        CAST(@ProductXML AS NVARCHAR(MAX)) +
 --        '</ProductSaveModel>' AS XML) )


    -- Final XML Output
    SELECT @ProductXML AS ProductXML;


	EXEC [dbo].[SP_Insert_StockMaster]
		@XMLDetails = @ProductXML,
		@Operation = 1,
		@Page = 0,
		@headerid = @HeaderId OUTPUT,
		@ProductItemCode = @ProductItemCode OUTPUT;

	-- Optional debug
	SELECT @HeaderId AS HeaderId, @ProductItemCode AS ProductItemCode;

END

GO

