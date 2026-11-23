

-- [dbo].[SP_AjustMonthlyReconcellation] 1,8337,'2025-06-30',8096


CREATE PROCEDURE [dbo].[SP_AjustMonthlyReconcellation]
    (
      @locationId INT,
      @StockItemID INT,
      @txnDate DATETIME,
      @newTransactionHeaderID BIGINT
    )
AS
    DECLARE @NewQuantity DECIMAL(18,6) ,
        @NewAveragePrice DECIMAL(18,6) ,
        @lastTransactionHeaderID BIGINT ,
        @TransactionDetailId BIGINT ,
        @curQuantity DECIMAL(18,6) ,
        @Variance DECIMAL(18,6) ,
        @varyqty DECIMAL(18,6), @VarianceHeaderID INT=-1, @propertyID INT
    DECLARE @CountCost DECIMAL(18,6)  --Added by Isuru 2026-10-09 Reason: cost of the count adjustment (average on the count date, or entered price when stock on the date <= 0)
	

	SELECT @propertyid=CompanyID FROM Locations 
	WHERE Id = @locationId

    SELECT TOP (1)
            @NewQuantity = NewQuantity ,
            @NewAveragePrice = NewAveragePrice
    FROM    StockTransactionDetails sd
            INNER JOIN StockTransactionHeaders sh ON sd.StockTransactionHeaderID = sh.Id
    WHERE   sh.LocationID = @locationId
            AND StockItemID = @StockItemID
            AND sh.TransactionDate <= @txnDate
            AND sh.Id <> @newTransactionHeaderID
	--ORDER BY sh.TransactionDate DESC, sh.CreatedDate DESC
	ORDER BY sh.TransactionDate DESC, sd.Id DESC


    CREATE TABLE #UpdateList
        (
          TransactionDetailId BIGINT
        )

    INSERT  INTO #UpdateList
    SELECT  sd.Id
    FROM    StockTransactionDetails sd
    INNER JOIN StockTransactionHeaders sh ON sd.StockTransactionHeaderID = sh.Id
    WHERE   sh.LocationID = @locationId
            AND StockItemID = @StockItemID
            AND sh.TransactionDate > @txnDate
            AND sh.Id <> @newTransactionHeaderID


    SET @Variance = 0
	
	SET @NewQuantity= ISNULL(@NewQuantity,0)
	SET @NewAveragePrice= ISNULL(@NewAveragePrice,0)

    IF @NewQuantity IS NOT NULL
        BEGIN

	-----for checking added by umesh ------

		
			DECLARE @Difference DECIMAL(18,6)

			SELECT  @Difference = ( NewQuantity - @NewQuantity )
			FROM    dbo.StockTransactionDetails
			WHERE   StockTransactionHeaderID = @newTransactionHeaderID
					AND StockItemID = @StockItemID

            --Added by Isuru 2026-10-09 Reason: a backdated count that lowers stock must not push any later transaction below zero
            --(item 477: later rows were shifted to -1,992,700 and the XX average divided by it). Checked before anything is written.
            IF @Difference < 0 AND EXISTS (SELECT 1 FROM dbo.StockTransactionDetails sdc
                                           INNER JOIN #UpdateList ul ON ul.TransactionDetailId = sdc.Id
                                           WHERE sdc.NewQuantity + @Difference < 0)
            BEGIN
                DECLARE @NegItemName VARCHAR(500)
                SELECT @NegItemName = Name FROM dbo.StockItemHeaders WITH (NOLOCK) WHERE Id = @StockItemID
                RAISERROR('Reconciliation cancelled: this backdated count makes later stock negative for %s. Correct the later transactions or use a later count date.', 16, 1, @NegItemName);
                RETURN;
            END
            --End of added by Isuru 2026-10-09

			UPDATE  dbo.StockItemDetails
			SET     QuantityInHand = QuantityInHand + ( @Difference )
			WHERE   StockItemHeaderID = @StockItemID
					AND LocationID = @locationId

	-----------------------

		DECLARE @TxnType AS CHAR(1) 


		
 


 
            UPDATE  StockTransactionDetails
            SET     Quantity = ABS(NewQuantity - @NewQuantity) ,
                    TxnType = CASE WHEN ( NewQuantity - @NewQuantity ) < 0
                                   THEN 'M'
                                   ELSE 'P'
                              END,
					@TxnType =  CASE WHEN ( NewQuantity - @NewQuantity ) < 0
                                   THEN 'M'
                                   ELSE 'P'
                              END,
                    --Commented by Isuru 2026-10-09 Reason: weighted formula used the seeded Quantity and treated a stock loss as a receipt (wrong day-end GL = UnitPrice x Quantity)
                    --UnitPrice = CASE
                    --WHEN @NewQuantity < 0 THEN @NewAveragePrice    -- prior stock negative: keep last average added by Isuru 2026-07-27
                    --WHEN @NewQuantity=0 OR (@NewQuantity+ Quantity) =0  THEN UnitPrice
                    --ELSE (( @NewAveragePrice * @NewQuantity) + (Quantity * UnitPrice) ) / (@NewQuantity+ Quantity) END ,
                    --Added by Isuru 2026-10-09 Reason: UnitPrice = value of the adjustment per unit, so day-end GL equals the real change in stock value
                    UnitPrice = CASE
                    WHEN @NewQuantity > 0 THEN @NewAveragePrice                       -- normal: adjustment at the average on the count date
                    WHEN NewQuantity = @NewQuantity THEN UnitPrice                    -- no adjustment
                    ELSE ROUND(ABS(NewQuantity * CASE WHEN NewQuantity > 0 AND UnitPrice > 0 THEN UnitPrice ELSE @NewAveragePrice END
                                   - @NewQuantity * @NewAveragePrice) / ABS(NewQuantity - @NewQuantity), 6) END ,   -- stock on the date <= 0
                    --End of added by Isuru 2026-10-09
					
					StockMasterQuantity = @NewQuantity, 
                    @curQuantity = Quantity ,
                    --Commented by Isuru 2026-10-09 Reason: Quantity here is the seeded |counted - TODAY's stock|, so @varyqty / @Variance mixed two different dates
                    --@Variance = ( Quantity - @NewQuantity ) * CASE WHEN @NewQuantity=0 THEN UnitPrice ELSE  @NewAveragePrice END ,
                    --@varyqty = ( Quantity - @NewQuantity ),
                    --Added by Isuru 2026-10-09 Reason: use the date-based difference (NewQuantity = counted, @NewQuantity = stock on the count date)
                    @CountCost = CASE WHEN @NewQuantity > 0 THEN @NewAveragePrice WHEN UnitPrice > 0 THEN UnitPrice ELSE @NewAveragePrice END ,
                    @Variance = ( NewQuantity - @NewQuantity ) * CASE WHEN @NewQuantity > 0 THEN @NewAveragePrice WHEN UnitPrice > 0 THEN UnitPrice ELSE @NewAveragePrice END ,
                    @varyqty = ( NewQuantity - @NewQuantity ),
                    --End of added by Isuru 2026-10-09
					
                    --Commented by Isuru 2026-10-09 Reason: same weighted formula as UnitPrice above
                    --NewAveragePrice = CASE
                    --WHEN @NewQuantity < 0 THEN @NewAveragePrice    -- prior stock negative: keep last average added by Isuru 2026-07-27
                    --WHEN @NewQuantity=0 OR (@NewQuantity+ Quantity) =0 THEN UnitPrice
                    --ELSE (( @NewAveragePrice * @NewQuantity) + (Quantity * UnitPrice) ) / (@NewQuantity+ Quantity) END
                    --Added by Isuru 2026-10-09 Reason: a count does not change the average; only new stock counted from zero/negative takes the entered price
                    NewAveragePrice = CASE WHEN @NewQuantity > 0 OR NewQuantity <= 0 OR UnitPrice <= 0 THEN @NewAveragePrice ELSE UnitPrice END
                    --End of added by Isuru 2026-10-09

            WHERE   StockTransactionHeaderID = @newTransactionHeaderID
                    AND StockItemID = @StockItemID


		
		--Added by Isuru 2025-10-15 to fix if same day reconcil multiple items to fix avg price not updating issue

			UPDATE  dbo.StockItemDetails
			SET     AveragePrice = dbo.[FN_GetLastAveragePrice](@LocationID,@StockItemID)
			WHERE   StockItemHeaderID = @StockItemID
					AND LocationID = @locationId

		--end


			DECLARE @CheckDiff DECIMAL(18,6),@CheckItemName VARCHAR(MAX)

            WHILE ( SELECT  COUNT(*)
                    FROM    #UpdateList
                  ) > 0
                BEGIN
		
                    SELECT TOP ( 1 )
                            @TransactionDetailId = TransactionDetailId
                    FROM    #UpdateList
                    ORDER BY TransactionDetailId

				
				--Added by Isuru 2025-07-21 to validate stock Minus update issue
					SELECT @CheckDiff = NewQuantity + (@Difference)
					FROM StockTransactionDetails WITH (NOLOCK)
					WHERE Id = @TransactionDetailId

					SELECT @CheckItemName = NAME
					FROM StockItemHeaders WITH (NOLOCK)
					WHERE ID = @StockItemID

					IF (@CheckDiff < 0 AND @Difference < 0)   --Changed by Isuru 2026-10-09: only block counts that reduce stock
					BEGIN
						RAISERROR('Reconciliation Cancelled due to Minus value Update for %s', 16, 1, @CheckItemName);
						RETURN;   --Changed by Isuru 2026-10-09: RETURN instead of ROLLBACK; the caller's CATCH rolls back the whole save
					END
				--End

		
					UPDATE  StockTransactionDetails
                    SET     NewQuantity = NewQuantity+(@Difference)
					,StockMasterQuantity = StockMasterQuantity + (@Difference) --Added by Isuru 2026-09-15 to update StockMasterQuantity with 'AA'
                    WHERE   Id = @TransactionDetailId 



		--For checking --------------------------------------------------------------------

                    SELECT  @curQuantity + ( CASE WHEN TxnType = 'M' THEN -1
                                                  ELSE 1
                                             END * Quantity ) AS newqtyinloop
                    FROM    StockTransactionDetails
                    WHERE   Id = @TransactionDetailId 


		------------------------------------------------------------------------------------
		
                    DELETE  FROM #UpdateList
                    WHERE   TransactionDetailId = @TransactionDetailId
				
                END 
	
        END 



    DECLARE @LastRecored BIGINT

