-- [dbo].[SP_GetAllGRNApprovalDetails] 8507

CREATE PROCEDURE [dbo].[SP_GetAllGRNApprovalDetails](@HeaderId INT, @ValueOfRequest DECIMAL(18,6)=0 OUT )

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

	
		DECLARE @TransactionType VARCHAR(10),@GRNHeaderID INT
		DECLARE @RowNo INT --added 2026-10-07 Reason: loop key, one per XML detail line
		SELECT @XMLDetails = CONVERT(XML,XMLDetails),@LocationId = LocationId
		FROM  GRNApprovalLog 
		WHERE Id = @HeaderId

		CREATE TABLE #AllData(
		StockItemID INT,
		GRNQty DECIMAL(18,6),
		UnitPrice DECIMAL(18,6),
		Unit VARCHAR(200),
		ItemName VARCHAR(250),
		Remarks VARCHAR(250),
		LocationId INT,
		QuantityInHand DECIMAL(18,6),
		DiscountValue DECIMAL(18,6),
		DiscountPercentage DECIMAL(18,6),
		TotalTax DECIMAL(18,6),
		GrossTotal DECIMAL(18,6),
		TotalDiscount DECIMAL(18,6),
		NetTotal DECIMAL(18,6),
		TotalAdditionalCharges DECIMAL(18,6),
		TransactionDate VARCHAR(20) null,
		LastGRNPrice DECIMAL(18,6) -- Added By Ravindu 225-12-01
		,UnitConversion VARCHAR(MAX)
		,TxnUnitId INT
		)
	-----------------------------------------------------------------------------------------
		SELECT @GRNXML = XMLDetails FROM  [dbo].[GRNApprovalLog] WHERE Id = @HeaderId
		SET @NEWGRNXML = CONVERT(XML,@GRNXML)

		CREATE TABLE #UnitConversionList(Id	INT,Name VARCHAR(100))

		DECLARE @MasterUnitID INT

		EXEC sp_xml_preparedocument @iDocIDORG OUTPUT, @NEWGRNXML;
		declare @tempDate varchar(20)

		SELECT @tempDate= TransactionDate  FROM
			OPENXML(@iDocIDORG, '/StockTransactionHeader', 2)
			WITH (TransactionDate DATE)

		--select * from #TempDetails

