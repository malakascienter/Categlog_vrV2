
-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <17/10/2021>
-- Description:	<Save item wise recipes>
-- =============================================
 --[dbo].[SP_SaveRecipeMapping] '<MappingData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><LocationId>-999</LocationId><ItemId>2379</ItemId><RecipeList><RecipeListData><id>1</id><text>R001/Recipe1</text><isChecked>false</isChecked></RecipeListData><RecipeListData><id>2</id><text>R002/Recipe2</text><isChecked>true</isChecked></RecipeListData><RecipeListData><id>3</id><text>R003/Recipe3</text><isChecked>false</isChecked></RecipeListData></RecipeList></MappingData>'
 --go
CREATE PROCEDURE [dbo].[SP_SaveRecipeMapping](@XMLData XML)
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		DECLARE @iDocID INT, @LocationId INT, @ItemId INT,@CompanyID INT,@IsRecipeLocationMaintain BIT
		DECLARE @UserID INT   --added 2026-10-23 - user for the audit columns

		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;


		--SELECT @LocationId = LocationId, @ItemId = ItemId,@CompanyID=CompanyId
		--FROM
		--	OPENXML(@iDocID, '/MappingData', 2)
		--	WITH
		--	(
		--		LocationId INT,
		--		ItemId INT,
		--		CompanyId INT
		--	);
		--Changed 2026-10-23 - also read the user (missing or 0 -> NULL)
		SELECT @LocationId = LocationId, @ItemId = ItemId,@CompanyID=CompanyId, @UserID = NULLIF(UserID, 0)
		FROM
			OPENXML(@iDocID, '/MappingData', 2)
			WITH
			(
				LocationId INT,
				ItemId INT,
				CompanyId INT,
				UserID INT
			);



			SELECT @IsRecipeLocationMaintain = IsRecipeLocationMaintain
			FROM Companies
			WHERE CompanyID = @CompanyID

		SELECT * INTO #TempRecipeList
		FROM OPENXML(@iDocID, '/MappingData/RecipeList/RecipeListData', 2)
			WITH
			(
				id INT,
				isChecked BIT,
				Quantity MONEY,
				UnitId INT,
				ProductionUnitID INT
			);

		--Changed 2026-10-23 (audit log) - replaced by the row-by-row save below
		----added 2026-10-23 - keep each mapping's audit stamps across the delete
		--SELECT I.RecipeId, I.Quantity, I.UnitId, I.ProductionUnitID,
		--       I.CreatedUserID, I.CreatedDate, I.LastModUserID, I.LastModDate,
		--       ROW_NUMBER() OVER (PARTITION BY I.RecipeId ORDER BY I.Id) AS rn
		--INTO #OldMappings
		--FROM Inv_ItemWiseRecipes I
		--INNER JOIN #TempRecipeList T ON I.RecipeId = T.id
		--WHERE I.LocationId = @LocationId AND I.StockItemId = @ItemId AND I.CompanyId = @CompanyID


		--IF(@IsRecipeLocationMaintain =1)
		--BEGIN
		--DELETE FROM  I
		--FROM Inv_ItemWiseRecipes I
		--INNER JOIN #TempRecipeList T ON I.RecipeId =  T.id
		--WHERE I.LocationId = @LocationId AND I.StockItemId = @ItemId AND I.CompanyId = @CompanyID
		--END
		--ELSE
		--BEGIN
		--	DELETE FROM  I
		--	FROM Inv_ItemWiseRecipes I
		--	INNER JOIN #TempRecipeList T ON I.RecipeId =  T.id
		--	WHERE  I.StockItemId = @ItemId AND I.CompanyId = @CompanyID

		--END

		----INSERT INTO Inv_ItemWiseRecipes (LocationId,StockItemId,RecipeId,CompanyId,Quantity,UnitId,ProductionUnitID)
		----SELECT @LocationId,@ItemId,id,@CompanyID,Quantity,UnitId,ProductionUnitID FROM  #TempRecipeList
		----WHERE isChecked = 1
		----Changed 2026-10-23 - audit columns: kept for unchanged mappings, stamped for new/changed ones
		--INSERT INTO Inv_ItemWiseRecipes (LocationId,StockItemId,RecipeId,CompanyId,Quantity,UnitId,ProductionUnitID,
		--                                 CreatedUserID, CreatedDate, LastModUserID, LastModDate)
		--SELECT @LocationId,@ItemId,T.id,@CompanyID,T.Quantity,T.UnitId,T.ProductionUnitID,
		--       CASE WHEN O.RecipeId IS NULL THEN @UserID    ELSE O.CreatedUserID END,
		--       CASE WHEN O.RecipeId IS NULL THEN GETDATE()  ELSE O.CreatedDate   END,
		--       CASE WHEN O.RecipeId IS NULL OR C.IsChanged = 1 THEN @UserID   ELSE O.LastModUserID END,
		--       CASE WHEN O.RecipeId IS NULL OR C.IsChanged = 1 THEN GETDATE() ELSE O.LastModDate   END
		--FROM  #TempRecipeList T
		--LEFT JOIN #OldMappings O ON O.rn = 1 AND O.RecipeId = T.id
		--CROSS APPLY (SELECT CASE WHEN ISNULL(O.UnitId, -1) <> ISNULL(T.UnitId, -1)
		--                           OR ISNULL(O.ProductionUnitID, 0) <> ISNULL(T.ProductionUnitID, 0)
		--                           OR ABS(ISNULL(O.Quantity, -1) - ISNULL(T.Quantity, -1)) > 0.000005
		--                         THEN 1 ELSE 0 END AS IsChanged) C
		--WHERE T.isChecked = 1

		-------------------------------------------------------------------------------
		--added 2026-10-23 (audit log) - row-by-row save + audit log
		-------------------------------------------------------------------------------
		DECLARE @AuditLogUserID INT = ISNULL(@UserID, 0)   -- the audit log uses 0 for "not known"
		DECLARE @AuditRowID INT

		-- Saved mappings this save may touch: the same rows the old DELETEs removed
		-- (only @LocationId when IsRecipeLocationMaintain = 1, every location otherwise)
		SELECT I.Id, I.LocationId, I.RecipeId, I.Quantity, I.UnitId, I.ProductionUnitID,
		       ROW_NUMBER() OVER (PARTITION BY I.LocationId, I.RecipeId ORDER BY I.Id) AS rn
		INTO #SavedMappings
		FROM Inv_ItemWiseRecipes I
		WHERE I.StockItemId = @ItemId
		  AND I.CompanyId = @CompanyID
		  AND (CASE WHEN @IsRecipeLocationMaintain = 1 THEN 1 ELSE 0 END = 0 OR I.LocationId = @LocationId)
		  AND EXISTS (SELECT 1 FROM #TempRecipeList T WHERE T.id = I.RecipeId)

		-- Ticked recipes, numbered within recipe
		SELECT T.id AS RecipeId, T.Quantity, T.UnitId, T.ProductionUnitID,
		       ROW_NUMBER() OVER (PARTITION BY T.id ORDER BY (SELECT NULL)) AS rn
		INTO #ScreenMappings
		FROM #TempRecipeList T
		WHERE T.isChecked = 1

		-- What to do with each ticked recipe: I = insert, U = update, '-' = unchanged
		SELECT N.RecipeId, N.Quantity, N.UnitId, N.ProductionUnitID, S.Id AS SavedId,
		       CASE WHEN S.Id IS NULL THEN 'I'
		            WHEN ISNULL(S.UnitId, -1) <> ISNULL(N.UnitId, -1)
		              OR ISNULL(S.ProductionUnitID, 0) <> ISNULL(N.ProductionUnitID, 0)
		              OR ABS(ISNULL(S.Quantity, -1) - ISNULL(N.Quantity, -1)) > 0.000005 THEN 'U'
		            ELSE '-'
		       END AS MapAction
		INTO #MappingPlan
		FROM #ScreenMappings N
		LEFT JOIN #SavedMappings S ON S.LocationId = @LocationId AND S.RecipeId = N.RecipeId AND S.rn = N.rn

		-- 1. Mappings removed: log first (the row must still exist), then delete
		DECLARE @RemovedMappings TABLE (Id INT PRIMARY KEY)
		INSERT INTO @RemovedMappings (Id)
		SELECT S.Id FROM #SavedMappings S
		WHERE NOT EXISTS (SELECT 1 FROM #MappingPlan P WHERE P.SavedId = S.Id)

		WHILE EXISTS (SELECT 1 FROM @RemovedMappings)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @RemovedMappings ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_ItemWiseRecipes', @AuditRowID, 'INV', 'IWRD', 'D', @AuditLogUserID, @CompanyID, '', ''
			DELETE FROM Inv_ItemWiseRecipes WHERE Id = @AuditRowID
			DELETE FROM @RemovedMappings WHERE Id = @AuditRowID
		END

		-- 2. Changed mappings: update in place, then log (old -> new values)
		UPDATE I
		SET I.Quantity         = P.Quantity,
		    I.UnitId           = P.UnitId,
		    I.ProductionUnitID = P.ProductionUnitID,
		    I.LastModUserID    = @UserID,
		    I.LastModDate      = GETDATE()
		FROM Inv_ItemWiseRecipes I
		INNER JOIN #MappingPlan P ON P.SavedId = I.Id
		WHERE P.MapAction = 'U'

		DECLARE @ChangedMappings TABLE (Id INT PRIMARY KEY)
		INSERT INTO @ChangedMappings (Id) SELECT SavedId FROM #MappingPlan WHERE MapAction = 'U'

		WHILE EXISTS (SELECT 1 FROM @ChangedMappings)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @ChangedMappings ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_ItemWiseRecipes', @AuditRowID, 'INV', 'IWRU', 'U', @AuditLogUserID, @CompanyID, '', ''
			DELETE FROM @ChangedMappings WHERE Id = @AuditRowID
		END

		-- 3. New mappings: insert, then log
		DECLARE @NewMappings TABLE (Id INT PRIMARY KEY)
		INSERT INTO Inv_ItemWiseRecipes (LocationId, StockItemId, RecipeId, CompanyId, Quantity, UnitId, ProductionUnitID,
		                                 CreatedUserID, CreatedDate, LastModUserID, LastModDate)
		OUTPUT INSERTED.Id INTO @NewMappings (Id)
		SELECT @LocationId, @ItemId, RecipeId, @CompanyID, Quantity, UnitId, ProductionUnitID,
		       @UserID, GETDATE(), @UserID, GETDATE()
		FROM #MappingPlan
		WHERE MapAction = 'I'

		WHILE EXISTS (SELECT 1 FROM @NewMappings)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @NewMappings ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_ItemWiseRecipes', @AuditRowID, 'INV', 'IWRI', 'I', @AuditLogUserID, @CompanyID, '', ''
			DELETE FROM @NewMappings WHERE Id = @AuditRowID
		END
		--end 2026-10-23 (audit log)

        COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
END

GO

