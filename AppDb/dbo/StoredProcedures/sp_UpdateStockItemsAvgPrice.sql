--	EXEC [sp_UpdateStockItemsAvgPrice] 582,8,'2026-07-01'

CREATE PROCEDURE [dbo].[sp_UpdateStockItemsAvgPrice]
@StockItemId INT,
@LocationId INT,
@TrDate DATETIME
AS
SET NOCOUNT ON


SET DATEFORMAT DMY


SELECT D.TxnType,H.TransactionDate,D.CreatedDate ,H.Id AS HeaderId,D.Id AS DetailId ,D.Quantity,D.StockMasterQuantity,D.NewQuantity,IH.Id AS StockItemId,H.PropertyID,ID.MasterUnitID,H.TransactionType,D.TxnUnitID,D.StockMasterAveragePrice,D.UnitPrice,D.NewAveragePrice
INTO #Items
FROM dbo.StockTransactionDetails AS D
INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationId -- AND IH.LocationId = ID.LocationID
INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
WHERE IH.Id = @StockItemId AND H.LocationID = @LocationId AND H.TransactionDate >= @TrDate
ORDER BY H.TransactionDate ,D.CreatedDate,D.Id

--select * from #Items


DECLARE @TxnType VARCHAR(1), @TransactionDate DATETIME, @CreatedDate DATETIME, @StockItmId INT, 
@Quantity NUMERIC(18,4), @NewQty NUMERIC(18,4), @HeaderId INT,@DetailId INT,@PropertyID INT,@MasterUnitID INT,@TransactionType VARCHAR(5),@TxnUnitID INT

DECLARE @MasterQuantity NUMERIC(18,4), @TRQuantity NUMERIC(18,4), @NewQuantity NUMERIC(18,4) ,@StockMasterAveragePrice NUMERIC(18,4),@NewStockMasterAveragePrice NUMERIC(18,4),@UnitPrice NUMERIC(18,4),@GRNUnitPrice NUMERIC(18,4) = 0,
@GRNUnitId INT = 0,@StockMasterQuantity NUMERIC(18,4) ,@AveragePriceForLog NUMERIC(18,4)

SET @MasterQuantity = (SELECT TOP(1) StockMasterQuantity FROM #Items --WHERE TransactionType IN ('GR','AA') 
ORDER BY TransactionDate, CreatedDate,DetailId)
SET @StockMasterAveragePrice = (SELECT TOP(1) UnitPrice FROM #Items --WHERE TransactionType IN ('GR','AA') 
ORDER BY TransactionDate, CreatedDate,DetailId)


