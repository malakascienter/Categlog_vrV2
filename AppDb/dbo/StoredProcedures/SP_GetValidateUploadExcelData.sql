-- =============================================
-- Author:		Nivesh
-- Create date: 2025-02-08
-- Description:	Validate excel column data
-- =============================================
--SP_GetValidateUploadExcelData '[{"StockItemCode":"003","ItemName":"EGG BUN (PRO)","UnitName":"NUMBERS05","ApprovedQuantity":10,"TaxAmount":5,"DiscountValue":10,"DiscountPercentage":"","Price":80},{"StockItemCode":"10006","ItemName":"FG CHICKEN CREPE","UnitName":"NUMBERS05","ApprovedQuantity":30,"TaxAmount":5,"DiscountValue":5,"DiscountPercentage":"","Price":40},{"StockItemCode":"10005","ItemName":"SFG  - CREPE BATTER","UnitName":"GRAM","ApprovedQuantity":20,"TaxAmount":5,"DiscountValue":20,"DiscountPercentage":"","Price":60}]','{"PropertyID":1,"LocationID":1,"RequestHeaderID":6033}','QU'



CREATE PROCEDURE [dbo].[SP_GetValidateUploadExcelData]
	@jsonEntity NVARCHAR(MAX),
	@jsonParamsData NVARCHAR(MAX),
	@TransactionType VARCHAR(5)
	--WITH RECOMPILE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	INSERT INTO CommonExcelUploadData (jsonData,TranType,Date,jsonParamData)
	VALUES(@jsonEntity,@TransactionType,GETDATE(),@jsonParamsData)

	IF(@TransactionType ='PR')
	BEGIN
		 DECLARE @TempData TABLE (
			StockName NVARCHAR(255),
			UnitName NVARCHAR(50),
			StockItemCode NVARCHAR(50),
			RequestedQuantity DECIMAL(18,2),
			Remarks NVARCHAR(255),
			CategoryName NVARCHAR(255)
		);

		DECLARE @PropertyID INT, @LocationID INT, @IsDepartmentWiseItemForPR BIT, @DeptId1 INT;

		SELECT @PropertyID =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID =JSON_VALUE(@jsonParamsData, '$.Locationid'),
				@DeptId1= JSON_VALUE(@jsonParamsData, '$.DepartmentID') 

		SELECT @IsDepartmentWiseItemForPR = IsDepartmentWiseItemForPR FROM Companies WHERE CompanyID = @Propertyid
		-- Parse JSON into table variable
		INSERT INTO @TempData (StockName, UnitName,
		StockItemCode,
		RequestedQuantity, Remarks, CategoryName)
		SELECT 
			StockName, UnitName,
			StockItemCode,
			RequestedQuantity, Remarks, CategoryName
		FROM OPENJSON(@jsonEntity)
		WITH (
			StockName NVARCHAR(255),
			UnitName NVARCHAR(50),
			 StockItemCode NVARCHAR(50),
			RequestedQuantity DECIMAL(18,2),
			Remarks NVARCHAR(255),
			CategoryName NVARCHAR(255)
		);

		IF @IsDepartmentWiseItemForPR IS NULL
			SET @IsDepartmentWiseItemForPR = 0

		IF(@IsDepartmentWiseItemForPR =0)
		BEGIN
		 SELECT DISTINCT
					dbo.StockItemHeaders.Id StockItemID ,
					t.StockName,
					dbo.StockItemDetails.AveragePrice AS CostPrice,
					U.Id UnitID ,
					t.UnitName,
					0 SellingPrice ,
					dbo.StockItemHeaders.IsPriceEditable ,
					 dbo.StockItemHeaders.StockItemCode ,
					dbo.StockItemHeaders.Barcode ,
					t.RequestedQuantity ,
				   0 Value ,
					dbo.StockItemDetails.SellingPrice AS TaxInclusivePrice ,
					MaintainPriceHistory AS MaintainPriceHistory,
					t.Remarks,
					C.Id CategoryId,
					t.CategoryName,
					0 status
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					INNER JOIN @TempData t ON t.StockName = dbo.StockItemHeaders.Name
					INNER JOIN Categories C ON C.Id = StockItemHeaders.CategoryID
					INNER JOIN units U ON u.Name = T.UnitName
					WHERE dbo.StockItemHeaders.CompanyId = @PropertyID and dbo.StockItemDetails.LocationID = @LocationID
		END
		ELSE
		BEGIN
			SELECT DISTINCT
					dbo.StockItemHeaders.Id StockItemID ,
					t.StockName,
					dbo.StockItemDetails.AveragePrice AS CostPrice,
					U.Id UnitID ,
					t.UnitName,
					0 SellingPrice ,
					dbo.StockItemHeaders.IsPriceEditable ,
					 dbo.StockItemHeaders.StockItemCode ,
					dbo.StockItemHeaders.Barcode ,
					t.RequestedQuantity ,
				   0 Value ,
					dbo.StockItemDetails.SellingPrice AS TaxInclusivePrice ,
					MaintainPriceHistory AS MaintainPriceHistory,
					t.Remarks,
					C.Id CategoryId,
					t.CategoryName,
					0 status
			FROM    dbo.StockItemDetails
					INNER JOIN dbo.StockItemHeaders ON dbo.StockItemDetails.StockItemHeaderID = dbo.StockItemHeaders.Id
					INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = dbo.StockItemHeaders.Id
					INNER JOIN @TempData t ON t.StockName = dbo.StockItemHeaders.Name
					INNER JOIN Categories C ON C.Id = StockItemHeaders.CategoryID
					INNER JOIN units U ON u.Name = T.UnitName
					WHERE dbo.StockItemHeaders.CompanyId = @PropertyID and dbo.StockItemDetails.LocationID = @LocationID
					AND DI.DepartmentId =  CASE WHEN @DeptId1 = -999 THEN  DI.DepartmentId ELSE @DeptId1 END
		END

		END
	ELSE IF(@TransactionType ='PO')
	BEGIN
			DECLARE @TempData1 TABLE (
			Name NVARCHAR(255),
			CostPrice DECIMAL(18,6),
			StockItemCode NVARCHAR(50),
			RequestedQuantity DECIMAL(18,2),
			DiscountPercentage  DECIMAL(18,2),
			DiscountValue  DECIMAL(18,2),
			CategoryName NVARCHAR(50),
			Remark NVARCHAR(255),
			UnitName NVARCHAR(255)
		);

		DECLARE @PropertyID1 INT, @LocationID1 INT, @Supplierid1 int 

		SELECT @PropertyID1 =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID1 =JSON_VALUE(@jsonParamsData, '$.Locationid')
		SELECT @Supplierid1 =JSON_VALUE(@jsonParamsData, '$.Supplierid')

		INSERT INTO @TempData1 (Name, CostPrice,
			StockItemCode,
			RequestedQuantity, DiscountPercentage, DiscountValue,CategoryName,Remark,UnitName)
		SELECT 
			Name, CostPrice,
			StockItemCode,
			RequestedQuantity, DiscountPercentage, DiscountValue,CategoryName,Remark,UnitName
		FROM OPENJSON(@jsonEntity)
		WITH (
			Name NVARCHAR(255),
			CostPrice DECIMAL(18,6),
			StockItemCode NVARCHAR(50),
			RequestedQuantity DECIMAL(18,2),
			DiscountPercentage  DECIMAL(18,2),
			DiscountValue  DECIMAL(18,2),
			CategoryName NVARCHAR(50),
			Remark NVARCHAR(255),
			UnitName NVARCHAR(255)
		);

			DECLARE 
		@TemperatureApplicableAttributeId INT,
		@IsDefault BIT,
		@ISGross2 BIT

		SELECT  @ISGross2 = IsTaxOrSellPrice
		FROM    dbo.Companies
		WHERE   CompanyID = @Propertyid1

		DECLARE @TempTable2 TABLE (
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

			INSERT INTO @TempTable2
			SELECT DISTINCT 
				SIH.Id ,
				SIH.Name,
				SIH.IsExpiryDateApplicable,
				IWA.IsActive AS IsTemperatureApplicable,
				SWID.IsDefaultSupplier ,
				U.Id MasterUnitID,
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
				T.RequestedQuantity ,
				dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
												SIH.TaxGroupID) Value ,
				SID.SellingPrice AS TaxInclusivePrice ,
				MaintainPriceHistory AS MaintainPriceHistory,
				dbo.[FN_GetStockInHand_Reatils](@Propertyid1,@Locationid1,SIH.Id) QtyInHand,
				T.DiscountPercentage,
				T.DiscountValue,
				SIH.CategoryID ,
				C.Name CategoryName,
				0 ItemTotal,
				T.Remark,
				ISNULL( [dbo].[FN_GetStockItemWiseTotalTax](SIH.Id,
				CASE WHEN T.DiscountPercentage>0 and T.DiscountValue=0 THEN SWID.CostPrice- (SWID.CostPrice*T.DiscountPercentage/100) ELSE
				CASE WHEN T.DiscountValue>0 and T.DiscountPercentage=0 THEN SWID.CostPrice-T.DiscountValue else SWID.CostPrice-T.DiscountValue end END ,
				@Supplierid1,@LocationID1),0) TaxAmount,
				U.Name UnitName
			FROM    dbo.StockItemDetails SID
				INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN @TempData1 T ON T.Name = SIH.Name
				INNER JOIN dbo.SupplierWiseItemDetails SWID ON SWID.StockItemID = SID.StockItemHeaderID
				INNER JOIN dbo.Categories C ON C.Id = SIH.CategoryID
				INNER JOIN dbo.Units U ON U.Name= T.UnitName
				LEFT JOIN StockItemWiseAttributes IWA ON SIH.Id = IWA.StockItemHeaderID 
					AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId AND IWA.IsActive = 1 

			WHERE   ( SID.LocationID = @Locationid1 )
				AND ( SID.PropertyID = @Propertyid1 ) AND (SWID.SupplierID= @Supplierid1) 
					AND  ( SWID.LocationId = @Locationid1) AND SID.IsActive=1
				 	AND (SWID.ValidTo >= GETDATE() OR SWID.ValidTo IS NULL)
				
				

			IF @IsDefault = 0
				SELECT * FROM @TempTable2 ORDER BY Name
			IF @IsDefault =1 
				SELECT * FROM @TempTable2 WHERE IsDefaultSupplier = 1  ORDER BY Name
	END
	ELSE IF(@TransactionType ='IR')
	BEGIN
		DECLARE @TempData3 TABLE (
			StockItemCode VARCHAR(100),
			Name  VARCHAR(255),
			RequestedQuantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255)
		);

		DECLARE @PropertyID3 INT, @LocationID3 INT, @DeptId INT 
		
		SELECT @PropertyID3 =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID3 =JSON_VALUE(@jsonParamsData, '$.Locationid')
		SELECT @DeptId =JSON_VALUE(@jsonParamsData, '$.DepId')		
		
		INSERT INTO @TempData3 (StockItemCode,Name,RequestedQuantity,UnitName,Remarks)
		SELECT 
			StockItemCode,Name,RequestedQuantity,UnitName,Remarks
		FROM OPENJSON(@jsonEntity)
		WITH (
			StockItemCode VARCHAR(100),
			Name  VARCHAR(255),
			RequestedQuantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255)
		);

        DECLARE @IsDeptWiseItem BIT,
			@CompanySeparator NVARCHAR(10),
			@ComCode NVARCHAR(50),
			@DeptCode NVARCHAR(150),@ISGross4 BIT
         
		SELECT @IsDeptWiseItem = IsDepartmentWiseItems, @CompanySeparator = CompanySeparator FROM Companies WHERE CompanyID = @PropertyID3
		SELECT @ComCode = Code,@ISGross4 = IsTaxOrSellPrice FROM  Companies WHERE CompanyID = @PropertyID3
		SELECT @DeptCode = Code FROM Departments WHERE Id = @DeptId

		DECLARE @TempTable4 TABLE(
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
					INSERT INTO @TempTable4(	Id ,
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
										T.UnitName,
										T.Remarks,
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
										T.RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName
					FROM    dbo.StockItemDetails SID
							INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
							INNER JOIN @TempData3 T ON T.StockItemCode = SIH.StockItemCode
							INNER JOIN Units U ON U.Name = T.UnitName
							INNER JOIN Categories C ON C.Id = SIH.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
					WHERE   ( SID.LocationID = @LocationID3 )
							AND ( SID.PropertyID = @PropertyID3 ) AND (SID.IsActive = 1) 
							AND DI.Level1 = @DeptCode AND DI.GLCompCode = @ComCode AND DI.BlockCode = 'ISN'
							

					ORDER BY Name
				END					
				ELSE
				BEGIN

					INSERT INTO @TempTable4(	Id ,
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
										T.RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName
					FROM    dbo.StockItemDetails SID
							INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
							INNER JOIN @TempData3 T ON T.StockItemCode = SIH.StockItemCode
							INNER JOIN Units U ON U.Name = T.UnitName
							INNER JOIN Categories C ON C.Id = SIH.CategoryId
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SIH.Id
					WHERE   ( SID.LocationID = @LocationID3 )
							AND ( SID.PropertyID = @PropertyID3 ) AND (SID.IsActive = 1) 
							AND DI.DepartmentId =  CASE WHEN @DeptId = -999 THEN  DI.DepartmentId ELSE @DeptId END

					ORDER BY Name
				END
					
			END
			ELSE
			BEGIN
					INSERT INTO @TempTable4(	Id ,
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
										T.RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName
				FROM    dbo.StockItemDetails SID
						INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
						INNER JOIN @TempData3 T ON T.StockItemCode = SIH.StockItemCode
						INNER JOIN Units U ON U.Name = T.UnitName
						INNER JOIN Categories C ON C.Id = SIH.CategoryId
						INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SIH.Id
				WHERE   ( SID.LocationID = @LocationID3 )
						AND ( SID.PropertyID = @PropertyID3 ) AND (SID.IsActive = 1) 
						AND DI.DepartmentId = @DeptId

				ORDER BY Name
			END
			
			SELECT * FROM @TempTable4 

	END
	ELSE IF(@TransactionType = 'GR')
	BEGIN
		DECLARE @TempData4 TABLE (
			Name NVARCHAR(255),
			CostPrice DECIMAL(18,6),
			StockItemCode NVARCHAR(50),
			RequestedQuantity DECIMAL(18,2),
			DiscountPercentage  DECIMAL(18,2),
			DiscountValue  DECIMAL(18,2),
			CategoryName NVARCHAR(50),
			Remark NVARCHAR(255),
			UnitName NVARCHAR(255)
		);

		DECLARE @PropertyID4 INT, @LocationID4 INT, @Supplierid4 int 

		SELECT @PropertyID4 =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID4 =JSON_VALUE(@jsonParamsData, '$.Locationid')
		SELECT @Supplierid4 =JSON_VALUE(@jsonParamsData, '$.Supplierid')

		INSERT INTO @TempData4 
		SELECT *
		FROM OPENJSON(@jsonEntity)
		WITH (
			Name NVARCHAR(255),
			CostPrice DECIMAL(18,6),
			StockItemCode NVARCHAR(50),
			RequestedQuantity DECIMAL(18,2),
			DiscountPercentage  DECIMAL(18,2),
			DiscountValue  DECIMAL(18,2),
			CategoryName NVARCHAR(50),
			Remark NVARCHAR(255),
			UnitName NVARCHAR(255)
		);

			DECLARE 
		@TemperatureApplicableAttributeId4 INT,
		@IsDefault4 BIT,
		@ISGross5 BIT

		SELECT  @ISGross5 = IsTaxOrSellPrice
		FROM    dbo.Companies
		WHERE   CompanyID = @Propertyid4

		DECLARE @TempTable5 TABLE (
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
         
			SELECT @TemperatureApplicableAttributeId4 = [TemperatureApplicableAttributeId] FROM CompanySettings WHERE CompanyId = @Propertyid4

			SELECT @IsDefault4 = CheckForDefaultSupplier  FROM CommonSettings

			INSERT INTO @TempTable5
			SELECT DISTINCT 
				SIH.Id ,
				SIH.Name,
				SIH.IsExpiryDateApplicable,
				IWA.IsActive AS IsTemperatureApplicable,
				SWID.IsDefaultSupplier ,
				U.Id MasterUnitID,
				CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END AS CostPrice,
				-- dbo.StockItemDetails.MasterUnitID ,
				0 SellingPrice ,
				SIH.IsPriceEditable ,
				SIH.StockItemCode ,
				SIH.Barcode ,
				ISNULL(T.RequestedQuantity,0) RequestedQuantity ,
				0 Value ,
				SID.SellingPrice AS TaxInclusivePrice ,
				MaintainPriceHistory AS MaintainPriceHistory,
				dbo.[FN_GetStockInHand_Reatils](@Propertyid4,@Locationid4,SIH.Id) QtyInHand,
				ISNULL(T.DiscountPercentage,0) DiscountPercentage,
				ISNULL(T.DiscountValue,0) DiscountValue,
				SIH.CategoryID ,
				C.Name CategoryName,
				(ISNULL(CASE WHEN ISNULL(T.DiscountPercentage,0)>0 and ISNULL(T.DiscountValue,0)=0 THEN (CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END- (CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END*ISNULL(T.DiscountPercentage,0)/100))*ISNULL(T.RequestedQuantity,0) ELSE
				CASE WHEN ISNULL(T.DiscountValue,0)>0 and ISNULL(T.DiscountPercentage,0)=0 THEN (CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END-ISNULL(T.DiscountValue,0))*ISNULL(T.RequestedQuantity,0) else (CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END-ISNULL(T.DiscountValue,0))*ISNULL(T.RequestedQuantity,0) end END,0))
				
				+(
				ISNULL( [dbo].[FN_GetStockItemWiseTotalTax](SIH.Id,
				CASE WHEN ISNULL(T.DiscountPercentage,0)>0 and ISNULL(T.DiscountValue,0)=0 THEN CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END- (CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END*ISNULL(T.DiscountPercentage,0)/100) ELSE
				CASE WHEN ISNULL(T.DiscountValue,0)>0 and ISNULL(T.DiscountPercentage,0)=0 THEN CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END-ISNULL(T.DiscountValue,0) else CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END-ISNULL(T.DiscountValue,0) end END ,
				@Supplierid4,@LocationID4),0) * ISNULL(T.RequestedQuantity,0)
				)
				ItemTotal,
				T.Remark,
				ISNULL( [dbo].[FN_GetStockItemWiseTotalTax](SIH.Id,
				CASE WHEN ISNULL(T.DiscountPercentage,0)>0 and ISNULL(T.DiscountValue,0)=0 THEN CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END- (CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END*ISNULL(T.DiscountPercentage,0)/100) ELSE
				CASE WHEN ISNULL(T.DiscountValue,0)>0 and ISNULL(T.DiscountPercentage,0)=0 THEN CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END-ISNULL(T.DiscountValue,0) else CASE WHEN T.CostPrice IS NULL OR T.CostPrice<0 THEN SWID.CostPrice ELSE T.CostPrice END-ISNULL(T.DiscountValue,0) end END ,
				@Supplierid4,@LocationID4),0) TaxAmount,
				U.Name UnitName,
				[dbo].[FUN_GetItemLevelAccountName](@Propertyid4,@Locationid4,SIH.Id) AccName
			FROM    dbo.StockItemDetails SID
				INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
				INNER JOIN @TempData4 T ON T.Name = SIH.Name
				INNER JOIN dbo.SupplierWiseItemDetails SWID ON SWID.StockItemID = SID.StockItemHeaderID
				INNER JOIN dbo.Categories C ON C.Id = SIH.CategoryID
				INNER JOIN dbo.Units U ON U.Name= T.UnitName
				LEFT JOIN StockItemWiseAttributes IWA ON SIH.Id = IWA.StockItemHeaderID 
					AND IWA.StockItemAttributeID = @TemperatureApplicableAttributeId4 AND IWA.IsActive = 1 

			WHERE   ( SID.LocationID = @Locationid4 )
				AND ( SID.PropertyID = @Propertyid4 ) AND (SWID.SupplierID= @Supplierid4) 
					AND  ( SWID.LocationId = @Locationid4) AND SID.IsActive=1
				 	AND (SWID.ValidTo >= GETDATE() OR SWID.ValidTo IS NULL)
				
				

			IF @IsDefault4 = 0
				SELECT * FROM @TempTable5 ORDER BY Name
			IF @IsDefault4 =1 
				SELECT * FROM @TempTable5 WHERE IsDefaultSupplier = 1  ORDER BY Name	

	END
	
	ELSE IF(@TransactionType ='DIR')
	BEGIN
		DECLARE @TempData5 TABLE (
			StockItemCode VARCHAR(100),
			Name  VARCHAR(255),
			RequestedQuantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255)
		);

		DECLARE @PropertyID5 INT, @LocationID5 INT, @ToLocationid5 INT
		
		SELECT @PropertyID5 =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID5 =JSON_VALUE(@jsonParamsData, '$.Locationid')	
		SELECT @ToLocationid5 =JSON_VALUE(@jsonParamsData, '$.Locationid2')
		
		INSERT INTO @TempData5 (StockItemCode,Name,RequestedQuantity,UnitName,Remarks)
		SELECT 
			StockItemCode,Name,RequestedQuantity,UnitName,Remarks
		FROM OPENJSON(@jsonEntity)
		WITH (
			StockItemCode VARCHAR(100),
			Name  VARCHAR(255),
			RequestedQuantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255)
		);

		DECLARE @TempTable6 TABLE(
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

					INSERT INTO @TempTable6(	Id ,
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
										T.RequestedQuantity,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName

				FROM    dbo.StockItemDetails SID
						INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
						INNER JOIN 
						(SELECT SID2.StockItemHeaderID FROM StockItemDetails SID2 WHERE SID2.LocationID = @ToLocationid5 AND SID2.CompanyID = @PropertyID5 AND SID2.IsActive =1) TempTable ON TempTable.StockItemHeaderID = SIH.Id
						INNER JOIN @TempData5 T ON T.StockItemCode = SIH.StockItemCode
						INNER JOIN Units U ON U.Name = T.UnitName
						INNER JOIN Categories C ON C.Id = SIH.CategoryId
				WHERE   ( SID.LocationID = @LocationID5 )
						AND ( SID.PropertyID = @PropertyID5 ) AND (SID.IsActive = 1) 

				ORDER BY Name
			
			SELECT * FROM @TempTable6 

	END
	ELSE IF(@TransactionType = 'QU')
	BEGIN

	
	 DECLARE @TempDataQU TABLE (
			StockItemCode VARCHAR(MAX),
			ItemName VARCHAR(MAX),
			UnitName VARCHAR(200),
			Quantity DECIMAL(18,6), 
			Price  DECIMAL(18,6),
			TaxAmount  DECIMAL(18,6),
			DiscountValue  DECIMAL(18,6),
			DiscountPercentage  DECIMAL(18,6)
		);
			
		DECLARE @PropertyIDQU INT,@LocationIDQU INT,@RequestHeaderIDQU INT

		SELECT @PropertyIDQU =JSON_VALUE(@jsonParamsData, '$.PropertyID')
		SELECT @LocationIDQU =JSON_VALUE(@jsonParamsData, '$.LocationID')
		SELECT @RequestHeaderIDQU =JSON_VALUE(@jsonParamsData, '$.RequestHeaderID') 

	INSERT INTO @TempDataQU (StockItemCode,ItemName,UnitName,Quantity,Price,TaxAmount,DiscountValue,DiscountPercentage)
	SELECT 
			StockItemCode,
			ItemName,
			UnitName,
			ISNULL(TRY_CAST(ApprovedQuantity AS DECIMAL(18,6)), 0) AS ApprovedQuantity,
			ISNULL(TRY_CAST(Price AS DECIMAL(18,6)), 0) AS Price,
			ISNULL(TRY_CAST(TaxAmount AS DECIMAL(18,6)), 0) AS TaxAmount,
			ISNULL(TRY_CAST(DiscountValue AS DECIMAL(18,6)), 0) AS DiscountValue,
			ISNULL(TRY_CAST(DiscountPercentage AS DECIMAL(18,6)), 0) AS DiscountPercentage
		FROM OPENJSON(@jsonEntity)
		WITH (
			StockItemCode VARCHAR(MAX),
			ItemName VARCHAR(MAX),
			UnitName VARCHAR(200),
			ApprovedQuantity NVARCHAR(50), 
			Price  NVARCHAR(50),
			TaxAmount NVARCHAR(50),
			DiscountValue NVARCHAR(50),
			DiscountPercentage NVARCHAR(50)
		);

		SELECT TP.StockItemCode,TP.ItemName,TP.UnitName,TP.Quantity,TP.Price,SH.Id ItemID,UN.Id UnitID, TP.TaxAmount, TP.DiscountValue, TP.DiscountPercentage
		FROM @TempDataQU TP
		INNER JOIN StockItemHeaders SH ON TP.StockItemCode = SH.StockItemCode
		INNER JOIN Units UN ON UN.Name = TP.UnitName
		WHERE SH.CompanyId = @PropertyIDQU


	END
	ELSE IF(@TransactionType ='CR')
	BEGIN
		DECLARE @TempData6 TABLE (
			StockItemCode VARCHAR(100),
			StockName  VARCHAR(MAX),
			Quantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255),
			DeliverySchedule VARCHAR(255)
		);

		DECLARE @PropertyID6 INT, @LocationID6 INT
		
		SELECT @PropertyID6 =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID6 =JSON_VALUE(@jsonParamsData, '$.Locationid')	
		
		INSERT INTO @TempData6 (StockItemCode,StockName,Quantity,UnitName,Remarks,DeliverySchedule)
		SELECT 
			StockItemCode,StockName,Quantity,UnitName,Remarks,DeliverySchedule
		FROM OPENJSON(@jsonEntity)
		WITH (
			StockItemCode VARCHAR(100),
			StockName  VARCHAR(MAX),
			Quantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255),
			DeliverySchedule VARCHAR(255)
		);

		DECLARE @TempTable7 TABLE(
						StockItemID INT,
						StockName VARCHAR(MAX),
						CategoryID INT,
						CategoryName VARCHAR(500),
						MasterUnitID INT,
						UnitName VARCHAR(500),
						Quantity DECIMAL(18,8),
						IsActive BIT,
						QuantityInHand DECIMAL(18,8),
						CostPrice DECIMAL(18,8),
						StockItemCode NVARCHAR(MAX),
						Remarks NVARCHAR(500),
						DeliverySchedule VARCHAR(500),
						DeliveryScheduleID INT
		)

					INSERT INTO @TempTable7(	StockItemID,StockName,CategoryID,CategoryName,MasterUnitID,UnitName,Quantity,IsActive,QuantityInHand,CostPrice,StockItemCode,Remarks,DeliverySchedule,DeliveryScheduleID)
					SELECT 
						StockItemID,
						StockName,
						CategoryID,
						C.Name AS CategoryName,
						U.Id AS MasterUnitID,
						T.UnitName,
						T.Quantity,
						SID.IsActive,
						QuantityInHand,
						SID.AveragePrice CostPrice,
						SIH.StockItemCode,
						T.Remarks,
						T.DeliverySchedule,
						D.ID AS DeliveryScheduleID
				FROM    dbo.StockItemDetails SID
						INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
						INNER JOIN @TempData6 T ON T.StockItemCode = SIH.StockItemCode
						INNER JOIN Units U ON U.Name = T.UnitName
						INNER JOIN Categories C ON C.Id = SIH.CategoryId
						LEFT JOIN DeliverySchedule D ON D.Name = T.DeliverySchedule
				WHERE   ( SID.LocationID = @LocationID6 )
						AND ( SID.PropertyID = @PropertyID6 ) AND (SID.IsActive = 1) 

				ORDER BY SIH.Name
			
			SELECT * FROM @TempTable7 

	END
	ELSE IF(@TransactionType ='DIN')
	BEGIN
		DECLARE @TempData7 TABLE (
			StockItemCode VARCHAR(100),
			Name  VARCHAR(255),
			RequestedQuantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255)
		);

		DECLARE @PropertyID7 INT, @LocationID7 INT, @DeptId7 INT 
		
		SELECT @PropertyID7 =JSON_VALUE(@jsonParamsData, '$.Propertyid')
		SELECT @LocationID7 =JSON_VALUE(@jsonParamsData, '$.Locationid')
		SELECT @DeptId7 =JSON_VALUE(@jsonParamsData, '$.DepId')		
		
		INSERT INTO @TempData7 (StockItemCode,Name,RequestedQuantity,UnitName,Remarks)
		SELECT 
			StockItemCode,Name,RequestedQuantity,UnitName,Remarks
		FROM OPENJSON(@jsonEntity)
		WITH (
			StockItemCode VARCHAR(100),
			Name  VARCHAR(255),
			RequestedQuantity DECIMAL(18,6),
			UnitName VARCHAR(255),
			Remarks VARCHAR(255)
		);

        DECLARE @IsDeptWiseItem7 BIT,
			@CompanySeparator7 NVARCHAR(10),
			@ComCode7 NVARCHAR(50),
			@DeptCode7 NVARCHAR(150),@ISGross7 BIT
         
		SELECT @IsDeptWiseItem7 = IsDepartmentWiseItems, @CompanySeparator7 = CompanySeparator FROM Companies WHERE CompanyID = @PropertyID7
		SELECT @ComCode7 = Code,@ISGross7 = IsTaxOrSellPrice FROM  Companies WHERE CompanyID = @PropertyID7
		SELECT @DeptCode7 = Code FROM Departments WHERE Id = @DeptId7

		DECLARE @TempTable8 TABLE(
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

			IF(@IsDeptWiseItem7 = 1 )
			BEGIN

				IF(@CompanySeparator7 = 'JT')
				BEGIN	
					INSERT INTO @TempTable8(	Id ,
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
										T.UnitName,
										T.Remarks,
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
										 ( CASE WHEN @ISGross7 = 0
										THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
																			SIH.TaxGroupID)
									   ELSE SID.SellingPrice
										 END ) SellingPrice ,
										SIH.IsPriceEditable,
										SIH.Barcode,
										T.RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName
					FROM    dbo.StockItemDetails SID
							INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
							INNER JOIN @TempData7 T ON T.StockItemCode = SIH.StockItemCode
							INNER JOIN Units U ON U.Name = T.UnitName
							INNER JOIN Categories C ON C.Id = SIH.CategoryId
							INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryId
							INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID 
							INNER JOIN [dbo].[Destinity_GLIntegrationAccountMapping] DI ON DI.Level2 = C.Code AND DI.Level3 = SC.Code AND DI.Level4 = SC2.Code
					WHERE   ( SID.LocationID = @LocationID7 )
							AND ( SID.PropertyID = @PropertyID7 ) AND (SID.IsActive = 1) 
							AND DI.Level1 = @DeptCode7 AND DI.GLCompCode = @ComCode7 AND DI.BlockCode = 'ISN'
							

					ORDER BY Name
				END					
				ELSE
				BEGIN

					INSERT INTO @TempTable8(	Id ,
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
										 ( CASE WHEN @ISGross7 = 0
										THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
																			SIH.TaxGroupID)
									   ELSE SID.SellingPrice
										 END ) SellingPrice ,
										SIH.IsPriceEditable,
										SIH.Barcode,
										T.RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName
					FROM    dbo.StockItemDetails SID
							INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
							INNER JOIN @TempData7 T ON T.StockItemCode = SIH.StockItemCode
							INNER JOIN Units U ON U.Name = T.UnitName
							INNER JOIN Categories C ON C.Id = SIH.CategoryId
							INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SIH.Id
					WHERE   ( SID.LocationID = @LocationID7 )
							AND ( SID.PropertyID = @PropertyID7 ) AND (SID.IsActive = 1) 
							AND DI.DepartmentId =  CASE WHEN @DeptId7 = -999 THEN  DI.DepartmentId ELSE @DeptId7 END

					ORDER BY Name
				END
					
			END
			ELSE
			BEGIN
					INSERT INTO @TempTable8(	Id ,
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
										 ( CASE WHEN @ISGross7 = 0
										THEN dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
																			SIH.TaxGroupID)
									   ELSE SID.SellingPrice
										 END ) SellingPrice ,
										SIH.IsPriceEditable,
										SIH.Barcode,
										T.RequestedQuantity,
										dbo.FN_GetActualPriceWithoutTax(SID.SellingPrice,
                                        SIH.TaxGroupID) Value ,
										SID.SellingPrice AS TaxInclusivePrice,
										SIH.MaintainPriceHistory,
										SIH.IsProductionItem,
										U.Id UnitID,
										U.Name UnitName,
										T.Remarks,
										C.Id CategoryID,
										C.Name CategoryName
				FROM    dbo.StockItemDetails SID
						INNER JOIN dbo.StockItemHeaders SIH ON SID.StockItemHeaderID = SIH.Id
						INNER JOIN @TempData7 T ON T.StockItemCode = SIH.StockItemCode
						INNER JOIN Units U ON U.Name = T.UnitName
						INNER JOIN Categories C ON C.Id = SIH.CategoryId
						INNER JOIN Departmentwiseitems DI ON DI.StockiTemId = SIH.Id
				WHERE   ( SID.LocationID = @LocationID7 )
						AND ( SID.PropertyID = @PropertyID7 ) AND (SID.IsActive = 1) 
						AND DI.DepartmentId = @DeptId7

				ORDER BY Name
			END
			
			SELECT * FROM @TempTable8 

	END
END

GO

