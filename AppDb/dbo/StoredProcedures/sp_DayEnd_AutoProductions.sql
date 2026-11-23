-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-06
-- Description:	Auto Production insert for Production items

--  [dbo].[sp_DayEnd_AutoProductions] 1,'T03','2026-07-03'


-- =============================================
CREATE PROCEDURE [dbo].[sp_DayEnd_AutoProductions]
	@PropertyID INT,
	@OutletCode varchar(5),
	@TxnDate DATE
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		SET NOCOUNT ON;

		DECLARE @IsLocationWiseDayendEnable BIT,@DayEndValidationMode CHAR(4),@LocationID INT,@ValidationProcessCode CHAR(1),@IsReconMandatory BIT,@DayEndItemTempId INT
		,@IsProductionLocation BIT,@IsAutoProduction BIT

		CREATE TABLE #TempRecipeDetails_DayEndProduction (
		StockItemId INT,
		QuantityInHand	DECIMAL(20,10),
		TxnUnitID INT
		);

		DECLARE @ProductionOutHeaderTable_DayEndProduction TABLE (ID INt)
	
		DECLARE @IsValidProcess BIT = 0;

		SELECT @IsLocationWiseDayendEnable =IsLocationWiseDayendEnable,@IsAutoProduction = ISNULL(IsAutoProduction,0)
		
		FROM COMPANIES
		WHERE CompanyID =@PropertyID


		SELECT @LocationID = StockLocationID
		FROM Location_Ref
		WHERE CODE = @OutletCode

		SELECT @DayEndValidationMode = DayEndValidationMode, @IsProductionLocation = ISNULL(IsProductionLocation,0)
		FROM Locations
		WHERE ID = @LocationID

		IF(@IsLocationWiseDayendEnable = 1 AND @IsAutoProduction = 1)
		BEGIN
			DECLARE @RecipeItemID INT,@RecipeQuantity DECIMAL(18,6),@RecipeUnitID INT,@RecipeQuantityVariance DECIMAL(18,6)
			DECLARE @ProductionOutHeaderID INT
			

			INSERT INTO #TempRecipeDetails_DayEndProduction(StockItemID,QuantityInHand,TxnUnitID)
			SELECT top 2 SD.StockItemHeaderID StockItemID,SD.QuantityInHand,MasterUnitID TxnUnitID
			FROM StockItemHeaders SH WITH (NOLOCK)
			INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.ID = SD.StockItemHeaderID
			WHERE SD.LocationID = @LocationID 
			AND SH.CompanyId = @PropertyID
			AND SH.IsProductionItem = 1
			AND SD.QuantityInHand < 0

			select '##TempRecipeDetails_DayEndProduction',*
			from #TempRecipeDetails_DayEndProduction


			WHILE EXISTS(SELECT 1 FROM #TempRecipeDetails_DayEndProduction)
				BEGIN
					SELECT TOP (1) @RecipeItemID= StockItemID, @RecipeQuantity = QuantityInHand,@RecipeUnitID =  TxnUnitID 
					FROM #TempRecipeDetails_DayEndProduction

					IF EXISTS(SELECT 1
						FROM StockItemHeaders SH WITH (NOLOCK)
						INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.Id = SD.StockItemHeaderID
						WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID AND SH.CompanyId = @PropertyID
						AND SH.IsProductionItem =1  
						AND SD.QuantityInHand < 0)
					BEGIN
							select 123
						SELECT @RecipeQuantityVariance = ABS(SD.QuantityInHand)
						FROM StockItemHeaders SH WITH (NOLOCK)
						INNER JOIN StockItemDetails SD WITH (NOLOCK) ON SH.Id = SD.StockItemHeaderID
						WHERE SH.Id = @RecipeItemID AND SD.LocationID = @LocationID 
						AND SH.CompanyId = @PropertyID
						AND SH.IsProductionItem =1  
						AND SD.QuantityInHand < 0;

						IF EXISTS(SELECT 1 FROM Inv_RecipeDetails rd WITH (NOLOCK)
						INNER JOIN Inv_RecipeHeader rh WITH (NOLOCK) ON rd.RecipeHeaderId = rh.Id
						INNER JOIN Inv_ItemWiseRecipes ir WITH (NOLOCK) ON ir.RecipeId = rh.Id
						INNER JOIN StockItemDetails id WITH (NOLOCK) ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
						WHERE ir.StockItemId = @RecipeItemID )
						BEGIN
							select @LocationID LocationID,@RecipeItemID RecipeItemID,@PropertyID PropertyID,@RecipeUnitID  RecipeUnitID, @RecipeQuantityVariance RecipeQuantityVariance
							,@TxnDate TxnDate

							EXEC SaveProductionRecipeDetails  @LocationID,@RecipeItemID,@PropertyID ,@RecipeUnitID , @RecipeQuantityVariance,0,@TxnDate,1,@ProductionOutHeaderID OUTPUT 

							IF(@ProductionOutHeaderID IS NOT NULL)
							BEGIN
								INSERT INTO @ProductionOutHeaderTable_DayEndProduction (Id)
								values(@ProductionOutHeaderID)
							END
								
						END
					END
					DELETE TOP (1) FROM #TempRecipeDetails_DayEndProduction
				END

				INSERT INTO DayEndAutoProduction_Log(ProductionOutHeaderID, OutletCode, Txndate, LocationID)
				SELECT Id,@OutletCode,@TxnDate,@LocationID
				FROM @ProductionOutHeaderTable_DayEndProduction
				
		END

	

COMMIT TRANSACTION 
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	
	DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage,SysDate)
	VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE(),GETDATE())

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH

END

GO

