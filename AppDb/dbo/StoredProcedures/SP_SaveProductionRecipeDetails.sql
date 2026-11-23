
CREATE PROCEDURE [dbo].[SP_SaveProductionRecipeDetails](@XMLData XMl)
AS

insert into tempProductionXML (XmlDATA)
select convert(varchar(max),  @XMLData)

BEGIN
	BEGIN TRY

	BEGIN TRANSACTION;

		DECLARE @HeaderId BIGINT;
		DECLARE @iDocID INT;
		DECLARE @XMLHeaderPU XML; DECLARE @XMLDataPU XML;
		DECLARE @XMLHeaderPI XML; DECLARE @XMLDataPI XML;
		DECLARE @PropertyID INT;                        --Added Tharuka 2026-07-17--
		DECLARE @IsProductionWithoutRecipe BIT;         --Added 2026-07-17--
		DECLARE @HasRecipeItems BIT;                    --Added 2026-07-17--

        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLData;

		SELECT * INTO #DataHeader
		 FROM
            OPENXML(@iDocID, 'ArrayOfRecipeTxnModel/RecipeTxnModel', 2)
            WITH(
			TransactionType NVARCHAR(5),
			PropertyID INT,
			LocationID INT,
			Remarks NVARCHAR(250),
			UserProfileID INT,
			CreatedUserID INT,
			LastModUserID INT,
			Mode CHAR(1),
			SupplierID INT,
			ReferenceID INT,
			DepartmentID INT,
			TransferLocationID INT,
			SuppCurrencyID INT,
			isExpiryDateApplicable BIT,
			EXPDate DATETIME
			)

			SELECT * INTO #DataDetails
		 FROM
            OPENXML(@iDocID, 'ArrayOfRecipeTxnModel/RecipeTxnModel/RecipeItemDetails/StockTransactionDetail', 2)
            WITH(
			CreatedUserID INT,
			LastModUserID INT,
			StockItemID INT,
			Quantity DECIMAL(18,6),
			MasterUnitID INT,
			UserProfileId INT,
			TxnType NVARCHAR(50),
			UnitPrice DECIMAL(18,6),
			TxnUnitID INT,
			DiscountValue DECIMAL(18,6),
			DiscountPercentage DECIMAL(18,6),
			BalanceQuantity DECIMAL(18,6),
			ReturnQuantity DECIMAL(18,6),
			QuantityInHand DECIMAL(18,6),
			isExpiryDateApplicable BIT,
			EXPDate DATETIME

			)

			-- Added 2026-07-17: decide whether this production consumes a recipe

			SELECT TOP 1 @PropertyID = PropertyID FROM #DataHeader;

			SELECT @IsProductionWithoutRecipe = ISNULL(IsProductionWithoutRecipe,0)
			FROM Companies
			WHERE CompanyID = @PropertyID;


			SET @HasRecipeItems =
				CASE
					WHEN EXISTS (SELECT 1 FROM #DataHeader  WHERE TransactionType = 'PI')
					 AND EXISTS (SELECT 1 FROM #DataDetails WHERE TxnType = 'M')
					THEN 1
					ELSE 0
				END;

			IF (@HasRecipeItems = 0 AND ISNULL(@IsProductionWithoutRecipe,0) = 0)
			BEGIN
				RAISERROR ('Production without a recipe cannot save.',16,1);
			END

			IF NOT EXISTS (SELECT 1 FROM #DataDetails WHERE TxnType = 'P')
			BEGIN
				RAISERROR ('No production item was supplied.',16,1);
			END
			-------------------------------------------------------------------

			--select * from #DataHeader
			--select * from #DataDetails



			-------------------------------------------------------------------
			-- Added 2026-08-06: raw-material validation for the PI leg.
			--
			-- SP_InsertStockTransactions only runs its "Cannot exceed quantity
			-- in hand!" check for @TransactionType IN ('IN','TO','DN','SR'), so
			-- the 'PI' consumption leg was never validated server-side.
			--
			-- #DataDetails.QuantityInHand arrives from the client and is
			-- deliberately IGNORED - availability is read from StockItemDetails
			-- so a forged payload cannot inflate it.
			-------------------------------------------------------------------
			IF (@HasRecipeItems = 1)
			BEGIN
				DECLARE @PILocationID INT;
				DECLARE @NoConvItems  NVARCHAR(MAX);
				DECLARE @ShortItems   NVARCHAR(MAX);
				DECLARE @StockError   NVARCHAR(MAX);

				SELECT TOP 1 @PILocationID = LocationID
				FROM #DataHeader
				WHERE TransactionType = 'PI';

				-- One row per recipe line, carrying the rate that converts the
				-- line's txn unit into the unit QuantityInHand is stored in.
				-- FN_GetUnitConvertionRate returns -1 when none is defined.
				SELECT
					D.StockItemID,
					D.TxnUnitID,
					ISNULL(D.Quantity, 0) AS Quantity,
					dbo.FN_GetMasterUnitID(@PropertyID, @PILocationID, D.StockItemID) AS MasterUnitID,
					ISNULL(dbo.FN_GetUnitConvertionRate(
						@PropertyID,
						D.TxnUnitID,
						dbo.FN_GetMasterUnitID(@PropertyID, @PILocationID, D.StockItemID)
					), -1) AS ConvRate
				INTO #RawLines
				FROM #DataDetails D
				WHERE D.TxnType = 'M';

				-- Collapse to one row per item. Summing matters: two lines of 6
				-- for the same item would each pass a per-row check against 10
				-- in hand, but together they need 12.
				SELECT
					L.StockItemID,
					MIN(L.ConvRate)              AS MinConvRate,
					SUM(L.Quantity * L.ConvRate) AS RequiredQty,
					MAX(L.MasterUnitID)          AS MasterUnitID,
					MAX(CASE WHEN L.ConvRate <= 0 THEN L.TxnUnitID END) AS BadUnitID
				INTO #RawRequired
				FROM #RawLines L
				GROUP BY L.StockItemID;

				-- Availability resolved by subquery rather than a join so a
				-- duplicate StockItemDetails row cannot fan out the rows above.
				-- No row for this location means the item is not stocked here.
				SELECT
					R.StockItemID,
					R.MinConvRate,
					R.RequiredQty,
					R.MasterUnitID,
					R.BadUnitID,
					ISNULL((SELECT MAX(SD.QuantityInHand)
							FROM StockItemDetails SD
							WHERE SD.StockItemHeaderID = R.StockItemID
							  AND SD.LocationID = @PILocationID), 0) AS AvailableQty
				INTO #RawStockCheck
				FROM #RawRequired R;

				---------------------------------------------------------------
				-- Check 1: unit conversion must exist.  Runs first because a -1
				-- rate makes RequiredQty negative, which would otherwise sail
				-- through the quantity check below.
				--
				-- Detection is a plain EXISTS over #RawStockCheck.  It must NOT
				-- depend on the StockItemHeaders join: an item id absent from
				-- StockItemHeaders would be dropped by an INNER JOIN and escape
				-- the check.  The joins below are LEFT and only build the text.
				---------------------------------------------------------------
				IF EXISTS (SELECT 1 FROM #RawStockCheck WHERE MinConvRate <= 0)
				BEGIN
					SELECT @NoConvItems = STUFF((
						SELECT ', ' + ISNULL(RTRIM(SH.Name), 'StockItemID ' + CONVERT(NVARCHAR(20), C.StockItemID))
									+ ISNULL(' (recipe unit ' + RTRIM(BU.Name) + ')', '')
						FROM #RawStockCheck C
						LEFT JOIN StockItemHeaders SH ON SH.Id = C.StockItemID
						LEFT JOIN Units           BU ON BU.Id = C.BadUnitID
						WHERE C.MinConvRate <= 0
						ORDER BY ISNULL(SH.Name, 'StockItemID ' + CONVERT(NVARCHAR(20), C.StockItemID))
						FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

					SET @StockError = 'Unit conversion not found for: ' + ISNULL(@NoConvItems, '');
					RAISERROR (@StockError, 16, 1);
				END

					---------------------------------------------------------------
				-- Check 2: requested quantity must not exceed quantity in hand.
				-- Both figures are in the item's master unit, so the unit name is
				-- spelled out - the operator may have typed GRAM while the item
				-- is stocked in KILOGRAM.
				---------------------------------------------------------------
				IF EXISTS (SELECT 1 FROM #RawStockCheck WHERE AvailableQty < RequiredQty)
				BEGIN
					SELECT @ShortItems = STUFF((
						SELECT ', ' + ISNULL(RTRIM(SH.Name), 'StockItemID ' + CONVERT(NVARCHAR(20), C.StockItemID))
							 + ' (in hand '  + CONVERT(NVARCHAR(50), CONVERT(DECIMAL(18,3), C.AvailableQty))
							 + ISNULL(' ' + RTRIM(MU.Name), '')
							 + ', required ' + CONVERT(NVARCHAR(50), CONVERT(DECIMAL(18,3), C.RequiredQty))
							 + ISNULL(' ' + RTRIM(MU.Name), '')
							 + ')'
						FROM #RawStockCheck C
						LEFT JOIN StockItemHeaders SH ON SH.Id = C.StockItemID
						LEFT JOIN Units           MU ON MU.Id = C.MasterUnitID
						WHERE C.AvailableQty < C.RequiredQty
						ORDER BY ISNULL(SH.Name, 'StockItemID ' + CONVERT(NVARCHAR(20), C.StockItemID))
						FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '');

					SET @StockError = 'Cannot exceed quantity in hand: ' + ISNULL(@ShortItems, '');
					RAISERROR (@StockError, 16, 1);
				END


				--------------------------------------------------------------------
				-- Cost the produced item at the cost of what it consumed
				-- --added by isuru 2026-08-19
				-- Reason: the PU leg used to be sent with UnitPrice = 0 and was
				--         retro-costed after posting, which ASSIGNED the batch cost
				--         over the running average. Both legs are visible here in
				--         #DataDetails before either one posts, so the batch cost is
				--         computed now and sent as the PU line's UnitPrice. That lets
				--         FN_GetAveragePrice blend it into the moving weighted average
				--         exactly like a GRN.
				--
				-- NOTE on units: UnitPrice must be per TRANSACTION unit, because
				--         FN_GetAveragePrice multiplies it by Quantity, which is also
				--         in transaction units. Do NOT divide by the conversion rate
				--         here - the rate is applied to the denominator only.
				--------------------------------------------------------------------

				DECLARE @BatchCost DECIMAL(18,6);
				DECLARE @PUPropertyID INT;
				DECLARE @PULocationID INT;

				SELECT @BatchCost = ISNULL(SUM(UnitPrice * Quantity), 0)
				FROM #DataDetails WHERE TxnType = 'M';

				SELECT TOP 1 @PUPropertyID = PropertyID, @PULocationID = LocationID
				FROM #DataHeader WHERE TransactionType = 'PU';


				--------------------------------------------------------------------
				-- GUARD - the PRODUCED item must have a usable unit conversion.
				-- --added by isuru 2026-08-19
				-- Reason: Check 1 further up validates the component ('M') lines only.
				--         The produced ('P') line was never checked, and
				--         FN_GetUnitConvertionRate returns -1 - not NULL, not an error -
				--         when no conversion exists between the production unit and the
				--         item's master unit. A negative rate makes FN_GetAveragePrice
				--         DECREASE stock when you produce, and corrupts the average,
				--         silently. 10 of 31 produced item/location pairs on this
				--         database are currently in that state.
				--------------------------------------------------------------------
				DECLARE @BadPUItem INT, @BadPUMsg NVARCHAR(400);

				SELECT TOP 1 @BadPUItem = d.StockItemID
				FROM #DataDetails d
				WHERE d.TxnType = 'P'
				  AND ISNULL(dbo.FN_GetUnitConvertionRate(
				        @PUPropertyID, d.TxnUnitID,
				        dbo.FN_GetMasterUnitID(@PUPropertyID, @PULocationID, d.StockItemID)), -1) <= 0;

				IF @BadPUItem IS NOT NULL
				BEGIN
				SET @BadPUMsg = 'Unit conversion not found for the produced item: '
					+ ISNULL((SELECT TOP 1 RTRIM(Name) FROM StockItemHeaders WHERE Id = @BadPUItem),
					          'StockItemID ' + CONVERT(NVARCHAR(20), @BadPUItem))
					+ '. Define the conversion between the production unit and the item master unit before producing.';
				RAISERROR (@BadPUMsg, 16, 1);
			END

				UPDATE d
				SET d.UnitPrice =
				CASE
				WHEN @BatchCost > 0 AND d.Quantity > 0
				THEN @BatchCost / d.Quantity
				ELSE
				ISNULL(dbo.FN_GetLastAveragePrice(@PULocationID, d.StockItemID), 0)
				* dbo.FN_GetUnitConvertionRate(@PUPropertyID, d.TxnUnitID,
					dbo.FN_GetMasterUnitID(@PUPropertyID, @PULocationID, d.StockItemID))
				END
				FROM #DataDetails d
				WHERE d.TxnType = 'P';



			END
			-------------------------------------------------------------------




			-- PU leg: the produced item. TxnType 'P' increases stock.
			SET @XMLHeaderPU = ( SELECT * FROM #DataHeader WHERE Transactiontype = 'PU' for xml path('StockTransactionHeader'))
			SET @XMLDataPU = (SELECT * FROM #DataDetails WHERE TxnType = 'P'for xml path ('StockTransactionDetail'),root('StockDetailList'))

			SET @XMLHeaderPU.modify('insert sql:variable("@XMLDataPU") as first into (/StockTransactionHeader)[1]')
			--select @XMLHeaderPU
			EXEC SP_InsertStockTransactions @XMLHeaderPU,'',0,'',@HeaderId OUTPUT,0,1

			-- Added 2026-07-17.
			IF (@HasRecipeItems = 1)
			BEGIN
				SET @XMLHeaderPI = ( SELECT * FROM #DataHeader WHERE Transactiontype = 'PI' for xml path('StockTransactionHeader'))
				SET @XMLDataPI = (SELECT * FROM #DataDetails WHERE TxnType = 'M'for xml path ('StockTransactionDetail'),root('StockDetailList'))

				SET @XMLHeaderPI.modify('insert sql:variable("@XMLDataPI") as first into (/StockTransactionHeader)[1]')
				--select @XMLHeaderPI


				-- Replace the value of <ReferenceID>
				SET @XMLHeaderPI.modify('replace value of (/StockTransactionHeader/ReferenceID/text())[1] with sql:variable("@HeaderId")')


				EXEC SP_InsertStockTransactions @XMLHeaderPI,'',0,'',0,0,1
			END

			EXEC sp_xml_removedocument @iDocID;

			COMMIT TRAN; -- Transaction Success!


		--COMMIT TRAN; -- Transaction Success! Commented by isuru 2024-09-10 for preventing skip roll back transactions

    END TRY

    BEGIN CATCH


	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION

	DECLARE @ErrorMessage NVARCHAR(4000);
	DECLARE @ErrorSeverity INT;
	DECLARE @ErrorState INT;
	DECLARE @ErrorProcedure NVARCHAR(4000);

	SELECT
    @ErrorMessage = ERROR_MESSAGE(),
    @ErrorSeverity = ERROR_SEVERITY(),
    @ErrorState = ERROR_STATE(),
	@ErrorProcedure = ERROR_PROCEDURE();
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);


    END CATCH;

END;

GO

