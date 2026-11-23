
-- =============================================
-- Author:			Vinuki
-- Create date:		21.05.2024
-- Modified by:		Nivesh
-- Modified date:	2024-12-23
-- Modified by:		Isuru
-- Modified date:	2026-10-07
-- Reason:			uploaded TaxGroupId was never validated
-- Description:	upload excel with updated data - supplier wise item details 

-- =============================================

--SP_ExcelDataUploadEditAndInsertion  ''
CREATE PROCEDURE [dbo].[SP_ExcelDataUploadEditAndInsertion]
	@UploadDataJsonToSP VARCHAR(MAX),
	@ColumnListJson VARCHAR(MAX),
	@LocationID int,
	@UserID int,
	@SupplierID int,
	@ProperyID INT,
	@docno VARCHAR(MAX) OUTPUT
AS
BEGIN
SET NOCOUNT ON;
BEGIN TRY 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements. Temp_SupplierItemExcelUpload
	CREATE TABLE #SupplierItemList(
		StockItemCode VARCHAR(20),
		LocationName VARCHAR(100) ,
		ItemName VARCHAR(100) ,
		CostPrice DECIMAL(18, 2) ,
		TaxName VARCHAR(50) ,
		IsDefaultSupplier BIT ,
		TaxGroupId INT ,
		PurchaseUnitName VARCHAR(50) ,
		LocationCode VARCHAR(20) ,
		CategoryName VARCHAR(50) ,
		SubCategoryName VARCHAR(50)
	)

	INSERT INTO #SupplierItemList 
	SELECT * FROM OPENJSON(@UploadDataJsonToSP)
	WITH
	(
		StockItemCode VARCHAR(20) '$.StockItemCode',
		LocationName VARCHAR(100) '$.LocationName',
		ItemName VARCHAR(100) '$.ItemName',
		CostPrice DECIMAL(18, 2) '$.CostPrice',
		TaxName VARCHAR(50) '$.TaxName',
		IsDefaultSupplier BIT '$.IsDefaultSupplier',
		TaxGroupId INT '$.TaxGroupId',
		PurchaseUnitName VARCHAR(50) '$.PurchaseUnitName',
		LocationCode VARCHAR(20) '$.LocationCode',
		CategoryName VARCHAR(50) '$.CategoryName',
		SubCategoryName VARCHAR(50) '$.SubCategoryName'
	)
	
	--added by Isuru 2026-10-07 reject rows whose tax group is not in TaxGroups, before anything is written or staged
	IF EXISTS
	(
		SELECT 1
		FROM #SupplierItemList SIL
		WHERE ISNULL(SIL.TaxGroupId, 0) <= 0
		   OR NOT EXISTS (SELECT 1 FROM TaxGroups TG WHERE TG.TaxGroupId = SIL.TaxGroupId)
	)
	BEGIN
		DECLARE @BadTaxGroupItems VARCHAR(MAX);

		SELECT @BadTaxGroupItems = STRING_AGG(CONVERT(NVARCHAR(MAX), ISNULL(SIL.StockItemCode, 'N/A')), ', ')
		FROM #SupplierItemList SIL
		WHERE ISNULL(SIL.TaxGroupId, 0) <= 0
		   OR NOT EXISTS (SELECT 1 FROM TaxGroups TG WHERE TG.TaxGroupId = SIL.TaxGroupId);

		SET @BadTaxGroupItems = 'A valid tax group is required for every row. Invalid for: '
			+ ISNULL(@BadTaxGroupItems, '');
		RAISERROR(@BadTaxGroupItems,16,1)
	END

	IF EXISTS(SELECT 1 FROM #SupplierItemList)
	BEGIN
		INSERT INTO [dbo].[Temp_SupplierItemExcelUpload]
           ([StockItemCode]
           ,[LocationName]
           ,[ItemName]
           ,[CostPrice]
           ,[TaxName]
           ,[IsDefaultSupplier]
           ,[TaxGroupId]
           ,[PurchaseUnitName]
           ,[LocationCode]
           ,[CategoryName]
           ,[SubCategoryName]
           ,[PropertyID],SupplierID,UserID,LocationID,CreatedDate)
		   SELECT [StockItemCode]
           ,[LocationName]
           ,[ItemName]
           ,[CostPrice]
           ,[TaxName]
           ,[IsDefaultSupplier]
           ,[TaxGroupId]
           ,[PurchaseUnitName]
           ,[LocationCode]
           ,[CategoryName]
           ,[SubCategoryName],@ProperyID,@SupplierID,@UserID,@LocationID,GETDATE() FROM #SupplierItemList
	END
BEGIN TRANSACTION	
	DECLARE @StockItemCode VARCHAR(20)
	DECLARE @stockitemID INT 
	DECLARE @PurchaseUnitID INT 
	DECLARE @PurchaseUnitName VARCHAR(20) , @DuplicateItems VARCHAR(MAX)

	IF NOT EXISTS(SELECT 1 FROM #SupplierItemList)
	BEGIN
		RAISERROR('Item not exists',16,1)
		ROLLBACK TRANSACTION
	END
	ELSE IF EXISTS(SELECT 1 FROM
		#SupplierItemList
		GROUP BY StockItemCode,ItemName,LocationName
		HAVING COUNT(*)>1)
	BEGIN 
		SELECT @DuplicateItems = STRING_AGG(CONVERT(NVARCHAR(max), ISNULL(ItemName,'N/A')), ',') FROM
		#SupplierItemList
		GROUP BY StockItemCode,ItemName,LocationName
		HAVING COUNT(*)>1
		SET	@DuplicateItems = 'Duplicate Items fount'+ @DuplicateItems
		RAISERROR(@DuplicateItems,16,1)
		ROLLBACK TRANSACTION
	END

	DECLARE @RowCount INT;
	SELECT @RowCount = COUNT(*) FROM #SupplierItemList;
	DECLARE @Counter INT = 1;

	WHILE @Counter <= @RowCount
	BEGIN
		
		SELECT 
			@StockItemCode = StockItemCode,
			@PurchaseUnitName = PurchaseUnitName
		FROM
			(SELECT 
				StockItemCode,
				PurchaseUnitName,
				ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNum
			 FROM 
				#SupplierItemList) AS SubQuery
		WHERE
			RowNum = @Counter;

			SELECT TOP(1) @StockItemID = Id
			FROM StockItemHeaders
			WHERE StockItemCode = @StockItemCode AND
			CompanyId = @ProperyID;


			SELECT TOP(1) @PurchaseUnitID = Id
			FROM Units
			WHERE Name = @PurchaseUnitName;

			IF EXISTS ( SELECT 1 FROM SupplierWiseItemDetails WHERE SupplierID = @SupplierID AND StockItemID = @stockitemID AND LocationId = @LocationID)
			BEGIN
				DELETE FROM SupplierWiseItemDetails WHERE SupplierID = @SupplierID AND StockItemID = @stockitemID AND LocationId = @LocationID
			END

				INSERT INTO SupplierWiseItemDetails (
				CompanyId,
				LocationId,
				SupplierID,
				StockItemID,
				PurchaseUnitID,
				CostPrice,
				IsDefaultSupplier,
				CreatedUserID,
				LastModUserID,
				CreatedDate,
				LastModDate,
				IPAddress,
				TBPHeaderID,
				TaxGroupID,
				Validfrom,
				ValidTo
			)
			SELECT
				@ProperyID,
				@LocationID,
				@SupplierID,
				@StockItemID,
				@PurchaseUnitID,
				CostPrice,
				IsDefaultSupplier,
				@UserID,
				@UserID,
				GETDATE(),
				GETDATE(),
				'',
				0,
				TaxGroupId,
				NULL,
				NULL
			FROM #SupplierItemList 
			WHERE
			StockItemCode = @StockItemCode;
		
		SET @Counter = @Counter + 1;
	END;
COMMIT TRANSACTION
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;


END

GO

