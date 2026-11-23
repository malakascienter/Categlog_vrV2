CREATE FUNCTION [dbo].[FN_GetAveragePrice]
    (
      @PropertyID INT ,
      @LocationID INT ,
      @StockItemID INT ,
      @TransactionType CHAR(2) ,
      @Quantity DECIMAL(18,6) ,
      @unitID INT ,
      @UnitPrice  DECIMAL(18,6)
    )
RETURNS  DECIMAL(18,6)
AS
    BEGIN
        DECLARE @currentAveragePrice  DECIMAL(18,6) ,
            @currentQuantityInHand  DECIMAL(18,6) ,
            @MasterUnitID INT

        SELECT  @currentAveragePrice = dbo.[FN_GetLastAveragePrice](@LocationID,@StockItemID) ,
                @currentQuantityInHand = QuantityInHand ,
                @MasterUnitID = MasterUnitID
        FROM    StockItemDetails
        WHERE   PropertyID = @PropertyID
                AND LocationID = @LocationID
                AND StockItemHeaderID = @StockItemID


		--SELECT TOP(1) @currentQuantityInHand =  D.NewQuantity,@currentAveragePrice = D.NewAveragePrice
		--FROM dbo.StockTransactionDetails AS D
		--INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
		--INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
		--INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationID -- AND IH.LocationId = ID.LocationID
		--INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
		--WHERE IH.Id = @StockItemId AND H.LocationID = @LocationID and h.PropertyID = @propertyId
		--ORDER BY H.TransactionDate DESC ,D.CreatedDate DESC,D.Id DESC

		SET @currentQuantityInHand = ISNULL(@currentQuantityInHand,0)
		--SET @currentAveragePrice = ISNULL(@currentAveragePrice,0)

	    -- Removed by Isuru 2026-07-23:
        -- Previously negative stock was forced to 0, which made the weighted-average
        -- formula collapse to @UnitPrice and let a single (possibly wrong) receipt
        -- overwrite the average while stock was negative. Negative stock is now handled
        -- explicitly by Guard A / Guard B below.
		--Added by Isuru 2025-01-07 for returning 0 value if Current Qty in Hand is minus value
		--IF (@currentQuantityInHand <0)
		--BEGIN
		--	SET @currentQuantityInHand =0
		--END
		--End

        IF @currentAveragePrice IS NULL
            RETURN ISNULL(@UnitPrice,0)

        IF @currentAveragePrice = 0
            AND @UnitPrice = 0
            RETURN 0

        IF @currentQuantityInHand = 0
            AND @Quantity = 0
            RETURN 0
          -- I/R added by Isuru 2026-03-13 by ArunaD,Budhdhika Instructions
          --'PU' added by Isuru 2026-08-19 by ArunaD Instructions
        IF @TransactionType NOT IN ( 'GR', 'SR', 'TI','IR','PU' )           
            RETURN @currentAveragePrice

        IF @TransactionType IN ( 'SR', 'DN', 'IN', 'TO', 'AAM', 'II','IF','PI' )
            SET @Quantity = @Quantity * -1


        --RETURN  @MasterUnitID

        
        --RETURN  @MasterUnitID

		--IF (@currentQuantityInHand+(1.0000*@Quantity * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID)))<=0
		--	RETURN 	@UnitPrice

             --------------------------------------------------------------------------
        -- Guard A (Isuru 2026-07-23): stock is negative and STAYS negative (or hits 0)
        -- after this transaction -> do NOT touch the average, keep the last good one.
        -- (Prevents a bad/oversell situation from resetting the average price.)
        --------------------------------------------------------------------------
        IF (@currentQuantityInHand + (1.0000 * @Quantity * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID))) <= 0
            RETURN @currentAveragePrice

        --------------------------------------------------------------------------
         -- Crossover (Isuru 2026-07-23): stock was negative but this receipt brings it positive.
        -- Zero the negative qty so the formula restarts cleanly at the receipt price (@UnitPrice/rate),
        -- instead of feeding the unreliable negative qty into the weighted average.
        -- Must stay AFTER Guard A, so it only affects the crossover case.
        IF (@currentQuantityInHand < 0)
        BEGIN
            SET @currentQuantityInHand = 0
        END
 
       -- RETURN 	((1.0000*@currentAveragePrice * @currentQuantityInHand)+ (1.0000*@Quantity* @UnitPrice * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID)))/ (@currentQuantityInHand+(1.0000*@Quantity * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID))) -- * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID) removed by isuru 2024-09-30 for average price calculation

    RETURN 	((1.0000*@currentAveragePrice * @currentQuantityInHand)+ (1.0000*@Quantity* @UnitPrice ))/ (@currentQuantityInHand+(1.0000*@Quantity * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID)))

	END

GO

