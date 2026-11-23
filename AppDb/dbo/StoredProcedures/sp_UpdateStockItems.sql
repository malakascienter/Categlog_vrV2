--  EXEC [sp_UpdateStockItems] 728,3,'2024-10-10'

CREATE PROCEDURE [dbo].[sp_UpdateStockItems]
@StockItemId INT,
@LocationId INT,
@TrDate DATETIME
AS
SET NOCOUNT ON


SET DATEFORMAT DMY

SELECT D.TxnType,H.TransactionDate,D.CreatedDate ,H.Id AS HeaderId,D.Id AS DetailId ,D.Quantity,D.StockMasterQuantity,D.NewQuantity,IH.Id AS StockItemId,H.PropertyID,ID.MasterUnitID,H.TransactionType,D.TxnUnitID,D.StockMasterAveragePrice
INTO #Items
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationId -- AND IH.LocationId = ID.LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = @StockItemId AND H.LocationID = @LocationId AND H.TransactionDate >= @TrDate
ORDER BY H.TransactionDate ,D.CreatedDate,D.Id


DECLARE @TxnType VARCHAR(1), @TransactionDate DATETIME, @CreatedDate DATETIME, @StockItmId INT, 
		@Quantity NUMERIC(18,4), @NewQty NUMERIC(18,4), @HeaderId INT,@DetailId INT,@PropertyID INT,@MasterUnitID INT,@TransactionType VARCHAR(5),@TxnUnitID INT

DECLARE @MasterQuantity NUMERIC(18,4), @TRQuantity NUMERIC(18,4), @NewQuantity NUMERIC(18,4) ,@StockMasterAveragePrice NUMERIC(18,4),@NewStockMasterAveragePrice NUMERIC(18,4)

SET @MasterQuantity = [dbo].[GetBalance_Cal](@TrDate ,@StockItemId, @LocationId,0, 0) --(SELECT TOP(1) StockMasterQuantity FROM #Items ORDER BY TransactionDate, CreatedDate,DetailId)
SET @StockMasterAveragePrice = (SELECT TOP(1) StockMasterAveragePrice FROM #Items ORDER BY TransactionDate, CreatedDate,DetailId)


WHILE EXISTS (SELECT StockItemId FROM #Items)
	BEGIN

		SELECT TOP(1) @TxnType = TxnType, @TransactionDate = TransactionDate, @CreatedDate = CreatedDate, @StockItmId = StockItemId, @Quantity = Quantity,
		@NewQty = NewQuantity,@HeaderId = HeaderId,@DetailId = DetailId,@PropertyID = PropertyID,@MasterUnitID = MasterUnitID,@TransactionType = TransactionType,@TxnUnitID = TxnUnitID
		FROM #Items 
		ORDER BY TransactionDate, CreatedDate,DetailId



			BEGIN
--select @MasterQuantity,@TransactionType TransactionType

			SET @Quantity = @Quantity * [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TxnUnitID, @MasterUnitID)

				IF( @TransactionType = 'AA' )
				BEGIN

						

						

						IF(@NewQty >= @MasterQuantity)
						BEGIN
							SET @Quantity = @Quantity
							SET @NewQuantity =@NewQty
							UPDATE StockTransactionDetails SET StockMasterQuantity = @MasterQuantity, NewQuantity = @NewQty,Quantity = @NewQty-@MasterQuantity,TxnType = 'P'
							WHERE Id = @DetailId

						END
						ELSE
						BEGIN
							SET @Quantity = @Quantity * -1
							SET @NewQuantity = @NewQty
							UPDATE StockTransactionDetails SET StockMasterQuantity = @MasterQuantity, NewQuantity = @NewQty,Quantity = @MasterQuantity-@NewQty,TxnType = 'M'
						    WHERE Id = @DetailId

						END



						--IF( @NewQty < 0 )
						--BEGIN

						-- insert into TempWrongRecItem (ItemId) values (@StockItemId)

						--END

						


				END
				ELSE
				BEGIN

 
						IF @TxnType = 'P'
						BEGIN
							SET @Quantity = @Quantity
						END

						IF @TxnType = 'M'
							BEGIN
								SET @Quantity = @Quantity * -1
							END

						SET @NewQuantity = @MasterQuantity + @Quantity

						--select @Quantity Quantity,@MasterQuantity MasterQuantity,@NewQuantity NewQuantity,@DetailId DetailId

						
						PRINT CONCAT(@Quantity,'-',@MasterQuantity,'-',@NewQuantity,'-',@DetailId)


						UPDATE StockTransactionDetails SET StockMasterQuantity = @MasterQuantity, NewQuantity = @NewQuantity
						WHERE Id = @DetailId


						

				END

				IF( (SELECT COUNT(*) FROM #Items) = 1 )
				BEGIN
				
				 PRINT @NewQuantity
				 UPDATE StockItemDetails set QuantityInHand = @NewQuantity WHERE StockItemId = @StockItemId and LocationID = @LocationId
				
				END


				
			END

		SET @MasterQuantity = @NewQuantity
		SET @StockMasterAveragePrice = @NewStockMasterAveragePrice
		
		DELETE FROM #Items WHERE DetailId = @DetailId
	END

	--SELECT @NewStockMasterAveragePrice =  [dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,0,@TxnUnitID,0,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)

GO

