CREATE FUNCTION [dbo].[FN_CAL_AveragePrice]
    (
      @PropertyID INT ,
      @LocationID INT ,
      @StockItemID INT ,
      @TransactionType CHAR(2) ,
      @Quantity DECIMAL(18,6) ,
      @unitID INT ,
      @UnitPrice  DECIMAL(18,6),
	  @currentAveragePrice  DECIMAL(18,6) ,
	  @currentQuantityInHand  DECIMAL(18,6) ,
      @MasterUnitID INT
    )
RETURNS  DECIMAL(18,6)
AS
    BEGIN

	 IF @TransactionType IN ( 'XX')
		  RETURN ISNULL(@currentAveragePrice,0)

	 IF @TransactionType IN ( 'AA')
		  RETURN ISNULL(@UnitPrice,0)
        
        IF @currentAveragePrice IS NULL
            RETURN @UnitPrice

        IF @currentAveragePrice = 0
            AND @UnitPrice = 0
            RETURN 0

        IF @currentQuantityInHand = 0
            AND @Quantity = 0
            RETURN 0

        IF @TransactionType NOT IN ( 'GR', 'SR', 'TI' )
            RETURN @currentAveragePrice

        IF @TransactionType IN ( 'SR', 'DN', 'IN', 'TO', 'AAM', 'II','IF' )
            SET @Quantity = @Quantity * -1



        --RETURN  @MasterUnitID

		IF (@currentQuantityInHand+(1.0000*@Quantity * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID)))<=0
			RETURN 	@UnitPrice

        RETURN 	((1.0000*@currentAveragePrice * @currentQuantityInHand)+ (1.0000*@Quantity* @UnitPrice * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID)))/ (@currentQuantityInHand+(1.0000*@Quantity * dbo.FN_GetUnitConvertionRate(@PropertyId,@unitID, @MasterUnitID)))
		
    END

GO

