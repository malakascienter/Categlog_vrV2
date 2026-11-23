/*

*/
-- SaveProductionRecipeDetails 14,776,1,66,1000,5815,'2024-10-29 00:00:00.000'



CREATE PROCEDURE [dbo].[SaveProductionRecipeDetailsProbPlan]
	@LocationID INT,
	@StockItemID INT,
	@PropertyID INT,
	@Unit INT,
	@Quantity DECIMAL(18,6),
	@UserProfileId INT,
	@RecipeTransactionDate DATETIME = NULL, -- Added by Isuru 2024-10-23
	@IsAutoProduction BIT = 0,
	@HeaderId BIGINT = 0 OUTPUT,
	@RawItemDeductQuantity DECIMAL(18,6) = 0,
	@IsRecipeChanged BIT = 0, --Added by Isuru 2026-01-12
	@RecipechangeReason NVARCHAR(MAX) = '', --Added by Isuru 2026-01-12
	@Recipejson NVARCHAR(MAX) = ''--Added by Isuru 2026-01-12
AS
BEGIN

	BEGIN TRY 

	BEGIN TRANSACTION;
			DECLARE @InvError VARCHAR(MAX)



	IF(@PropertyID =0 OR @PropertyID IS NULL)
	BEGIN
		RAISERROR ( 'Invalid Proprty ID Found', 16, 1 );  
		ROLLBACK TRANSACTION
	END

		--Added by Isuru 2024-10-23
		IF(@RecipeTransactionDate IS NULL)
		BEGIN

		SET @RecipeTransactionDate = ISNULL([dbo].[FN_GetCurrentDate](@PropertyID,@LocationID),GETDATE())

		END
		--End

		DECLARE @RecipeHeaderID INT,@CostPrice Money,@ProdLocation INT,@SubItemId INT,@QtyInHand MONEY,@RequedQty MONEY,
		@TxnUnit INT,@MasterUnit INT,@Qty MONEY,
		@XMLHeaderPI XML,@XMLDataPI XML;DECLARE @XMLDataPU XML, @XMLHeaderPU XML

		CREATE TABLE #DataDetails_Temp (
			StockItemID INT,
			Quantity DECIMAL(20,10),
			MasterUnitID INT,
			LocationID INT,
			CreatedUserID INT DEFAULT 0,
			LastModUserID INT DEFAULT 0,
			UserProfileId INT DEFAULT 0,
			TxnType NVARCHAR(50),
			UnitPrice DECIMAL(20,10) DEFAULT 0,
			TxnUnitID INT DEFAULT 0,
			DiscountValue DECIMAL DEFAULT 0,
			DiscountPercentage DECIMAL DEFAULT 0,
			BalanceQuantity DECIMAL DEFAULT 0,
			ReturnQuantity DECIMAL DEFAULT 0,
			QuantityInHand DECIMAL DEFAULT 0,
			isExpiryDateApplicable BIT DEFAULT 0,
			EXPDate DATETIME
		)

		CREATE TABLE #DataHeader_Temp (
			TransactionType NVARCHAR(5) NOT NULL DEFAULT '',
			PropertyID INT NOT NULL DEFAULT 0,
			LocationID INT NOT NULL DEFAULT 0,
			Remarks NVARCHAR(250) NOT NULL DEFAULT '',
			UserProfileID INT NOT NULL DEFAULT 0,
			CreatedUserID INT NOT NULL DEFAULT 0,
			LastModUserID INT NOT NULL DEFAULT 0,
			Mode CHAR(1) NOT NULL DEFAULT '',
			SupplierID INT NOT NULL DEFAULT 0,
			ReferenceID INT NOT NULL DEFAULT 0,
			DepartmentID INT NOT NULL DEFAULT 0,
			TransferLocationID INT NOT NULL DEFAULT 0,
			SuppCurrencyID INT NOT NULL DEFAULT 0,
			isExpiryDateApplicable BIT NOT NULL DEFAULT 0,
			EXPDate DATETIME NOT NULL DEFAULT '1900-01-01',
			TransactionDate DATETIME NOT NULL  DEFAULT GETDATE()
		);
 
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

		INSERT INTO #ProductionRawItems(ProdConsolidateHeaderID,RecipeItemID,ItemName,Qty,StockItemId,UnitId,ChangeRecipeQuanity,changeReason)
		SELECT  
		R.ProdConsolidateHeaderID,
		R.RecipeItemID,
		R.ItemName,
		R.Qty,
		R.StockItemId,
		R.UnitId,
		R.ChangeRecipeQuanity,
		R.changeReason
		FROM OPENJSON(@Recipejson) 
		WITH (
		ProdConsolidateHeaderID INT,
		RecipeItemID INT,
		ItemName NVARCHAR(200),
		Qty DECIMAL(18,4),
		StockItemId INT,
		UnitId INT,
		ChangeRecipeQuanity DECIMAL(18,4),
		changeReason NVARCHAR(MAX)
		) AS R;



		INSERT INTO #DataHeader_Temp (TransactionType, PropertyID, LocationID, CreatedUserID,TransactionDate,Remarks)
		VALUES ('PU', @PropertyID, @LocationID, @UserProfileId,@RecipeTransactionDate,CASE WHEN @IsAutoProduction=1 THEN 'AUTO PU' ELSE '' END ),
			('PI', @PropertyID, @LocationID, @UserProfileId,@RecipeTransactionDate,
			CASE WHEN @IsAutoProduction=1 THEN 'AUTO PI' 
			WHEN @IsRecipeChanged = 1 THEN ISNULL(@RecipechangeReason,'')
			ELSE '' END );



		--Finding Items without unit conversion 2024-10-30 
		SELECT rd.StockItemId,@Unit Unit,rh.UnitId RecipeHeaderUnitID,rh.RecipeName,[dbo].[FN_GetUnitConvertionRate](1,@Unit,rh.UnitId) AS ConvertionRate
		INTO #tempUnitCheck_Temp
		FROM Inv_RecipeDetails rd
		INNER JOIN Inv_RecipeHeader rh ON rd.RecipeHeaderId = rh.Id
		INNER JOIN Inv_ItemWiseRecipes ir ON ir.RecipeId = rh.Id
		INNER JOIN StockItemDetails id ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
		WHERE ir.StockItemId = @StockItemID --AND ir.LocationId = @LocationID	

		DECLARE @UnitConversionRate INT,@InvError2 VARCHAR(MAX),@UnitConversionItemName VARCHAR(200),@UnitConversionItemID INT,@RecipeName VARCHAR(MAX)

			WHILE (SELECT COUNT(*) FROM #tempUnitCheck_Temp) > 0
			BEGIN
			SELECT TOP(1) @UnitConversionItemID = StockItemId, @RecipeName =RecipeName, @UnitConversionRate = ConvertionRate  FROM #tempUnitCheck_Temp

			IF(@UnitConversionRate = -1)
			BEGIN
				SELECT @UnitConversionItemName= Name
				FROM StockItemHeaders
				WHERE ID = @StockItemID

				SET @InvError =  'Unit Conversion not Found for Item '+ ' '+@UnitConversionItemName +' And '+@RecipeName +' Recipe.'
				RAISERROR ( @InvError, 16, 1 );  
				ROLLBACK TRANSACTION

			END


			DELETE TOP (1) FROM #tempUnitCheck_Temp
			END
		--End

		SELECT @IsRecipeChanged IsRecipeChanged

		IF(@IsRecipeChanged = 1)
		BEGIN
			IF EXISTS(SELECT 1 FROM #ProductionRawItems)
			BEGIN
				INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
				SELECT rd.StockItemId,
				@RawItemDeductQuantity*rd.ChangeRecipeQuanity*ir.Quantity*[dbo].[FN_GetUnitConvertionRate](@PropertyID,@Unit,rh.UnitId) AS Qty,
				rd.UnitId,rd.UnitId,@LocationID LocationId,@UserProfileId,'M',id.QuantityInHand

				,[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId) * [dbo].[FN_GetUnitConvertionRate](@PropertyID,rd.UnitId,id.MasterUnitID) 
				FROM #ProductionRawItems rd
				INNER JOIN Inv_ItemWiseRecipes ir ON ir.StockItemId = rd.RecipeItemID
				INNER JOIN Inv_RecipeHeader rh ON ir.RecipeId = rh.Id
				INNER JOIN StockItemDetails id ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
				WHERE ir.StockItemId = @StockItemID --AND ir.LocationId = @LocationID			
			END
			ELSE
			BEGIN
				INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
				SELECT rd.StockItemId,
				@RawItemDeductQuantity*rd.Quantity*ir.Quantity*[dbo].[FN_GetUnitConvertionRate](1,@Unit,rh.UnitId) AS Qty,
				rd.UnitId,rd.UnitId,rd.LocationId,@UserProfileId,'M',id.QuantityInHand
				--[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId) --commented by isuru 2024-10-28 to fix invalid average price insertion in auto Pi
				--,[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId)* [dbo].[FN_GetUnitConvertionRate](@PropertyID,@Unit,rd.UnitId) 
				,[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId) * [dbo].[FN_GetUnitConvertionRate](@PropertyID,rd.UnitId,id.MasterUnitID) 
				FROM Inv_RecipeDetails rd
				INNER JOIN Inv_RecipeHeader rh ON rd.RecipeHeaderId = rh.Id
				INNER JOIN Inv_ItemWiseRecipes ir ON ir.RecipeId = rh.Id
				INNER JOIN StockItemDetails id ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
				WHERE ir.StockItemId = @StockItemID --AND ir

			END

		END
		ELSE
		BEGIN

			INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
			SELECT rd.StockItemId,
			@RawItemDeductQuantity*rd.Quantity*ir.Quantity*[dbo].[FN_GetUnitConvertionRate](1,@Unit,rh.UnitId) AS Qty,
			rd.UnitId,rd.UnitId,rd.LocationId,@UserProfileId,'M',id.QuantityInHand
			--[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId) --commented by isuru 2024-10-28 to fix invalid average price insertion in auto Pi
			--,[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId)* [dbo].[FN_GetUnitConvertionRate](@PropertyID,@Unit,rd.UnitId) 
			,[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId) * [dbo].[FN_GetUnitConvertionRate](@PropertyID,rd.UnitId,id.MasterUnitID) 
			FROM Inv_RecipeDetails rd
			INNER JOIN Inv_RecipeHeader rh ON rd.RecipeHeaderId = rh.Id
			INNER JOIN Inv_ItemWiseRecipes ir ON ir.RecipeId = rh.Id
			INNER JOIN StockItemDetails id ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
			WHERE ir.StockItemId = @StockItemID --AND ir.LocationId = @LocationID			

		END
		SET @CostPrice = (SELECT SUM(Quantity*UnitPrice) FROM #DataDetails_Temp)
		
		INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
		SELECT @StockItemID,@Quantity,@Unit,@Unit,@LocationID,@UserProfileId,'P',0,@CostPrice/@Quantity


		SELECT '##DataDetails_Temp' DataDetails_Temp,*
		FROM #DataDetails_Temp



		SET @XMLHeaderPU = ( SELECT * FROM #DataHeader_Temp WHERE Transactiontype = 'PU' for xml path('StockTransactionHeader'))
		SET @XMLDataPU = (SELECT * FROM #DataDetails_Temp WHERE TxnType = 'P'for xml path ('StockTransactionDetail'),root('StockDetailList'))

		SET @XMLHeaderPU.modify('insert sql:variable("@XMLDataPU") as first into (/StockTransactionHeader)[1]')
		
		SELECT @XMLHeaderPU XMLHeaderPu
	    EXEC SP_InsertStockTransactions @XMLHeaderPU,'',0,'',@HeaderId OUTPUT,0

		SET @XMLHeaderPI = ( SELECT * FROM #DataHeader_Temp WHERE Transactiontype = 'PI' for xml path('StockTransactionHeader'))
		SET @XMLDataPI = (SELECT * FROM #DataDetails_Temp WHERE TxnType = 'M'for xml path ('StockTransactionDetail'),root('StockDetailList'))

		SET @XMLHeaderPI.modify('insert sql:variable("@XMLDataPI") as first into (/StockTransactionHeader)[1]')

		SET @XMLHeaderPI.modify('replace value of (/StockTransactionHeader/ReferenceID/text())[1] with sql:variable("@HeaderId")')

		SELECT @XMLHeaderPI XMLHeaderPI

		EXEC SP_InsertStockTransactions @XMLHeaderPI,'',0,'',0,0

			COMMIT TRAN; -- Transaction Success!
		
		 
		--COMMIT TRAN; -- Transaction Success! Commented by isuru 2024-09-10 for preventing skip roll back transactions
		
    END TRY

    BEGIN CATCH

	
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	
    END CATCH;
	
END;

GO

