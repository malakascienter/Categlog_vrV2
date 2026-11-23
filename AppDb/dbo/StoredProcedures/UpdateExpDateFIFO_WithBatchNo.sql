
-- EXEC [UpdateExpDateFIFO_WithBatchNo] 1,1,3415,30,21841,10,'001','2025-02-28',0



CREATE PROCEDURE [dbo].[UpdateExpDateFIFO_WithBatchNo](@PropertyID INT,@LocationID INT,  @StockItemID INT, @Quantity MONEY, @TxnID INT,@TransactionID INT
,@BatchNo VARCHAR(MAX) = NULL ,@EXPDateU DATE= NULL , @BatchID INT =0,@SellingPrice DECIMAL(18,8)=0)
AS
BEGIN
	
	DECLARE @ProcessedQty MONEY= @Quantity, @ID INT , @BalanceQuantity MONEY , @EXPDate DATE, @TransactionType varchar(50), @ThisQty  MONEY ,@StockMasterQty DECIMAL(18,8)
	,@TransactionDate DATE,@StockMasterQtyU DECIMAL(18,8),@PreviousID INT

	 CREATE TABLE #UpdateList(ID INT IDENTITY(1,1),TransactionDetailId BIGINT,TransactionType CHAR(3),BalanceQty DECIMAL(18,8),StockMasterQty DECIMAL(18,8))

	 CREATE TABLE #UpdateList2(ID INT,TransactionDetailId BIGINT,TransactionType CHAR(3),BalanceQty DECIMAL(18,8),StockMasterQty DECIMAL(18,8))


	 DECLARE @BatchIDU INT,@BatchQtyU DECIMAL(18,8),@TxnType CHAR(2),@BatchTransactionType CHAR(3)

	SELECT @TransactionType = TransactionTypes.Code 
	FROM TransactionTypes
	WHERE Id = @TransactionID

	SELECT @TransactionDate = TransactionDate
	FROM StockTransactionHeaders
	WHERE ID = @TxnID

	SELECT @TxnType = TxnType
	FROM StockTransactionDetails
	WHERE StockTransactionHeaderID = @TxnID AND StockItemID = @StockItemID

	SELECT @StockMasterQty = [dbo].[FN_GetBatchBalanceQty](@StockItemID,@LocationID,@BatchNo,@EXPDateU,@TransactionDate)

	IF(@TransactionID = 14)
	BEGIN

	SELECT @TransactionDate =CONVERT(DATE,SystemDate)
	FROM RequestHeaders
	WHERE ID = @TxnID

	SELECT @StockMasterQty = [dbo].[FN_GetBatchBalanceQty](@StockItemID,@LocationID,@BatchNo,@EXPDateU,@TransactionDate)


	select  @TxnID 
	SELECT RH.PropertyID,RH.LocationID,RH.Id,'RD' TransactionType,RD.StockItemID, @Quantity Quantity,
	 @StockMasterQty -@Quantity BalanceQuantity, @EXPDateU EXPDate,GETDATE() LogDate,@BatchNo BatchNo,RD.UnitID TxnUnitID,@StockMasterQty StockMasterQty,CONVERT(DATE,RH.SystemDate) TransactionDate
	 ,RD.UnitID MasterUnitID, @Quantity PhysicalQty
	FROM RequestHeaders RH
	INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
	WHERE RH.Id = @TxnID AND RD.StockItemID = @StockItemID

	INSERT INTO StockItemWiseEXPDateIns(PropertyID, LocationID, TransactionID, TransactionType, StockItemID, Quantity
	,BalanceQuantity, EXPDate, LogDate, BatchNo, TxnUnitID, StockMasterQty, TransactionDate, MasterUnitID, PhysicalQty,TxnType,SellingPrice)

	SELECT RH.PropertyID,RH.LocationID,RH.Id,'RD' TransactionType,RD.StockItemID, @Quantity Quantity,
	 @StockMasterQty -@Quantity BalanceQuantity, @EXPDateU EXPDate,GETDATE() LogDate,@BatchNo BatchNo,RD.UnitID TxnUnitID,@StockMasterQty StockMasterQty,CONVERT(DATE,RH.SystemDate) TransactionDate
	 ,RD.UnitID MasterUnitID, @Quantity PhysicalQty,'M',@SellingPrice
	FROM RequestHeaders RH
	INNER JOIN RequestDetails RD ON RH.Id = RD.RequestHeaderID
	WHERE RH.Id = @TxnID AND RD.StockItemID = @StockItemID

	END
	ELSE IF(@TransactionID = 10)
	BEGIN
		IF(@TransactionDate <> CONVERT(DATE,GETDATE()))
		BEGIN

		INSERT  INTO #UpdateList
		SELECT ID,TransactionType,BalanceQuantity,StockMasterQty
		FROM StockItemWiseEXPDateIns
		WHERE StockItemID = @StockItemID
		AND LocationID = @LocationID
		AND PropertyID = @PropertyID
		AND BatchNo = @BatchNo
		AND EXPDate = @EXPDateU
		AND TransactionID <> @TxnID
		AND TransactionDate > @TransactionDate
		SELECT @StockMasterQty StockMasterQty

		SELECT '#UpdateList',*
		FROM #UpdateList

		INSERT INTO #UpdateList2
		select *
		from #UpdateList

		SELECT @BatchQtyU = @Quantity - @StockMasterQty--CASE WHEN @TxnType ='P' THEN @Quantity - @StockMasterQty WHEN @TxnType ='M' THEN @StockMasterQty - @Quantity END


		
		SELECT @StockMasterQty StockMasterQty, @BatchQtyU BatchQtyU

		WHILE EXISTS(SELECT 1 FROM #UpdateList)
		BEGIN
			SELECT TOP (1)@BatchIDU =TransactionDetailId,@BatchTransactionType = TransactionType,@PreviousID = (ID-1)
			FROM #UpdateList


			select @PreviousID PreviousID

			SELECT @StockMasterQtyU = BalanceQty
			FROM #UpdateList2
			where id = @PreviousID
			
			
		
				
				IF(@BatchTransactionType <> 'AA')
				BEGIN
				SELECT StockMasterQty,@StockMasterQtyU StockMasterQtyU,@BatchTransactionType
				FROM StockItemWiseEXPDateIns
				WHERE ID = @BatchIDU

				UPDATE StockItemWiseEXPDateIns
				SET BalanceQuantity = BalanceQuantity + @BatchQtyU,StockMasterQty = StockMasterQty + @BatchQtyU
				WHERE ID = @BatchIDU


				UPDATE #UpdateList2
				SET BalanceQty =  BalanceQty + @BatchQtyU,StockMasterQty = @StockMasterQtyU
				WHERE TransactionDetailId =@BatchIDU


				END
				ELSE
				BEGIN


					SELECT StockMasterQty,@StockMasterQtyU StockMasterQtyU,@BatchTransactionType
				FROM StockItemWiseEXPDateIns
				WHERE ID = @BatchIDU

				UPDATE StockItemWiseEXPDateIns
				SET --BalanceQuantity = BalanceQuantity + @BatchQtyU,
				StockMasterQty = @StockMasterQtyU,
				Quantity = ABS(@StockMasterQtyU - PhysicalQty)
				WHERE ID = @BatchIDU

				
				UPDATE #UpdateList2
				SET StockMasterQty = @StockMasterQtyU
				WHERE TransactionDetailId =@BatchIDU

				SET @BatchQtyU = 0

				END
			DELETE TOP (1) FROM #UpdateList

		END
			INSERT INTO StockItemWiseEXPDateIns(PropertyID, LocationID, TransactionID, TransactionType, StockItemID, Quantity
			,BalanceQuantity, EXPDate, LogDate, BatchNo, TxnUnitID, StockMasterQty, TransactionDate, MasterUnitID, PhysicalQty,TxnType,SellingPrice)

			SELECT SH.PropertyID,SH.LocationID,SH.Id,SH.TransactionType,SD.StockItemID,

			CASE WHEN @StockMasterQty = 0 THEN ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2)
				WHEN SD.TxnType = 'P' THEN ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) - @StockMasterQty 
				WHEN TxnType = 'M' THEN @StockMasterQty - ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) END Quantity ,

			ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) BalanceQuantity,

				@EXPDateU EXPDate,GETDATE() LogDate,@BatchNo,SD.TxnUnitID,@StockMasterQty StockMasterQty,SH.TransactionDate,SD.MasterUnitID, @Quantity PhysicalQty,SD.TxnType,@SellingPrice
			FROM StockTransactionHeaders SH
			INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
			WHERE SH.Id = @TxnID AND SD.StockItemID = @StockItemID
		END
		ELSE
		BEGIN
			INSERT INTO StockItemWiseEXPDateIns(PropertyID, LocationID, TransactionID, TransactionType, StockItemID, BalanceQuantity 
			,Quantity, EXPDate, LogDate, BatchNo, TxnUnitID, StockMasterQty, TransactionDate, MasterUnitID, PhysicalQty,TxnType,SellingPrice)
			SELECT SH.PropertyID,SH.LocationID,SH.Id,SH.TransactionType,SD.StockItemID,
			CASE WHEN SD.TxnType = 'P' THEN ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) - @StockMasterQty 
				WHEN TxnType = 'M' THEN @StockMasterQty - ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) END  BalanceQuantity,
			ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) Quantity ,
			@EXPDateU EXPDate,GETDATE() LogDate,@BatchNo,SD.TxnUnitID,@StockMasterQty StockMasterQty,SH.TransactionDate,SD.MasterUnitID, @Quantity PhysicalQty,SD.TxnType,@SellingPrice
			FROM StockTransactionHeaders SH
			INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
			WHERE SH.Id = @TxnID AND SD.StockItemID = @StockItemID
		END


	END
	ELSE
	BEGIN
	INSERT INTO StockItemWiseEXPDateIns(PropertyID, LocationID, TransactionID, TransactionType, StockItemID, Quantity
	,BalanceQuantity, EXPDate, LogDate, BatchNo, TxnUnitID, StockMasterQty, TransactionDate, MasterUnitID, PhysicalQty,TxnType,SellingPrice)

	SELECT SH.PropertyID,SH.LocationID,SH.Id,SH.TransactionType,SD.StockItemID,ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) Quantity,
	CASE WHEN SD.TxnType = 'P' THEN  @StockMasterQty +ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) 
	 WHEN TxnType = 'M' THEN @StockMasterQty - ROUND(dbo.FN_GetUnitConvertionRate(SH.PropertyID,SD.TxnUnitID,SD.MasterUnitID) * @Quantity,2) END BalanceQuantity,
	 @EXPDateU EXPDate,GETDATE() LogDate,@BatchNo,SD.TxnUnitID,@StockMasterQty StockMasterQty,SH.TransactionDate,SD.MasterUnitID, @Quantity PhysicalQty,SD.TxnType,@SellingPrice
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID = SH.Id
	WHERE SH.Id = @TxnID AND SD.StockItemID = @StockItemID
	END
	
END

GO

