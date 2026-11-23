CREATE PROCEDURE [dbo].[SP_CheckItemExist] 
    @itemsJson NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

	DECLARE @jsonCategory NVARCHAR(MAX);

	SELECT @jsonCategory = (
		SELECT [Id], [Name]
		FROM [dbo].[Categories]
		FOR JSON PATH
	);

    DECLARE @jsonSubCategory NVARCHAR(MAX);

    SELECT @jsonSubCategory = (
	SELECT [Id], [Name]
	FROM [dbo].[SubCategories]
	FOR JSON PATH
	);

	--SELECT @jsonCategory AS JsonCategoryString;

	DECLARE @jsonUnit NVARCHAR(MAX);

	SELECT @jsonUnit = (
		SELECT [Id], [Name]
		FROM [dbo].[Units]
		FOR JSON PATH
	);

  --SELECT @jsonUnit AS JsonUnitString;


        -- Create temporary table to store parsed items
        CREATE TABLE #TempItems (
            Id INT IDENTITY(1,1),
            ItemText NVARCHAR(500),
            AccName NVARCHAR(500),
            ReceivedQuantity DECIMAL(18,3),
            UnitName NVARCHAR(100),
            UnitPrice DECIMAL(18,2),
            TaxAmount DECIMAL(18,2),
            DiscountPercentage DECIMAL(18,2),
            DiscountValue DECIMAL(18,2),
            ItemValue DECIMAL(18,2),
            ItemTotal DECIMAL(18,2),
            IsExpiryDateApplicable BIT,
            IsTemperatureApplicable BIT,
            ItemWiseRemarks NVARCHAR(MAX),
            IsExcelItem BIT,
            
            -- Status columns for checking
            IsExist BIT DEFAULT 0,
            ExistingItemId INT NULL,
            Message NVARCHAR(500) NULL,
            ValidationStatus NVARCHAR(50) DEFAULT 'Pending',
			CategoryId INT,
			UnitId INT,
			jsonCategoryString VARCHAR(MAX),
			jsonUnitString VARCHAR(MAX),
            jsonSubCategoryString VARCHAR(MAX),
            SubCategoryId INT
        );

        -- Parse JSON and insert into temp table
        INSERT INTO #TempItems (
            ItemText, 
            AccName, 
            ReceivedQuantity, 
            UnitName, 
            UnitPrice, 
            TaxAmount, 
            DiscountPercentage, 
            DiscountValue, 
            ItemValue, 
            ItemTotal, 
            IsExpiryDateApplicable, 
            IsTemperatureApplicable, 
            ItemWiseRemarks, 
            IsExcelItem,
			CategoryId,
			UnitId,
            SubCategoryId
        )
        SELECT 
            JSON_VALUE(item.value, '$.ItemText') AS ItemText,
            JSON_VALUE(item.value, '$.AccName') AS AccName,
            JSON_VALUE(item.value, '$.ReceivedQuantity') AS ReceivedQuantity,
            JSON_VALUE(item.value, '$.UnitName') AS UnitName,
            JSON_VALUE(item.value, '$.UnitPrice') AS UnitPrice,
            JSON_VALUE(item.value, '$.TaxAmount') AS TaxAmount,
            JSON_VALUE(item.value, '$.DiscountPercentage') AS DiscountPercentage,
            JSON_VALUE(item.value, '$.DiscountValue') AS DiscountValue,
            JSON_VALUE(item.value, '$.ItemValue') AS ItemValue,
            JSON_VALUE(item.value, '$.ItemTotal') AS ItemTotal,
            JSON_VALUE(item.value, '$.IsExpiryDateApplicable') AS IsExpiryDateApplicable,
            JSON_VALUE(item.value, '$.IsTemperatureApplicable') AS IsTemperatureApplicable,
            JSON_VALUE(item.value, '$.ItemWiseRemarks') AS ItemWiseRemarks,
            JSON_VALUE(item.value, '$.IsExcelItem') AS IsExcelItem,
			0,
			0,
            0
        FROM OPENJSON(@itemsJson) AS item;

        -- Update temp table with existence check (example logic)
        -- Modify this based on your actual business rules
        UPDATE #TempItems
        SET 
            IsExist = CASE WHEN i.Id IS NOT NULL THEN 1 ELSE 0 END,
            ExistingItemId = ISNULL(i.Id,-888),
			UnitId = ISNULL((select top(1) MasterUnitID from StockItemDetails where StockItemHeaderID = i.Id),-888),
			CategoryId = ISNULL(i.CategoryID,0),
			jsonCategoryString = (CASE WHEN ISNULL(i.CategoryID,0) <> 0 THEN  @jsonCategory ELSE @jsonCategory END ),
			jsonUnitString = (CASE WHEN  ISNULL((select top(1) MasterUnitID from StockItemDetails where StockItemHeaderID = i.Id),0) <> 0 THEN  @jsonUnit 
            ELSE ( SELECT *
           FROM (SELECT -888 AS Id, UnitName AS Name 
            FROM #TempItems T 
            WHERE T.AccName = ti.AccName 
            AND UnitName NOT IN (SELECT NAME FROM Units)
            UNION ALL 
            SELECT DISTINCT [Id], [Name]
		    FROM [dbo].[Units]
            ) A
            ORDER BY A.ID
            FOR JSON PATH) END ),
            jsonSubCategoryString = (CASE WHEN ISNULL(i.CategoryID,0) <> 0 THEN  @jsonSubCategory ELSE @jsonSubCategory END ),
            Message = CASE 
                        WHEN i.Id IS NOT NULL AND i.Id <> 0 THEN 'Item already exists in database'
                        WHEN ItemText IS NULL OR ItemText = '' THEN 'Item name is required'
                        WHEN ReceivedQuantity <= 0 THEN 'Quantity must be greater than 0'
                        WHEN UnitPrice < 0 THEN 'Unit price cannot be negative'
                        ELSE 'Valid new item'
                      END,
             SubCategoryId =  ISNULL(i.SubCategoryID,0),
            ValidationStatus = CASE 
                                WHEN i.Id IS NOT NULL THEN 'Duplicate'
                                WHEN ItemText IS NULL OR ItemText = '' THEN 'Invalid'
                                WHEN ReceivedQuantity <= 0 THEN 'Invalid'
                                WHEN UnitPrice < 0 THEN 'Invalid'
                                ELSE 'Valid'
                              END
        FROM #TempItems ti
        LEFT JOIN StockItemHeaders i ON ti.AccName = i.PLUCode 
        WHERE 1=1;

        -- Return results with status
        SELECT 
            ti.Id,
            ti.ItemText,
            ti.AccName,
            ti.ReceivedQuantity,
            ti.ReceivedQuantity OriginalQty,
            ti.UnitName,
            ti.UnitPrice,
            ti.TaxAmount,
            ti.DiscountPercentage,
            ti.DiscountValue,
            ti.ItemValue,
            ti.ItemTotal,
            ti.IsExpiryDateApplicable,
            ti.IsTemperatureApplicable,
            ti.ItemWiseRemarks,
            ti.IsExcelItem,
            ti.IsExist,
            ti.ExistingItemId,
            ti.Message,
            ti.ValidationStatus,
			jsonCategoryString AS jsonCategoryString,
			jsonUnitString AS jsonUnitString,
			ti.CategoryId,
            ti.UnitId,
            ti.jsonSubCategoryString as jsonSubCategoryString,
            ti.SubCategoryId as SubCategoryId
        FROM #TempItems ti
        ORDER BY ti.Id;

       
        DROP TABLE #TempItems;

    END TRY
    BEGIN CATCH
        -- Return error details
        SELECT 
            NULL AS ItemText,
            NULL AS AccName,
            NULL AS ReceivedQuantity,
            NULL AS OriginalQty,
            NULL AS UnitName,
            NULL AS UnitPrice,
            NULL AS TaxAmount,
            NULL AS DiscountPercentage,
            NULL AS DiscountValue,
            NULL AS ItemValue,
            NULL AS ItemTotal,
            NULL AS IsExpiryDateApplicable,
            NULL AS IsTemperatureApplicable,
            NULL AS ItemWiseRemarks,
            NULL AS IsExcelItem,
            0 AS IsExist,
            NULL AS ExistingItemId,
            ERROR_MESSAGE() AS Message,
            'Error' AS ValidationStatus,
			'' AS jsonCategoryString,
			'' AS jsonUnitString,
			-888 as CategoryId,
            -888 as UnitId,
            '' as jsonSubCategoryString,
            -888 as SubCategoryId;
        
        THROW;
    END CATCH
END

GO

