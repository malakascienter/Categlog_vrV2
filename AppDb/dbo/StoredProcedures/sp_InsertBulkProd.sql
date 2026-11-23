CREATE PROCEDURE [dbo].[sp_InsertBulkProd]
    @json NVARCHAR(MAX),
	@StockTransactionHeaderIds VARCHAR(MAX) OUTPUT,
	@ProdConHeaderID BIGINT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;


		 -- Create temp table for output
        IF OBJECT_ID('tempdb..#ProdTranIds') IS NOT NULL DROP TABLE #ProdTranIds;
        CREATE TABLE #ProdTranIds (
            StockTransactionHeaderId BIGINT
        );

        -- Create temp table for header
        IF OBJECT_ID('tempdb..#ProdConsolidateHeader') IS NOT NULL DROP TABLE #ProdConsolidateHeader;
        CREATE TABLE #ProdConsolidateHeader (
            ProdConsolidateHeaderID BIGINT,
            userId INT,
            propertyID INT,
			LocationId INT
        );

        -- Create temp table for details
        IF OBJECT_ID('tempdb..#ProdPlanDetails') IS NOT NULL DROP TABLE #ProdPlanDetails;
        CREATE TABLE #ProdPlanDetails (
            ProdConsolidateHeaderID INT,
            ItemId INT,
            ItemCode NVARCHAR(50),
            ItemName NVARCHAR(100),
            UnitId INT,
            UnitName NVARCHAR(50),
            ConvertedQuanity DECIMAL(18, 4),
			ChangeQuanity DECIMAL(18, 4),
			Approve BIT,
            IsRecipeChanged BIT,
            changeReason NVARCHAR(MAX)
        );


		IF OBJECT_ID('tempdb..#ExecuteProdPlanDetails') IS NOT NULL DROP TABLE #ExecuteProdPlanDetails;
        CREATE TABLE #ExecuteProdPlanDetails (
            ProdConsolidateHeaderID INT,
            ItemId INT,
            ItemCode NVARCHAR(50),
            ItemName NVARCHAR(100),
            UnitId INT,
            UnitName NVARCHAR(50),
            ConvertedQuanity DECIMAL(18, 4),
			ChangeQuanity DECIMAL(18, 4),
			Approve BIT,
            IsRecipeChanged BIT,
            changeReason NVARCHAR(MAX)
        );

        IF OBJECT_ID('tempdb..#ProductionRawItems') IS NOT NULL DROP TABLE #ProductionRawItems;
        CREATE TABLE #ProductionRawItems (
            ProdConsolidateHeaderID INT,
            RecipeItemID INT,
            ItemName NVARCHAR(MAX),
            Qty DECIMAL(18, 4),
            StockItemId INT,
            UnitId INT,
            ChangeRecipeQuanity DECIMAL(18, 4),
			changeReason NVARCHAR(MAX)
        );

        -- Insert header
        INSERT INTO #ProdConsolidateHeader (ProdConsolidateHeaderID, userId, propertyID,LocationId)
        SELECT 
            JSON_VALUE(@json, '$.ProdConsolidateHeaderID'),
            JSON_VALUE(@json, '$.userId'),
            JSON_VALUE(@json, '$.propertyID'),
			JSON_VALUE(@json, '$.LocationId')
        -- Insert details

        INSERT INTO #ProdPlanDetails (
            ProdConsolidateHeaderID,
            ItemId,
            ItemCode,
            ItemName,
            UnitId,
            UnitName,
            ConvertedQuanity,
			ChangeQuanity,
			Approve,
            IsRecipeChanged,
            changeReason
        )
        SELECT
            JSON_VALUE(@json, '$.ProdConsolidateHeaderID'),
            ItemId,
            ItemCode,
            ItemName,
            UnitId,
            UnitName,
            ConvertedQuanity,
			ChangeQuanity,
			Approve,
            IsRecipeChanged,
            changeReason
        FROM OPENJSON(@json, '$.ProdPlanDetails') 
        WITH (
            ItemId INT,
            ItemCode NVARCHAR(50),
            ItemName NVARCHAR(100),
            UnitId INT,
            UnitName NVARCHAR(50),
            ConvertedQuanity DECIMAL(18,4),
			ChangeQuanity DECIMAL(18,4),
			Approve BIT,
            IsRecipeChanged BIT,
            changeReason NVARCHAR(MAX)
        );


        INSERT INTO #ProductionRawItems(ProdConsolidateHeaderID,RecipeItemID,ItemName,Qty,StockItemId,UnitId,ChangeRecipeQuanity,changeReason)
        SELECT  
        JSON_VALUE(@json, '$.ProdConsolidateHeaderID') ProdConsolidateHeaderID,
        R.RecipeItemID,
        R.ItemName,
        R.Qty,
        R.StockItemId,
        R.UnitId,
        R.ChangeRecipeQuanity,
        R.changeReason
        FROM OPENJSON(@json, '$.ProdPlanDetails') AS P
        CROSS APPLY OPENJSON(P.[value], '$.recipeItems')
        WITH (
        RecipeItemID INT '$.RecipeItemID',
        ItemName NVARCHAR(MAX) '$.ItemName',
        Qty DECIMAL(18,4) '$.Qty',
        StockItemId INT '$.StockItemId',
        UnitId INT '$.UnitId',
        ChangeRecipeQuanity DECIMAL(18,4) '$.ChangeRecipeQuanity',
        changeReason NVARCHAR(MAX) '$.changeReason'
        ) AS R
        WHERE JSON_QUERY(P.[value], '$.recipeItems') IS NOT NULL




		DECLARE @LocationID BIGINT,@PropertyID BIGINT,@UserId BIGINT,@RecipeTransactionDate DATE = GETDATE(),@ProdConsolidateHeaderID BIGINT

		SELECT @LocationID = LocationId,@PropertyID = propertyID,@UserId = userId ,@ProdConsolidateHeaderID = ProdConsolidateHeaderID FROM #ProdConsolidateHeader

		
		INSERT INTO #ExecuteProdPlanDetails(ProdConsolidateHeaderID,ItemId,ItemCode,ItemName,UnitId,UnitName,ConvertedQuanity,ChangeQuanity,Approve
        ,IsRecipeChanged,changeReason )
		SELECT ProdConsolidateHeaderID,ItemId,ItemCode,ItemName,UnitId,UnitName,ConvertedQuanity,ChangeQuanity,Approve ,ISNULL(IsRecipeChanged,0),changeReason
		FROM #ProdPlanDetails 
		WHERE Approve = 1


		--IF( (SELECT COUNT(*) FROM #ProdPlanDetails ) = (SELECT COUNT(*) FROM #ExecuteProdPlanDetails ) )
		--BEGIN

			

		--        UPDATE ProductionConsolidateHeader
		--		SET Status = 'C'
		--		WHERE ID = @ProdConsolidateHeaderID 

		--END
        
        
		WHILE EXISTS( SELECT * FROM #ExecuteProdPlanDetails )
		BEGIN

				DECLARE @RecipeItemID BIGINT,@RecipeUnitID BIGINT,@ProdQuantity DECIMAL(18,6)
                ,@RawItemDeductQuantity DECIMAL(18,6)
                ,@ProductionOutHeaderID BIGINT
                ,@IsRecipeChanged BIT,@changeReason VARCHAR(MAX),@Recipejson NVARCHAR(MAX)

				SELECT TOP(1) @RecipeItemID = ItemId,@RecipeUnitID = UnitId,@ProdQuantity = ChangeQuanity
                ,@RawItemDeductQuantity = ConvertedQuanity  ,@IsRecipeChanged = ISNULL(IsRecipeChanged,0)
                ,@changeReason = ISNULL(changeReason,'')
                FROM #ExecuteProdPlanDetails

                 SELECT @Recipejson = (
                    SELECT 
                        ProdConsolidateHeaderID,
                        RecipeItemID,
                        ItemName,
                        Qty,
                        StockItemId,
                        UnitId,
                        ChangeRecipeQuanity,
                        changeReason
                    FROM #ProductionRawItems
                    WHERE RecipeItemID = @RecipeItemID
                    FOR JSON PATH
                );

                select @Recipejson
               

				EXEC SaveProductionRecipeDetailsProbPlan  @LocationID,@RecipeItemID,@PropertyID ,@RecipeUnitID 
                , @ProdQuantity,@UserId,@RecipeTransactionDate,0,@ProductionOutHeaderID OUTPUT ,@RawItemDeductQuantity
                ,@IsRecipeChanged,@changeReason,@Recipejson

              

				UPDATE ProductionConsolidateDetails
				SET TransactionRefId = ISNULL(@ProductionOutHeaderID,0),ProceedQty = ProceedQty +@ProdQuantity
				WHERE HeaderID = @ProdConsolidateHeaderID AND StockItemID = @RecipeItemID


				UPDATE ProductionConsolidateDetails
				SET IsProductionProcess = 1
				WHERE HeaderID = @ProdConsolidateHeaderID AND StockItemID = @RecipeItemID
				AND ProceedQty >= ProductionQuantity

				INSERT INTO #ProdTranIds(StockTransactionHeaderId)
				VALUES(ISNULL(@ProductionOutHeaderID,0))

				PRINT 'AAAAAAAAAAAAAAAA'
				
				DELETE TOP(1) FROM #ExecuteProdPlanDetails

		END

       
		IF NOT EXISTS (SELECT 1 FROM ProductionConsolidateDetails
		WHERE HeaderID = @ProdConsolidateHeaderID AND ProductionQuantity > ProceedQty)
		BEGIN
		
			UPDATE ProductionConsolidateHeader
			SET Status = 'C'
			WHERE ID = @ProdConsolidateHeaderID
		END;	

		SELECT @StockTransactionHeaderIds = STRING_AGG(StockTransactionHeaderId, ',') FROM #ProdTranIds
		SET @ProdConHeaderID = @ProdConsolidateHeaderID

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- You can log errors here or return them to caller
        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(),
            @ErrSeverity = ERROR_SEVERITY();

        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;

GO

