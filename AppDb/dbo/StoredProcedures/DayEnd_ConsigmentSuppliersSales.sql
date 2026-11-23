-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-26
-- Description:	Calculate Sales Qty of consigment suppliers
-- [dbo].[DayEnd_ConsigmentSuppliersSales] 1,12,'2025-01-06'

-- =============================================
CREATE PROCEDURE [dbo].[DayEnd_ConsigmentSuppliersSales]
	@PropertyID INT,
	@LocationID INT,
	@currentDate Date
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @currentDate2 Date,
			@StockItemID INT,
			@InvoiceQuantity DECIMAL(18,8),
			@GRNQty DECIMAL(18,8),
			@SalesQty DECIMAL(18,8),
			@DetailID INT,
			@VarianceQty DECIMAL(18,8),
			@ReturnQuantity DECIMAL(18,8)


	IF OBJECT_ID('tempdb..#ConsigmentItems') IS NOT NULL
	DROP TABLE #ConsigmentItems

	CREATE TABLE #ConsigmentItems(ID INT IDENTITY,ItemID INT, Quantity DECIMAL(18,8),ReturnQuantity DECIMAL(18,8))

	IF OBJECT_ID('tempdb..#GRNItems') IS NOT NULL
	DROP TABLE #GRNItems

	CREATE TABLE #GRNItems(ID INT IDENTITY,ItemID INT,LocationID INT,SaleQty  DECIMAL(18,8))

	--SELECT @currentDate = '2024-10-14' --CurrentDate
	--FROM Locations
	--WHERE ID = @LocationID

	SELECT @currentDate

	INSERT INTO #ConsigmentItems(ItemID, Quantity,ReturnQuantity)
	SELECT  ItemID,sum(Quantity) Quantity,0 ReturnQuantity
	FROM [dbo].[POS_InvoiceDetail]
	WHERE itemid in(SELECT DISTINCT stockitemid
	FROM supplierwiseitemdetails
	WHERE LocationId=@LocationID AND supplierid in (SELECT id
	FROM suppliers
	WHERE isconsigments=1)
	)
	AND ItemID=5269
	and BusinessDate = @currentDate
	GROUP BY ItemID

	INSERT INTO #ConsigmentItems(ItemID, Quantity,ReturnQuantity)
	SELECT  ItemID,0 Quantity,sum(Quantity) ReturnQuantity
	FROM [dbo].POS_SalesReturnDetail
	WHERE itemid in(SELECT DISTINCT stockitemid
	FROM supplierwiseitemdetails
	WHERE LocationId=@LocationID AND supplierid in (SELECT id
	FROM suppliers
	WHERE isconsigments=1)
	)
	AND ItemID=5269
	and BusinessDate = @currentDate
	GROUP BY ItemID

	SELECT *
	FROM #ConsigmentItems

	WHILE EXISTS(SELECT 1 FROM #ConsigmentItems)
	BEGIN
	SELECT TOP(1) @StockItemID= ItemID ,@InvoiceQuantity= SUM(Quantity-ReturnQuantity), @ReturnQuantity = SUM(ReturnQuantity)
	FROM #ConsigmentItems
	GROUP BY ItemID

	SELECT @StockItemID ItemID,@InvoiceQuantity InvoiceQuantity,@ReturnQuantity ReturnQty

	SELECT SH.DocumentNo,SH.TransactionDate,SD.UnitPrice, SH.LocationID,SD.StockItemID,ISNULL(SD.SaleQty,0) SaleQty ,SD.Quantity,SD.Id DetailID,SH.SupplierID
	INTO #TempSalesItems
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	WHERE SH.TransactionType='GR' AND SD.StockItemID = @StockItemID

	SELECT *
	FROM #TempSalesItems

	WHILE EXISTS(SELECT 1 FROM #TempSalesItems)
	BEGIN
		SELECT TOP(1) @GRNQty = Quantity,@SalesQty = SaleQty, @DetailID = DetailID FROM #TempSalesItems

		SELECT @GRNQty GRNQty,@SalesQty SalesQty,@DetailID DetailID

		IF(@InvoiceQuantity <>0)
		BEGIN

			IF(@GRNQty <> @SalesQty)
			BEGIN
			SELECT @GRNQty GRNQty,@SalesQty SalesQty, @StockItemID StockItemID,@InvoiceQuantity InvoiceQuantity

				SET @SalesQty = @GRNQty - @SalesQty
				
				SELECT @VarianceQty = @InvoiceQuantity - @SalesQty

				SELECT @VarianceQty VarianceQty

				IF(@VarianceQty) < 0
				BEGIN
					SELECT 'MINUS FOUND' SE, @VarianceQty VarianceQty,@InvoiceQuantity InvoiceQuantity ,@SalesQty SalesQty

					SET @SalesQty = @SalesQty + @VarianceQty
				END

				SELECT 123, @VarianceQty VarianceQty,@InvoiceQuantity InvoiceQuantity ,@SalesQty SalesQty

			
				SET @InvoiceQuantity = @InvoiceQuantity- @SalesQty


				SELECT @InvoiceQuantity UPDATEDInvoiceQuantity

				SELECT SaleQty,@SalesQty 
				FROM StockTransactionDetails
				WHERE ID = @DetailID

				UPDATE StockTransactionDetails
				SET SaleQty = ISNULL(SaleQty,0) +@SalesQty
				WHERE ID = @DetailID

				INSERT INTO ConsigmentItemsSalesDetails(DocumentNo, SupplierID, LocationID,StockItemID, TransactionDate, UnitPrice, GRNQty, SalesQty, BusinessDate, SysDateTime)
				select TOP(1) DocumentNo,SupplierID,LocationID,StockItemID,TransactionDate,UnitPrice,Quantity,@SalesQty,@currentDate,GETDATE()
				FROM #TempSalesItems

			--SELECT @GRNQty GRNQty,@SalesQty SalesQty, @StockItemID StockItemID,@InvoiceQuantity InvoiceQuantity

		
		END
		END
		

		
	DELETE TOP(1) FROM #TempSalesItems

	

	END
	--SELECT @StockItemID ItemID,@SalesQty Quantity,@InvoiceQuantity LASTInvoiceQuantity



	SELECT SH.DocumentNo,SH.LocationID,SD.StockItemID,ISNULL(SD.SaleQty,0) SaleQty ,SD.Quantity,SD.Id DetailID
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	WHERE SH.TransactionType='GR' AND SD.StockItemID = @StockItemID

		IF(@InvoiceQuantity <> 0)
	BEGIN
		SELECT @InvoiceQuantity RemainQuantity, @StockItemID StockItemID
	END

	
	--SELECT SH.DocumentNo,SH.LocationID,SD.StockItemID,ISNULL(SD.SaleQty,0) SaleQty ,SD.Quantity,SD.Id DetailID
	--FROM StockTransactionHeaders SH
	--INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	--WHERE SH.TransactionType='GR' AND SD.StockItemID = @StockItemID

	DROP TABLE #TempSalesItems
	DELETE TOP (1) FROM #ConsigmentItems 

	END

	
END

GO