---------------------------------------------------------------------------------------------
		
		EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
		
  		--modified 2026-10-07 Reason: RowNo identifies each XML line, so a document that lists the same item
		--on more than one line can no longer show one line twice and drop the other (TOP(1)/DELETE TOP(1) mismatch)
		SELECT IDENTITY(INT,1,1) AS RowNo, * INTO #tempItemDetails FROM 
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

		
		 SELECT @TransactionType = TransactionType
		 FROM GRNApprovalLog
		 WHERE Id = @HeaderId

		WHILE (SELECT COUNT(*) FROM #tempItemDetails)>0
		BEGIN
				SELECT TOP(1) @RowNo = RowNo, @StockItemID = StockItemID, @Qty = Quantity --@RowNo added 2026-10-07
				FROM #tempItemDetails
				ORDER BY  StockItemID, RowNo

				SELECT  TOP(1)  @ItemTotal = (UnitPrice - CASE WHEN DiscountValue>0 THEN ( DiscountValue / Quantity) ELSE UnitPrice * DiscountPercentage /100 END )
				FROM #tempItemDetails
				WHERE RowNo = @RowNo --modified 2026-10-07: price/discount of this line, not of any line of the item

				SET @MasterUnitID = NULL --added 2026-10-07 Reason: do not reuse the previous item's unit list
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



		 SELECT @GRNHeaderID = ReferenceID  FROM 
		OPENXML(@iDocID, '/StockTransactionHeader', 2) 
		WITH (ReferenceID INT)



		 IF(@TransactionType = 'SR')
		 BEGIN
		SELECT  @TaxAmount = SUM(ISNULL (t.TaxAmount,0) / Quantity)	
		FROM         StockTransactionDetails AS c 
		LEFT OUTER  join   StockTransactionwiseTaxes t on c.Id = t.StockTransactionDetailID
		WHERE     c.StockTransactionHeaderID=@GRNHeaderID AND C.Quantity > 0
		AND C.StockItemID = @StockItemID
		
		SET @TaxAmount  = @TaxAmount * @Qty
		
		 END
		
		IF(@TransactionType = 'AA')
		BEGIN
		SET @TaxAmount =0
		--select @tempDate date
					INSERT INTO #AllData
					SELECT TOP(1) TD.StockItemID,
					TD.Quantity AS GRNQty,TD.UnitPrice, U.Name AS Unit, SH.Name ItemName,  TD.Remarks,@LocationId AS LocationId,
					 [dbo].[FN_GetStockInHand_Reatils](SH.CompanyId,@LocationId,TD.StockItemID)  AS QuantityInHand,
					--(SELECT QuantityInHand FROM  StockItemDetails WHERE StockItemHeaderID = TD.StockItemID AND LocationID = @LocationId) AS QuantityInHand,
					TD.DiscountValue, TD.DiscountPercentage,@TaxAmount AS TotalTax,TD.UnitPrice * TD.Quantity AS GRossTotal,
					0 AS TotalDiscount, (TD.UnitPrice * TD.Quantity) AS NetTotal,@TotalCharges,
					@tempDate TransactionDate,
					0 AS LastGRNPrice  -- Added By Ravindu 225-12-02
					,NULL UnitConversion
					,TxnUnitId
					FROM #tempItemDetails TD
					INNER JOIN Units U ON U.Id = TD.TxnUnitId
					INNER JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
					WHERE SH.ID= @StockItemID AND TD.RowNo = @RowNo --RowNo added 2026-10-07  -- Added by Isuru 2026-02-13 to fix incorrect items inserting in temp table
					--select * from #TempDetails
					
					
					set @TaxAmount=0
			drop table #TaxTable
			DELETE FROM #tempItemDetails --modified 2026-10-07: delete exactly the processed line
			WHERE RowNo = @RowNo
		END
        
        
		--end
		--end
		ELSE
		BEGIN
		
		 --end
		
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
				SELECT TOP(1) TD.StockItemID, TD.Quantity AS GRNQty,TD.UnitPrice, U.Name AS Unit, SH.Name ItemName,  TD.Remarks,@LocationId AS LocationId,
				(SELECT QuantityInHand FROM  StockItemDetails WHERE StockItemHeaderID = TD.StockItemID AND LocationID = @LocationId) AS QuantityInHand,
				TD.DiscountValue, TD.DiscountPercentage,@TaxAmount AS TotalTax,TD.UnitPrice * TD.Quantity AS GRossTotal,
				(UnitPrice - @ItemTotal)*Quantity AS TotalDiscount, (((TD.UnitPrice * TD.Quantity)-(UnitPrice - @ItemTotal)*Quantity)+@TaxAmount) AS NetTotal,@TotalCharges
				,@tempDate TransactionDate,
				ISNULL(dbo.FN_GetLastGRNPrice_SupplierWise(@LocationId, TD.StockItemID,@SupplierID),0) AS LastGRNPrice   -- Added By Ravindu 225-12-02
				,(SELECT DISTINCT [Id], [Name]
					FROM #UnitConversionList
					FOR JSON PATH) AS UnitConversion
					,TxnUnitId
				FROM #tempItemDetails TD
				INNER JOIN Units U ON U.Id = TD.TxnUnitId
				INNER JOIN StockItemHeaders SH ON SH.Id = TD.StockItemID
				WHERE SH.ID= @StockItemID AND TD.RowNo = @RowNo --RowNo added 2026-10-07 -- Added by Isuru 2026-02-13 to fix incorrect items inserting in temp table
				set @TaxAmount=0

			drop table #TaxTable
			DELETE FROM #tempItemDetails --modified 2026-10-07: delete exactly the processed line
			WHERE RowNo = @RowNo

			DELETE FROM #UnitConversionList
			END
		END
		IF(@TransactionType = 'AA') --Added by Nivesh 2024-03-16
		BEGIN
			SELECT * FROM  #AllData
		END
		ELSE
		BEGIN
			SELECT * FROM  #AllData where GRNQty > 0
		END
		
		-- CLEANUP (correct place)
		IF @iDocID IS NOT NULL
			EXEC sp_xml_removedocument @iDocID;

		IF @iDocIDORG IS NOT NULL
			EXEC sp_xml_removedocument @iDocIDORG;
		--SELECT @ValueOfRequest = UnitPrice * Quantity FROM #tempItemDetails





END TRY
BEGIN CATCH
	    IF @iDocID IS NOT NULL
        EXEC sp_xml_removedocument @iDocID;

    IF @iDocIDORG IS NOT NULL
        EXEC sp_xml_removedocument @iDocIDORG;

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