--if @Variance <> 0 
select @varyqty varyqty 

    IF @varyqty <> 0
        BEGIN
		--PRINT '@varyqty <> 0'
			
			IF (@VarianceHeaderID=-1)
			BEGIN
				
				declare @DocumentNo varchar(100), @TransactionType char(2)='XX'
				declare @NextNo varchar(20), @LocCode varchar(20), @CountDocNo varchar(100)   --added by Isuru 2026-10-19 Reason: XX number LOC/XX/nnnnnn and link to the count

				SELECT TOP ( 1 )
				@LastRecored = sd.Id
				FROM    StockTransactionDetails sd
				INNER JOIN StockTransactionHeaders sh ON sd.StockTransactionHeaderID = sh.Id
				WHERE   sh.LocationID = @locationId
				AND StockItemID = @StockItemID
				AND sh.TransactionDate > @txnDate
				AND NewQuantity <> 0
                --ORDER BY sd.Id DESC   --Commented by Isuru 2026-10-09 Reason: highest Id is not always the latest row (backdated rows)
                ORDER BY sh.TransactionDate DESC, sd.Id DESC   --Added by Isuru 2026-10-09

			

				IF @LastRecored IS NOT NULL
				BEGIN

					--added by Isuru 2026-10-19 Reason: the number was never increased (every XX was 000001);
					--take the next number, increase it, and format it like other documents: <location code>/XX/<number>
					SET @NextNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);
					IF @NextNo IS NULL
					BEGIN
						INSERT INTO TransactionTypeWiseNextNumbers (PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
						VALUES (@PropertyID, @LocationID, @TransactionType, 1, 6);
						SET @NextNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @TransactionType);
					END;

					UPDATE TransactionTypeWiseNextNumbers
					SET    NextNumber = NextNumber + 1
					WHERE  PropertyID = @PropertyID AND LocationID = @LocationID AND TransactionType = @TransactionType;

					SELECT @LocCode = Code FROM Locations WHERE Id = @LocationID;
					SELECT @CountDocNo = DocumentNo FROM StockTransactionHeaders WHERE Id = @newTransactionHeaderID;
					SET @DocumentNo = @LocCode + '/XX/' + @NextNo;

					--changed by Isuru 2026-10-19 Reason: ReferenceNo / ReferenceID point to the count (AA) that created this XX
					INSERT INTO StockTransactionHeaders (DocumentNo, TransactionType, TransactionDate, PropertyID, LocationID, ReferenceNo, SupplierID, Remarks,
					ReferenceID, DepartmentID, UserProfileID,TransferLocationID, TimeStamp, TransactionID, Mode,SuppCurrencyID,ExchangeRate, CreatedUserID, LastModUserID,CreatedDate,LastModDate)
					SELECT @DocumentNo, @TransactionType, GETDATE(), PropertyID, LocationID, @CountDocNo, SupplierID, Remarks,
					@newTransactionHeaderID, DepartmentID, UserProfileID,TransferLocationID, TimeStamp, 20, CASE WHEN @Variance <0 THEN 'M' ELSE 'P' END ,SuppCurrencyID,ExchangeRate,  CreatedUserID, LastModUserID,GETDATE(),GETDATE()
					FROM StockTransactionHeaders
					WHERE ID= @newTransactionHeaderID

					SET @VarianceHeaderID = SCOPE_IDENTITY ()
				END 
			END 

			
			

			INSERT INTO StockTransactionDetails
			(
				StockTransactionHeaderID,
				StockItemID,
				Quantity,
				UnitPrice,
				TxnUnitID,
				MasterUnitID,
				MasterUnitConversion,
				ReportUnitID,
				ReportUnitConversion,
				DiscountValue,
				DiscountPercentage,
				StockMasterQuantity,
				StockMasterAveragePrice,
				NewQuantity,
				NewAveragePrice,
				Remarks,
				UserProfileId,
				CostTransactionAccountID,
				PurchaseTransactionAccountID,
				TxnType,
				ItemUnitPriceInSuppCurrency,
				BalanceQuantity,
				ReturnQuantity,
				CreatedUserID,
				LastModUserID,
				CreatedDate,
				LastModDate
			)

			SELECT @VarianceHeaderID,
				StockItemID,
				0,
				0,
				TxnUnitID,
				MasterUnitID,
				MasterUnitConversion,
				ReportUnitID,
				ReportUnitConversion,
				DiscountValue,
				DiscountPercentage,
				StockMasterQuantity + ( CASE WHEN TxnType='M' THEN -1 ELSE  1 END * Quantity ) ,
				--StockMasterAveragePrice, --Commented by Isuru 2026-10-19
				NewAveragePrice,   --changed by Isuru 2026-10-19 Reason: average before the XX
				NewQuantity,
				--(NewAveragePrice * (NewQuantity - @varyqty) / NewQuantity)+  (@Variance /NewQuantity), 
				--Commented by Isuru 2026-07-27 to fix (-) price inserting in XX transactions
                --Commented by Isuru 2026-10-09 Reason: divides by the later quantity even when it is 0 or tiny, and extrapolates on a stock loss (gave 1433.856259)
                --CASE
                --WHEN NewQuantity < 0 THEN NewAveragePrice
                --WHEN ((NewAveragePrice*(NewQuantity-@varyqty)/NewQuantity)+(@Variance/NewQuantity)) < 0 THEN NewAveragePrice
                --ELSE (NewAveragePrice*(NewQuantity-@varyqty)/NewQuantity)+(@Variance/NewQuantity) END AS NewAveragePrice,
                --Added by Isuru 2026-10-09 Reason: bounded average - result always lies between the current average and the count cost
                CASE
                WHEN NewQuantity <= 0 THEN NewAveragePrice                  -- no positive stock after the count: keep the average
                WHEN NewQuantity - @varyqty <= 0 THEN @CountCost            -- stock before the count was 0/negative: all stock now at the count cost
                WHEN @varyqty < 0 THEN NewAveragePrice                      -- stock loss: valued in the count row (GL), average unchanged
                ELSE (NewAveragePrice*(NewQuantity-@varyqty)/NewQuantity)+(@Variance/NewQuantity) END AS NewAveragePrice,   -- gain: weighted average
                --End of added by Isuru 2026-10-09
				--Added by Isuru 2026-07-27
				Remarks,
				UserProfileId,
				CostTransactionAccountID,
				PurchaseTransactionAccountID,
				TxnType,
				ItemUnitPriceInSuppCurrency,
				BalanceQuantity,
				ReturnQuantity,
				CreatedUserID,
				LastModUserID,
				GETDATE(),
				GETDATE()
				FROM StockTransactionDetails
				WHERE ID =@LastRecored

			


			DECLARE @AvgPrice DECIMAL(18,6) 
			select SCOPE_IDENTITY ()  [SCOPE_IDENTITY]


			

			IF SCOPE_IDENTITY () IS NOT NULL
			BEGIN
				select  @AvgPrice = isnull(NewAveragePrice,0)
				FROM StockTransactionDetails
				WHERE ID =SCOPE_IDENTITY ()

				--------added----------
				IF @AvgPrice IS NULL 
					SET @AvgPrice = 0
				--------added----------
				--SELECT @AvgPrice AvgPrice
			END 
			ELSE
			BEGIN
				select  @AvgPrice = isnull(NewAveragePrice,0)
				FROM StockTransactionDetails D 
				INNER JOIN StockTransactionHeaders H ON H.ID= D.StockTransactionHeaderID 
				WHERE H.ID =@newTransactionHeaderID AND D.StockItemID= @StockItemID

				SELECT D.*
				FROM StockTransactionDetails D 
				INNER JOIN StockTransactionHeaders H ON H.ID= D.StockTransactionHeaderID 
				WHERE H.ID =@newTransactionHeaderID AND D.StockItemID= @StockItemID



				--SELECT @AvgPrice AvgPrice2
			END 

			--PRINT '@AvgPrice'+convert(varchar,isnull(@AvgPrice,-999))

            --UPDATE  StockTransactionDetails
            --SET     NewAveragePrice = NewAveragePrice + ( @Variance / NewQuantity )
            --WHERE   Id = @LastRecored
			--Added by Isuru 2026-07-27 to prevent (-) avg price updating
			IF @AvgPrice < 0
			BEGIN
				SET @AvgPrice = @NewAveragePrice
			END

            UPDATE  StockItemDetails
            SET     AveragePrice = @AvgPrice
            WHERE   StockItemId = @StockItemID AND LocationID = @locationId



		--Added by isruru to monitor reconcilation issues 2024-10-16
			INSERT INTO AjustMonthlyReconcellation_LogTable(locationId, StockItemID, txnDate, newTransactionHeaderID, NewQuantity, NewAveragePrice, Difference, Variance, varyqty, LastRecored)
			SELECT @locationId,@StockItemID,@txnDate,@newTransactionHeaderID,@NewQuantity,@NewAveragePrice,@Difference,@Variance,@varyqty,@LastRecored
		--	end
 


			

		--PRINT 'sdsadasd'
        END
		
		---added 2018-12-18

		select @NewQuantity NewQuantity
		IF @NewQuantity IS NULL
		BEGIN
		
		
            SELECT  @Difference = ( Quantity - StockMasterQuantity )
            FROM    dbo.StockTransactionDetails
            WHERE   StockTransactionHeaderID = @newTransactionHeaderID
                    AND StockItemID = @StockItemID


            UPDATE  dbo.StockItemDetails
            SET     QuantityInHand = QuantityInHand + ( @Difference )
            WHERE   StockItemHeaderID = @StockItemID
                    AND LocationID = @locationId

		   UPDATE dbo.StockTransactionDetails 
		   SET Quantity=ABS(@Difference) 
		   WHERE StockTransactionHeaderID=@newTransactionHeaderID 
		   AND StockItemID=@StockItemID
		
		
		END

GO

