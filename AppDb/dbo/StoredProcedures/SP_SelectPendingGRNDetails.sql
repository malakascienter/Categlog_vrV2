-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-12-24
-- Description:	Loading Pending GRN Approval details for Edit GRN 

-- [dbo].[SP_SelectPendingGRNDetails] 8507

-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectPendingGRNDetails]
@HeaderId INT
AS
BEGIN
------------------------------------------------------------------------------------
BEGIN TRY 
		DECLARE @XMLDetails XML,@iDocID INT,@LocationId INT,@ItemTotal DECIMAl(18,6),@StockItemID INT,@SupplierID INT, @TaxAmount DECIMAL(18,6),
		@Qty DECIMAL(18,6)

				DECLARE @GRNXML VARCHAR(MAX),
				@NEWGRNXML XML,
				--@iDocID INT,
				@iDocIDORG INT

		SELECT @XMLDetails = CONVERT(XML,XMLDetails),@LocationId = LocationId
		FROM  GRNApprovalLog 
		WHERE Id = @HeaderId

		CREATE TABLE #AllData(
		StockItemID INT,
		ReceivedQuantity DECIMAL(18,6),
		UnitPrice DECIMAL(18,6),
		UnitName VARCHAR(200),
		ItemText VARCHAR(250),
		Remarks VARCHAR(250),
		LocationId INT,
		QuantityInHand DECIMAL(18,6),
		DiscountValue DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6),
		TotalTax DECIMAL(18,6),
		GrossTotal DECIMAL(18,6),
		TotalDiscount DECIMAL(18,6),
		ItemTotal DECIMAL(18,6),
		TotalAdditionalCharges DECIMAL(18,6),
		TransactionDate VARCHAR(20) null
		,UnitConversion VARCHAR(MAX)
		,UnitId INT
		,SupplierInvoiceNo NVARCHAR(MAX)
		,IsTransactionExist BIT
		,OriginalItemText VARCHAR(250)
		)
	-----------------------------------------------------------------------------------------
		SELECT @GRNXML = XMLDetails FROM  [dbo].[GRNApprovalLog] WHERE Id = @HeaderId
		SET @NEWGRNXML = CONVERT(XML,@GRNXML)

		CREATE TABLE #UnitConversionList(Id	INT,Name VARCHAR(100))

		DECLARE @MasterUnitID INT

		EXEC sp_xml_preparedocument @iDocIDORG OUTPUT, @NEWGRNXML;
		declare @tempDate varchar(20),@ReferenceNo NVARCHAR(max)

		SELECT @tempDate= TransactionDate  ,@ReferenceNo = ReferenceNo
		FROM
			OPENXML(@iDocIDORG, '/StockTransactionHeader', 2)
			WITH (TransactionDate DATE, ReferenceNo VARCHAR(MAX))

		--select * from #TempDetails

