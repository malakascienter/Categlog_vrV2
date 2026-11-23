-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-08
-- Description:	Validate excel column data
-- =============================================
-- SP_ValidateExcelRowAllData '[{"StockItemCode":"FOD/DAI/BUT/001","Name":"ANCHOR BUTTER ffff","RequestedQuantity":1,"UnitName":"KILOGRAM jjj","Remarks":""},{"StockItemCode":"FOD/DAI/BUT/002","Name":"BUTTER  SALTED 227GM","RequestedQuantity":1,"UnitName":"KILOGRAM ","Remarks":""},{"StockItemCode":"FOD/DAI/BUT/003","Name":"BUTTER BLOCK UNSALTED","RequestedQuantity":1,"UnitName":"KILOGRAM ","Remarks":""}]','["StockItemCode","Name","RequestedQuantity","UnitName","Remarks"]','{"Id":"1","Name":"StockItemCode","IsActive":"true","IsInputField":"false","InputType":"text","width":"30px","ColorDuplicate":"Green","ColorValidate":"Red","IsValidate":"true","IsDuplicate":"false","ErrorMessage":"GL mapping error","SPName":"SP_ValidateExcelRowData"}', '{"Propertyid":1,"Locationid":1,"DepId":59}', 'IR', 'UnitName'

