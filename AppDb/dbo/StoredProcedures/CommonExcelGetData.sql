-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-08
-- Description:	Getting data for exporting excel 
-- =============================================
-- CommonExcelGetData '{"Propertyid":1,"Locationid":1,"CheckBoxValue":"[]","DropDownValue":"[{\"Name\":\"Category\",\"Value\":[{\"id\":\"-999\",\"text\":\"--All--\"},{\"id\":\"2\",\"text\":\"BEVERAGE\"},{\"id\":\"3\",\"text\":\"CHEMICALS\"},{\"id\":\"4\",\"text\":\"CUTLERY & CROCKERY,GLASSWARE\"},{\"id\":\"5\",\"text\":\"ENGINEERING\"},{\"id\":\"6\",\"text\":\"FOOD\"},{\"id\":\"11\",\"text\":\"GAS & FUEL\"},{\"id\":\"14\",\"text\":\"GENERAL & OTHER\"},{\"id\":\"10\",\"text\":\"LINEN\"},{\"id\":\"15\",\"text\":\"PRODUCTION\"},{\"id\":\"13\",\"text\":\"STATIONERY\"},{\"id\":\"12\",\"text\":\"TOBACCO\"}],\"Active\":true,\"Parameters\":{},\"SPName\":\"SP_GetExcelDropdownData\",\"SelectedID\":-999,\"SelectedName\":\"\"}]"}','CR'

