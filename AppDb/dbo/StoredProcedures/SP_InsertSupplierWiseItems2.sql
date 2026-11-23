
-- =============================================
-- Author			: Nivesh
-- Create date		: 2024-09-06
-- Modified By		: Nivesh
-- Modified date	: 2025-11-13
-- Modified By		: Isuru
-- Modified date	: 2026-10-07
-- Reason			: TaxGroupID was being saved as 0 / NULL
-- Description:	Supplier-wise Item detail
-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertSupplierWiseItems2] (@XMLDetails XML, @Action CHAR(1))
AS
BEGIN

  INSERT tempStockItems
    (
        xmldata
    )
    SELECT @XMLDetails XMLDetails;

    BEGIN TRANSACTION;

    BEGIN TRY
    SET NOCOUNT ON;

    DECLARE @iDocID INT,
            @StockitemID int,
            @SupplierID int,
            @CompanyList XML,
            @IsCheck BIT,
            @StockItemCode VARCHAR(MAX),
            @iDocIDProp INT,
            @ItemName VARCHAR(MAX),
            @TaxGroupID INT,
            @LocationID INT,
            @CompanyId INT,
			@IsCurrentCompany BIT,
			@SUPWD_ID INT,
			@AuditTailUserID INT,
			@tempCostPrice DECIMAL(18,8) =0,
			@tempUnitID INT =0,
			@tempTaxGroupID INT =0,
			@IsDefaultSupplier BIT =0,
			@Id INT =0,
			@IsContractedSupplier BIT,
			@Validfrom DATETIME,
			@ValidTo DATETIME,
			@MultipleLocationList XML,
			@IsAllLocation BIT,
			@iDocIDMulLoc INT,
			@isSupplierForAllLocation BIT =0,
			@CurrentCompanyID INT;

	
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    CREATE TABLE #ItemListTemp
    (
        StockItemCode VARCHAR(MAX),
        LocationName VARCHAR(MAX),
        ItemName VARCHAR(MAX),
        CostPrice DECIMAL(18,8),
        TaxName VARCHAR(MAX),
        IsDefaultSupplier BIT,
        LocationID INT,
        StockItemID INT,
        CompanyId INT,
        SupplierID INT,
        UnitId INT,
        UserID INT,
        TaxGroupId INT,
        PurchaseUnitName VARCHAR(MAX),
        CompanyList XML,
		Id INT,
		IsContractedSupplier BIT,
		Validfrom DATETIME,
		ValidTo DATETIME,
		MultipleLocationList XML,
		IsAllLocation BIT
    );

    INSERT INTO #ItemListTemp
    (
        StockItemCode,
        LocationName,
        ItemName,
        CostPrice,
        TaxName,
        IsDefaultSupplier,
        LocationID,
        StockItemID,
        CompanyId,
        SupplierID,
        UnitId,
        UserID,
        TaxGroupId,
        PurchaseUnitName,
        CompanyList,
		Id,
		IsContractedSupplier,
		Validfrom,
		ValidTo,
		MultipleLocationList,
		IsAllLocation
    )
	SELECT	StockItemCode,
			LocationName,
			ItemName,
			CostPrice,
			TaxName,
			IsDefaultSupplier,
			LocationID,
			StockItemID,
			CompanyId,
			SupplierID,
			UnitId,
			UserID,
			TaxGroupId,
			PurchaseUnitName,
			CompanyList,
			Id,
			IsContractedSupplier,
			Validfrom,
			ValidTo,
			MultipleLocationList,
			IsAllLocation
    FROM
        OPENXML(@iDocID, '/GetStockItemHeadersWithSuppliersModel', 2)
        WITH
        (
            StockItemCode VARCHAR(MAX),
            LocationName VARCHAR(MAX),
            ItemName VARCHAR(MAX),
            CostPrice DECIMAL(18,8),
            TaxName VARCHAR(MAX),
            IsDefaultSupplier BIT,
            LocationID INT,
            StockItemID INT,
            CompanyId INT,
            SupplierID INT,
            UnitId INT,
            UserID INT,
            TaxGroupId INT,
            PurchaseUnitName VARCHAR(MAX),
            CompanyList XML,
			Id INT,
			IsContractedSupplier BIT,
			Validfrom DATETIME,
			ValidTo DATETIME,
			MultipleLocationList XML,
			IsAllLocation BIT
        );

		CREATE TABLE #TempPropIN
		 (
                CompanyId INT,
                IsChecked BIT,
                SupplierID INT,
                StockItemID INT,
				LocationId INT,
				LocationName VARCHAR(MAX),
				IsCurrentCompany BIT,
				CostPrice DECIMAL(18,8),
				UnitId INT,
				TaxGroupId INT
            )
			DECLARE @MultipleLocation TABLE(
				id INT,
				isMainStore BIT,
				UnitId INT,
				isActive BIT,
				DefaultLocation BIT,
				IsExpiryDateApplicable BIT,
				isSelected BIT
			)
    --------------------------------------------------Things Updates---------------------------------------------------------------------------
		SELECT @StockItemID = StockItemID,
			   @StockItemCode = StockItemCode,
			   @ItemName = ItemName,
			   @TaxGroupID = TaxGroupID,
			   @CompanyList = CompanyList,
			   @LocationID = LocationID,
			   @CompanyId = CompanyId,
			   @StockItemID = StockItemID,
			   @SupplierID = SupplierID,
			   @AuditTailUserID = UserID,
				@tempCostPrice = ISNULL(CostPrice,0),
				@tempUnitID = UnitId,
				@IsDefaultSupplier=IsDefaultSupplier,
				@Id = Id,
				@IsContractedSupplier = IsContractedSupplier,
				@Validfrom = Validfrom,
				@ValidTo = ValidTo,
				@MultipleLocationList = MultipleLocationList,
				@IsAllLocation = IsAllLocation
		FROM #ItemListTemp;

		--added by Isuru 2026-10-07 reject an invalid tax group on insert
		DECLARE @IsTaxGroupValid BIT =
			CASE WHEN EXISTS (SELECT 1 FROM TaxGroups WHERE TaxGroupId = @TaxGroupID) THEN 1 ELSE 0 END;

		IF (@Action = 'I' AND @IsTaxGroupValid = 0)
		BEGIN
			RAISERROR('A valid tax group is required.',16,1)
		END

		SELECT @isSupplierForAllLocation = ISNULL(isSupplierForAllLocation,0) 
		FROM 
		Companies
		WHERE CompanyID = @CompanyId

		SET @CurrentCompanyID = @CompanyId

		IF(@isSupplierForAllLocation =1 AND @IsAllLocation =1)
		BEGIN
		
			EXEC sp_xml_preparedocument @iDocIDMulLoc OUTPUT, @MultipleLocationList;

			INSERT INTO @MultipleLocation ( 
				id,
				isMainStore,
				UnitId,
				isActive,
				DefaultLocation,
				IsExpiryDateApplicable,
				isSelected)
			SELECT id,
				   isMainStore,
				   UnitId,
				   isActive,
				   DefaultLocation,
				   IsExpiryDateApplicable,
				   isSelected
			FROM
				OPENXML(@iDocIDMulLoc, '/MultipleLocationList/GridSelectLocation', 2)
				WITH
				(
					id INT,
					isMainStore BIT,
					UnitId INT,
					isActive BIT,
					DefaultLocation BIT,
					IsExpiryDateApplicable BIT,
					isSelected BIT
				)
		END

		EXEC sp_xml_preparedocument @iDocIDProp OUTPUT, @CompanyList;

	 	INSERT INTO #TempPropIN ( CompanyId,
               IsChecked,
               SupplierID,
               StockItemID,
			   LocationId,
			   LocationName,
			   IsCurrentCompany,
			   CostPrice,
			   UnitId,
			   TaxGroupId)
		SELECT CompanyId,
               IsChecked,
               SupplierID,
               StockItemID,
			   LocationId,
			   LocationName,
			   IsCurrentCompany,
			   CostPrice,
			   UnitId,
			   TaxGroupId
       -- INTO #TempPropIN
        FROM
            OPENXML(@iDocIDProp, '/CompanyList/UserWiseItemWiseCompniesNew', 2)
            WITH
            (
                CompanyId INT,
                IsChecked BIT,
                SupplierID INT,
                StockItemID INT,
				LocationId INT,
				LocationName VARCHAR(MAX),
				IsCurrentCompany BIT,
				CostPrice FLOAT,
				UnitId INT,
				TaxGroupId INT
            )

		IF(@Action = 'I') -- Insert
		BEGIN
		 WHILE
        (SELECT COUNT(*) FROM #TempPropIN) > 0
        BEGIN
			
			DECLARE @tempLocationID INT = 0

            SELECT TOP (1)
                @CompanyId = CompanyId,
                @IsCheck = IsChecked,
				@IsCurrentCompany = IsCurrentCompany,
                @StockitemID = StockitemID,
				@tempLocationID = LocationId,
				@tempCostPrice = ISNULL(CostPrice,0),
				@tempUnitID = UnitId,
				--added by Isuru 2026-10-07 NULL here was inserted as NULL instead of falling back to the header tax group
				@tempTaxGroupID = ISNULL(TaxGroupId, 0)
            FROM #TempPropIN

            IF (
                   @IsCheck = 1
                   and EXISTS
            (
                SELECT 1
                FROM StockItemHeaders
                WHERE CompanyId = @CompanyId
                      AND StockItemCode = @StockItemCode
            )
               ) -- check the Item availability in company
            BEGIN

				IF(@isSupplierForAllLocation = 0 --Single locaion insertion
					OR 
					(
					@isSupplierForAllLocation = 1 
					AND @CurrentCompanyID = @CompanyId 
					AND NOT EXISTS
					(
						SELECT 1 FROM @MultipleLocation WHERE IsActive = 1 AND isSelected = 1
					)
					AND @IsAllLocation = 0
					) -- when config multiple location and not select all locaion and item update in current locaion
				) 
				BEGIN
					INSERT INTO SupplierWiseItemDetails
					(
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
						TaxGroupID,
						IsContractedSupplier
						,Validfrom
						,ValidTo
					)
					SELECT @CompanyId,
						   ( CASE WHEN @IsCurrentCompany = 1 THEN LocationID ELSE
						   case when @tempLocationID =0 then
						   (SELECT TOP 1 id FROM Locations WHERE CompanyID =@CompanyId and DefaultLocation =1 )
						   else @tempLocationID end
						   END),
						   @SupplierId,
						   @StockitemID,
						  case when @tempUnitID =0 then UnitId else @tempUnitID end ,
						   case when @tempCostPrice =0 then CostPrice else @tempCostPrice end,
						   IsDefaultSupplier,
						   UserID,
						   UserID,
						   GETDATE(),
						   GETDATE(),
						   '',
						  case when @tempTaxGroupID = 0
							    OR NOT EXISTS (SELECT 1 FROM TaxGroups TG WHERE TG.TaxGroupId = @tempTaxGroupID)
							   then TaxGroupId else @tempTaxGroupID end ,
						  @IsContractedSupplier,
						  CASE WHEN @IsContractedSupplier =1 THEN @Validfrom ELSE NULL END,
						  CASE WHEN @IsContractedSupplier =1 THEN @ValidTo ELSE NULL END
					FROM #ItemListTemp
					WHERE StockItemCode = @StockItemCode AND
					NOT EXISTS
					(
						SELECT 1
						FROM SupplierWiseItemDetails
						WHERE CompanyId = @CompanyId
							  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID
					)
				--END
			
					SET @SUPWD_ID =  SCOPE_IDENTITY()

					-------------------------------------------Log SupplierWiseItemDetails Insert-2024-02-22-----------------
					IF EXISTS (SELECT 1 FROM #ItemListTemp where StockItemCode = @StockItemCode AND
						NOT EXISTS
						(
							SELECT 1
							FROM SupplierWiseItemDetails
							WHERE CompanyId = @CompanyId
									AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID
						))
					BEGIN
						EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDI', 'I', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
					END
					---------------------------------------------------------------------------------------------------
				END
				ELSE IF(
					@isSupplierForAllLocation = 1 --when config multiple locaion 
					AND @CurrentCompanyID = @CompanyId -- In Current company
					AND EXISTS
					(
						SELECT 1 FROM @MultipleLocation WHERE IsActive = 1 AND isSelected = 1
					)
					AND @IsAllLocation = 1 -- select All locaion check box and select multiple locaion
				) 
				BEGIN
					DECLARE 
						@id_Loc INT,
						@isMainStore_Loc BIT,
						@UnitId_Loc INT,
						@isActive_Loc BIT,
						@DefaultLocation_Loc BIT,
						@IsExpiryDateApplicable_Loc BIT,
						@isSelected_Loc INT;

					-- 1?? Declare cursor
					DECLARE multipleLocaion CURSOR FAST_FORWARD
					FOR
					SELECT id,
					isMainStore,
					UnitId,
					isActive,
					DefaultLocation,
					IsExpiryDateApplicable,
					isSelected
					FROM @MultipleLocation WHERE IsActive = 1 AND isSelected = 1;

					-- 2?? Open cursor
					OPEN multipleLocaion;

					-- 3?? Fetch first row
					FETCH NEXT FROM multipleLocaion INTO @id_Loc, @isMainStore_Loc, @UnitId_Loc, @isActive_Loc, @DefaultLocation_Loc, @IsExpiryDateApplicable_Loc,@isSelected_Loc;

					-- 4?? Loop through rows
					WHILE @@FETCH_STATUS = 0
					BEGIN
						
						INSERT INTO SupplierWiseItemDetails
						(
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
							TaxGroupID,
							IsContractedSupplier
							,Validfrom
							,ValidTo
						)
						SELECT @CompanyId,
							   @id_Loc,
							   @SupplierId,
							   @StockitemID,
							  case when @tempUnitID =0 then UnitId else @tempUnitID end ,
							   case when @tempCostPrice =0 then CostPrice else @tempCostPrice end,
							   IsDefaultSupplier,
							   UserID,
							   UserID,
							   GETDATE(),
							   GETDATE(),
							   '',
							  case when @tempTaxGroupID = 0
							    OR NOT EXISTS (SELECT 1 FROM TaxGroups TG WHERE TG.TaxGroupId = @tempTaxGroupID)
							   then TaxGroupId else @tempTaxGroupID end ,
							  @IsContractedSupplier,
							  CASE WHEN @IsContractedSupplier =1 THEN @Validfrom ELSE NULL END,
							  CASE WHEN @IsContractedSupplier =1 THEN @ValidTo ELSE NULL END
						FROM #ItemListTemp
						WHERE StockItemCode = @StockItemCode AND
						NOT EXISTS
						(
							SELECT 1
							FROM SupplierWiseItemDetails
							WHERE CompanyId = @CompanyId
								  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @id_Loc
						)
					--END
			
						SET @SUPWD_ID =  SCOPE_IDENTITY()

						-------------------------------------------Log SupplierWiseItemDetails Insert-2024-02-22-----------------
						IF EXISTS (SELECT 1 FROM #ItemListTemp where StockItemCode = @StockItemCode AND
							NOT EXISTS
							(
								SELECT 1
								FROM SupplierWiseItemDetails
								WHERE CompanyId = @CompanyId
										AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @id_Loc
							))
						BEGIN
							EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDI', 'I', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
						END
						---------------------------------------------------------------------------------------------------
						-- Fetch next row
						
						FETCH NEXT FROM multipleLocaion INTO @id_Loc, @isMainStore_Loc, @UnitId_Loc, @isActive_Loc, @DefaultLocation_Loc, @IsExpiryDateApplicable_Loc,@isSelected_Loc;
					END

					-- 5?? Close and deallocate
					CLOSE multipleLocaion;
					DEALLOCATE multipleLocaion;

				END
				ELSE IF (@isSupplierForAllLocation = 1 AND @CurrentCompanyID <> @CompanyId) -- when config multiple locaion and not current company
				BEGIN
					INSERT INTO SupplierWiseItemDetails
					(
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
						TaxGroupID,
						IsContractedSupplier
						,Validfrom
						,ValidTo
					)
					SELECT @CompanyId,
						   ( CASE WHEN @IsCurrentCompany = 1 THEN LocationID ELSE
						   case when @tempLocationID =0 then
						   (SELECT TOP 1 id FROM Locations WHERE CompanyID =@CompanyId and DefaultLocation =1 )
						   else @tempLocationID end
						   END),
						   @SupplierId,
						   @StockitemID,
						  case when @tempUnitID =0 then UnitId else @tempUnitID end ,
						   case when @tempCostPrice =0 then CostPrice else @tempCostPrice end,
						   IsDefaultSupplier,
						   UserID,
						   UserID,
						   GETDATE(),
						   GETDATE(),
						   '',
						  case when @tempTaxGroupID = 0
							    OR NOT EXISTS (SELECT 1 FROM TaxGroups TG WHERE TG.TaxGroupId = @tempTaxGroupID)
							   then TaxGroupId else @tempTaxGroupID end ,
						  @IsContractedSupplier,
						  CASE WHEN @IsContractedSupplier =1 THEN @Validfrom ELSE NULL END,
						  CASE WHEN @IsContractedSupplier =1 THEN @ValidTo ELSE NULL END
					FROM #ItemListTemp
					WHERE StockItemCode = @StockItemCode AND
					NOT EXISTS
					(
						SELECT 1
						FROM SupplierWiseItemDetails
						WHERE CompanyId = @CompanyId
							  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID
					)
				--END
			
					SET @SUPWD_ID =  SCOPE_IDENTITY()

					-------------------------------------------Log SupplierWiseItemDetails Insert-2024-02-22-----------------
					IF EXISTS (SELECT 1 FROM #ItemListTemp where StockItemCode = @StockItemCode AND
						NOT EXISTS
						(
							SELECT 1
							FROM SupplierWiseItemDetails
							WHERE CompanyId = @CompanyId
									AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @tempLocationID
						))
					BEGIN
						EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDI', 'I', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
					END
					---------------------------------------------------------------------------------------------------				
				END
            END

            DELETE TOP (1)
            FROM #TempPropIN

        END
		END
		ELSE IF(@Action = 'U') -- Update
		BEGIN

			IF(@isSupplierForAllLocation =0 OR @IsAllLocation =0) --When not config multiple locaion and not select all location check box
			BEGIN
				IF EXISTS(SELECT 1 FROM SupplierWiseItemDetails WHERE StockItemID = @StockitemID AND LocationId = @LocationID AND CompanyId= @CompanyId AND SupplierID = @SupplierID AND Id = @Id)
				BEGIN
					UPDATE 
					SupplierWiseItemDetails
					--added by Isuru 2026-10-07 keep the stored TaxGroupID when the incoming value is invalid
					SET TaxGroupID = CASE WHEN @IsTaxGroupValid = 1 THEN @TaxGroupID ELSE TaxGroupID END,
					CostPrice = @tempCostPrice,
					PurchaseUnitID = @tempUnitID,
					IsDefaultSupplier=@IsDefaultSupplier,
					IsContractedSupplier= @IsContractedSupplier,
					Validfrom =	CASE WHEN @IsContractedSupplier =1 THEN @Validfrom ELSE NULL END,
					ValidTo =CASE WHEN @IsContractedSupplier =1 THEN @ValidTo ELSE NULL END
					WHERE StockItemID = @StockitemID AND LocationId = @LocationID AND CompanyId= @CompanyId AND SupplierID = @SupplierID AND Id = @Id

					EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @Id, 'INV', 'SWDU', 'U', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
				END
				ELSE
				BEGIN
					RAISERROR('Item not exists',16,1)
				END
			END
			ELSE IF(@isSupplierForAllLocation = 1 AND @IsAllLocation =1 AND EXISTS(SELECT 1 FROM @MultipleLocation  WHERE IsActive = 1 AND isSelected = 1)) -- When config multiple locaion and select all locaion check box and select multiple location
			BEGIN
				UPDATE SWD
				--added by Isuru 2026-10-07 same as above, for the multiple location update
				SET SWD.TaxGroupID = CASE WHEN @IsTaxGroupValid = 1 THEN @TaxGroupID ELSE SWD.TaxGroupID END,
					SWD.CostPrice = @tempCostPrice,
					SWD.PurchaseUnitID = @tempUnitID,
					SWD.IsDefaultSupplier=@IsDefaultSupplier,
					SWD.IsContractedSupplier= @IsContractedSupplier,
					SWD.Validfrom =	CASE WHEN @IsContractedSupplier =1 THEN @Validfrom ELSE NULL END,
					SWD.ValidTo =CASE WHEN @IsContractedSupplier =1 THEN @ValidTo ELSE NULL END
				FROM
				SupplierWiseItemDetails SWD
				INNER JOIN @MultipleLocation M ON M.id = SWD.LocationId
				WHERE M.IsActive = 1 AND M.isSelected = 1 AND SWD.StockItemID = @StockitemID AND SWD.CompanyId= @CompanyId AND SWD.SupplierID = @SupplierID --update existing items 

				IF EXISTS(
				SELECT 1 
				FROM @MultipleLocation M
				LEFT JOIN   SupplierWiseItemDetails SWD ON M.id = SWD.LocationId  and SWD.StockItemID = @StockitemID AND SWD.CompanyId= @CompanyId AND SWD.SupplierID = @SupplierID 
				WHERE M.IsActive = 1 AND M.isSelected = 1  AND SWD.id IS NULL) -- Insert not existing items
				BEGIN
					DECLARE @UpdateLocationID INT

					-- 1?? Declare cursor
					DECLARE updateMulLocationCursor CURSOR FAST_FORWARD
					FOR
					SELECT M.id 
					FROM @MultipleLocation M
					LEFT JOIN   SupplierWiseItemDetails SWD ON M.id = SWD.LocationId  and SWD.StockItemID = @StockitemID AND SWD.CompanyId= @CompanyId AND SWD.SupplierID = @SupplierID 
					WHERE M.IsActive = 1 AND M.isSelected = 1  AND SWD.id IS NULL;

					-- 2?? Open cursor
					OPEN updateMulLocationCursor;

					-- 3?? Fetch first row
					FETCH NEXT FROM updateMulLocationCursor INTO @UpdateLocationID

					-- 4?? Loop through rows
					WHILE @@FETCH_STATUS = 0
					BEGIN
						INSERT INTO SupplierWiseItemDetails
						(
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
							TaxGroupID,
							IsContractedSupplier
							,Validfrom
							,ValidTo
						)
						SELECT @CompanyId,
							   @UpdateLocationID,
							   @SupplierId,
							   @StockitemID,
							  case when @tempUnitID =0 then UnitId else @tempUnitID end ,
							   case when @tempCostPrice =0 then CostPrice else @tempCostPrice end,
							   IsDefaultSupplier,
							   UserID,
							   UserID,
							   GETDATE(),
							   GETDATE(),
							   '',
							  case when @tempTaxGroupID = 0
							    OR NOT EXISTS (SELECT 1 FROM TaxGroups TG WHERE TG.TaxGroupId = @tempTaxGroupID)
							   then TaxGroupId else @tempTaxGroupID end ,
							  @IsContractedSupplier,
							  CASE WHEN @IsContractedSupplier =1 THEN @Validfrom ELSE NULL END,
							  CASE WHEN @IsContractedSupplier =1 THEN @ValidTo ELSE NULL END
						FROM #ItemListTemp
						WHERE StockItemCode = @StockItemCode AND
						NOT EXISTS
						(
							SELECT 1
							FROM SupplierWiseItemDetails
							WHERE CompanyId = @CompanyId
								  AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @UpdateLocationID
						)
					--END
			
						SET @SUPWD_ID =  SCOPE_IDENTITY()

						-------------------------------------------Log SupplierWiseItemDetails Insert-2024-02-22-----------------
						IF EXISTS (SELECT 1 FROM #ItemListTemp where StockItemCode = @StockItemCode AND
							NOT EXISTS
							(
								SELECT 1
								FROM SupplierWiseItemDetails
								WHERE CompanyId = @CompanyId
										AND StockitemID = @StockitemID and SupplierID =@SupplierID AND LocationId = @UpdateLocationID
							))
						BEGIN
							EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @SUPWD_ID, 'INV', 'SWDI', 'I', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
						END
						---------------------------------------------------------------------------------------------------
						-- Fetch next row
						FETCH NEXT FROM updateMulLocationCursor INTO @UpdateLocationID
					END

					-- 5?? Close and deallocate
					CLOSE updateMulLocationCursor;
					DEALLOCATE updateMulLocationCursor;

				END
			END
			ELSE
			BEGIN
				RAISERROR('Item not exists',16,1)
			END
		END
		ELSE IF(@Action = 'D') -- Delete
		BEGIN
		IF EXISTS(SELECT 1 FROM SupplierWiseItemDetails WHERE StockItemID = @StockitemID AND LocationId = @LocationID AND CompanyId= @CompanyId AND SupplierID = @SupplierID AND Id = @Id)
			BEGIN
				DELETE FROM 
				SupplierWiseItemDetails
				WHERE StockItemID = @StockitemID AND LocationId = @LocationID AND CompanyId= @CompanyId AND SupplierID = @SupplierID AND Id = @Id

				EXEC Inventry_AuditTail_WriteToLog 'SupplierWiseItemDetails', @Id, 'INV', 'SWDD', 'D', @AuditTailUserID,@CompanyId, 'SP_InsertSupplierWiseItems', ''
			END
			ELSE
			BEGIN
				RAISERROR('Item not exists',16,1)
			END
		END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
        ROLLBACK TRANSACTION;
        
    END CATCH
END;

GO

