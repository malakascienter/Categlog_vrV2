
-- [dbo].[sp_GetStockItemBalance] 44321,78,'2024-12-20'

create PROCEDURE [dbo].[sp_GetStockItemBalance]
	@StockItemId BIGINT,
	@LocationId INT,
	@TrDate DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @InvBalance DECIMAL(18,4) = 0 ,@GLBalance DECIMAL(18,4) = 0 ,@GLBalance_P DECIMAL(18,4) = 0 ,@GLBalance_M DECIMAL(18,4) = 0 


	SELECT @InvBalance = ISNULL(SUM( [dbo].[GetBalance](@TrDate,@StockItemId,L.Id,0,1) ),0) 
	FROM Locations L

	SELECT D.TxnType,H.TransactionDate,D.CreatedDate ,H.Id AS HeaderId,D.Id AS DetailId ,D.Quantity,IH.Id AS StockItemId,H.PropertyID,H.TransactionType,
	D.UnitPrice,D.DiscountValue,D.DiscountPercentage
	INTO #Items
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = H.LocationId 
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	WHERE IH.Id = @StockItemId AND H.TransactionDate <= @TrDate and H.LocationID = case when @LocationId = 999 then H.LocationID else @LocationId end
	ORDER BY H.TransactionDate ,D.CreatedDate,D.Id

	 

	WHILE EXISTS( SELECT * FROM #Items )
	BEGIN

	    DECLARE @TransactionType VARCHAR(5),@UnitPrice DECIMAL(18,4),@Quantity DECIMAL(18,4),@TxnType VARCHAR(2),@DiscountValue DECIMAL(18,4)
		,@DiscountPercentage DECIMAL(18,4)

		SELECT TOP(1) @TransactionType = TransactionType,@UnitPrice = UnitPrice,@Quantity = Quantity,@TxnType = TxnType 
		,@DiscountValue = DiscountValue,@DiscountPercentage = DiscountPercentage
		FROM #Items


       -- SELECT @TransactionType

			IF( @TransactionType = 'IN' )
			BEGIN

				SET @GLBalance_M = @GLBalance_M + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'TI' )
			BEGIN

				 SET @GLBalance_P = @GLBalance_P + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'GR' )
			BEGIN
			
			SELECT @UnitPrice = @UnitPrice- SUM( CASE WHEN @DiscountValue=0 THEN  @UnitPrice * @DiscountPercentage /100 ELSE  @DiscountValue END )
			--SELECT @UnitPrice 

				 SET @GLBalance_P = @GLBalance_P + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'IR' )
			BEGIN

				 SET @GLBalance_P = @GLBalance_P + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'TO' )
			BEGIN

				SET @GLBalance_M = @GLBalance_M + (@Quantity*@UnitPrice)

			END

			--IF( @TransactionType = 'XX' )
			--BEGIN

			--	SET @GLBalance = 0

			--END

			IF( @TransactionType = 'DN' )
			BEGIN

				SET @GLBalance_M = @GLBalance_M + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'IF' )
			BEGIN

				SET @GLBalance_M = @GLBalance_M + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'SR' )
			BEGIN

				SET @GLBalance_M = @GLBalance_M + (@Quantity*@UnitPrice)

			END

			IF( @TransactionType = 'AA' )
			BEGIN

				
					IF( @TxnType = 'M' )
					BEGIN

					 SET @GLBalance_M = @GLBalance_M + (@Quantity*@UnitPrice)

					END
					ELSE
					BEGIN

					  SET @GLBalance_P = @GLBalance_P + (@Quantity*@UnitPrice)

					END


			END


		DELETE TOP(1) FROM #Items 
 

	END

	SET @GLBalance = @GLBalance_P - @GLBalance_M


	SELECT @StockItemId AS ITEM_ID ,@GLBalance AS GL_VAL,@InvBalance AS INV_VAL,@GLBalance - @InvBalance AS Diff
    
END

GO

