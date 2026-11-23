-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-08
-- Description:	Validate excel column data
-- =============================================
-- SP_ValidateExcelRowData '{"StockItemCode":"003","ItemName":"EGG BUN (PRO)","UnitName":"NUMBERS05","ApprovedQuantity":10,"TaxAmount":5,"DiscountValue":10,"DiscountPercentage":"","Price":80}','{"PropertyID":1,"LocationID":1,"RequestHeaderID":6033}','QU','TaxAmount'

CREATE PROCEDURE [dbo].[SP_ValidateExcelRowData]
	@JsonData NVARCHAR(MAX),
	@paramsData NVARCHAR(MAX),
	@TransactionType VARCHAR(5),
	@Name VARCHAR(100)
	--WITH RECOMPILE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TempData TABLE (
			Text varchar(2)
		);
	INSERT INTO Temp_ValidateExcelRowData
	SELECT @JsonData JsonData,@paramsData JsonParamData,@TransactionType TranType, @Name Name, GETDATE() logDate
	
	IF(@TransactionType = 'PR')
	BEGIN

		DECLARE @PropertyID INT, @LocationID INT, @IsDepartmentWiseItemForPR BIT, @DeptId1 INT;

		SELECT @PropertyID =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID =JSON_VALUE(@paramsData, '$.Locationid') ,
				@DeptId1= JSON_VALUE(@JsonData, '$.DepartmentID') 

		SELECT @IsDepartmentWiseItemForPR = IsDepartmentWiseItemForPR FROM Companies WHERE CompanyID = @Propertyid

		IF @IsDepartmentWiseItemForPR IS NULL
			SET @IsDepartmentWiseItemForPR = 0
		
		IF(@IsDepartmentWiseItemForPR =0)
		BEGIN
			IF(@Name = 'StockName')
			BEGIN

				DECLARE  @ItemName VARCHAR(200)
			
				SELECT @ItemName =JSON_VALUE(@JsonData, '$.StockName')

				SELECT * FROM StockItemHeaders SH
				INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
				WHERE SH.Name = @ItemName AND SH.CompanyId = @PropertyID AND SD.LocationID = @LocationID AND SD.IsActive=1

			END

			ELSE IF(@Name = 'UnitName')
			BEGIN

				DECLARE @unitName VARCHAR(100), @StockItemCode VARCHAR(100)

				SELECT @unitName =JSON_VALUE(@JsonData, '$.UnitName')
				SELECT @StockItemCode =JSON_VALUE(@JsonData, '$.StockItemCode')

					--select @unitName unitName, @StockItemCode StockItemCode
				   ;WITH tempTable AS (
					SELECT 
						ToUnitID AS UnitID,
						ToUnitName AS UnitName,
						Value
					FROM dbo.UnitConversions
					WHERE FromUnitName = @unitName AND CompanyId = @PropertyID

					UNION ALL

					SELECT 
						FromUnitID AS UnitID,
						FromUnitName AS UnitName,
						Value
					FROM dbo.UnitConversions
					WHERE ToUnitName = @unitName AND CompanyId = @PropertyID

					UNION

					SELECT 
						Id AS UnitID,
						Name AS UnitName,
						1 AS Value
					FROM dbo.Units
					WHERE Name = @unitName
				)
				 (SELECT * INTO #tempTable2 FROM tempTable)

				SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
				dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
				dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode AND SD.LocationID= @LocationID AND SH.CompanyId = @PropertyID
				and U.Name IN ( SELECT UnitName FROM #tempTable2)
			 
		
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData
			END
		END
		ELSE
		BEGIN
			IF(@Name = 'StockName')
			BEGIN

				DECLARE  @ItemNameV VARCHAR(200)
			
				SELECT @ItemNameV =JSON_VALUE(@JsonData, '$.StockName')

				SELECT * FROM StockItemHeaders SH
				INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
				INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SH.Id
				WHERE SH.Name = @ItemNameV AND SH.CompanyId = @PropertyID AND SD.LocationID = @LocationID AND SD.IsActive=1
				AND DI.DepartmentId =  CASE WHEN @DeptId1 = -999 THEN  DI.DepartmentId ELSE @DeptId1 END

			END

			ELSE IF(@Name = 'UnitName')
			BEGIN

				DECLARE @unitNameV VARCHAR(100), @StockItemCodeV VARCHAR(100)

				SELECT @unitNameV =JSON_VALUE(@JsonData, '$.UnitName')
				SELECT @StockItemCodeV =JSON_VALUE(@JsonData, '$.StockItemCode')

					--select @unitName unitName, @StockItemCode StockItemCode
				   ;WITH tempTable AS (
					SELECT 
						ToUnitID AS UnitID,
						ToUnitName AS UnitName,
						Value
					FROM dbo.UnitConversions
					WHERE FromUnitName = @unitNameV AND CompanyId = @PropertyID

					UNION ALL

					SELECT 
						FromUnitID AS UnitID,
						FromUnitName AS UnitName,
						Value
					FROM dbo.UnitConversions
					WHERE ToUnitName = @unitNameV AND CompanyId = @PropertyID

					UNION

					SELECT 
						Id AS UnitID,
						Name AS UnitName,
						1 AS Value
					FROM dbo.Units
					WHERE Name = @unitNameV
				)
				 (SELECT * INTO #tempTableV FROM tempTable)

				SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
				dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID
				INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SH.Id
				INNER JOIN 
				dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCodeV AND SD.LocationID= @LocationID AND SH.CompanyId = @PropertyID
				AND DI.DepartmentId =  CASE WHEN @DeptId1 = -999 THEN  DI.DepartmentId ELSE @DeptId1 END
				and U.Name IN ( SELECT UnitName FROM #tempTableV)
			 
		
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData
			END
		END
	END
	ELSE IF(@TransactionType = 'PO')
	BEGIN
		DECLARE @PropertyID1 INT, @LocationID1 INT,@Supplierid1 int ,@DiscountPercentage DECIMAL(18,6), @DiscountVal DECIMAL(18,6), @CostPrice DECIMAL(18,6)
		, @ItemName1 VARCHAR(200)
		SELECT @PropertyID1 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID1 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @Supplierid1 =JSON_VALUE(@paramsData, '$.Supplierid')

		IF(@Name = 'Name')
		BEGIN

			
			
			SELECT @ItemName1 =JSON_VALUE(@JsonData, '$.Name')

			SELECT * FROM StockItemHeaders SH
			INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
			INNER JOIN  SupplierWiseItemDetails SWID ON SWID.SupplierID = @Supplierid1 AND SWID.LocationId = @LocationID1 AND SWID.StockItemID = SH.Id
			WHERE SH.Name = @ItemName1 AND SH.CompanyId = @PropertyID1 AND SD.LocationID = @LocationID1 AND SD.IsActive=1

		END
		ELSE IF(@Name ='DiscountPercentage')
		BEGIN
			SELECT @DiscountPercentage = JSON_VALUE(@JsonData, '$.DiscountPercentage')
			SELECT @DiscountVal = JSON_VALUE(@JsonData, '$.DiscountValue')
			SELECT @ItemName1 = JSON_VALUE(@JsonData, '$.Name')

			SELECT @CostPrice = SWID.CostPrice FROM StockItemHeaders SH
			INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
			INNER JOIN  SupplierWiseItemDetails SWID ON SWID.SupplierID = @Supplierid1 AND SWID.LocationId = @LocationID1 AND SWID.StockItemID = SH.Id
			WHERE SH.Name = @ItemName1 AND SH.CompanyId = @PropertyID1 AND SD.LocationID = @LocationID1 AND SD.IsActive=1

			IF(@DiscountPercentage>0 AND @DiscountVal>0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountPercentage<0 OR @DiscountVal<0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountPercentage>0 AND @DiscountPercentage> 100)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 TEXT
			END

		END
		ELSE IF(@Name ='DiscountValue')
		BEGIN
			SELECT @DiscountPercentage = JSON_VALUE(@JsonData, '$.DiscountPercentage')
			SELECT @DiscountVal = JSON_VALUE(@JsonData, '$.DiscountValue')
			SELECT @ItemName1 = JSON_VALUE(@JsonData, '$.Name')

			SELECT @CostPrice = SWID.CostPrice FROM StockItemHeaders SH
			INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
			INNER JOIN  SupplierWiseItemDetails SWID ON SWID.SupplierID = @Supplierid1 AND SWID.LocationId = @LocationID1 AND SWID.StockItemID = SH.Id
			WHERE SH.Name = @ItemName1 AND SH.CompanyId = @PropertyID1 AND SD.LocationID = @LocationID1 AND SD.IsActive=1

			IF(@DiscountPercentage>0 AND @DiscountVal>0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountVal<0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountVal>@CostPrice)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 TEXT
			END

		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName1 VARCHAR(100), @StockItemCode1 VARCHAR(100)
			DECLARE @tempTable2 TABLE(
			UnitID INT,
			UnitName VARCHAR(100),
			Value DECIMAL(18,8)
			)

			SELECT @unitName1 =JSON_VALUE(@JsonData, '$.UnitName')
			SELECT @StockItemCode1 =JSON_VALUE(@JsonData, '$.StockItemCode')

				--select @unitName unitName, @StockItemCode StockItemCode
			   ;WITH tempTable AS (
				SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE FromUnitName = @unitName1 AND CompanyId = @PropertyID1

				UNION ALL

				SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE ToUnitName = @unitName1 AND CompanyId = @PropertyID1

				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
				WHERE Name = @unitName1
			)
			 INSERT INTO @tempTable2 SELECT *  FROM tempTable

			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode1 AND SD.LocationID= @LocationID1 AND SH.CompanyId = @PropertyID1
			and U.Name IN ( SELECT UnitName FROM @tempTable2)
			 
		
		END
		ELSE 
		BEGIN
			SELECT * FROM @TempData
		END


	END
	ELSE IF(@TransactionType = 'IR')
	BEGIN
		DECLARE @PropertyID3 INT, @LocationID3 INT,@DeptId INT, @StockItemCode3 VARCHAR(100)

		SELECT @PropertyID3 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID3 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @DeptId =JSON_VALUE(@paramsData, '$.DepId')	
		SELECT @StockItemCode3 =JSON_VALUE(@JsonData, '$.StockItemCode')

		IF(@Name = 'Name')
		BEGIN

			DECLARE  @ItemName3 VARCHAR(200)
			
			SELECT @ItemName3 =JSON_VALUE(@JsonData, '$.Name')
			DECLARE @IsDeptWiseItem BIT,
				@CompanySeparator NVARCHAR(10),
				@ComCode NVARCHAR(50),
				@DeptCode NVARCHAR(150),@ISGross4 BIT
         
			SELECT @IsDeptWiseItem = IsDepartmentWiseItems, @CompanySeparator = CompanySeparator FROM Companies WHERE CompanyID = @PropertyID3
			SELECT @ComCode = Code,@ISGross4 = IsTaxOrSellPrice FROM  Companies WHERE CompanyID = @PropertyID3
			SELECT @DeptCode = Code FROM Departments WHERE Id = @DeptId

			IF(@IsDeptWiseItem = 1)
			BEGIN

			
				IF(@CompanySeparator = 'JT')
				BEGIN	
					SELECT 
					dbo.StockItemHeaders.Id
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName3 and dbo.StockItemDetails.LocationID = @LocationID3
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode AND DI.GLCompCode = @ComCode AND DI.BlockCode = 'ISN'
							AND dbo.StockItemHeaders.Name = @ItemName3
							
				END					
				ELSE
				BEGIN
					SELECT 
					dbo.StockItemHeaders.Id
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName3 and dbo.StockItemDetails.LocationID = @LocationID3
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId = @DeptId 
							AND dbo.StockItemHeaders.Name = @ItemName3
				END

				
			END
			ELSE
			BEGIN
			    SELECT 
                dbo.StockItemHeaders.Id 
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName3 and dbo.StockItemDetails.LocationID = @LocationID3
				WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
						AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1)
						AND dbo.StockItemHeaders.Name = @ItemName3

			END
		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName3 VARCHAR(100)
			DECLARE @tempTable3 TABLE(
			UnitID INT,
			UnitName VARCHAR(100),
			Value DECIMAL(18,8)
			)

			SELECT @unitName3 =JSON_VALUE(@JsonData, '$.UnitName')
				--select @unitName unitName, @StockItemCode StockItemCode
			   ;WITH tempTable AS (
				SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE FromUnitName = @unitName3 AND CompanyId = @PropertyID3

				UNION ALL

				SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE ToUnitName = @unitName3 AND CompanyId = @PropertyID3

				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
				WHERE Name = @unitName3
			)
			 INSERT INTO @tempTable3 SELECT *  FROM tempTable

			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode3 AND SD.LocationID= @LocationID3 AND SH.CompanyId = @PropertyID3
			and U.Name IN ( SELECT UnitName FROM @tempTable3)
			 
		
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN
			DECLARE @StockItemID INT, @HaveMapping BIT
			SELECT @StockItemID = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode3 AND CompanyId = @PropertyID3
			
			EXEC [dbo].[CheckGLMappings_FroExcel] 
				@StockItemID, 
				'RI', 
				@LocationID3, 
				@PropertyID3, 
				@DeptId, 
				@HaveMapping OUTPUT ; --Check GL mapping

			IF(@HaveMapping = 1)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
		END
		ELSE
		BEGIN
	
			SELECT * FROM @TempData --When result no exists

		END
	END 
	ELSE IF(@TransactionType = 'GR')
	BEGIN
		DECLARE @PropertyID4 INT, @LocationID4 INT,@Supplierid4 int ,@DiscountPercentage4 DECIMAL(18,6), @DiscountVal4 DECIMAL(18,6), @CostPrice4 DECIMAL(18,6)
		, @ItemName4 VARCHAR(200)
		SELECT @PropertyID4 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID4 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @Supplierid4 =JSON_VALUE(@paramsData, '$.Supplierid')

		IF(@Name = 'Name')
		BEGIN

			
			
			SELECT @ItemName4 =JSON_VALUE(@JsonData, '$.Name')

			SELECT * FROM StockItemHeaders SH
			INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
			INNER JOIN  SupplierWiseItemDetails SWID ON SWID.SupplierID = @Supplierid4 AND SWID.LocationId = @LocationID4 AND SWID.StockItemID = SH.Id
			WHERE SH.Name = @ItemName4 AND SH.CompanyId = @PropertyID4 AND SD.LocationID = @LocationID4 AND SD.IsActive=1

		END
		ELSE IF(@Name ='DiscountPercentage')
		BEGIN
			SELECT @DiscountPercentage4 = JSON_VALUE(@JsonData, '$.DiscountPercentage')
			SELECT @DiscountVal4 = JSON_VALUE(@JsonData, '$.DiscountValue')
			SELECT @ItemName4 = JSON_VALUE(@JsonData, '$.Name')

			SELECT @CostPrice4 = SWID.CostPrice FROM StockItemHeaders SH
			INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
			INNER JOIN  SupplierWiseItemDetails SWID ON SWID.SupplierID = @Supplierid4 AND SWID.LocationId = @LocationID4 AND SWID.StockItemID = SH.Id
			WHERE SH.Name = @ItemName4 AND SH.CompanyId = @PropertyID4 AND SD.LocationID = @LocationID4 AND SD.IsActive=1

			IF(@DiscountPercentage4>0 AND @DiscountVal4>0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountPercentage4<0 OR @DiscountVal4<0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountPercentage4>0 AND @DiscountPercentage4> 100)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 TEXT
			END

		END
		ELSE IF(@Name ='DiscountValue')
		BEGIN
			SELECT @DiscountPercentage4 = JSON_VALUE(@JsonData, '$.DiscountPercentage')
			SELECT @DiscountVal4 = JSON_VALUE(@JsonData, '$.DiscountValue')
			SELECT @ItemName4 = JSON_VALUE(@JsonData, '$.Name')
			SELECT @CostPrice4 = JSON_VALUE(@JsonData, '$.CostPrice')
			DECLARE @RequestedQuantity4 DECIMAL(18,8) = JSON_VALUE(@JsonData, '$.RequestedQuantity')

			IF(@CostPrice4 IS NULL OR @CostPrice4 <0)
			BEGIN
				SELECT @CostPrice4 = SWID.CostPrice FROM StockItemHeaders SH
				INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SH.id
				INNER JOIN  SupplierWiseItemDetails SWID ON SWID.SupplierID = @Supplierid4 AND SWID.LocationId = @LocationID4 AND SWID.StockItemID = SH.Id
				WHERE SH.Name = @ItemName4 AND SH.CompanyId = @PropertyID4 AND SD.LocationID = @LocationID4 AND SD.IsActive=1
			END
			IF(@DiscountPercentage4>0 AND @DiscountVal4>0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountVal4<0)
			BEGIN
				SELECT * FROM @TempData
			END

			ELSE IF(@DiscountVal4>@CostPrice4)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 TEXT
			END

		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName4 VARCHAR(100), @StockItemCode4 VARCHAR(100)
			DECLARE @tempTable4 TABLE(
			UnitID INT,
			UnitName VARCHAR(100),
			Value DECIMAL(18,8)
			)

			SELECT @unitName4 =JSON_VALUE(@JsonData, '$.UnitName')
			SELECT @StockItemCode4 =JSON_VALUE(@JsonData, '$.StockItemCode')

				--select @unitName unitName, @StockItemCode StockItemCode
			   ;WITH tempTable AS (
				SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE FromUnitName = @unitName4 AND CompanyId = @PropertyID4

				UNION ALL

				SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE ToUnitName = @unitName4 AND CompanyId = @PropertyID4

				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
				WHERE Name = @unitName4
			)
			 INSERT INTO @tempTable4 SELECT *  FROM tempTable

			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode4 AND SD.LocationID= @LocationID4 AND SH.CompanyId = @PropertyID4
			and U.Name IN ( SELECT UnitName FROM @tempTable4)
			 
		
		END
		ELSE IF(@Name = 'CostPrice')
		BEGIN
			 
			SELECT @CostPrice4 =JSON_VALUE(@JsonData, '$.CostPrice')

			IF(@CostPrice4<0 OR @CostPrice4 IS NULL)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 'text'
			END
		END
		ELSE IF(@Name = 'RequestedQuantity')
		BEGIN
			 
			SELECT @RequestedQuantity4 =JSON_VALUE(@JsonData, '$.RequestedQuantity')

			IF(@RequestedQuantity4 <= 0 OR @RequestedQuantity4 IS NULL)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 'text'
			END
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN

			DECLARE @AccName NVARCHAR(250), @StockItemID4 INT
			
			SELECT @StockItemID4 = SIH.Id FROM StockItemHeaders SIH
			INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id
			INNER JOIN SupplierWiseItemDetails SWID ON SWID.LocationId = @LocationID4 AND SWID.CompanyId = @PropertyID4 AND SWID.SupplierID = @Supplierid4
			WHERE SID.LocationID = @LocationID4 AND SIH.CompanyId = @PropertyID4 AND SID.IsActive=1			
			
			SELECT @AccName=  [dbo].[FUN_GetItemLevelAccountName](@PropertyID4, @LocationID4, @StockItemID4)

			IF(@AccName IS NULL)
			BEGIN
				SELECT * FROM @TempData
			END
			ELSE
			BEGIN
				SELECT 1 'text'
			END

		END
		ELSE 
		BEGIN
			SELECT * FROM @TempData
		END


	END
	ELSE IF(@TransactionType = 'DIR')
	BEGIN
		DECLARE @PropertyID5 INT, @LocationID5 INT, @StockItemCode5 VARCHAR(100), @ToLocationid5 INT, @DeptId5 INT = -999

		SELECT @PropertyID5 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID5 =JSON_VALUE(@paramsData, '$.Locationid')
		SELECT @StockItemCode5 =JSON_VALUE(@JsonData, '$.StockItemCode')
		SELECT @ToLocationid5 =JSON_VALUE(@paramsData, '$.Locationid2')

		IF(@Name = 'Name')
		BEGIN

			DECLARE  @ItemName5 VARCHAR(200)
			
			SELECT @ItemName5 =JSON_VALUE(@JsonData, '$.Name')

			IF(@LocationID5 = @ToLocationid5)
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
			ELSE
			BEGIN
			    SELECT 
                dbo.StockItemHeaders.Id 
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName5 and dbo.StockItemDetails.LocationID = @LocationID5
						INNER JOIN 
						(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid5 AND SID2.CompanyID = @PropertyID5 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID =dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID = @LocationID5 )
						AND ( dbo.StockItemDetails.PropertyID = @PropertyID5 ) AND (dbo.StockItemDetails.IsActive = 1)
						AND dbo.StockItemHeaders.Name = @ItemName5			
			END



		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName5 VARCHAR(100)
			DECLARE @tempTable5 TABLE(
			UnitID INT,
			UnitName VARCHAR(100),
			Value DECIMAL(18,8)
			)

			SELECT @unitName5 =JSON_VALUE(@JsonData, '$.UnitName')
				--select @unitName unitName, @StockItemCode StockItemCode
			   ;WITH tempTable AS (
				SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE FromUnitName = @unitName5 AND CompanyId = @PropertyID5

				UNION ALL

				SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE ToUnitName = @unitName5 AND CompanyId = @PropertyID5

				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
				WHERE Name = @unitName5
			)
			 INSERT INTO @tempTable5 SELECT *  FROM tempTable

			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode5 AND SD.LocationID= @LocationID5 AND SH.CompanyId = @PropertyID5
			and U.Name IN ( SELECT UnitName FROM @tempTable5)

			IF EXISTS(
			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode5 AND SD.LocationID= @LocationID5 AND SH.CompanyId = @PropertyID5
			and U.Name IN ( SELECT UnitName FROM @tempTable5) ) AND
			EXISTS(
			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode5 AND SD.LocationID= @ToLocationid5 AND SH.CompanyId = @PropertyID5
			and U.Name IN ( SELECT UnitName FROM @tempTable5))
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
			 
		
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN
			DECLARE @StockItemID5 INT, @HaveMapping5 BIT,@ToHaveMapping5 BIT
			SELECT @StockItemID5 = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode5 AND CompanyId = @PropertyID5
			
			EXEC [dbo].[CheckGLMappings_FroExcel] 
				@StockItemID5, 
				'RI', 
				@LocationID5, 
				@PropertyID5, 
				@DeptId5, 
				@HaveMapping5 OUTPUT ; --Check GL mapping
			
			EXEC [dbo].[CheckGLMappings_FroExcel] 
				@StockItemID5, 
				'RI', 
				@ToLocationid5, 
				@PropertyID5, 
				@DeptId5, 
				@ToHaveMapping5 OUTPUT ; --Check GL mapping

			IF(@HaveMapping5 = 1 AND @ToHaveMapping5=1)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
		END
		ELSE
		BEGIN
	
			SELECT * FROM @TempData --When result no exists

		END
	END 
	ELSE IF(@TransactionType = 'QU')
	BEGIN

	DECLARE @PropertyIDQU INT,@LocationIDQU INT,@RequestHeaderIDQU INT,@StockItemCodeQU VARCHAR(MAX),@UnitQU VARCHAR(MAX), @TaxAmountQU MONEY, @DiscountValueQU MONEY, @DiscountPercentageQU MONEY, @PriceQU MONEY

	
		SELECT @PropertyIDQU =JSON_VALUE(@paramsData, '$.PropertyID')
		SELECT @LocationIDQU =JSON_VALUE(@paramsData, '$.LocationID')
		SELECT @RequestHeaderIDQU =JSON_VALUE(@paramsData, '$.RequestHeaderID') 

		SELECT @DiscountValueQU =JSON_VALUE(@JsonData, '$.DiscountValue')
		SELECT @DiscountPercentageQU =JSON_VALUE(@JsonData, '$.DiscountPercentage')
		SELECT @TaxAmountQU =JSON_VALUE(@JsonData, '$.TaxAmount')
		SELECT @PriceQU =JSON_VALUE(@JsonData, '$.Price')

		IF(@Name = 'StockItemCode')
		BEGIN
			SELECT @StockItemCodeQU =JSON_VALUE(@JsonData, '$.StockItemCode')

			IF EXISTS (SELECT 1
			FROM StockItemHeaders SH
			INNER JOIN RequestDetails RD ON SH.Id = RD.StockItemID
			WHERE RD.RequestHeaderID = @RequestHeaderIDQU
			AND SH.StockItemCode = @StockItemCodeQU	)
			BEGIN
				SELECT DISTINCT SH.*
				FROM StockItemHeaders SH
				INNER JOIN RequestDetails RD ON SH.Id = RD.StockItemID
				WHERE RD.RequestHeaderID = @RequestHeaderIDQU
				AND SH.StockItemCode = @StockItemCodeQU	
			END
			ELSE
			BEGIN
			 SELECT 1 TEXT
			END
		END

		ELSE IF(@Name = 'UnitName')
		BEGIN
			SELECT @UnitQU =JSON_VALUE(@JsonData, '$.UnitName')

			IF EXISTS(SELECT 1
			FROM RequestHeaders RH
			INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
			INNER JOIN Units UN ON  UN.Id = RD.UnitID
			WHERE RH.Id = @RequestHeaderIDQU
			AND UN.Name = @UnitQU)
			BEGIN
				SELECT DISTINCT UN.*
				FROM RequestHeaders RH
				INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
				INNER JOIN Units UN ON  UN.Id = RD.UnitID
				WHERE RH.Id = @RequestHeaderIDQU
				AND UN.Name = @UnitQU
			END
			ELSE
			BEGIN
			 SELECT 1 TEXT
			END
		END
		ELSE IF(@Name = 'Price')
		BEGIN
			IF (TRY_CAST(@PriceQU AS DECIMAL(18,2)) IS NULL AND @PriceQU <> '') OR @PriceQU <=0 
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
			ELSE
			BEGIN
			 SELECT 1 TEXT
			END
		END
		ELSE IF(@Name = 'TaxAmount')
		BEGIN
			IF (TRY_CAST(@TaxAmountQU AS DECIMAL(18,2)) IS NULL AND @TaxAmountQU <> '') OR @TaxAmountQU <0 
			BEGIN
			 SELECT * FROM @TempData --When result no exists
			END
			ELSE IF NOT EXISTS (
				SELECT 1 FROM TaxGroupDetails  TG
				INNER JOIN TaxDetails TD ON TD.TaxTypeId = TG.TaxTypeId AND TG.ChargeRate = @TaxAmountQU
			)
			BEGIN
			 SELECT * FROM @TempData --When result no exists
			END			
			ELSE
			BEGIN
			 SELECT 1 TEXT
			END


		END
		ELSE IF(@Name = 'DiscountValue')
		BEGIN
			IF (TRY_CAST(@DiscountValueQU AS DECIMAL(18,2)) IS NULL AND @DiscountValueQU <> '')  OR @DiscountValueQU <0 OR @DiscountValueQU >= @PriceQU
			BEGIN
			 SELECT * FROM @TempData --When result no exists
			END
			ELSE IF(@DiscountPercentageQU >0 AND @DiscountValueQU >0)
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
			ELSE
			BEGIN
				SELECT 1 TEXT
			END

		END
		ELSE IF(@Name = 'DiscountPercentage')
		BEGIN
			IF (
				TRY_CAST(@DiscountPercentageQU AS DECIMAL(18,2)) IS NULL 
				AND @DiscountPercentageQU <> ''
			) 
			OR @DiscountPercentageQU < 0 
			OR @DiscountPercentageQU >= 100 
			OR (
				@DiscountPercentageQU >0 
				AND @DiscountValueQU >0
			)
			BEGIN
			 SELECT * FROM @TempData --When result no exists
			END
			ELSE
			BEGIN
				SELECT 1 TEXT
			END
		END

	END
	ELSE IF(@TransactionType = 'CR')
	BEGIN
		DECLARE @PropertyID6 INT, @LocationID6 INT,@ToLocationid6 INT, @StockItemCode6 VARCHAR(100), @DeptId6 INT = -999

		SELECT @PropertyID6 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID6 =JSON_VALUE(@paramsData, '$.Locationid')
		SELECT @StockItemCode6 =JSON_VALUE(@JsonData, '$.StockItemCode')
		SELECT @ToLocationid6 =JSON_VALUE(@paramsData, '$.Locationid2')
		
		IF(@Name = 'StockName')
		BEGIN

			DECLARE  @ItemName6 VARCHAR(200)
			
			SELECT @ItemName6 =JSON_VALUE(@JsonData, '$.StockName')
			
			IF(@LocationID6 = @ToLocationid6)
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
			ELSE
			BEGIN

			    SELECT 
                dbo.StockItemHeaders.Id 
				FROM    dbo.StockItemDetails
				INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName6 and dbo.StockItemDetails.LocationID = @LocationID6
				INNER JOIN 
				(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid6 AND SID2.CompanyID = @PropertyID6 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID =dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID6 )
				AND ( dbo.StockItemDetails.PropertyID = @PropertyID6 ) AND (dbo.StockItemDetails.IsActive = 1)
				AND dbo.StockItemHeaders.Name = @ItemName6	
			END

		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName6 VARCHAR(100)
			DECLARE @tempTable6 TABLE(
			UnitID INT,
			UnitName VARCHAR(100),
			Value DECIMAL(18,8)
			)

			SELECT @unitName6 =JSON_VALUE(@JsonData, '$.UnitName')
				--select @unitName unitName, @StockItemCode StockItemCode
			   ;WITH tempTable AS (
				SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE FromUnitName = @unitName6 AND CompanyId = @PropertyID6

				UNION ALL

				SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE ToUnitName = @unitName6 AND CompanyId = @PropertyID6

				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
				WHERE Name = @unitName6
			)
			 INSERT INTO @tempTable6 SELECT *  FROM tempTable

			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode6 AND SD.LocationID= @LocationID6 AND SH.CompanyId = @PropertyID6
			and U.Name IN ( SELECT UnitName FROM @tempTable6)

			IF EXISTS(
			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode6 AND SD.LocationID= @LocationID6 AND SH.CompanyId = @PropertyID6
			and U.Name IN ( SELECT UnitName FROM @tempTable6) ) AND
			EXISTS(
			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode6 AND SD.LocationID= @ToLocationid6 AND SH.CompanyId = @PropertyID6
			and U.Name IN ( SELECT UnitName FROM @tempTable6))
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
			 
		
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN
			DECLARE @StockItemID6 INT = NULL, @HaveMapping6 BIT,@ToHaveMapping6 BIT
			SELECT @StockItemID6 = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode6 AND CompanyId = @PropertyID6
			
			

			IF(@StockItemID6 IS NOT NULL)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
		END
		ELSE IF(@Name = 'Quantity')
		BEGIN
			DECLARE @Qty6 MONEY
			SELECT @Qty6 = JSON_VALUE(@JsonData, '$.Quantity')
			
			

			IF(@Qty6 IS NOT NULL AND @Qty6 >=0)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
		END
		ELSE IF(@Name = 'DeliverySchedule')
		BEGIN
			DECLARE @DeliverySchedule VARCHAR(200)

			SELECT @DeliverySchedule = JSON_VALUE(@JsonData, '$.DeliverySchedule')
			
			

			IF EXISTS (SELECT 1 FROM DeliverySchedule WHERE [Name] = @DeliverySchedule)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
		END
		ELSE
		BEGIN
	
			SELECT * FROM @TempData --When result no exists

		END
	END 
	ELSE IF(@TransactionType = 'DIN')
	BEGIN
		DECLARE @PropertyID7 INT, @LocationID7 INT,@DeptId7 INT, @StockItemCode7 VARCHAR(100),@RequestedQuantity DECIMAL(18,6),@QuantityInHand DECIMAL(18,6)

		SELECT @PropertyID7 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID7 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @DeptId7 =JSON_VALUE(@paramsData, '$.DepId')	
		SELECT @StockItemCode7 =JSON_VALUE(@JsonData, '$.StockItemCode')
		SELECT @RequestedQuantity =JSON_VALUE(@JsonData, '$.RequestedQuantity')
		SELECT @QuantityInHand =JSON_VALUE(@JsonData, '$.QuantityInHand')

		IF(@Name = 'Name')
		BEGIN

			DECLARE  @ItemName7 VARCHAR(200)
			
			SELECT @ItemName7 =JSON_VALUE(@JsonData, '$.Name')
			DECLARE @IsDeptWiseItem7 BIT,
				@CompanySeparator7 NVARCHAR(10),
				@ComCode7 NVARCHAR(50),
				@DeptCode7 NVARCHAR(150),@ISGross7 BIT
         
			SELECT @IsDeptWiseItem7 = IsDepartmentWiseItems, @CompanySeparator7 = CompanySeparator FROM Companies WHERE CompanyID = @PropertyID7
			SELECT @ComCode7 = Code,@ISGross7 = IsTaxOrSellPrice FROM  Companies WHERE CompanyID = @PropertyID7
			SELECT @DeptCode7 = Code FROM Departments WHERE Id = @DeptId7

			IF(@IsDeptWiseItem7 = 1)
			BEGIN

			
				IF(@CompanySeparator7 = 'JT')
				BEGIN	
					SELECT 
					dbo.StockItemHeaders.Id
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName7 and dbo.StockItemDetails.LocationID = @LocationID7
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID7 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID7 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode7 AND DI.GLCompCode = @ComCode7 AND DI.BlockCode = 'ISN'
							AND dbo.StockItemHeaders.Name = @ItemName7
							
				END					
				ELSE
				BEGIN
					SELECT 
					dbo.StockItemHeaders.Id
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName7 and dbo.StockItemDetails.LocationID = @LocationID7
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID7 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID7 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId = @DeptId7 
							AND dbo.StockItemHeaders.Name = @ItemName7
				END

				
			END
			ELSE
			BEGIN
			    SELECT 
                dbo.StockItemHeaders.Id 
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  AND dbo.StockItemHeaders.Name = @ItemName7 and dbo.StockItemDetails.LocationID = @LocationID3
				WHERE   ( dbo.StockItemDetails.LocationID = @LocationID7 )
						AND ( dbo.StockItemDetails.PropertyID = @PropertyID7 ) AND (dbo.StockItemDetails.IsActive = 1)
						AND dbo.StockItemHeaders.Name = @ItemName7

			END
		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName7 VARCHAR(100)
			DECLARE @tempTable7 TABLE(
			UnitID INT,
			UnitName VARCHAR(100),
			Value DECIMAL(18,8)
			)

			SELECT @unitName7 =JSON_VALUE(@JsonData, '$.UnitName')
				--select @unitName unitName, @StockItemCode StockItemCode
			   ;WITH tempTable AS (
				SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE FromUnitName = @unitName7 AND CompanyId = @PropertyID7

				UNION ALL

				SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE ToUnitName = @unitName7 AND CompanyId = @PropertyID7

				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
				WHERE Name = @unitName7
			)
			 INSERT INTO @tempTable7 SELECT *  FROM tempTable

			SELECT 1  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.StockItemCode= @StockItemCode7 AND SD.LocationID= @LocationID7 AND SH.CompanyId = @PropertyID7
			and U.Name IN ( SELECT UnitName FROM @tempTable7)
			 
		
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN
			DECLARE @StockItemID7 INT, @HaveMapping7 BIT
			SELECT @StockItemID7 = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode7 AND CompanyId = @PropertyID7
			
			EXEC [dbo].[CheckGLMappings_FroExcel] 
				@StockItemID7, 
				'RI', 
				@LocationID7, 
				@PropertyID7, 
				@DeptId7, 
				@HaveMapping7 OUTPUT ; --Check GL mapping

			IF(@HaveMapping7 = 1)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData --When result no exists
			END
		END
		ELSE IF(@Name = 'RequestedQuantity')
		BEGIN
			DECLARE @StockItemID8 INT
			SELECT @StockItemID8 = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode7 AND CompanyId = @PropertyID7
			
			

			IF(@RequestedQuantity <= @QuantityInHand)
			BEGIN
				SELECT 'PASS' text
			END
			ELSE
			BEGIN
				SELECT * FROM @TempData 
			END
		END
		ELSE
		BEGIN
	
			SELECT * FROM @TempData --When result no exists

		END
	END 
	ELSE
	BEGIN

		SELECT * FROM @TempData --When result no exists

	END 
END

GO