WHILE EXISTS (SELECT StockItemId FROM #Items)
BEGIN

PRINT 'AAAAAAAAAAAA'

		SELECT TOP(1) @TxnType = TxnType, @TransactionDate = TransactionDate, @CreatedDate = CreatedDate, @StockItmId = StockItemId, @Quantity = Quantity,
		@NewQty = NewQuantity,@HeaderId = HeaderId,@DetailId = DetailId,@PropertyID = PropertyID,@MasterUnitID = MasterUnitID,@TransactionType = TransactionType,@TxnUnitID = TxnUnitID,@UnitPrice = UnitPrice,@StockMasterQuantity = StockMasterQuantity,
		@AveragePriceForLog = NewAveragePrice
		FROM #Items 
		ORDER BY TransactionDate, CreatedDate,DetailId

		
	


				IF( @TransactionType = 'GR' OR (@TransactionType = 'AA' AND @StockMasterQuantity = 0 AND @UnitPrice >= 0) OR @TransactionType = 'SR'  )
				BEGIN

						 SET @GRNUnitPrice = @UnitPrice / [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TxnUnitID, @MasterUnitID)
						 SET @GRNUnitId = @TxnUnitID
						 SET @UnitPrice = @GRNUnitPrice

				END
				ELSE IF( @TransactionType = 'PU'  )
				BEGIN

						DECLARE @PUUnitPrice DECIMAL(18,8)

						--SELECT @PUUnitPrice = SUM(UnitPrice*Quantity* MasterUnitConversion)
						--FROM StockTransactionDetails 
						--WHERE StockTransactionHeaderID in (SELECT id FROM StockTransactionHeaders WHERE ReferenceID = @HeaderId AND  TransactionType = 'PI')

						--UPDATE StockTransactionDetails
						--SET UnitPrice =  ISNULL(@PUUnitPrice,0)/ Quantity,NewAveragePrice  =  ISNULL(@PUUnitPrice,0)/ Quantity
						--WHERE Id = @DetailId 

						-- select @GRNUnitPrice = UnitPrice from StockTransactionDetails WHERE Id = @DetailId 
						-- SET @UnitPrice = @GRNUnitPrice

						SELECT @PUUnitPrice = SUM(NewAveragePrice*Quantity* MasterUnitConversion)
						FROM StockTransactionDetails 
						WHERE StockTransactionHeaderID in (SELECT id FROM StockTransactionHeaders WHERE ReferenceID = @HeaderId AND  TransactionType = 'PI')

						UPDATE StockTransactionDetails
						SET UnitPrice =  ISNULL(@PUUnitPrice,0)/ Quantity,NewAveragePrice  =  ISNULL(@PUUnitPrice,0)/ Quantity
						WHERE Id = @DetailId 

						 select @GRNUnitPrice = UnitPrice from StockTransactionDetails WHERE Id = @DetailId 
						 SET @UnitPrice = @GRNUnitPrice


				END
				ELSE IF( @TransactionType = 'TI'  )
				BEGIN

						DECLARE @TIUnitPrice DECIMAL(18,8)
						DECLARE @TIRefNo VARCHAR(100)
						DECLARE @TOId BIGINT
						DECLARE @TOTxnUnitId BIGINT

						SELECT  @TIRefNo = ReferenceNo FROM StockTransactionHeaders WHERE ID = @HeaderId
						
						IF( ISNULL(@TIRefNo,'') = '' OR @TIRefNo = '-999' )
						BEGIN
								PRINT 'ABC'
								 UPDATE StockTransactionDetails 
								 --SET UnitPrice = CASE WHEN @GRNUnitPrice = 0 THEN 0 ELSE @GRNUnitPrice  END,NewAveragePrice = @GRNUnitPrice
								 SET UnitPrice = CASE WHEN ISNULL(@NewStockMasterAveragePrice,0) = 0 THEN 0 ELSE ISNULL(@NewStockMasterAveragePrice,0)   END,NewAveragePrice = ISNULL(@NewStockMasterAveragePrice,0) 
								 WHERE Id = @DetailId

								 --SET @UnitPrice = @GRNUnitPrice  --/ [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TxnUnitID, @MasterUnitID)	
								 SET @UnitPrice = ISNULL(@NewStockMasterAveragePrice,0) 
						END
						ELSE
						BEGIN 
						        PRINT 'DFG'
								PRINT @TIRefNo
							--	SELECT  @TOId = Id FROM StockTransactionHeaders WHERE ReferenceNo = @TIRefNo AND TransactionType = 'TO'

								SELECT @TOId = Id FROM StockTransactionHeaders WHERE DocumentNo  = @TIRefNo AND TransactionType = 'TO'

								SELECT @TIUnitPrice = UnitPrice,@TOTxnUnitId = TxnUnitID
								FROM StockTransactionDetails 
								WHERE StockTransactionHeaderID = @TOId AND StockItemID = @StockItemId

								
								IF( @TIUnitPrice is not null )
								BEGIN

									SET @GRNUnitPrice = @TIUnitPrice / [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TOTxnUnitId, @TxnUnitID)
									SET @UnitPrice = @GRNUnitPrice 

								END
								else
								begin
									SET @UnitPrice = ISNULL(@NewStockMasterAveragePrice,0) 
								end


								UPDATE StockTransactionDetails
								SET UnitPrice =  ISNULL(@UnitPrice,0)
								WHERE Id = @DetailId  
						END


				END
				ELSE
				BEGIN


						UPDATE StockTransactionDetails 
						--SET UnitPrice = CASE WHEN @GRNUnitPrice = 0 THEN 0 ELSE @GRNUnitPrice  END,NewAveragePrice = @GRNUnitPrice
						SET UnitPrice = (CASE WHEN ISNULL(@NewStockMasterAveragePrice,0)  = 0 THEN 0 ELSE ISNULL(@NewStockMasterAveragePrice,0)   END) * [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TxnUnitID, @MasterUnitID),
							NewAveragePrice = ISNULL(@NewStockMasterAveragePrice,0) 
						WHERE Id = @DetailId

						
						 SET @UnitPrice = ISNULL(@NewStockMasterAveragePrice,0)   --/ [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TxnUnitID, @MasterUnitID)
						

				END

			    SET @Quantity = @Quantity  * [dbo].[FN_GetUnitConvertionRate](@PropertyID,@TxnUnitID, @MasterUnitID)

			    
				IF( @TransactionType = 'GR' OR @TransactionType = 'SR' OR  (@TransactionType = 'AA' AND @StockMasterQuantity = 0) OR @TransactionType = 'TI' )
				BEGIN
				    -- GET LAST AVG PRICE WHEN STOCK MINUS COMMENT BECAUSE WHEN STOCK MINUS IT COSIDER AS STOCK IS ZERO
				    --IF(@MasterQuantity < 0)
					--BEGIN

					   --SET @NewStockMasterAveragePrice = @StockMasterAveragePrice

					--END
					--ELSE
					--BEGIN

					  SET @NewStockMasterAveragePrice = [dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
				 
					--END
					

				END
				ELSE IF( @TransactionType = 'PU'  )
				BEGIN

					SET @NewStockMasterAveragePrice = @GRNUnitPrice --@StockMasterAveragePrice --[dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
				 

				END
				ELSE
				BEGIN

					SET @NewStockMasterAveragePrice = @StockMasterAveragePrice --[dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
				 

				END

				IF( @TransactionType = 'AA' )
				BEGIN

						


						IF(@NewQty >= @MasterQuantity)
						BEGIN
							SET @Quantity = @Quantity
							SET @NewQuantity =@NewQty
							UPDATE StockTransactionDetails 
							SET NewAveragePrice = @NewStockMasterAveragePrice --[dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
							--,UnitPrice = @GRNUnitPrice
							WHERE Id = @DetailId

							
						END
						ELSE
						BEGIN
							SET @Quantity = @Quantity * -1
							SET @NewQuantity = @NewQty
							UPDATE StockTransactionDetails 
							SET NewAveragePrice = @NewStockMasterAveragePrice --[dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
							--,UnitPrice = @GRNUnitPrice
						    WHERE Id = @DetailId

						
						END


						


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
						
						
						--DECLARE @NewUnitPrice decimal(18,6)
						--IF( @TransactionType <> 'GR' AND @TransactionType <> 'AA' AND @TransactionType <> 'SR'  )
						--BEGIN
						
						--			SELECT @NewUnitPrice = (D.NewQuantity * D.NewAveragePrice) / D.NewQuantity
						--			FROM StockTransactionDetails D
						--			WHERE Id = @DetailId
						--END
						--ELSE
						--BEGIN
						--			SET @NewUnitPrice= @GRNUnitPrice
						--END
						
						UPDATE StockTransactionDetails 
						SET NewAveragePrice = @NewStockMasterAveragePrice --[dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
						--,UnitPrice = @NewUnitPrice --CASE WHEN @NewUnitPrice= NULL THEN @GRNUnitPrice ELSE @NewUnitPrice END
						WHERE Id = @DetailId
						
						
						

				END



				IF( (SELECT COUNT(*) FROM #Items) = 1 )
				BEGIN

						 UPDATE StockItemDetails 
						 SET AveragePrice = @NewStockMasterAveragePrice -- [dbo].[FN_CAL_AveragePrice](@PropertyID,@LocationId,@StockItemId,@TransactionType,@Quantity,@TxnUnitID,@UnitPrice,@StockMasterAveragePrice,@MasterQuantity,@MasterUnitID)
						 WHERE StockItemId = @StockItemId and LocationID = @LocationId

						
				
				END



        print @TransactionType
		print @NewStockMasterAveragePrice
		print @DetailId

		SET @MasterQuantity = @NewQuantity
		SET @StockMasterAveragePrice = @NewStockMasterAveragePrice
		
		DELETE FROM #Items WHERE DetailId = @DetailId
END

GO