---------------------------------------------------------------------------------------------
		
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		
  		SELECT * INTO #tempItemDetails FROM 
		OPENXML(@iDocID, '/StockTransactionHeader/StockDetailList/StockTransactionDetail', 2) 
		WITH (StockItemID INT, Quantity DECIMAL(18,6),UnitPrice DECIMAL(18,6),TxnUnitID INT, Remarks VARCHAR(MAX),DiscountValue DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6))

		--select * from #tempItemDetails
		SELECT @SupplierID = SupplierID  FROM 
		OPENXML(@iDocID, '/StockTransactionHeader', 2) 
		WITH (SupplierID INT)


		----Added 14/03/2022-----------------
		DECLARE @TotalCharges DECIMAL(18,6)
		SELECT Amount INTO #tempAdditionalCharges FROM 
		OPENXML(@iDocID, '/StockTransactionHeader/AdditionalChargesList/AdditionalChargesDetails', 2) 
		WITH (Amount DECIMAL(18,6))

		SELECT @TotalCharges =SUM(Amount) FROM  #tempAdditionalCharges
		----Added 14/03/2022-----------------


		WHILE (SELECT COUNT(*) FROM #tempItemDetails)>0
		BEGIN
				SELECT TOP(1) @StockItemID = StockItemID, @Qty = Quantity 
				FROM #tempItemDetails
				SELECT  TOP(1)  @ItemTotal = (UnitPrice - CASE WHEN DiscountValue>0 THEN ( DiscountValue / Quantity) ELSE UnitPrice * DiscountPercentage /100 END )

		 FROM #tempItemDetails

			SELECT @MasterUnitID = MasterUnitID
			FROM StockItemDetails
			WHERE LocationID = @LocationId
			AND StockItemHeaderID = @StockItemID


	
		
				CREATE TABLE #TaxTable
				(
					TaxTypeId INT,
					TaxValue DECIMAL(18,6)
				);
				
				INSERT INTO #TaxTable
				EXEC [SP_Select_StockItemWiseTaxAmount] @StockItemID, @ItemTotal,@SupplierID,@LocationId;
		
				select TOP(1) @TaxAmount =   (TaxValue * @Qty) from #TaxTable


					 --added by Isuru 2023-08-02
		 DECLARE @TransactionType VARCHAR(10),
				@GRNHeaderID INT


		 SELECT @GRNHeaderID = ReferenceID  FROM 
		OPENXML(@iDocID, '/StockTransactionHeader', 2) 
		WITH (ReferenceID INT)


		 SELECT @TransactionType = TransactionType
		 FROM GRNApprovalLog
		 WHERE Id = @HeaderId

		INSERT INTO #UnitConversionList
		SELECT Id,Name
		FROM (
		SELECT ID as Id, Name as Name FROM Units WHERE ID = @MasterUnitID
		UNION
		select UC.FromUnitID as Id, U.Name as Name
		from UnitConversions UC INNER JOIN Units U ON UC.FromUnitID = U.ID
		WHERE UC.ToUnitID = @MasterUnitID
	
		UNION
		select UC.ToUnitID as Id, U.Name as Name
		from UnitConversions UC INNER JOIN Units U ON UC.ToUnitID = U.ID
		WHERE UC.FromUnitID = @MasterUnitID
		) AS A

		INSERT INTO #AllData
		SELECT TOP(1) TD.StockItemID, TD.Quantity AS ReceivedQuantity,TD.UnitPrice, U.Name AS UnitName, SH.Name ItemName,  TD.Remarks,@LocationId AS LocationId,
		(SELECT QuantityInHand FROM  StockItemDetails WHERE StockItemHeaderID = TD.StockItemID AND LocationID = @LocationId) AS QuantityInHand,
		TD.DiscountValue, TD.DiscountPercentage,@TaxAmount AS TotalTax,TD.UnitPrice * TD.Quantity AS GRossTotal,
		(UnitPrice - @ItemTotal)*Quantity AS TotalDiscount, (((TD.UnitPrice * TD.Quantity)-(UnitPrice - @ItemTotal)*Quantity)+@TaxAmount) AS NetTotal,@TotalCharges
		,@tempDate TransactionDate
		,(SELECT DISTINCT [Id], [Name]
			FROM #UnitConversionList
			FOR JSON PATH) AS UnitConversion
			,TxnUnitId,@ReferenceNo SupplierInvoiceNo
			,[dbo].[fn_IsTransactionExistsItemWise] (TD.StockItemID)
			,SH.Name
		FROM #tempItemDetails TD
		INNER JOIN Units U ON U.Id = TD.TxnUnitId
		INNER JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
		WHERE SH.ID= @StockItemID

		set @TaxAmount=0

	drop table #TaxTable
	DELETE TOP(1) FROM #tempItemDetails
	DELETE FROM #UnitConversionList
	END
	
		
		
		
	SELECT * FROM  #AllData where ReceivedQuantity > 0





END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
------------------------------------------------------------------------------------


END

GO

