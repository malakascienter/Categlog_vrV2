
CREATE PROCEDURE [dbo].[UpdateExpDateFIFO](@PropertyID INT,@LocationID INT,  @StockItemID INT, @Quantity MONEY, @TxnID INT,@TransactionID INT )
AS
BEGIN
	--PRINT '[UpdateExpDateFIFO]'
	DECLARE @ProcessedQty MONEY= @Quantity, @ID INT , @BalanceQuantity MONEY , @EXPDate DATE, @TransactionType varchar(50), @ThisQty  MONEY 


	SELECT @TransactionType = TransactionTypes.Code 
	FROM TransactionTypes
	WHERE Id = @TransactionID

	SELECT ID, BalanceQuantity, EXPDate
	INTO #ExpDateStock
	FROM StockItemWiseEXPDateIns
	WHERE LocationID = @LocationID and StockItemID= @StockITemID and BalanceQuantity>0
	ORDER BY EXPDate

 
	WHILE @ProcessedQty >0 and (SELECT SUM(BalanceQuantity) FROM #ExpDateStock)>0
	BEGIN
		SET @ThisQty=0

		Select TOP 1 @ID=ID, @BalanceQuantity=BalanceQuantity, @EXPDate=EXPDate
		FROM #ExpDateStock
		WHERE BalanceQuantity>0
		ORDER BY EXPDate

 
		UPDATE #ExpDateStock
		SET BalanceQuantity= CASE WHEN @BalanceQuantity> @ProcessedQty THEN @BalanceQuantity - @ProcessedQty ELSE 0 END 
		WHERE ID = @ID


		UPDATE StockItemWiseEXPDateIns
		SET BalanceQuantity= CASE WHEN @BalanceQuantity> @ProcessedQty THEN @BalanceQuantity - @ProcessedQty ELSE 0 END 
		WHERE ID = @ID

		SET @ThisQty = CASE WHEN @BalanceQuantity > @ProcessedQty THEN @ProcessedQty ELSE @BalanceQuantity END


		SET @ProcessedQty = CASE WHEN @BalanceQuantity> @ProcessedQty THEN 0 ELSE  @ProcessedQty - @BalanceQuantity END

		 

		INSERT INTO StockItemWiseEXPDateIns( PropertyID, LocationID, TransactionID, TransactionType, StockItemID, Quantity, BalanceQuantity, EXPDate)
		VALUES (	@PropertyID, @LocationID, @TxnID, @TransactionType, @StockItemID, @ThisQty ,0, @EXPDate)

	END 


		--PRINT 'END [UpdateExpDateFIFO]'
END

GO

