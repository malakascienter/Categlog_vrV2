CREATE PROCEDURE [dbo].[InsertPOSOrderReturnToStockTransactions_OutletWise] (@PropertyID int = 1 , @TxnDate DATE ='2020-07-30',@Outlet VARCHAR(3))
AS
BEGIN TRY
	BEGIN TRANSACTION

	--SELECT  TxnDate,K.PropertyID,I.LocationID,k.StockItemID,I.AveragePrice, 
	--		Quantity * [dbo].[FN_GetUnitConvertionRate](K.PropertyID,K.TxnUnitID, I.MasterUnitID) Quantity, 
	--		I.MasterUnitID TxnUnitID, DepartmentID
	SELECT TxnDate,K.PropertyID,I.LocationID,k.StockItemID, I.AveragePrice  AveragePrice, 
			Quantity * [dbo].[FN_GetUnitConvertionRate](K.PropertyID,K.TxnUnitID, I.MasterUnitID) Quantity, 
			I.MasterUnitID TxnUnitID, DepartmentID
	INTO	#tempKitIssueData
	FROM	OutletOrderReturn K
			INNER JOIN StockItemdetails I 
	ON		K.StockItemID= I.StockItemHeaderID AND K.LocationID= I.LocationID
	WHERE	TxnDate= @TxnDate and K.PropertyID= @PropertyID AND K.OutletCode = @Outlet

	DECLARE @StockTransactionHeader XML 
	DECLARE @StockDetailList XML, @DepartmentID INT, @LocationId INT
	

	WHILE Exists(SELECT TOP 1 1 FROM #tempKitIssueData)  
	BEGIN


		SELECT TOP 1 @DepartmentID = DepartmentID , @LocationId= LocationId
		FROM #tempKitIssueData

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
					'ORDER RETURN' Remarks,
					0 ReferenceID,
					DepartmentID,
					0 UserProfileID,
					-1 TransferLocationID,
					51 TransactionID,
					0 SuppCurrencyID,
					0 ExchangeRate,
					0 CreatedUserID,
					0 LastModUserID,
					GETDATE() CreatedDate,
					GETDATE() LastModDate,
					'' StockDetailList
		FROM #tempKitIssueData
		WHERE DepartmentID =@DepartmentID AND LocationId = @LocationId
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
				'ORDER RETURN'Remarks,
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
			FROM #tempKitIssueData
			WHERE DepartmentID =@DepartmentID AND LocationId = @LocationId

			GROUP BY StockItemID,TxnUnitID, AveragePrice
			FOR XML PATH('StockTransactionDetail'))

		
		DECLARE @FinalXml XML 
		SET  @FinalXml= CONVERT(XML, REPLACE(CONVERT(VARCHAR(MAX),@StockTransactionHeader),'<StockDetailList/>',
		'<StockDetailList>'+CONVERT(VARCHAR(MAX),@StockDetailList)+'</StockDetailList>'))


		DELETE FROM #tempKitIssueData 
		WHERE DepartmentID =@DepartmentID AND LocationId = @LocationId

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