CREATE PROCEDURE [dbo].[CommonExcelGetData]
	@JsonData NVARCHAR(MAX),
	@tranType VARCHAR(5)
	--WITH RECOMPILE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	insert into temp_CommonExcelGetData
	select @JsonData JsonData, @tranType tranType, getdate() logDate

	IF(@tranType ='PR')
	BEGIN
	  DECLARE @Locationid INT ,
            @Propertyid INT,
			@ViewAccess BIT,
			@QuotationManageAttId INT , @ISGross BIT, @CategoryID INT = -999, @Locationid2 INT, @IsDepartmentWiseItemForPR BIT, @DeptId1 INT;

			     
        SELECT  @ISGross = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid

		SELECT @Locationid=	JSON_VALUE(@JsonData, '$.Locationid'),
				@Propertyid= JSON_VALUE(@JsonData, '$.Propertyid') ,
				@DeptId1= JSON_VALUE(@JsonData, '$.DepartmentID') 

		SELECT @IsDepartmentWiseItemForPR = IsDepartmentWiseItemForPR FROM Companies WHERE CompanyID = @Propertyid

		IF @IsDepartmentWiseItemForPR IS NULL
			SET @IsDepartmentWiseItemForPR = 0
		
		IF(@IsDepartmentWiseItemForPR =0)
		BEGIN
			;WITH ParsedJSON AS (
			SELECT 
				JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
			)
			SELECT 
				JSON_VALUE([value], '$.Name') AS Name,
				JSON_VALUE([value], '$.Active') AS Active,
				JSON_VALUE([value], '$.SelectedID') AS SelectedID
				into #tempDropDownItemValue
			FROM ParsedJSON
			CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);


			IF EXISTS(SELECT 1 FROM #tempDropDownItemValue)
			BEGIN
				SELECT @CategoryID = SelectedID FROM #tempDropDownItemValue WHERE Name ='Category'
				SELECT @Locationid2 = SelectedID FROM #tempDropDownItemValue WHERE Name ='Location'
			END
      
			SELECT @QuotationManageAttId = QuotationManageByHOAttributeId  FROM CommonSettings 
			SET @CategoryID = isnull(@CategoryID,-999)
			SET @Locationid = isnull(@Locationid2,@Locationid)

			;WITH tempTable AS(
			SELECT DISTINCT dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode + '/'
						+ dbo.StockItemHeaders.Name AS Name,
						ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice
				FROM    dbo.StockItemDetails
						inner JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID =   CASE WHEN  @Locationid = -999  THEN  dbo.StockItemDetails.LocationID ELSE @Locationid END )
						AND ( dbo.StockItemDetails.PropertyID = @Propertyid )
						AND dbo.StockItemDetails.IsActive = 1 AND dbo.stockitemheaders.CategoryID = CASE WHEN @CategoryID = -999 THEN dbo.stockitemheaders.CategoryID ELSE @CategoryID END
			
				EXCEPT 

				SELECT DISTINCT dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode + '/'
						+ dbo.StockItemHeaders.Name AS Name,
						ROUND(dbo.StockItemDetails.AveragePrice,2)  AveragePrice
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
						LEFT JOIN StockItemWiseAttributes SIT ON SIT.StockItemHeaderID = dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID =   CASE WHEN  @Locationid = -999  THEN  dbo.StockItemDetails.LocationID ELSE @Locationid END ) AND dbo.stockitemheaders.CategoryID = CASE WHEN @CategoryID = -999 THEN dbo.stockitemheaders.CategoryID ELSE @CategoryID END
						AND ( dbo.StockItemDetails.PropertyID = @Propertyid )
						AND dbo.StockItemDetails.IsActive = 1  AND SIT.StockItemAttributeID = @QuotationManageAttId AND SIT.IsActive = 1
			
			)	
			SELECT DISTINCT
					dbo.StockItemHeaders.Id StockItemID ,
					dbo.StockItemHeaders.Name StockName,
					dbo.StockItemDetails.AveragePrice AS CostPrice,
					dbo.StockItemDetails.MasterUnitID UnitID ,
					U.Name UnitName,
					( CASE WHEN @ISGross = 0
						   THEN dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
																dbo.StockItemHeaders.TaxGroupID)
						   ELSE dbo.StockItemDetails.SellingPrice
					  END ) SellingPrice ,
					dbo.StockItemHeaders.IsPriceEditable ,
					dbo.StockItemHeaders.StockItemCode ,
					dbo.StockItemHeaders.Barcode ,
					1 RequestedQuantity ,
					dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
													dbo.StockItemHeaders.TaxGroupID) Value ,
					dbo.StockItemDetails.SellingPrice AS TaxInclusivePrice ,
					MaintainPriceHistory AS MaintainPriceHistory,
					'' Remarks,
					C.Id CategoryId,
					C.Name CategoryName,
					0 status
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					INNER JOIN Categories C ON C.Id = StockItemHeaders.CategoryID
					INNER JOIN units U ON u.id = StockItemDetails.MasterUnitID
					INNER JOIN tempTable t ON t.Id = dbo.StockItemHeaders.Id
					WHERE dbo.StockItemHeaders.CompanyId = @Propertyid AND dbo.StockItemDetails.LocationID = @Locationid 
					AND dbo.stockitemheaders.CategoryID = CASE WHEN @CategoryID = -999 THEN dbo.stockitemheaders.CategoryID ELSE @CategoryID END
		END
		ELSE 
		BEGIN
		;WITH ParsedJSON AS (
			SELECT 
				JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
			)
			SELECT 
				JSON_VALUE([value], '$.Name') AS Name,
				JSON_VALUE([value], '$.Active') AS Active,
				JSON_VALUE([value], '$.SelectedID') AS SelectedID
				into #tempDropDownItemValueV
			FROM ParsedJSON
			CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);


			IF EXISTS(SELECT 1 FROM #tempDropDownItemValueV)
			BEGIN
				SELECT @CategoryID = SelectedID FROM #tempDropDownItemValueV WHERE Name ='Category'
			END
			SET @CategoryID = isnull(@CategoryID,-999)
			SELECT  DISTINCT
					dbo.StockItemHeaders.Id StockItemID ,
					dbo.StockItemHeaders.Name StockName,
					dbo.StockItemDetails.AveragePrice AS CostPrice,
					dbo.StockItemDetails.MasterUnitID UnitID ,
					U.Name UnitName,
					( CASE WHEN @ISGross = 0
						   THEN dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
																dbo.StockItemHeaders.TaxGroupID)
						   ELSE dbo.StockItemDetails.SellingPrice
					  END ) SellingPrice ,
					dbo.StockItemHeaders.IsPriceEditable ,
					dbo.StockItemHeaders.StockItemCode ,
					dbo.StockItemHeaders.Barcode ,
					1 RequestedQuantity ,
					dbo.FN_GetActualPriceWithoutTax(dbo.StockItemDetails.SellingPrice,
													dbo.StockItemHeaders.TaxGroupID) Value ,
					dbo.StockItemDetails.SellingPrice AS TaxInclusivePrice ,
					MaintainPriceHistory AS MaintainPriceHistory,
					'' Remarks,
					C.Id CategoryId,
					C.Name CategoryName,
					0 status
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					INNER JOIN Categories C ON C.Id = StockItemHeaders.CategoryID
					INNER JOIN units U ON u.id = StockItemDetails.MasterUnitID
					INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
			WHERE   ( dbo.StockItemDetails.LocationID = @Locationid )
					AND ( dbo.StockItemDetails.PropertyID = @Propertyid )
					AND ( dbo.StockItemHeaders.CategoryID = CASE WHEN @CategoryID = -999 THEN dbo.stockitemheaders.CategoryID ELSE @CategoryID END ) AND dbo.StockItemDetails.IsActive=1
					AND DI.DepartmentId =  CASE WHEN @DeptId1 = -999 THEN  DI.DepartmentId ELSE @DeptId1 END
			ORDER BY dbo.StockItemHeaders.Name
		END
	END
	ELSE IF(@tranType = 'PO')
	BEGIN
		declare @Locationid3 int  , @Propertyid2 int , @Supplierid2 int , @CategoryID2 INT = -999

		SELECT @PropertyID2 =JSON_VALUE(@JsonData, '$.Propertyid')
		SELECT @LocationID3 =JSON_VALUE(@JsonData, '$.Locationid')
		SELECT @Supplierid2 =JSON_VALUE(@JsonData, '$.Supplierid')

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
		)
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Active') AS Active,
			JSON_VALUE([value], '$.SelectedID') AS SelectedID
			into #tempDropDownItemValue2
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);

		IF EXISTS(SELECT 1 FROM #tempDropDownItemValue2)
		BEGIN
			SELECT @CategoryID2 = SelectedID FROM #tempDropDownItemValue2 WHERE Name ='Category'
		END
		SET @CategoryID2 = isnull(@CategoryID2,-999)

		DECLARE @Locationid1 INT= @Locationid3 ,
				@Propertyid1 INT = @Propertyid2,
				@TemperatureApplicableAttributeId INT,
				@IsDefault BIT,
				@Supplierid1 INT = @Supplierid2,
            @ISGross2 BIT

        SELECT  @ISGross2 = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid1

		DECLARE @TempTable TABLE (
			Id INT,
			Name VARCHAR(200),
			IsExpiryDateApplicable BIT,
			IsTemperatureApplicable BIT,
			IsDefaultSupplier BIT,
			MasterUnitID INT,
			CostPrice DECIMAL(18,6),
			SellingPrice DECIMAL(18,6),
			IsPriceEditable BIT,
			StockItemCode VARCHAR(50),
			Barcode VARCHAR(100),
			RequestedQuantity DECIMAL(18,6),
			Value DECIMAL(18,6),
			TaxInclusivePrice DECIMAL(18,6),
			MaintainPriceHistory BIT,
			QtyInHand DECIMAL(18,6),
			DiscountPercentage DECIMAL(18,6),
			DiscountValue DECIMAL(18,6),
			CategoryID INT,
			CategoryName VARCHAR(100),
			ItemTotal DECIMAL(18,6),
			Remark VARCHAR(200),
			TaxAmount DECIMAL(18,6),
			UnitName VARCHAR(100)
		)
         
			SELECT @TemperatureApplicableAttributeId = [TemperatureApplicableAttributeId] FROM CompanySettings WHERE CompanyId = @Propertyid1

			SELECT @IsDefault = CheckForDefaultSupplier  FROM CommonSettings

		INSERT INTO @TempTable
		  SELECT DISTINCT 
                SIH.Id ,
                SIH.Name,
				SIH.IsExpiryDateApplicable,
				IWA.IsActive AS IsTemperatureApplicable,
				SWID.IsDefaultSupplier ,
				SWID.PurchaseUnitID MasterUnitID,
               SWID.CostPrice AS CostPrice,
               -- dbo.StockItemDetails.MasterUnitID ,
			  
                ( CASE WHEN @ISGross2 = 0
                       THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                                            SIH.TaxGroupID)
                       ELSE SID.SellingPrice
                  END ) SellingPrice ,
                SIH.IsPriceEditable ,
                SIH.StockItemCode ,
                SIH.Barcode ,
                1 RequestedQuantity ,
                dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                                SIH.TaxGroupID) Value ,
                SID.SellingPrice AS TaxInclusivePrice ,
                MaintainPriceHistory AS MaintainPriceHistory,
				dbo.[FN_GetStockInHand_Reatils](@Propertyid1,@Locationid1,SIH.Id) QtyInHand,
				0 DiscountPercentage,
				0 DiscountValue,
				SIH.CategoryID ,
				C.Name CategoryName,
				0 ItemTotal,
				'' Remark,
				ISNULL( [dbo].[FN_GetStockItemWiseTotalTax](SIH.Id,SWID.CostPrice ,@Supplierid1,@LocationID1),0) TaxAmount,
				U.Name UnitName
        FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN dbo.SupplierWiseItemDetails SWID ON SWID.StockItemID = SID.StockItemHeaderID
				INNER JOIN dbo.Categories C ON C.Id = SIH.CategoryID
				INNER JOIN dbo.Units U ON U.Id = SID.MasterUnitID
				LEFT JOIN StockItemWiseAttributes IWA ON SIH.Id = IWA.StockItemHeaderID 
					AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId AND IWA.IsActive = 1 
        WHERE   ( SID.LocationID = @Locationid1 )
                AND ( SID.PropertyID = @Propertyid1 ) AND (SWID.SupplierID= @Supplierid1) 
				 AND  ( SWID.LocationId = @Locationid1) AND SID.IsActive=1
				 	AND (SWID.ValidTo >= GETDATE() OR SWID.ValidTo IS NULL)
				AND SIH.CategoryID = CASE WHEN @CategoryID2 = -999 THEN SIH.CategoryID ELSE @CategoryID2 END
				

		IF @IsDefault = 0
			SELECT * FROM @TempTable ORDER BY Name
		IF @IsDefault =1 
			SELECT * FROM @TempTable WHERE IsDefaultSupplier = 1  ORDER BY Name
	END
	ELSE IF(@tranType = 'IR')
	BEGIN
		 declare   @Locationid4 INT ,
			@Propertyid4 INT ,
			@DeptId INT, @CategoryID4 INT = -999, @IsExpireDateApplicable4 BIT = 0

			Declare @CheckBoxTable TABLE(
				Name NVARCHAR(200),
				Value BIT ,
				Active BIT
			)

		SELECT @Propertyid4 =JSON_VALUE(@JsonData, '$.Propertyid')
		SELECT @Locationid4 =JSON_VALUE(@JsonData, '$.Locationid')
		SELECT @DeptId =JSON_VALUE(@JsonData, '$.DepId')

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
		)
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Active') AS Active,
			JSON_VALUE([value], '$.SelectedID') AS SelectedID
			into #tempDropDownItemValue4
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.CheckBoxValue') AS CheckBoxValue
		)
		INSERT INTO @CheckBoxTable
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Value') AS Value,
			JSON_VALUE([value], '$.Active') AS Active
			
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.CheckBoxValue);
		
		IF EXISTS(SELECT 1 FROM @CheckBoxTable)
		BEGIN
			SELECT @IsExpireDateApplicable4 = Value FROM @CheckBoxTable WHERE Name ='Expiry Date'
		END
		SET @IsExpireDateApplicable4 = isnull(@IsExpireDateApplicable4,0)

		IF EXISTS(SELECT 1 FROM #tempDropDownItemValue4)
		BEGIN
			SELECT @CategoryID4 = SelectedID FROM #tempDropDownItemValue4 WHERE Name ='Category'
		END
		SET @CategoryID4 = isnull(@CategoryID4,-999)

        DECLARE @IsDeptWiseItem BIT,
			@CompanySeparator NVARCHAR(10),
			@ComCode NVARCHAR(50),
			@DeptCode NVARCHAR(150),@ISGross4 BIT
         
		SELECT @IsDeptWiseItem = IsDepartmentWiseItems, @CompanySeparator = CompanySeparator FROM Companies WHERE CompanyID = @Propertyid4
		SELECT @ComCode = Code,@ISGross4 = IsTaxOrSellPrice FROM  Companies WHERE CompanyID = @PropertyId4
		SELECT @DeptCode = Code FROM Departments WHERE Id = @DeptId

		DECLARE @TempTable3 TABLE(
			Id INT,
			StockItemCode VARCHAR(50),
			Name VARCHAR(200),
			IsExpiryDateApplicable BIT,
			QuantityInHand DECIMAL(18,6),
			UnitPrice DECIMAL(18,6),
			MasterUnitID INT,
			SellingPrice DECIMAL(18,6),
			IsPriceEditable BIT,
			Barcode  VARCHAR(50),
			RequestedQuantity DECIMAL(18,6),
			Value DECIMAL(18,6),
			TaxInclusivePrice DECIMAL(18,6),
			MaintainPriceHistory BIT,
			IsProductionItem BIT,
			UnitID INT,
			UnitName  VARCHAR(50),
			Remarks  VARCHAR(200),
			CategoryID INT,
			CategoryName VARCHAR(100)
		)

			IF(@IsDeptWiseItem = 1 )
			BEGIN

				IF(@CompanySeparator = 'JT')
				BEGIN	
					INSERT INTO @TempTable3(	Id ,
										StockItemCode,
										Name,
										IsExpiryDateApplicable,
										QuantityInHand,
										UnitPrice,
										MasterUnitID,
										SellingPrice,
										IsPriceEditable,
										Barcode,
										RequestedQuantity,
										Value,
										TaxInclusivePrice,
										MaintainPriceHistory,
										IsProductionItem,
										UnitID,
										UnitName,
										Remarks,
										CategoryID,
										CategoryName)
					SELECT DISTINCT
										SIH.Id ,
										SIH.StockItemCode,
										SIH.Name as Name,
										SIH.IsExpiryDateApplicable,
										SID.QuantityInHand,
										SID.AveragePrice UnitPrice,
										SID.MasterUnitID,
										 ( CASE WHEN @ISGross4 = 0
										THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
																			SIH.TaxGroupID)
									   ELSE SID.SellingPrice
										 END ) SellingPrice ,
										SIH.IsPriceEditable,
										SIH.Barcode,
										1 RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										SID.MasterUnitID UnitID,
										U.Name UnitName,
										'' Remarks,
										C.Id CategoryID,
										C.Name CategoryName
					FROM    dbo.StockItemDetails SID
							INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
							INNER JOIN Units U ON U.Id = SID.MasterUnitID
							INNER JOIN Categories C ON C.Id = SIH.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
					WHERE   ( SID.LocationID = @Locationid4 )
							AND ( SID.PropertyID = @Propertyid4 ) AND (SID.IsActive = 1) 
							AND DI.Level1 = @DeptCode AND DI.GLCompCode = @ComCode AND DI.BlockCode = 'ISN'
							AND SIH.IsExpiryDateApplicable = CASE WHEN @IsExpireDateApplicable4 =0 THEN SIH.IsExpiryDateApplicable ELSE @IsExpireDateApplicable4 END
							

					ORDER BY Name
				END					
				ELSE
				BEGIN

					INSERT INTO @TempTable3(	Id ,
										StockItemCode,
										Name,
										IsExpiryDateApplicable,
										QuantityInHand,
										UnitPrice,
										MasterUnitID,
										SellingPrice,
										IsPriceEditable,
										Barcode,
										RequestedQuantity,
										Value,
										TaxInclusivePrice,
										MaintainPriceHistory,
										IsProductionItem,
										UnitID,
										UnitName,
										Remarks,
										CategoryID,
										CategoryName)
					SELECT DISTINCT
										SIH.Id ,
										SIH.StockItemCode,
										SIH.Name as Name,
										SIH.IsExpiryDateApplicable,
										SID.QuantityInHand,
										SID.AveragePrice UnitPrice,
										SID.MasterUnitID,
										 ( CASE WHEN @ISGross4 = 0
										THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
																			SIH.TaxGroupID)
									   ELSE SID.SellingPrice
										 END ) SellingPrice ,
										SIH.IsPriceEditable,
										SIH.Barcode,
										1 RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										SID.MasterUnitID UnitID,
										U.Name UnitName,
										'' Remarks,
										C.Id CategoryID,
										C.Name CategoryName
					FROM    dbo.StockItemDetails SID
							INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
							INNER JOIN Units U ON U.Id = SID.MasterUnitID
							INNER JOIN Categories C ON C.Id = SIH.CategoryId
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SIH.Id
					WHERE   ( SID.LocationID = @Locationid4 )
							AND ( SID.PropertyID = @Propertyid4 ) AND (SID.IsActive = 1) 
							AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END
							AND SIH.IsExpiryDateApplicable = CASE WHEN @IsExpireDateApplicable4 =0 THEN SIH.IsExpiryDateApplicable ELSE @IsExpireDateApplicable4 END
					ORDER BY Name
				END
					
			END
			ELSE
			BEGIN
					INSERT INTO @TempTable3(	Id ,
										StockItemCode,
										Name,
										IsExpiryDateApplicable,
										QuantityInHand,
										UnitPrice,
										MasterUnitID,
										SellingPrice,
										IsPriceEditable,
										Barcode,
										RequestedQuantity,
										Value,
										TaxInclusivePrice,
										MaintainPriceHistory,
										IsProductionItem,
										UnitID,
										UnitName,
										Remarks,
										CategoryID,
										CategoryName)
					SELECT DISTINCT
										SIH.Id ,
										SIH.StockItemCode,
										SIH.Name as Name,
										SIH.IsExpiryDateApplicable,
										SID.QuantityInHand,
										SID.AveragePrice UnitPrice,
										SID.MasterUnitID,
										 ( CASE WHEN @ISGross4 = 0
										THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
																			SIH.TaxGroupID)
									   ELSE SID.SellingPrice
										 END ) SellingPrice ,
										SIH.IsPriceEditable,
										SIH.Barcode,
										1 RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										SID.MasterUnitID UnitID,
										U.Name UnitName,
										'' Remarks,
										C.Id CategoryID,
										C.Name CategoryName
				FROM    dbo.StockItemDetails SID
						INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
						INNER JOIN Units U ON U.Id = SID.MasterUnitID
						INNER JOIN Categories C ON C.Id = SIH.CategoryId
						INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SIH.Id
				WHERE   ( SID.LocationID = @Locationid4 )
						AND ( SID.PropertyID = @Propertyid4 ) AND (SID.IsActive = 1) 
						AND DI.DepartmentId = @DeptId
						AND SIH.IsExpiryDateApplicable = CASE WHEN @IsExpireDateApplicable4 =0 THEN SIH.IsExpiryDateApplicable ELSE @IsExpireDateApplicable4 END
				ORDER BY Name
			END
			
			SELECT * FROM @TempTable3 WHERE CategoryID = CASE WHEN @CategoryID4 = -999 THEN CategoryID ELSE @CategoryID4 END


	END
	ELSE IF(@tranType = 'GR')
	BEGIN
		declare @Locationid5 int  , @Propertyid5 int , @Supplierid5 int , @CategoryID5 INT = -999

		SELECT @Propertyid5 =JSON_VALUE(@JsonData, '$.Propertyid')
		SELECT @Locationid5 =JSON_VALUE(@JsonData, '$.Locationid')
		SELECT @Supplierid5 =JSON_VALUE(@JsonData, '$.Supplierid')

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
		)
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Active') AS Active,
			JSON_VALUE([value], '$.SelectedID') AS SelectedID
			into #tempDropDownItemValue3
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);

		IF EXISTS(SELECT 1 FROM #tempDropDownItemValue3)
		BEGIN
			SELECT @CategoryID5 = SelectedID FROM #tempDropDownItemValue3 WHERE Name ='Category'
		END
		SET @CategoryID5 = isnull(@CategoryID5,-999)

		DECLARE
				@TemperatureApplicableAttributeId1 INT,
				@IsDefault5 BIT,
            @ISGross5 BIT

        SELECT  @ISGross5 = IsTaxOrSellPrice
        FROM    dbo.Companies
        WHERE   CompanyID = @Propertyid5

		DECLARE @TempTable4 TABLE (
			Id INT,
			Name VARCHAR(200),
			IsExpiryDateApplicable BIT,
			IsTemperatureApplicable BIT,
			IsDefaultSupplier BIT,
			MasterUnitID INT,
			CostPrice DECIMAL(18,6),
			SellingPrice DECIMAL(18,6),
			IsPriceEditable BIT,
			StockItemCode VARCHAR(50),
			Barcode VARCHAR(100),
			RequestedQuantity DECIMAL(18,6),
			Value DECIMAL(18,6),
			TaxInclusivePrice DECIMAL(18,6),
			MaintainPriceHistory BIT,
			QtyInHand DECIMAL(18,6),
			DiscountPercentage DECIMAL(18,6),
			DiscountValue DECIMAL(18,6),
			CategoryID INT,
			CategoryName VARCHAR(100),
			ItemTotal DECIMAL(18,6),
			Remark VARCHAR(200),
			TaxAmount DECIMAL(18,6),
			UnitName VARCHAR(100),
			AccName VARCHAR(200)
		)
         
			SELECT @TemperatureApplicableAttributeId1 = [TemperatureApplicableAttributeId] FROM CompanySettings WHERE CompanyId = @Propertyid5

			SELECT @IsDefault5 = CheckForDefaultSupplier  FROM CommonSettings

		INSERT INTO @TempTable4
		  SELECT DISTINCT 
                SIH.Id ,
                SIH.Name,
				SIH.IsExpiryDateApplicable,
				IWA.IsActive AS IsTemperatureApplicable,
				SWID.IsDefaultSupplier ,
				SWID.PurchaseUnitID MasterUnitID,
				SWID.CostPrice AS CostPrice,
               -- dbo.StockItemDetails.MasterUnitID ,
			  
                ( CASE WHEN @ISGross5 = 0
                       THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                                            SIH.TaxGroupID)
                       ELSE SID.SellingPrice
                  END ) SellingPrice ,
                SIH.IsPriceEditable ,
                SIH.StockItemCode ,
                SIH.Barcode ,
                1 RequestedQuantity ,
                dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                                SIH.TaxGroupID) Value ,
                SID.SellingPrice AS TaxInclusivePrice ,
                MaintainPriceHistory AS MaintainPriceHistory,
				dbo.[FN_GetStockInHand_Reatils](@Propertyid5,@Locationid5,SIH.Id) QtyInHand,
				0 DiscountPercentage,
				0 DiscountValue,
				SIH.CategoryID ,
				C.Name CategoryName,
				isnull(SWID.CostPrice,0)+ISNULL( [dbo].[FN_GetStockItemWiseTotalTax](SIH.Id,SWID.CostPrice ,@Supplierid5,@LocationID5),0) ItemTotal,
				'' Remark,
				ISNULL( [dbo].[FN_GetStockItemWiseTotalTax](SIH.Id,SWID.CostPrice ,@Supplierid5,@LocationID5),0) TaxAmount,
				U.Name UnitName,
				 [dbo].[FUN_GetItemLevelAccountName](@Propertyid5,@Locationid5,SIH.Id) AccName
        FROM    dbo.StockItemDetails SID
                INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN dbo.SupplierWiseItemDetails SWID ON SWID.StockItemID = SID.StockItemHeaderID
				INNER JOIN dbo.Categories C ON C.Id = SIH.CategoryID
				INNER JOIN dbo.Units U ON U.Id = SID.MasterUnitID
				LEFT JOIN StockItemWiseAttributes IWA ON SIH.Id = IWA.StockItemHeaderID 
					AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId1 AND IWA.IsActive = 1 
        WHERE   ( SID.LocationID = @Locationid5 )
                AND ( SID.PropertyID = @Propertyid5 ) AND (SWID.SupplierID= @Supplierid5) 
				 AND  ( SWID.LocationId = @Locationid5) AND SID.IsActive=1
				 	AND (SWID.ValidTo >= GETDATE() OR SWID.ValidTo IS NULL)
				AND SIH.CategoryID = CASE WHEN @CategoryID5 = -999 THEN SIH.CategoryID ELSE @CategoryID5 END
				

		IF @IsDefault5 = 0
			SELECT * FROM @TempTable4 ORDER BY Name
		IF @IsDefault5 =1 
			SELECT * FROM @TempTable4 WHERE IsDefaultSupplier = 1  ORDER BY Name		
	END
	ELSE IF(@tranType = 'DIR')
	BEGIN
		 declare   @Locationid6 INT ,@ToLocationid6 INT,
			@Propertyid6 INT ,
			@CategoryID6 INT = -999

		SELECT @Propertyid6 =JSON_VALUE(@JsonData, '$.Propertyid')
		SELECT @Locationid6 =JSON_VALUE(@JsonData, '$.Locationid')
		SELECT @ToLocationid6 =JSON_VALUE(@JsonData, '$.Locationid2')
		

		DECLARE @tempDropDownItemValue5 TABLE(
			Name NVARCHAR(200),
			Active BIT,
			SelectedID INT
		)

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
		)
		INSERT INTO @tempDropDownItemValue5
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Active') AS Active,
			JSON_VALUE([value], '$.SelectedID') AS SelectedID
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);

		IF EXISTS(SELECT 1 FROM @tempDropDownItemValue5)
		BEGIN
			SELECT @CategoryID6 = SelectedID FROM @tempDropDownItemValue5 WHERE Name ='Category'
		END
		SET @CategoryID6 = isnull(@CategoryID6,-999)

		DECLARE @TempTable5 TABLE(
			Id INT,
			StockItemCode VARCHAR(50),
			Name VARCHAR(200),
			QuantityInHand DECIMAL(18,6),
			UnitPrice DECIMAL(18,6),
			MasterUnitID INT,
			RequestedQuantity DECIMAL(18,6),
			UnitID INT,
			UnitName  VARCHAR(50),
			Remarks  VARCHAR(200),
			CategoryID INT,
			CategoryName VARCHAR(100)
		)

				INSERT INTO @TempTable5(	Id ,
										StockItemCode,
										Name,
										QuantityInHand,
										UnitPrice,
										MasterUnitID,
										RequestedQuantity,
										UnitID,
										UnitName,
										Remarks,
										CategoryID,
										CategoryName)
				SELECT DISTINCT
										SIH.Id ,
										SIH.StockItemCode,
										SIH.Name as Name,
										SID.QuantityInHand,
										SID.AveragePrice UnitPrice,
										SID.MasterUnitID,
										1 RequestedQuantity,
										SID.MasterUnitID UnitID,
										U.Name UnitName,
										'' Remarks,
										C.Id CategoryID,
										C.Name CategoryName


				FROM    dbo.StockItemDetails SID
						INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
						INNER JOIN 
						(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid6 AND SID2.CompanyID = @Propertyid6 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID = SIH.Id
						INNER JOIN Units U ON U.Id = SID.MasterUnitID
						INNER JOIN Categories C ON C.Id = SIH.CategoryId
				WHERE   ( SID.LocationID = @Locationid6 )
						AND ( SID.PropertyID = @Propertyid6 ) AND (SID.IsActive = 1)
						AND SIH.CategoryID = CASE WHEN @CategoryID6 = -999 THEN SIH.CategoryID ELSE @CategoryID6 END
				ORDER BY Name
			
			SELECT * FROM @TempTable5 WHERE CategoryID = CASE WHEN @CategoryID6 = -999 THEN CategoryID ELSE @CategoryID6 END


	END
	ELSE IF(@tranType = 'CR')
	BEGIN
		 declare   @Locationid7 INT,
		 @ToLocationid7 INT,
			@Propertyid7 INT ,
			@CategoryID7 INT = -999, @DeptId7 INT = -999,
			@IsDeptWiseItem7 BIT,
			@CompanySeparator7 NVARCHAR(10),
			@ComCode7 NVARCHAR(50),
			@DeptCode7 NVARCHAR(150)

		

		IF @DeptId7 IS NULL SET @DeptId7 = -999

		SELECT @Propertyid7 =JSON_VALUE(@JsonData, '$.Propertyid')
		SELECT @Locationid7 =JSON_VALUE(@JsonData, '$.Locationid')
		SELECT @ToLocationid7 =JSON_VALUE(@JsonData, '$.Locationid2')
			SELECT @IsDeptWiseItem7 = IsDepartmentWiseItems, @CompanySeparator7 = CompanySeparator FROM Companies WHERE CompanyID = @Propertyid7
			SELECT @ComCode7 = Code FROM  Companies WHERE CompanyID = @PropertyId7
			SELECT @DeptCode7 = Code FROM Departments WHERE Id = @DeptId7

		DECLARE @tempDropDownItemValue7 TABLE(
			Name NVARCHAR(200),
			Active BIT,
			SelectedID INT
		)

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
		)
		INSERT INTO @tempDropDownItemValue7
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Active') AS Active,
			JSON_VALUE([value], '$.SelectedID') AS SelectedID
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);

		IF EXISTS(SELECT 1 FROM @tempDropDownItemValue7)
		BEGIN
			SELECT @CategoryID7 = SelectedID FROM @tempDropDownItemValue7 WHERE Name ='Category'
		END
		SET @CategoryID7 = isnull(@CategoryID7,-999)

		DECLARE @TempTable7 TABLE(
			StockItemID INT,
			StockItemCode VARCHAR(50),
			StockName NVARCHAR(MAX),
			QuantityInHand DECIMAL(18,6),
			CostPrice DECIMAL(18,6),
			MasterUnitID INT,
			Quantity DECIMAL(18,6),
			UnitName  VARCHAR(50),
			CategoryID INT,
			CategoryName NVARCHAR(MAX),
			IsActive BIT,
			Remarks  VARCHAR(200),
			DeliverySchedule VARCHAR(500),
			DeliveryScheduleID INT
		)

			IF(@IsDeptWiseItem7 = 1 AND @DeptId7 <> -999)
			BEGIN

					IF(@CompanySeparator7 = 'JT')
					BEGIN	
					
						INSERT INTO @TempTable7(StockItemID,StockName,CategoryID,CategoryName,MasterUnitID,UnitName,Quantity,IsActive,QuantityInHand,CostPrice,StockItemCode,Remarks,DeliverySchedule,DeliveryScheduleID)
						SELECT DISTINCT
						H.Id StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,sd.MasterUnitID, U.Name UnitName,0 Quantity,SD.IsActive IsActive,  [dbo].[GetBalance](getdate() ,h.Id,1,0,0) QuantityInHand, sd.AveragePrice AS CostPrice,H.StockItemCode, '' Remarks, (SELECT TOP 1 Name FROM DeliverySchedule) DeliverySchedule, (SELECT TOP 1 Id FROM DeliverySchedule) DeliveryScheduleID

						FROM    dbo.StockItemDetails SD
								INNER JOIN dbo.StockItemHeaders H ON SD.StockItemHeaderID = H.Id
								INNER JOIN 
						(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid7 AND SID2.CompanyID = @Propertyid7 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID = H.Id
								INNER JOIN Categories C ON C.Id = H.CategoryId
								INNER JOIN SubCategories SC ON SC.Id = H.SubCategoryId
								INNER JOIN SubCategories02 SC2 ON SC2.Id = H.SubCategory2ID 
								INNER JOIN	Units U on u.Id = sd.MasterUnitID
								INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
						WHERE   ( SD.LocationID = @Locationid7 )
								AND ( SD.PropertyID = @Propertyid7 ) AND (SD.IsActive = 1) 
								AND DI.Level1 = @DeptCode7 AND DI.GLCompCode = @ComCode7 AND DI.BlockCode = 'ISN'
								AND ISNULL(H.IsProductionItem,0) = 1 --loading only production items
							

						ORDER BY H.Name
					END					
					ELSE
					BEGIN
					
						INSERT INTO @TempTable7(StockItemID,StockName,CategoryID,CategoryName,MasterUnitID,UnitName,Quantity,IsActive,QuantityInHand,CostPrice,StockItemCode,Remarks,DeliverySchedule,DeliveryScheduleID)
						SELECT DISTINCT
						H.Id StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,sd.MasterUnitID, U.Name UnitName,0 Quantity,SD.IsActive IsActive,  [dbo].[GetBalance](getdate() ,h.Id,1,0,0) QuantityInHand, sd.AveragePrice AS CostPrice,H.StockItemCode, '' Remarks, (SELECT TOP 1 Name FROM DeliverySchedule) DeliverySchedule, (SELECT TOP 1 Id FROM DeliverySchedule) DeliveryScheduleID

						FROM    dbo.StockItemDetails SD
								INNER JOIN dbo.StockItemHeaders H ON SD.StockItemHeaderID = H.Id
								INNER JOIN 
						(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid7 AND SID2.CompanyID = @Propertyid7 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID = H.Id
								INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = H.Id
									INNER JOIN	Units U on u.Id = sd.MasterUnitID 
								INNER JOIN	Categories C on C.Id = H.CategoryId 
						WHERE   ( SD.LocationID = @Locationid7 )
								AND ( SD.PropertyID = @Propertyid7 ) AND (SD.IsActive = 1) 
								AND DI.DepartmentId =  CASE WHEN @DeptId7 = -999 THEN  DI.DepartmentId ELSE @DeptId7 END
								AND ISNULL(H.IsProductionItem,0) = 1 --loading only production items
						ORDER BY H.Name
					END

				
				END
			ELSE
			BEGIN
			
				INSERT INTO @TempTable7(StockItemID,StockName,CategoryID,CategoryName,MasterUnitID,UnitName,Quantity,IsActive,QuantityInHand,CostPrice,StockItemCode,Remarks,DeliverySchedule,DeliveryScheduleID)
				SELECT 
				DISTINCT
					H.Id StockItemID,H.Name StockName,C.id CategoryID,C.Name CategoryName,sd.MasterUnitID, U.Name UnitName,0 Quantity,SD.IsActive IsActive,  [dbo].[GetBalance](getdate() ,h.Id,1,0,0) QuantityInHand, sd.AveragePrice AS CostPrice,H.StockItemCode, '' Remarks, (SELECT TOP 1 Name FROM DeliverySchedule) DeliverySchedule, (SELECT TOP 1 Id FROM DeliverySchedule) DeliveryScheduleID
				FROM    dbo.StockItemDetails SD
						INNER JOIN dbo.StockItemHeaders H ON SD.StockItemHeaderID = H.Id
						INNER JOIN 
						(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid7 AND SID2.CompanyID = @Propertyid7 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID = H.Id
								INNER JOIN	Units U on u.Id = sd.MasterUnitID 
							INNER JOIN	Categories C on C.Id = H.CategoryId 
				WHERE   ( SD.LocationID = @Locationid7 )
						AND ( SD.PropertyID = @Propertyid7 ) AND (SD.IsActive = 1)
						AND ISNULL(H.IsProductionItem,0) = 1 --loading only production items
				ORDER BY H.Name
			END	

			SELECT * FROM @TempTable7 WHERE CategoryID = CASE WHEN @CategoryID7 = -999 THEN CategoryID ELSE @CategoryID7 END


	END
	ELSE IF (@tranType = 'DIN')
	BEGIN
		 declare   @Locationid8 INT ,@DepartmentID INT,
			@Propertyid8 INT ,
			@CategoryID8 INT = -999

		SELECT @Propertyid8 =JSON_VALUE(@JsonData, '$.Propertyid')
		SELECT @Locationid8 =JSON_VALUE(@JsonData, '$.Locationid')
		SELECT @DepartmentID =JSON_VALUE(@JsonData, '$.DepId')


		DECLARE @tempDropDownItemValue8 TABLE(
			Name NVARCHAR(200),
			Active BIT,
			SelectedID INT
		)

		;WITH ParsedJSON AS (
		SELECT 
			JSON_VALUE(@JsonData, '$.DropDownValue') AS DropDownValue
		)
		INSERT INTO @tempDropDownItemValue8
		SELECT 
			JSON_VALUE([value], '$.Name') AS Name,
			JSON_VALUE([value], '$.Active') AS Active,
			JSON_VALUE([value], '$.SelectedID') AS SelectedID
		FROM ParsedJSON
		CROSS APPLY OPENJSON(ParsedJSON.DropDownValue);


		IF EXISTS(SELECT 1 FROM @tempDropDownItemValue8)
		BEGIN
			SELECT @CategoryID8 = SelectedID FROM @tempDropDownItemValue8 WHERE Name ='Category'
		END
		SET @CategoryID8 = isnull(@CategoryID8,-999)


		       DECLARE 
			@IsDeptWiseItem8 BIT,
			@CompanySeparator8 NVARCHAR(10),
			@ComCode8 NVARCHAR(50),
			@DeptCode8 NVARCHAR(150)

			SELECT @IsDeptWiseItem8 = IsDepartmentWiseItems, @CompanySeparator8 = CompanySeparator FROM Companies WHERE CompanyID = @Propertyid8
			SELECT @ComCode8 = Code FROM  Companies WHERE CompanyID = @Propertyid8
			SELECT @DeptCode8 = Code FROM Departments WHERE Id = @DepartmentID

			IF(@IsDeptWiseItem8 = 1 AND @DepartmentID <> -999)
			BEGIN

			
				IF(@CompanySeparator = 'JT')
				BEGIN	
					SELECT DISTINCT
					dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode+ '/'+
					dbo.StockItemHeaders.Name as Name,StockItemHeaders.IsExpiryDateApplicable,QuantityInHand,
					dbo.StockItemDetails.AveragePrice UnitPrice
					,0 RequestedQuantity
					,'' Remarks
					--c.name as category, C.Code catCode,SC.Code subCatCode, @DeptCode depCode
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Categories C ON C.Id = dbo.StockItemHeaders.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = dbo.StockItemHeaders.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = dbo.StockItemHeaders.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
							--INNER JOIN Departmentwiseitems D ON D.StockiTemId = dbo.StockItemHeaders.Id
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationid8 )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyid8 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.Level1 = @DeptCode8 AND DI.GLCompCode = @ComCode8 AND DI.BlockCode = 'ISN'
							

					ORDER BY Name
				END					
				ELSE
				BEGIN

					SELECT DISTINCT
					dbo.StockItemHeaders.Id ,
					dbo.StockItemHeaders.StockItemCode StockItemCode,
					StockItemHeaders.IsExpiryDateApplicable
					,QuantityInHand,
					dbo.StockItemDetails.AveragePrice UnitPrice,
					UN.NAME UnitName
					,dbo.StockItemHeaders.Name 
					,dbo.StockItemHeaders.CategoryID,0 RequestedQuantity,'' Remarks
					FROM    dbo.StockItemDetails
							INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
							INNER JOIN Units UN ON UN.ID = dbo.StockItemDetails.MasterUnitID
					WHERE   ( dbo.StockItemDetails.LocationID = @Locationid8 )
							AND ( dbo.StockItemDetails.PropertyID = @Propertyid8 ) AND (dbo.StockItemDetails.IsActive = 1) 
							AND DI.DepartmentId =  CASE WHEN @DepartmentID = -999 THEN  DI.DepartmentId ELSE @DepartmentID END
							AND dbo.StockItemHeaders.CategoryID = CASE WHEN @CategoryID8 = -999 THEN  dbo.StockItemHeaders.CategoryID ELSE @CategoryID8 END
					ORDER BY dbo.StockItemHeaders.Name
				END

				
			END
			ELSE
			BEGIN
		
			    SELECT 
                dbo.StockItemHeaders.Id ,
                dbo.StockItemHeaders.StockItemCode+ '/'+
                dbo.StockItemHeaders.Name as Name,StockItemHeaders.IsExpiryDateApplicable,QuantityInHand
				,0 RequestedQuantity,'' Remarks
				FROM    dbo.StockItemDetails
						INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
				WHERE   ( dbo.StockItemDetails.LocationID = @Locationid8 )
						AND ( dbo.StockItemDetails.PropertyID = @Propertyid8 ) AND (dbo.StockItemDetails.IsActive = 1)

				ORDER BY Name
			END



	END

END

GO