CREATE PROCEDURE [dbo].[SP_ValidateExcelRowAllData]
	@JsonData NVARCHAR(MAX),
	@JsonActiveNames NVARCHAR(MAX),
	@JsonFilterValidColumnConfigurationData NVARCHAR(MAX),
	@paramsData NVARCHAR(MAX),
	@TransactionType VARCHAR(5),
	@Name VARCHAR(100)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	insert into ValidateExcelRowAllData
	Select @JsonData JsonData, @JsonActiveNames JsonActiveNames, @JsonFilterValidColumnConfigurationData JsonFilterValidColumnConfigurationData, @paramsData paramsData,
	@TransactionType TransactionType, @Name Name, getdate() logDate 

	DECLARE @TempData TABLE (
			Text varchar(2)
		);

	IF(@TransactionType = 'PR')
	BEGIN

		DECLARE @PropertyID INT, @LocationID INT

		SELECT @PropertyID =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID =JSON_VALUE(@paramsData, '$.Locationid')

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
		DECLARE @PropertyID3 INT, @LocationID3 INT,@DeptId INT, @StockItemCode3 VARCHAR(100), @ColumnIndex int

		SELECT @PropertyID3 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID3 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @DeptId =JSON_VALUE(@paramsData, '$.DepId')	
		SELECT @StockItemCode3 =JSON_VALUE(@JsonData, '$.StockItemCode')

		IF(@Name = 'Name')
		BEGIN

			SELECT @ColumnIndex= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table3 table(
							Name NVARCHAR(200)
			)

			insert into @table3
			SELECT 
			Name
			FROM OPENJSON(@JsonData)
			WITH (
				Name NVARCHAR(200)
			);

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
					T.Name, case when T2.Id is null then 0 else 1 end IsVal, @ColumnIndex ColumnIndex
					FROM @table3  T 
					left join (
					select dbo.StockItemHeaders.Name,dbo.StockItemHeaders.Id
					from
					dbo.StockItemHeaders
					 INNER JOIN dbo.StockItemDetails on  dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  and dbo.StockItemDetails.LocationID = @LocationID3
							
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode AND DI.GLCompCode = @ComCode AND DI.BlockCode = 'ISN'
					) T2 on T.Name = T2.Name
							
				END					
				ELSE
				BEGIN
					SELECT 
					T.Name, case when T2.Id is null then 0 else 1 end IsVal, @ColumnIndex ColumnIndex
					FROM @table3   T 
					left join (
					select dbo.StockItemHeaders.Name,dbo.StockItemHeaders.Id from
					dbo.StockItemHeaders 
					 INNER JOIN dbo.StockItemDetails on  dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  and dbo.StockItemDetails.LocationID = @LocationID3
							
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId = @DeptId
					) T2 on T2.Name = T.Name
				END

				
			END
			ELSE
			BEGIN
			    SELECT 
                T.Name, case when T2.Id is null then 0 else 1 end IsVal, @ColumnIndex ColumnIndex
				FROM @table3 T 
					left join (
					select dbo.StockItemHeaders.Name,dbo.StockItemHeaders.Id from
					dbo.StockItemHeaders 
					 INNER JOIN dbo.StockItemDetails on  dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  and dbo.StockItemDetails.LocationID = @LocationID3
							
				WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
						AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1)
					) T2 on T2.Name = T.Name
					

			END
		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName3 VARCHAR(100)
			DECLARE @tempTable3 TABLE(
			UnitName VARCHAR(100),
			Name VARCHAR(100),
			UnitID int
			)
			SELECT @ColumnIndex= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table4 table(
				UnitName NVARCHAR(200),
				Name varchar(200)
			)

			insert into @table4
			SELECT 
			UnitName,Name
			FROM OPENJSON(@JsonData)
			WITH (
				UnitName NVARCHAR(200),
				Name varchar(200)
			);

			;with tempTable As(
			select distinct  T.UnitName,T.Name,T2.UnitID from
			@table4 T
			left join (
			SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE CompanyId = @PropertyID3
			union all
			SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE CompanyId = @PropertyID3
				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
			) T2 on t2.UnitName =T.UnitName
			)
			insert into @tempTable3 select * from tempTable

			select t.UnitName,@ColumnIndex ColumnIndex, case when t2.Name is null then 0 else 1 end IsVal from @tempTable3 t
			left join (
			SELECT U.Name UnitName, sh.name  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE  SD.LocationID= @LocationID3 AND SH.CompanyId = @PropertyID3
			) t2 on t2.UnitName = t.UnitName and t.Name = t2.Name
			
			 
		
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN
			DECLARE @StockItemID INT, @HaveMapping BIT
			SELECT @StockItemID = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode3 AND CompanyId = @PropertyID3

			SELECT @ColumnIndex= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table5 table(
							StockItemCode NVARCHAR(200)
			)

			insert into @table5
			SELECT 
			StockItemCode
			FROM OPENJSON(@JsonData)
			WITH (
				StockItemCode NVARCHAR(200)
			);
			
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
		, @ItemName4 VARCHAR(200), @ColumnIndex4 INT, @StockItemCode4 VARCHAR(100)

		SELECT @PropertyID4 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID4 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @Supplierid4 =JSON_VALUE(@paramsData, '$.Supplierid')	
		SELECT @StockItemCode4 =JSON_VALUE(@JsonData, '$.StockItemCode')	
		
		IF(@Name = 'StockItemCode')
		BEGIN

			SELECT @ColumnIndex4= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table6 table(
				StockItemCode NVARCHAR(100)
			)

			insert into @table6
			SELECT 
				StockItemCode
			FROM OPENJSON(@JsonData)
			WITH (
				StockItemCode NVARCHAR(100)
			);

			SELECT T.StockItemCode,CASE WHEN T2.AccNum IS NULL THEN 0 ELSE 1 END IsVal  FROM
			@table6 T 
			LEFT JOIN 
			(
			SELECT sih.StockItemCode Name,
			  [dbo].[FUN_GetItemLevelAccountName](@PropertyID4, @LocationID4, SIH.Id) AccNum
			FROM StockItemHeaders SIH
			INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id
			INNER JOIN SupplierWiseItemDetails SWID ON SWID.LocationId = @LocationID4 AND SWID.CompanyId = @PropertyID4 AND SWID.SupplierID = @Supplierid4 and SWID.StockItemID = SIH.Id
			WHERE SID.LocationID = @LocationID4 AND SIH.CompanyId = @PropertyID4 AND SID.IsActive=1				
			) T2 ON T2.Name = T.StockItemCode

			--;with temptable4 as(
			--SELECT T.StockItemCode,CASE WHEN T2.AccNum IS NULL THEN 0 ELSE 1 END IsVal  FROM
			--@table6 T 
			--LEFT JOIN 
			--(
			--SELECT sih.StockItemCode Name,
			--  [dbo].[FUN_GetItemLevelAccountName](@PropertyID4, @LocationID4, SIH.Id) AccNum
			--FROM StockItemHeaders SIH
			--INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id
			--INNER JOIN SupplierWiseItemDetails SWID ON SWID.LocationId = @LocationID4 AND SWID.CompanyId = @PropertyID4 AND SWID.SupplierID = @Supplierid4 and SWID.StockItemID = SIH.Id
			--WHERE SID.LocationID = @LocationID4 AND SIH.CompanyId = @PropertyID4 AND SID.IsActive=1				
			--) T2 ON T2.Name = T.StockItemCode
			--) select StockItemCode from temptable4 where IsVal=0 
		END
	END
	ELSE IF(@TransactionType = 'DIN')
	BEGIN
		DECLARE @PropertyID5 INT, @LocationID5 INT,@DeptId5 INT, @StockItemCode5 VARCHAR(100), @ColumnIndex5 int

		SELECT @PropertyID5 =JSON_VALUE(@paramsData, '$.Propertyid')
		SELECT @LocationID5 =JSON_VALUE(@paramsData, '$.Locationid')	
		SELECT @DeptId5 =JSON_VALUE(@paramsData, '$.DepId')	
		SELECT @StockItemCode5 =JSON_VALUE(@JsonData, '$.StockItemCode')

		IF(@Name = 'Name')
		BEGIN

			SELECT @ColumnIndex= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table9 table(
							Name NVARCHAR(200)
			)

			insert into @table9
			SELECT 
			Name
			FROM OPENJSON(@JsonData)
			WITH (
				Name NVARCHAR(200)
			);

			DECLARE @IsDeptWiseItem5 BIT,
				@CompanySeparator5 NVARCHAR(10),
				@ComCode5 NVARCHAR(50),
				@DeptCode5 NVARCHAR(150),@ISGross5 BIT
         
			SELECT @IsDeptWiseItem5 = IsDepartmentWiseItems, @CompanySeparator5 = CompanySeparator FROM Companies WHERE CompanyID = @PropertyID3
			SELECT @ComCode5 = Code,@ISGross5 = IsTaxOrSellPrice FROM  Companies WHERE CompanyID = @PropertyID3
			SELECT @DeptCode5 = Code FROM Departments WHERE Id = @DeptId

			IF(@IsDeptWiseItem5 = 1)
			BEGIN

			
				IF(@CompanySeparator5 = 'JT')
				BEGIN	
					SELECT 
					T.Name, case when T2.Id is null then 0 else 1 end IsVal, @ColumnIndex ColumnIndex
					FROM @table9  T 
					left join (
					select dbo.StockItemHeaders.Name,dbo.StockItemHeaders.Id
					from
					dbo.StockItemHeaders
					 INNER JOIN dbo.StockItemDetails on  dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  and dbo.StockItemDetails.LocationID = @LocationID3
							
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode5 AND DI.GLCompCode = @ComCode5 AND DI.BlockCode = 'ISN'
					) T2 on T.Name = T2.Name
							
				END					
				ELSE
				BEGIN
					SELECT 
					T.Name, case when T2.Id is null then 0 else 1 end IsVal, @ColumnIndex ColumnIndex
					FROM @table9   T 
					left join (
					select dbo.StockItemHeaders.Name,dbo.StockItemHeaders.Id from
					dbo.StockItemHeaders 
					 INNER JOIN dbo.StockItemDetails on  dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  and dbo.StockItemDetails.LocationID = @LocationID3
							
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
							AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId = @DeptId
					) T2 on T2.Name = T.Name
				END

				
			END
			ELSE
			BEGIN
			    SELECT 
                T.Name, case when T2.Id is null then 0 else 1 end IsVal, @ColumnIndex ColumnIndex
				FROM @table9 T 
					left join (
					select dbo.StockItemHeaders.Name,dbo.StockItemHeaders.Id from
					dbo.StockItemHeaders 
					 INNER JOIN dbo.StockItemDetails on  dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id  and dbo.StockItemDetails.LocationID = @LocationID3
							
				WHERE   ( dbo.StockItemDetails.LocationID = @LocationID3 )
						AND ( dbo.StockItemDetails.PropertyID = @PropertyID3 ) AND (dbo.StockItemDetails.IsActive = 1)
					) T2 on T2.Name = T.Name
					

			END
		END
		ELSE IF(@Name = 'UnitName')
		BEGIN

			DECLARE @unitName5 VARCHAR(100)
			DECLARE @tempTable6 TABLE(
			UnitName VARCHAR(100),
			Name VARCHAR(100),
			UnitID int
			)
			SELECT @ColumnIndex= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table7 table(
				UnitName NVARCHAR(200),
				Name varchar(200)
			)

			insert into @table7
			SELECT 
			UnitName,Name
			FROM OPENJSON(@JsonData)
			WITH (
				UnitName NVARCHAR(200),
				Name varchar(200)
			);

			;with tempTable As(
			select distinct  T.UnitName,T.Name,T2.UnitID from
			@table7 T
			left join (
			SELECT 
					ToUnitID AS UnitID,
					ToUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE CompanyId = @PropertyID3
			union all
			SELECT 
					FromUnitID AS UnitID,
					FromUnitName AS UnitName,
					Value
				FROM dbo.UnitConversions
				WHERE CompanyId = @PropertyID3
				UNION

				SELECT 
					Id AS UnitID,
					Name AS UnitName,
					1 AS Value
				FROM dbo.Units
			) T2 on t2.UnitName =T.UnitName
			)
			insert into @tempTable6 select * from tempTable

			select t.UnitName,@ColumnIndex ColumnIndex, case when t2.Name is null then 0 else 1 end IsVal from @tempTable6 t
			left join (
			SELECT U.Name UnitName, sh.name  FROM dbo.StockItemHeaders SH INNER jOIN
			dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
			dbo.Units U ON U.id=SD.MasterUnitID WHERE  SD.LocationID= @LocationID3 AND SH.CompanyId = @PropertyID3
			) t2 on t2.UnitName = t.UnitName and t.Name = t2.Name
			
			 
		
		END
		ELSE IF(@Name = 'StockItemCode')
		BEGIN
			DECLARE @StockItemID5 INT, @HaveMapping5 BIT
			SELECT @StockItemID5 = Id FROM StockItemHeaders WHERE StockItemCode = @StockItemCode3 AND CompanyId = @PropertyID3

			SELECT @ColumnIndex= [key] 
			FROM OPENJSON(@JsonActiveNames) where [value] = @Name;

			declare @table8 table(
							StockItemCode NVARCHAR(200)
			)

			insert into @table8
			SELECT 
			StockItemCode
			FROM OPENJSON(@JsonData)
			WITH (
				StockItemCode NVARCHAR(200)
			);
			
			EXEC [dbo].[CheckGLMappings_FroExcel] 
				@StockItemID5, 
				'RI', 
				@LocationID3, 
				@PropertyID3, 
				@DeptId, 
				@HaveMapping5 OUTPUT ; --Check GL mapping

			IF(@HaveMapping5 = 1)
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
	ELSE
	BEGIN
	
		SELECT * FROM @TempData --When result no exists

	END
END

GO

