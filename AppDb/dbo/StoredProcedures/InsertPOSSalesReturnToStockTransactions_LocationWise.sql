CREATE PROCEDURE [dbo].[InsertPOSSalesReturnToStockTransactions_LocationWise] (@PropertyID int = 1 , @TxnDate DATE ='2020-07-30',@LocationId INT)
AS
BEGIN TRY
	BEGIN TRANSACTION

	SELECT K.BusinessDate AS TxnDate,K.CompanyID AS PropertyID,I.LocationID,k.ItemID StockItemID, SD.AveragePrice  AveragePrice, 
			Quantity * [dbo].[FN_GetUnitConvertionRate](K.CompanyID, I.MasterUnitID, I.MasterUnitID) Quantity, 
			I.MasterUnitID TxnUnitID, SL.DepartmentID AS DepartmentID
	INTO	#tempSalesData
	FROM	POS_SalesReturnDetail K INNER JOIN StockItemdetails I ON K.ItemID= I.StockItemHeaderID AND K.LocationID= I.LocationID
			INNER JOIN Locations SL ON K.LocationID = SL.Id
			INNER JOIN StockItemDetails SD ON K.ItemID = SD.StockItemHeaderID AND K.LocationID = SD.LocationID AND K.CompanyID = SD.CompanyID
	WHERE	K.BusinessDate= @TxnDate and K.CompanyID = @PropertyID AND K.LocationID = @LocationId


	SELECT TxnDate,PropertyID,LocationID,StockItemID,AveragePrice,SUM(Quantity) AS Quantity,TxnUnitID,DepartmentID
	INTO #tempSalesDataTran
	FROM #tempSalesData 
	GROUP BY TxnDate,PropertyID,LocationID,StockItemID,AveragePrice,TxnUnitID,DepartmentID

	DECLARE @StockTransactionHeader XML 
	DECLARE @StockDetailList XML, @DepartmentID INT, @TranLocationId INT
	

	WHILE Exists(SELECT TOP 1 1 FROM #tempSalesDataTran)  
	BEGIN


		SELECT TOP 1 @DepartmentID = DepartmentID , @TranLocationId= LocationId
		FROM #tempSalesDataTran

		SET @StockTransactionHeader= (
		SELECT		TOP 1
					'P'Mode,
					'' DocumentNo,
					'RC' TransactionType,
					TxnDate TransactionDate,
					LocationID,
					PropertyID,
					'' ReferenceNo,
					0 SupplierID,
					'INVOICE RETURN' Remarks,
					0 ReferenceID,
					DepartmentID,
					0 UserProfileID,
					-1 TransferLocationID,
					9 TransactionID,
					0 SuppCurrencyID,
					0 ExchangeRate,
					0 CreatedUserID,
					0 LastModUserID,
					GETDATE() CreatedDate,
					GETDATE() LastModDate,
					'' StockDetailList
		FROM #tempSalesDataTran
		WHERE DepartmentID =@DepartmentID AND LocationId = @TranLocationId
		FOR XML PATH('StockTransactionHeader')
		)

		SET @StockDetailList =(
			SELECT		1 StockTransactionHeaderID,
				StockItemID,
				SUM(Quantity) Quantity,
				AVG(AveragePrice) UnitPrice,
				TxnUnitID,
				TxnUnitID MasterUnitID,
				1 MasterUnitConversion,
				1 ReportUnitID,
				1 ReportUnitConversion,
				0 DiscountValue,
				0 DiscountPercentage,
				0 StockMasterQuantity,
				AVG(AveragePrice) StockMasterAveragePrice,
				0 NewQuantity,
				AVG(AveragePrice) NewAveragePrice,
				'INVOICE RETURN'Remarks,
				0 UserProfileId,
				1 CostTransactionAccountID,
				1 PurchaseTransactionAccountID,
				'P' TxnType,
				0 ItemUnitPriceInSuppCurrency,
				0 BalanceQuantity,
				0 ReturnQuantity,
				0 CreatedUserID,
				0 LastModUserID,
				GETDATE() CreatedDate,
				GETDATE() LastModDate 
			FROM #tempSalesDataTran
			WHERE DepartmentID =@DepartmentID AND LocationId = @TranLocationId

			GROUP BY StockItemID,TxnUnitID, AveragePrice
			FOR XML PATH('StockTransactionDetail'))

		
		DECLARE @FinalXml XML 
		SET  @FinalXml= CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX),@StockTransactionHeader),'<StockDetailList/>',
		'<StockDetailList>'+CONVERT(VARCHAR(MAX),@StockDetailList)+'</StockDetailList>'))


		DELETE FROM #tempSalesDataTran 
		WHERE DepartmentID =@DepartmentID AND LocationId = @TranLocationId

		select @FinalXml FinalXml

		exec [dbo].SP_InsertStockTransactions  @FinalXml,'',0,'',1

	END 
	COMMIT TRANSACTION

END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH

GO

