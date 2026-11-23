-- =============================================
-- Modified by:        Nivesh
-- Modified date:   2025-04-28
-- Description:   Insert stock item request
-- =============================================
--[dbo].[SP_InsertStockItemrequest ] '<StockItemRequestModel xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>1009</Id><PropertyId>3</PropertyId><ItemCode>www</ItemCode><ItemDescription>www</ItemDescription><ItemUnit>4</ItemUnit><CategoryId>6</CategoryId><SubCategoryId>1005</SubCategoryId><SubCategory2Id>2</SubCategory2Id><Remarks>wwww</Remarks><ItemWiseLocation><ItemWiseLocation><text>AWANI MAIN STORES</text><id>10</id></ItemWiseLocation><ItemWiseLocation><text>AWANI MAIN BAR</text><id>11</id></ItemWiseLocation></ItemWiseLocation></StockItemRequestModel>',0

--go
CREATE PROCEDURE [dbo].[SP_InsertStockItemrequest ] ( @XMLDetails XML, @Operation INT,@OutputInsertedID INT = 0 OUTPUT )

AS
DECLARE @iDocID INT, @TempStockItemReqId INT, @CatId INT, @SubCatId INT, @CatCode NVARCHAR(150), @SubCatCode NVARCHAR(150)
,@PropertyId INT,@ComCode NVARCHAR(150), @IsAutoStockItemCode BIT,@UserID INT;
BEGIN
	
	BEGIN TRY 
	BEGIN TRANSACTION
	  EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		
        SELECT * INTO #TempStockItemRequest
        FROM
        OPENXML(@iDocID, '/StockItemRequestModel', 2)
		WITH (Id INT ,PropertyId INT , ItemCode VARCHAR(150),ItemDescription VARCHAR(500),ItemUnit INT , CategoryId INT , SubCategoryId INT , SubCategory2Id INT ,
		Remarks VARCHAR( 500),UserID INT)

		------Added--------------
		select @CatId = CategoryId, @SubCatId = SubCategoryId, @PropertyId = PropertyId ,@UserID = UserID
		from #TempStockItemRequest

		SELECT @CatCode = code FROM Categories WHERE Id = @CatId
		SELECT @SubCatCode = code FROM SubCategories WHERE Id = @SubCatId
		SELECT @ComCode = Code,@IsAutoStockItemCode = ISNULL(AutoStockItemCode,0) FROM  Companies WHERE CompanyID = @PropertyId

		--select * from Categories where id = 6
		--select @CatId,@SubCatId
		--select @CatCode,@SubCatCode

		--update Categories set code = 40 where id = 6
		--update SubCategories set code = 11 where id = 1005

		--IF NOT EXISTS(SELECT * FROM [dbo].[Destinity_GLIntegrationAccountMapping] WHERE Level2 = @CatCode AND Level3 = @SubCatCode AND GLCompCode = @ComCode)
			--RAISERROR('Invalid Category Mapping',16,1)
		------Added--------------
		-------------------Added by Nivesh 2024-02-26----------------------
		DECLARE @InsertedIDs_TempStockItemRequest TABLE (ID INT);
		DECLARE @tempTeStItRe int = null 
		DECLARE @InsertedIDs_TempStockItemRequestWiseLocations TABLE (ID INT); 
		DECLARE @tempTeStItReWiLo int = null
		DECLARE @TempStItReWiLo_log int = null
		------------------------------------------
		SELECT * INTO #TempLocations
        FROM
        OPENXML(@iDocID, '/StockItemRequestModel/ItemWiseLocation/ItemWiseLocation', 2)
		WITH (text VARCHAR(200), id INT )

		--SELECT * FROM #TempStockItemRequest
		--SELECT * FROM #TempLocations

		DECLARE @ItemCode VARCHAR( 150) , @Id INT , @Name VARCHAR(MAX), @Temp_log_ID int

		SELECT @ItemCode = ItemCode, @Id = Id,@Name = ItemDescription FROM #TempStockItemRequest

		IF(@IsAutoStockItemCode =1)
		BEGIN
			Select @ItemCode= ItemTempNo +1 FROM commonSettings

			UPDATE commonSettings
			set ItemTempNo =ItemTempNo +1 

			-----------------------------------------Log commonSettings Update 2024-02-26------------------------------------------------
			select @Temp_log_ID = ID FROM commonSettings WHERE ItemTempNo =@ItemCode
			EXEC Inventry_AuditTail_WriteToLog 'commonSettings', @Temp_log_ID, 'INV', 'CSU', 'U', 0,@PropertyId, '', ''
			-----------------------------------------------------------------------------------------
		END


		IF EXISTS(SELECT 1 FROM TempStockItemRequest WHERE ItemCode = @ItemCode AND @Id <> Id) 
			BEGIN
				
				RAISERROR ('ItemCode already exists', 16, 1 );  
				ROLLBACK TRANSACTION
			END 
			IF EXISTS (SELECT  1 FROM dbo.StockItemHeaders WHERE StockItemCode = @ItemCode ) 
			BEGIN 
			select '@ItemCode',@ItemCode
				RAISERROR ('ItemCode already exists in stockmaster', 16, 1 );  
				ROLLBACK TRANSACTION
			END 

		IF(@Operation = 1)
		BEGIN 
			EXEC InsertMasterFileChangeLog 'Stock Item Request',1,'I',@Name

			INSERT INTO TempStockItemRequest(PropertyId,ItemCode,ItemDescription,CategoryId,SubCategoryId,SubCategory2Id
			,Remarks,ItemUnit,CreatedDate,CreatedUserID,LastModDate,LastModUserID)
			OUTPUT INSERTED.Id INTO @InsertedIDs_TempStockItemRequest --Added by Nivesh 2024-02-26
			SELECT PropertyId,UPPER(@ItemCode),UPPER(ItemDescription),CategoryId,SubCategoryId,SubCategory2Id,Remarks,ItemUnit,GETDATE(),@UserID,NULL,NULL
			FROM #TempStockItemRequest

			SET @TempStockItemReqId = SCOPE_IDENTITY()
			SET @OutputInsertedID =@TempStockItemReqId



			--------------------------------------Log TempStockItemRequest Insert 2024-02-26------------------------------------------
			WHILE EXISTS (SELECT 1 FROM @InsertedIDs_TempStockItemRequest)
			BEGIN
				SELECT TOP(1) @tempTeStItRe = Id FROM @InsertedIDs_TempStockItemRequest
				EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequest', @tempTeStItRe, 'INV', 'TSIRI', 'I', 0,@PropertyId, '', ''
				DELETE TOP(1) FROM @InsertedIDs_TempStockItemRequest
			END

			--added by Isuru 2025-07-03 
				DECLARE @IsItemCreationMail BIT
				SELECT @IsItemCreationMail= ISNULL(IsItemCreationMail,0)
				FROM COMPANIES
				WHERE COMPANYID=@PropertyID

				IF(@IsItemCreationMail =1)
				BEGIN
				 EXEC [dbo].[SendTransactionWiseEmailS] 'IC',@TempStockItemReqId,0,@PropertyID,'C'

				
				END
			--end
			--------------------------------------------------------------------------------
			INSERT INTO [dbo].[TempStockItemRequestWiseLocations] ([StockItemRequestId], [LocationId])
			OUTPUT INSERTED.Id INTO @InsertedIDs_TempStockItemRequestWiseLocations --Added by Nivesh 2024-02-26
			SELECT @TempStockItemReqId, id FROM #TempLocations

			--------------------------------------Log TempStockItemRequestWiseLocations Insert 2024-02-26------------------------------------------
			WHILE EXISTS (SELECT 1 FROM @InsertedIDs_TempStockItemRequestWiseLocations)
			BEGIN
				SELECT TOP(1) @tempTeStItReWiLo = Id FROM @InsertedIDs_TempStockItemRequestWiseLocations
				EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequestWiseLocations', @tempTeStItReWiLo, 'INV', 'TSIRWLI', 'I', 0,@PropertyId, '', ''
				DELETE TOP(1) FROM @InsertedIDs_TempStockItemRequestWiseLocations
			END
			--------------------------------------------------------------------------------
		END 
		ELSE
        BEGIN 
			EXEC InsertMasterFileChangeLog 'Stock Item Request',1,'U',@Name

			UPDATE TempStockItemRequest 
			SET PropertyId = ts.PropertyId, ItemCode = ts.ItemCode, ItemDescription = ts.ItemDescription,CategoryId = ts.CategoryId,
			SubCategoryId = ts.SubCategoryId,SubCategory2Id = ts.SubCategory2Id, Remarks = ts.Remarks, ItemUnit = ts.ItemUnit
			,LastModDate = GETDATE(),LastModUserID = @UserID
			FROM #TempStockItemRequest ts WHERE TempStockItemRequest.Id = @Id

			----------------------------------------------Log TempStockItemRequest Update 2024-02-27----------------------------------------------
			EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequest', @Id, 'INV', 'TSIRU', 'U', 0,@PropertyId, '', ''
			-------------------------------------------------------------------------------------------------------------------------------------

			------------------------------Log TempStockItemRequestWiseLocations Delete 2024-02-27-----------------------
			
			SELECT *
			INTO #TempResults
			FROM [TempStockItemRequestWiseLocations]
			WHERE [TempStockItemRequestWiseLocations].StockItemRequestId = @Id;


			select * from #TempResults
			while EXISTS (SELECT 1 FROM #TempResults WHERE  StockItemRequestId = @Id)
			BEGIN
			
			SELECT TOP (1) @TempStItReWiLo_log = ID FROM #TempResults WHERE  StockItemRequestId = @Id
				EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequestWiseLocations', @TempStItReWiLo_log, 'INV', 'TSIRWLD', 'D', 0,@PropertyId, '', ''
				DELETE TOP(1) FROM #TempResults WHERE  StockItemRequestId = @Id
				
			END
			
			------------------------------------------------------------------------------------------------------------
			DELETE FROM [TempStockItemRequestWiseLocations] WHERE  [TempStockItemRequestWiseLocations].StockItemRequestId = @Id

			INSERT INTO [dbo].[TempStockItemRequestWiseLocations] ([StockItemRequestId], [LocationId])
			OUTPUT INSERTED.Id INTO @InsertedIDs_TempStockItemRequestWiseLocations --Added by Nivesh 2024-02-27
			SELECT @Id, id FROM #TempLocations

			------------------------------Log TempStockItemRequestWiseLocations Insert 2024-02-27-----------------------
			WHILE EXISTS (SELECT 1 FROM @InsertedIDs_TempStockItemRequestWiseLocations)
			BEGIN
				SELECT TOP(1) @tempTeStItReWiLo = Id FROM @InsertedIDs_TempStockItemRequestWiseLocations
				EXEC Inventry_AuditTail_WriteToLog 'TempStockItemRequestWiseLocations', @tempTeStItReWiLo, 'INV', 'TSIRWLI', 'I', 0,@PropertyId, '', ''
				DELETE TOP(1) FROM @InsertedIDs_TempStockItemRequestWiseLocations
			END
			------------------------------------------------------------------------------------------------------------
		END 
		
		COMMIT TRANSACTION

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
	ROLLBACK TRANSACTION 
	END CATCH 


END

GO

