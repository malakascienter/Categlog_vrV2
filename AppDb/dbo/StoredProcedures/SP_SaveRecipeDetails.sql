
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
 --=============================================
--[dbo].[SP_SaveRecipeDetails] '<dataRecipeDetails xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><RecipeId>1</RecipeId><ItemDetails><RecipeWiseItems><ItemId>1118</ItemId><ItemName>code111</ItemName><UnitId>2</UnitId><UnitName>KILOGRAM</UnitName><Qty>1</Qty></RecipeWiseItems><RecipeWiseItems><ItemId>1122</ItemId><ItemName>TEST 3</ItemName><UnitId>7</UnitId><UnitName>dfdfd</UnitName><Qty>2</Qty></RecipeWiseItems></ItemDetails></dataRecipeDetails>'
--go
CREATE PROCEDURE [dbo].[SP_SaveRecipeDetails](@XMLDetails XMl, @Value CHAR(1))
AS
BEGIN

	BEGIN TRY
	--------------Insert XML to temp table-------------------
		INSERT INTO [dbo].[tempRecipeDetail_XML] (XmlDATA)
		SELECT CONVERT(VARCHAR(MAX),  @XMLDetails)
	---------------------------------
	BEGIN TRANSACTION

		CREATE TABLE #TempItems (
			ItemId INT,
			UnitId INT,
			ItemName NVARCHAR(250),
			UnitName NVARCHAR(250),
			Qty DECIMAL(18,6),
			LocationId INT NULL
		)
		DECLARE @iDocID INT;
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		DECLARE @RecipeId INT
		DECLARE @UserID INT   --added 2026-10-23 - user for the audit columns

		--SELECT @RecipeId = RecipeId FROM
		--OPENXML(@iDocID, 'dataRecipeDetails ', 2) WITH(RecipeId INT)
		--Changed 2026-10-23 - also read the user (missing or 0 -> NULL)
		SELECT @RecipeId = RecipeId, @UserID = NULLIF(UserID, 0) FROM
		OPENXML(@iDocID, 'dataRecipeDetails ', 2) WITH(RecipeId INT, UserID INT)


		INSERT INTO #TempItems
		SELECT *  FROM
		OPENXML(@iDocID, 'dataRecipeDetails/ItemDetails/RecipeWiseItems ', 2)
		WITH(
			ItemId INT,
			UnitId INT,
			ItemName NVARCHAR(250),
			UnitName NVARCHAR(250),
			Qty DECIMAL(18,6),
			LocationId INT
		);

		--Changed 2026-10-23 (audit log) - replaced by the row-by-row save below
		----added 2026-10-23 - keep each line's audit stamps across the delete
		--SELECT StockItemId, LocationId, Quantity, UnitId,
		--       CreatedUserID, CreatedDate, LastModUserID, LastModDate,
		--       ROW_NUMBER() OVER (PARTITION BY StockItemId, ISNULL(LocationId, 0) ORDER BY Id) AS rn
		--INTO #OldRecipeDetails
		--FROM dbo.Inv_RecipeDetails
		--WHERE RecipeHeaderId = @RecipeId


		----------------------Log POS_ItemBarcode Delete 2024-02-22-----------------------
		--DECLARE @TempRecipeDetailID INT;
		--WHILE EXISTS (SELECT 1 FROM dbo.Inv_RecipeDetails WHERE RecipeHeaderId = @RecipeId)
		--BEGIN

		--	SELECT TOP 1 @TempRecipeDetailID = id FROM dbo.Inv_RecipeDetails WHERE RecipeHeaderId = @RecipeId
		--	IF(@TempRecipeDetailID IS NOT NULL)
		--	BEGIN

		--		EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeDetails', @TempRecipeDetailID, 'INV', 'RDD', 'D', 0,0, '', ''

		--		DELETE FROM dbo.Inv_RecipeDetails WHERE Id = @TempRecipeDetailID

		--	END
		--	SET @TempRecipeDetailID = NULL
		--END
		------------------------------------------------------------------------------------------
		--SET @Value = 'I'
		--IF(@Value = 'I')
		--BEGIN
		--	IF( SELECT COUNT(*) FROM Inv_RecipeDetails D
		--	INNER JOIN #TempItems T ON D.StockItemId = T.ItemId
		--	WHERE D.RecipeHeaderId = @RecipeId) > 0
		--	RAISERROR('Some items already assigned to this recipe',16,1)
		--ELSE
		--BEGIN
		--	--INSERT INTO Inv_RecipeDetails (RecipeHeaderId , StockItemId, Quantity, UnitId,LocationId)
		--	--SELECT @RecipeId, ItemId,Qty,UnitId,LocationId FROM #TempItems
		--	--Changed 2026-10-23 - audit columns: kept for unchanged lines, stamped for new/changed lines
		--	INSERT INTO Inv_RecipeDetails (RecipeHeaderId , StockItemId, Quantity, UnitId,LocationId,
		--	                               CreatedUserID, CreatedDate, LastModUserID, LastModDate)
		--	SELECT @RecipeId, T.ItemId, T.Qty, T.UnitId, T.LocationId,
		--	       CASE WHEN O.StockItemId IS NULL THEN @UserID    ELSE O.CreatedUserID END,
		--	       CASE WHEN O.StockItemId IS NULL THEN GETDATE()  ELSE O.CreatedDate   END,
		--	       CASE WHEN O.StockItemId IS NULL OR C.IsChanged = 1 THEN @UserID   ELSE O.LastModUserID END,
		--	       CASE WHEN O.StockItemId IS NULL OR C.IsChanged = 1 THEN GETDATE() ELSE O.LastModDate   END
		--	FROM #TempItems T
		--	LEFT JOIN #OldRecipeDetails O ON O.rn = 1
		--	                             AND O.StockItemId = T.ItemId
		--	                             AND ISNULL(O.LocationId, 0) = ISNULL(T.LocationId, 0)
		--	CROSS APPLY (SELECT CASE WHEN ISNULL(O.UnitId, -1) <> ISNULL(T.UnitId, -1)
		--	                           OR ABS(ISNULL(O.Quantity, -1) - ISNULL(T.Qty, -1)) > 0.000005
		--	                         THEN 1 ELSE 0 END AS IsChanged) C
		--
		--END
		--END

		-------------------------------------------------------------------------------
		--added 2026-10-23 (audit log) - row-by-row save + audit log
		-------------------------------------------------------------------------------
		DECLARE @AuditLogUserID INT = ISNULL(@UserID, 0)   -- the audit log uses 0 for "not known"
		DECLARE @AuditCompanyID INT = ISNULL((SELECT TOP 1 CompanyId FROM dbo.Inv_RecipeHeader WHERE Id = @RecipeId), 0)
		DECLARE @AuditRowID INT

		-- Saved lines, numbered within item + location
		SELECT Id, StockItemId, ISNULL(LocationId, 0) AS LocKey, Quantity, UnitId,
		       ROW_NUMBER() OVER (PARTITION BY StockItemId, ISNULL(LocationId, 0) ORDER BY Id) AS rn
		INTO #SavedLines
		FROM dbo.Inv_RecipeDetails
		WHERE RecipeHeaderId = @RecipeId

		-- Screen lines, numbered the same way
		SELECT ItemId, UnitId, Qty, LocationId, ISNULL(LocationId, 0) AS LocKey,
		       ROW_NUMBER() OVER (PARTITION BY ItemId, ISNULL(LocationId, 0) ORDER BY (SELECT NULL)) AS rn
		INTO #ScreenLines
		FROM #TempItems

		-- What to do with each screen line: I = insert, U = update, '-' = unchanged
		SELECT N.ItemId, N.UnitId, N.Qty, N.LocationId, S.Id AS SavedId,
		       CASE WHEN S.Id IS NULL THEN 'I'
		            WHEN ISNULL(S.UnitId, -1) <> ISNULL(N.UnitId, -1)
		              OR ABS(ISNULL(S.Quantity, -1) - ISNULL(N.Qty, -1)) > 0.000005 THEN 'U'
		            ELSE '-'
		       END AS LineAction
		INTO #LinePlan
		FROM #ScreenLines N
		LEFT JOIN #SavedLines S ON S.StockItemId = N.ItemId AND S.LocKey = N.LocKey AND S.rn = N.rn

		-- 1. Lines removed on the screen: log first (the row must still exist), then delete
		DECLARE @RemovedLines TABLE (Id INT PRIMARY KEY)
		INSERT INTO @RemovedLines (Id)
		SELECT S.Id FROM #SavedLines S
		WHERE NOT EXISTS (SELECT 1 FROM #LinePlan P WHERE P.SavedId = S.Id)

		WHILE EXISTS (SELECT 1 FROM @RemovedLines)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @RemovedLines ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeDetails', @AuditRowID, 'INV', 'RDD', 'D', @AuditLogUserID, @AuditCompanyID, '', ''
			DELETE FROM dbo.Inv_RecipeDetails WHERE Id = @AuditRowID
			DELETE FROM @RemovedLines WHERE Id = @AuditRowID
		END

		-- 2. Changed lines: update in place, then log (old -> new values)
		UPDATE D
		SET D.Quantity      = P.Qty,
		    D.UnitId        = P.UnitId,
		    D.LastModUserID = @UserID,
		    D.LastModDate   = GETDATE()
		FROM dbo.Inv_RecipeDetails D
		INNER JOIN #LinePlan P ON P.SavedId = D.Id
		WHERE P.LineAction = 'U'

		DECLARE @ChangedLines TABLE (Id INT PRIMARY KEY)
		INSERT INTO @ChangedLines (Id) SELECT SavedId FROM #LinePlan WHERE LineAction = 'U'

		WHILE EXISTS (SELECT 1 FROM @ChangedLines)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @ChangedLines ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeDetails', @AuditRowID, 'INV', 'RDU', 'U', @AuditLogUserID, @AuditCompanyID, '', ''
			DELETE FROM @ChangedLines WHERE Id = @AuditRowID
		END

		-- 3. New lines: insert, then log
		DECLARE @NewLines TABLE (Id INT PRIMARY KEY)
		INSERT INTO Inv_RecipeDetails (RecipeHeaderId, StockItemId, Quantity, UnitId, LocationId,
		                               CreatedUserID, CreatedDate, LastModUserID, LastModDate)
		OUTPUT INSERTED.Id INTO @NewLines (Id)
		SELECT @RecipeId, ItemId, Qty, UnitId, LocationId,
		       @UserID, GETDATE(), @UserID, GETDATE()
		FROM #LinePlan
		WHERE LineAction = 'I'

		WHILE EXISTS (SELECT 1 FROM @NewLines)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @NewLines ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeDetails', @AuditRowID, 'INV', 'RDI', 'I', @AuditLogUserID, @AuditCompanyID, '', ''
			DELETE FROM @NewLines WHERE Id = @AuditRowID
		END
		--end 2026-10-23 (audit log)

		--IF(@Value = 'U')
		--BEGIN
		--	UPDATE D SET StockItemId =  ItemId, UnitId = UnitId, Quantity = Qty
		--	FROM Inv_RecipeDetails D
		--	INNER JOIN #TempItems T ON T.ItemId=  D.StockItemId
		--	WHERE D.RecipeHeaderId = @RecipeId

		--END

	COMMIT TRAN
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

