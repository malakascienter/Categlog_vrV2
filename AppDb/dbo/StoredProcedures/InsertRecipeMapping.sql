/* 
InsertRecipeMapping '{
  "LocationId": 15,
  "ItemId": 1019,
  "CompanyId": 1,
  "RecipeList": [
    {
      "id": 3,
      "text": "C002/C_WWW",
      "isMainStore": null,
      "unitId": 2,
      "isExpiryDateApplicable": null,
      "IsChecked": true,
      "quantity": 100,
      "unitName": "SHEETS"
    },
    {
      "id": 7,
      "text": "C001/C_ABC1",
      "isMainStore": null,
      "unitId": 10,
      "isExpiryDateApplicable": null,
      "IsChecked": true,
      "quantity": 201,
      "unitName": "BOX"
    }
  ]
}'
*/

CREATE PROCEDURE [dbo].[InsertRecipeMapping] 
	@data VARCHAR(MAX)
AS
BEGIN

BEGIN TRY 

BEGIN TRAN

	    DECLARE @LocationId INT,@ItemId INT,@CompanyID INT
		SELECT @LocationId= LocationId,@ItemId = ItemId,@CompanyID = CompanyId
		FROM OPENJSON(@data)
		WITH (
			LocationId INT,
			ItemId INT,
			CompanyId INT
		);

		SELECT id,text,unitId,quantity INTO #TempRecipeList
		FROM OPENJSON(@data, '$.RecipeList')
		WITH (
			id INT,
			text NVARCHAR(100),
			unitId INT,
			quantity MONEY
		)


		IF EXISTS( SELECT * FROM Inv_RecipeDetails O INNER JOIN #TempRecipeList T ON O.RecipeHeaderId = T.id WHERE O.StockItemId = @ItemId )
		BEGIN

			RAISERROR('same item used in production is used as its raw item.. ',16,1)
			ROLLBACK TRANSACTION

		END


		--DELETE FROM  I
		--FROM Inv_ItemWiseRecipes I
		--INNER JOIN #TempRecipeList T ON I.RecipeId =  T.id
		--WHERE I.LocationId = @LocationId AND I.StockItemId = @ItemId AND I.CompanyId = @CompanyID

		DELETE FROM  Inv_ItemWiseRecipes
		WHERE LocationId = @LocationId AND StockItemId = @ItemId AND CompanyId = @CompanyID

		INSERT INTO Inv_ItemWiseRecipes (LocationId,StockItemId,RecipeId,CompanyId,Quantity,UnitId)
		SELECT @LocationId,@ItemId,id,@CompanyID,quantity,unitId
		FROM #TempRecipeList

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

		INSERT INTO #DataDetails_Temp (StockItemID,Quantity,TxnUnitID,MasterUnitID,LocationID,UserProfileId,TxnType,QuantityInHand,UnitPrice)
		SELECT rd.StockItemId,
		1*rd.Quantity*ir.Quantity*[dbo].[FN_GetUnitConvertionRate](1,id.MasterUnitID,rh.UnitId) AS Qty,
		rd.UnitId,rd.UnitId,rd.LocationId,1,'M',id.QuantityInHand
		,[dbo].[FN_GetLastAveragePrice](@LocationID,rd.StockItemId) * [dbo].[FN_GetUnitConvertionRate](@CompanyID,rd.UnitId,id.MasterUnitID) 
		FROM Inv_RecipeDetails rd
		INNER JOIN Inv_RecipeHeader rh ON rd.RecipeHeaderId = rh.Id
		INNER JOIN Inv_ItemWiseRecipes ir ON ir.RecipeId = rh.Id
		INNER JOIN StockItemDetails id ON id.StockItemHeaderID = rd.StockItemId AND ir.LocationId = id.LocationID
		WHERE ir.StockItemId = @ItemId AND ir.LocationId = @LocationId			


		DECLARE @CostPrice MONEY
		SET @CostPrice = (SELECT SUM(Quantity*UnitPrice) FROM #DataDetails_Temp)


		DECLARE @CurrentCostPrice MONEY
		SELECT TOP(1)  @CurrentCostPrice = AveragePrice FROM StockItemDetails WHERE  StockItemHeaderID = @ItemId AND LocationID = @LocationId
		
		IF( ISNULL(@CurrentCostPrice,0) = 0 )
		BEGIN

			UPDATE StockItemDetails
			SET AveragePrice = isnull(@CostPrice,0)
			WHERE StockItemHeaderID = @ItemId AND LocationID = @LocationId 

		END


COMMIT TRAN

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION

END CATCH

END

GO

