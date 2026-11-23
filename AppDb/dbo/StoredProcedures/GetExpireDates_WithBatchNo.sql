-- =============================================
-- Author:		Isuru Pramodya
-- Create date:2025-02-10
-- Description:	Loading Item Wise Batch Transactions for Supplier Return

-- [dbo].[GetExpireDates_WithBatchNo] 3415,0,1,'TO',1,4,'2025-04-08'

-- =============================================
CREATE PROCEDURE [dbo].[GetExpireDates_WithBatchNo] 
@StockItemId INT,
@TransactionID INT,
@LocationID INT,
@TransactionType CHAR(3),
@PropertyId INT,
@TxnUnitID INT,
@TransactionDate DATETIME

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DATE DATE

	SET @DATE = CONVERT(DATE,GETDATE())



	IF(@TransactionType = 'SR')
	BEGIN
		SET @TransactionType  ='GR';

		SELECT 1 ID
		,[dbo].[FN_GetBatchBalanceQty](ST.StockItemID,@LocationID,BatchNo,CONVERT(DATE,ST.EXPDate),@DATE) Quantity,
		CONVERT(VARCHAR,CONVERT(DATE,EXPDate)) EXPDate,StockItemID,BatchNo,SellingPrice,0 TransactionID,0 ReturnQty
		FROM StockItemWiseEXPDateIns ST
		WHERE ST.StockItemID = @StockItemId
		AND ST.TransactionID = CASE WHEN @TransactionID =-999 THEN ST.TransactionID ELSE @TransactionID END
		AND ST.TransactionType = CASE WHEN @TransactionType ='-99' THEN ST.TransactionType ELSE @TransactionType END
		AND BatchNo IS NOT NULL
		AND ST.LocationID = CASE WHEN @LocationID = -999 THEN ST.LocationID ELSE @LocationID END
		AND [dbo].[FN_GetBatchBalanceQty](ST.StockItemID,@LocationID,BatchNo,CONVERT(DATE,ST.EXPDate),@DATE) >0
		GROUP BY ST.ID,EXPDate,StockItemID,BatchNo,TransactionID,SellingPrice
	END
	ELSE IF(@TransactionType = 'AA')
	BEGIN
		SELECT 
		[dbo].[FN_GetBatchBalanceQty](StockItemID,@LocationID,BatchNo,CONVERT(DATE,EXPDate),CONVERT(DATE,@TransactionDate)) Quantity,
		EXPDate,StockItemID,BatchNo,SellingPrice,0 ReturnQty
	  FROM StockItemWiseEXPDateIns 
	  WHERE StockItemID = @StockItemId AND 	[dbo].[FN_GetBatchBalanceQty](StockItemID,@LocationID,BatchNo,CONVERT(DATE,EXPDate),CONVERT(DATE,@TransactionDate)) > 0 AND PropertyID = @PropertyId AND LocationID = @LocationID
	  AND TransactionDate =CONVERT(DATE,@TransactionDate)
	  GROUP BY EXPDate,StockItemID,BatchNo,SellingPrice
	END	
	ELSE IF(@TransactionType = 'DN')
	BEGIN
		SELECT 
		--SUM(BalanceQuantity) Quantity,
		[dbo].[FN_GetBatchBalanceQty](StockItemID,@LocationID,BatchNo,CONVERT(DATE,EXPDate),@DATE) Quantity,
		EXPDate,StockItemID,BatchNo,SellingPrice,0 ReturnQty
	  FROM StockItemWiseEXPDateIns 
	  WHERE StockItemID = @StockItemId AND [dbo].[FN_GetBatchBalanceQty](StockItemID,@LocationID,BatchNo,CONVERT(DATE,EXPDate),@DATE) > 0 
	  AND PropertyID = @PropertyId AND LocationID = @LocationID
	  GROUP BY EXPDate,StockItemID,BatchNo,SellingPrice
	END
	ELSE IF(@TransactionType = 'TO')
	BEGIN
		SELECT [dbo].[FN_GetBatchBalanceQty](StockItemID,@LocationID,BatchNo,CONVERT(DATE,EXPDate),@DATE) Quantity,
		EXPDate,StockItemID,BatchNo,SellingPrice,0 ReturnQty
		INTO #Temp
	  FROM StockItemWiseEXPDateIns 
	  WHERE StockItemID = @StockItemId AND [dbo].[FN_GetBatchBalanceQty](StockItemID,@LocationID,BatchNo,CONVERT(DATE,EXPDate),@DATE) > 0 AND PropertyID = @PropertyId AND LocationID = @LocationID
	  GROUP BY EXPDate,StockItemID,BatchNo,SellingPrice


	  select ROUND(dbo.FN_GetUnitConvertionRate(@PropertyId,CASE WHEN @TxnUnitID=0 THEN  [dbo].[FN_GetMasterUnitID] (@PropertyId,@LocationID,@StockItemId) ELSE @TxnUnitID END,[dbo].[FN_GetMasterUnitID] (@PropertyId,@LocationID,@StockItemId)) * Quantity,2)  Quantity
	 , EXPDate,StockItemID,BatchNo,0 ReturnQty,SellingPrice
	   from #Temp

	END
	ELSE IF(@TransactionType ='TI')
	BEGIN

	DECLARE @FromLocationID INT

	SELECT @FromLocationID= LocationID FROM StockTransactionHeaders WHERE ID = @TransactionID

		SELECT --[dbo].[FN_GetBatchBalanceQty](ST.StockItemID,ISNULL(@FromLocationID,@LocationID),BatchNo,CONVERT(DATE,ST.EXPDate),@DATE) Quantity,
		SUM(Quantity) Quantity,
		CONVERT(VARCHAR,CONVERT(DATE,EXPDate)) EXPDate,StockItemID,BatchNo,SellingPrice,0 TransactionID,0 ReturnQty
		FROM StockItemWiseEXPDateIns ST
		WHERE ST.StockItemID = @StockItemId
		AND ST.TransactionID =@TransactionID
		AND BatchNo IS NOT NULL
		AND ST.LocationID = ISNULL(@FromLocationID,@LocationID)
	--	AND [dbo].[FN_GetBatchBalanceQty](ST.StockItemID,ISNULL(@FromLocationID,@LocationID),BatchNo,CONVERT(DATE,ST.EXPDate),@DATE) >0
		GROUP BY EXPDate,StockItemID,BatchNo,TransactionID,SellingPrice
	END
	ELSE	IF(@TransactionType = 'IN')
	BEGIN
		SET @TransactionType  ='-99';

		SELECT DISTINCT  1 ID,
	--	,SUM(BalanceQuantity) Quantity,
		[dbo].[FN_GetBatchBalanceQty](ST.StockItemID,@LocationID,BatchNo,CONVERT(DATE,ST.EXPDate),@DATE) Quantity
		,CONVERT(VARCHAR,CONVERT(DATE,EXPDate)) EXPDate,StockItemID,BatchNo,SellingPrice,0 TransactionID,0 ReturnQty
		FROM StockItemWiseEXPDateIns ST
		WHERE ST.StockItemID = @StockItemId
		AND ST.TransactionID = CASE WHEN @TransactionID =-999 THEN ST.TransactionID ELSE @TransactionID END
		AND ST.TransactionType = CASE WHEN @TransactionType ='-99' THEN ST.TransactionType ELSE @TransactionType END
		AND [dbo].[FN_GetBatchBalanceQty](ST.StockItemID,@LocationID,BatchNo,CONVERT(DATE,ST.EXPDate),@DATE)>0
		--AND CONVERT(DATE,ST.EXPDate) > = CONVERT(DATE,GETDATE())
		AND BatchNo IS NOT NULL
		AND ST.LocationID = CASE WHEN @LocationID = -999 THEN ST.LocationID ELSE @LocationID END
		GROUP BY ST.ID,EXPDate,StockItemID,BatchNo,TransactionID,SellingPrice
	END
	ELSE IF(@TransactionType = 'IR')
	BEGIN
		SET @TransactionType  ='IN';

		SELECT 1 ID,
		--,SUM(Quantity) Quantity,
		[dbo].[FN_GetBatchBalanceQty](ST.StockItemID,@LocationID,BatchNo,CONVERT(DATE,ST.EXPDate),@DATE) Quantity,
		CONVERT(VARCHAR,CONVERT(DATE,EXPDate)) EXPDate,StockItemID,BatchNo,SellingPrice,0 TransactionID,0 ReturnQty
		FROM StockItemWiseEXPDateIns ST
		WHERE ST.StockItemID = @StockItemId
		AND ST.TransactionID = CASE WHEN @TransactionID =-999 THEN ST.TransactionID ELSE @TransactionID END
		AND ST.TransactionType = CASE WHEN @TransactionType ='-99' THEN ST.TransactionType ELSE @TransactionType END
		AND [dbo].[FN_GetBatchBalanceQty](ST.StockItemID,@LocationID,BatchNo,CONVERT(DATE,ST.EXPDate),@DATE)>0
		AND BatchNo IS NOT NULL
		AND ST.LocationID = CASE WHEN @LocationID = -999 THEN ST.LocationID ELSE @LocationID END
		GROUP BY ST.ID,EXPDate,StockItemID,BatchNo,TransactionID,SellingPrice
	END

END

GO

