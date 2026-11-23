-- =============================================
-- Author:		Nivesh
-- Create date: 2024-09-10
-- Description:	Get All Stock Reconciliation Items Excel Data
-- =============================================
-- [GetAllStockReconciliationItems] 1, 1, '2024-09-12', 5
CREATE PROCEDURE [dbo].[GetAllStockReconciliationItems] (
	@PropertyId INT,
	@LocationID INT,
	@TxnDate date=null ,
	@excelCategoryID INT = -999,
	@IsWithoutExpiryDate BIT = 0
	)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY 
	DECLARE @DeptId INT = -999
	------------------------------------------------
	IF OBJECT_ID('tempdb..#TempDetail2') IS NOT NULL
BEGIN
    DROP TABLE #TempDetail2;
END
	CREATE TABLE #TempDetail2 (
	Id INT,
	IsExpiryDateApplicable BIT
	
	)
		IF @DeptId IS NULL SET @DeptId = -999
			
        DECLARE @Locationid2 INT= @Locationid ,
            @Propertyid2 INT = @Propertyid,
			@IsDeptWiseItem BIT,
			@CompanySeparator NVARCHAR(10),
			@ComCode NVARCHAR(50),
			@DeptCode NVARCHAR(150)

			SELECT @IsDeptWiseItem = IsDepartmentWiseItems, @CompanySeparator = CompanySeparator FROM Companies WHERE CompanyID = @Propertyid
			SELECT @ComCode = Code FROM  Companies WHERE CompanyID = @PropertyId
			SELECT @DeptCode = Code FROM Departments WHERE Id = @DeptId

			--select @DeptCode,@ComCode

			IF(@IsDeptWiseItem = 1 AND @DeptId <> -999)
			BEGIN
			TRUNCATE TABLE #TempDetail2
			
				IF(@CompanySeparator = 'JT')
				BEGIN	
					INSERT INTO #TempDetail2(Id,IsExpiryDateApplicable)
					SELECT DISTINCT
					dbo.StockItemHeaders.Id ,dbo.StockItemHeaders.IsExpiryDateApplicable
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode AND DI.GLCompCode = @ComCode AND DI.BlockCode = 'ISN'
							AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @excelCategoryID = -999 THEN dbo.StockItemHeaders.CategoryID ELSE @excelCategoryID END )
							AND dbo.StockItemHeaders.IsExpiryDateApplicable = CASE WHEN @IsWithoutExpiryDate = 1 THEN 0 ELSE dbo.StockItemHeaders.IsExpiryDateApplicable END
							
				END					
				ELSE
				BEGIN

				TRUNCATE TABLE #TempDetail2

				INSERT INTO #TempDetail2(Id,IsExpiryDateApplicable)
					SELECT DISTINCT
					dbo.StockItemHeaders.Id ,StockItemHeaders.IsExpiryDateApplicable
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END
							AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @excelCategoryID = -999 THEN dbo.StockItemHeaders.CategoryID ELSE @excelCategoryID END )
							AND dbo.StockItemHeaders.IsExpiryDateApplicable = CASE WHEN @IsWithoutExpiryDate = 1 THEN 0 ELSE dbo.StockItemHeaders.IsExpiryDateApplicable END
				END

				
			END
			ELSE
			BEGIN
			
				TRUNCATE TABLE #TempDetail2

				INSERT INTO #TempDetail2(Id,IsExpiryDateApplicable)
			    SELECT 
                dbo.StockItemHeaders.Id ,StockItemHeaders.IsExpiryDateApplicable
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID = @Locationid2 )
						AND ( dbo.StockItemDetails.PropertyID = @Propertyid2 ) AND (dbo.StockItemDetails.IsActive = 1)
						AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @excelCategoryID = -999 THEN dbo.StockItemHeaders.CategoryID ELSE @excelCategoryID END )
						AND dbo.StockItemHeaders.IsExpiryDateApplicable = CASE WHEN @IsWithoutExpiryDate = 1 THEN 0 ELSE dbo.StockItemHeaders.IsExpiryDateApplicable END
			END
	--------------------------------------------------
		declare  @ErrorMessage NVARCHAR(4000); 


	SELECT	
		H.id StockItemID,
		H.Name StockName,
		C.id CategoryID,
		C.Name CategoryName,
		U.id UnitID,
		U.Name UnitName,
		sd.MasterUnitID MasterUnitID,
		[dbo].[GetBalance](@TxnDate ,h.Id,@LocationID,0,0) QuantityInHand,
		0 Quantity,
		sd.AveragePrice AS UnitPrice,
		H.StockItemCode,
		TD.IsExpiryDateApplicable
	FROM			StockItemHeaders H
	INNER JOIN  dbo.StockItemDetails SD ON sd.StockItemHeaderID = h.Id	
	INNER JOIN	Units U on u.Id = sd.MasterUnitID
	INNER JOIN	Categories C on C.Id = H.CategoryId 
	INNER JOIN Locations L on l.Id = sd.LocationID
	INNER JOIN #TempDetail2 TD on td.Id = H.ID	
	WHERE SD.LocationID =@LocationID AND H.CompanyId = @PropertyId AND H.CategoryID = CASE WHEN @excelCategoryID = -999 THEN H.CategoryID ELSE @excelCategoryID END
	ORDER BY H.Name

	END TRY
	BEGIN CATCH
		 
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

