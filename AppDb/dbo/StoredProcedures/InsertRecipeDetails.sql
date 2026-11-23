/*
InsertRecipeDetails '{
  "RecipeId": 15,
  "ItemDetails": [
    {
      "ItemId": 150,
      "ItemName": "8''x3'' Lotus Tower Flag",
      "UnitId": 271,
      "UnitName": "No",
      "Qty": 34.0,
      "LocationId": 22,
      "Location": "KITCHEN",
      "CostPrice": 0.0
    }
  ]
}','I'
*/

CREATE PROCEDURE [dbo].[InsertRecipeDetails]
	@Data VARCHAR(MAX),
	@Operation CHAR(1)
AS
BEGIN
	BEGIN TRY
		BEGIN TRAN
			DECLARE @RecipeId INT,@Validation VARCHAR(100),@IsValidation INT,@ErrorMessage VARCHAR(500),@ItemId INT

			SELECT @RecipeId = RecipeId
			FROM OPENJSON(@Data,'$')
			WITH
			(
				RecipeId INT
			)

			SELECT ItemId,UnitId,Qty,LocationId,CostPrice INTO #TempItems
			FROM OPENJSON(@Data,'$.ItemDetails')
			WITH
			(
				ItemId INT,
				UnitId INT,
				Qty MONEY,
				LocationId INT,
				CostPrice MONEY
			)

			IF EXISTS( SELECT * FROM Inv_ItemWiseRecipes O  WHERE O.RecipeId = @RecipeId AND O.StockItemId IN (SELECT ItemId FROM #TempItems) )
			BEGIN

				RAISERROR('same item used in production is used as its raw item.. ',16,1)
				ROLLBACK TRANSACTION

			END
 

			IF(@Operation = 'I')
			BEGIN

					DELETE r
					FROM Inv_RecipeDetails r
					INNER JOIN #TempItems t ON t.ItemId = r.StockItemId
					WHERE r.RecipeHeaderId = @RecipeId;

					INSERT INTO Inv_RecipeDetails (RecipeHeaderId , StockItemId, Quantity, UnitId,LocationId) 
					SELECT @RecipeId, ItemId,Qty,UnitId,LocationId FROM #TempItems


			END
		COMMIT TRAN
	END TRY
	BEGIN CATCH

		SELECT @ErrorMessage=ERROR_MESSAGE()
		IF @@TRANCOUNT>0
			ROLLBACK TRANSACTION

		IF @IsValidation=1
		BEGIN
			EXEC sp_addmessage @MsgNum=50005,@Severity=1,@MsgText=@Validation,@Replace='replace';
			RAISERROR (50005,16,1)
		END
		ELSE
			RAISERROR (@ErrorMessage,16,1)
	
		EXEC sp_dropmessage 50005;	
		RETURN 0

	END CATCH
END

GO

