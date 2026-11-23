CREATE PROCEDURE [dbo].[SPP_Save_RateAnalysisDetailsForPackage] 
 --DECLARE PARAMETERS 27
    @Id INT ,                                                 
    @RateAnalysisHeaderID INT ,
    @BoqID INT ,                                         
    @SequNo INT ,
    @LocationID INT ,
    @ItemHeaderID INT ,
    @ItemType NVARCHAR(1) ,
    @UnitID INT ,
    @UnitPrice DECIMAL(18, 2) ,
    @Quantity DECIMAL(18, 2) ,
    @ProfitMarginVal DECIMAL(18, 2) ,
    @OverheadCostVal DECIMAL(18, 2) ,
    @isDisRate BIT ,
    @isProjectspecificSubstituteItem BIT ,
    @DisValue DECIMAL(18, 2) ,
    @IPAddress NVARCHAR(MAX) ,
    @CreatedUserID INT ,
    @LastModUserID INT ,
    @CreatedDate DATETIME ,
    @LastModDate DATETIME ,
    @Action int ,
    @status [INT] OUTPUT ,
    @ProjectID INT ,
    @DeptID INT ,
    @PropertyID INT ,
    @WorkDetailID INT,
	@Currency INT,
	@ExchangeRate Decimal(18,2),
	@PackID INT,
	@PackQty decimal(18,2),
	@PackRate decimal(18,2),
	@PackBreakdownQty decimal(18,2),
	@IsProfitMarg bit,
	@DiscountPercentage Decimal(18,2),
	@ProfitMarginPercentage Decimal(18,2)

	   

AS
    DECLARE @statusIN [INT]
    SET @statusIN = 0;
    BEGIN
        BEGIN TRY
		   
		  select 'action is' , @Action
		

            INSERT  INTO testXml
                    ( val )
            VALUES  ( @Quantity )
            INSERT  INTO testXml
                    ( val )
            VALUES  ( @UnitID )
            BEGIN TRANSACTION

	

	        DECLARE @QQTY DECIMAL(18,2)
			SELECT @QQTY=@Quantity
            DECLARE @MasterUnit INT ,
                @value DECIMAL 
            SELECT  @MasterUnit = MasterUnitID
            FROM    dbo.StockItemDetails
            WHERE   PropertyID = @ProjectID
                    AND LocationID = @LocationID
                    AND StockItemHeaderID = @ItemHeaderID
     
			
            IF @MasterUnit <> @UnitID
                BEGIN
     
                    SELECT TOP ( 1 )
                            @value = Value
                    FROM    dbo.UnitConversions
                    WHERE   FromUnitID = @UnitID
                            AND ToUnitID = @MasterUnit
                            AND CompanyId = @ProjectID

                    SELECT  @UnitID = @MasterUnit
                    SELECT  @Quantity = @Quantity * @value

                END 

            DECLARE @NextNO INT

            SELECT  @NextNO = COUNT(SequNo)
            FROM    dbo.RateAnalysisDetails
            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
            SELECT  @NextNO
            BEGIN
                IF @NextNO = 0 
                    BEGIN
					
                        SELECT  @NextNO = @NextNO + 1
	
                    END 

                ELSE
                    BEGIN
                        SELECT  @NextNO = MAX(SequNo)
                        FROM    dbo.RateAnalysisDetails
                        WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                        SELECT  @NextNO = @NextNO + 1
                    END 
            END 
            SELECT  @NextNO
			
            IF @Action = 1
                BEGIN

                    SELECT  'came to action 1' ,
                            @Action
                    IF EXISTS ( SELECT  *
                                FROM    BOQRateanalysisAllocationDetails
                                WHERE   [ID] = @Id
                                        AND [BOQID] = @BoqID
                                        AND PackID = @PackID )
                        BEGIN
		 --UPDATE THE RECORD 
		 
							SELECT  'If True Part', @Id as id ,@BoqID as boqid , @ItemHeaderID as Itemheadeid
                            DECLARE @Qty DECIMAL ,
                                @QtyAmount DECIMAL ,
                                @WorkdetailQTY DECIMAL

                            SELECT  @Qty = Quantity
                            FROM    dbo.BOQRateanalysisAllocationDetails
                            WHERE   ID = @Id
                            SELECT  @QtyAmount = @Quantity - @Qty


                            UPDATE  BOQRateanalysisAllocationDetails
                            SET     [RateID] = @RateAnalysisHeaderID ,
                                    [SequNo] = @SequNo ,
                                    [Location] = @LocationID ,
                                    [ItemID] = @ItemHeaderID ,
                                    [ItemType] = @ItemType ,
                                    [Unit] = @UnitID ,
                                    [UnitPrice] = @UnitPrice ,
                                    [Quantity] = @Quantity ,
                                    [ProfitMarginVal] = @ProfitMarginVal ,
                                    [OverheadCostVal] = @OverheadCostVal ,
                                    [IsPercentageOrValue] = @isDisRate ,
                                    [isProjectspecificSubstituteItem] = @isProjectspecificSubstituteItem ,
                                    [DiscountValue] = @DisValue ,
                                    [IPAddress] = @IPAddress ,
                                    [CreatedUserID] = @CreatedUserID ,
                                    [LastModUserID] = @LastModUserID ,
                                    [CreatedDate] = @CreatedDate ,
                                    [LastModDate] = @LastModDate,
									[Currency]=@Currency,
									[ExchangeRate]=@ExchangeRate,
									[IsProfitMarg]= @IsProfitMarg,
									[DiscountPercentage]=@DiscountPercentage,
									[ProfitMarginPercentage]=@ProfitMarginPercentage

                            WHERE   [ID] = @Id
                            DECLARE @RateQuantitiyInWork DECIMAL= 0;
                            DECLARE @QtyAmountNew DECIMAL= 0;
                            DECLARE @cnt INT = 0;
                            DECLARE @totalcount INT  = 0;

                            SELECT  @totalcount = COUNT(ID)
                            FROM    dbo.BOQRateanalysisAllocationHeaders

                            SELECT  'cnt' ,
                                    @cnt 
                            SELECT  'Tt' ,
                                    @totalcount 
							
							
                            WHILE @totalcount + 1 > @cnt
								
                                BEGIN
                                    SELECT  'cnt' ,
                                            @cnt 
								

                                    IF EXISTS ( SELECT  *
                                                FROM    dbo.BOQRateanalysisAllocationHeaders
                                                WHERE   ID = @cnt
                                                        AND RateAnalysisID = @RateAnalysisHeaderID )
                                        BEGIN

                                            SELECT  @RateQuantitiyInWork = RateQtyInWork
                                            FROM    dbo.BOQRateanalysisAllocationHeaders
                                            WHERE   ID = @cnt
                                                    AND RateAnalysisID = @RateAnalysisHeaderID

                                            SELECT  @QtyAmountNew = @QtyAmountNew
                                                    + @QtyAmount
                                                    * @RateQuantitiyInWork; 

                                        END
                                    SET @cnt = @cnt + 1
                                END
		
                            --UPDATE  dbo.MRNItemRegistries
                            --SET     BOQQuantity = BOQQuantity + @QtyAmountNew ,
                            --        UnitID = @UnitID ,
                            --        BalanceQuantity = BalanceQuantity
                            --        + @QtyAmountNew ,
                            --        LastModUserID = @LastModUserID ,
                            --        LastModDate = @LastModDate
                            --WHERE   ItemId = @ItemHeaderID
                            --        AND BOQId = @BoqID
                            --        AND DepId = @DeptID
                            --        AND ProjectID = @ProjectID

                            SELECT  @ItemHeaderID ,
                                    @BoqID ,
                                    @DeptID ,
                                    @ProjectID
                            SELECT  @QtyAmountNew
                            SET @statusIN = 2
							
                        END
                    ELSE
                        BEGIN
	--INSERT THE RECORD		
							SELECT  'If False Part' 
                            INSERT  INTO RateAnalysisDetails
                                    ( [RateAnalysisHeaderID] ,
                                      [SequNo] ,
                                      [LocationID] ,
                                      [ItemHeaderID] ,
                                      [ItemType] ,
                                      [UnitID] ,
                                      [UnitPrice] ,
                                      [Quantity] ,
                                      [ProfitMarginVal] ,
                                      [OverheadCostVal] ,
                                      [isDisRate] ,
                                      [isProjectspecificSubstituteItem] ,
                                      [DisValue] ,
                                      [IPAddress] ,
                                      [CreatedUserID] ,
                                      [LastModUserID] ,
                                      [CreatedDate] ,
                                      [LastModDate],
									  [Currency],
									  [ExchangeRate],
									  [PackID],
									  [PackQty],
									  [PackRate],
									  [PackBreakdownQty],
									  [IsProfitMarg],
									  [DiscountPercentage],
									  [ProfitMarginPercentage]

									

		                            )
                            VALUES  ( @RateAnalysisHeaderID ,
                                      @NextNO ,
                                      @LocationID ,
                                      @ItemHeaderID ,
                                      @ItemType ,
                                      @UnitID ,
                                      @UnitPrice ,
                                      @Quantity ,
                                      @ProfitMarginVal ,
                                      @OverheadCostVal ,
                                      @isDisRate ,
                                      @isProjectspecificSubstituteItem ,
                                      @DisValue ,
                                      @IPAddress ,
                                      @CreatedUserID ,
                                      @LastModUserID ,
                                      @CreatedDate ,
                                      @LastModDate,
									  @Currency,
									  @ExchangeRate,
									  @PackID,
									  @PackQty,
									  @PackRate,
									  @PackBreakdownQty,
									  @IsProfitMarg,
									  @DiscountPercentage,
									  @ProfitMarginPercentage
		                            )
                            SELECT  SCOPE_IDENTITY() AS ID
							SELECT  'came to action 1' , 'Else PArt'	,@RateAnalysisHeaderID ,@ItemHeaderID ,  SCOPE_IDENTITY() as ' SCOPE_IDENTITY' 
                            SET @statusIN = 1;
                            DECLARE @TotalPMV2 DECIMAL(8, 2) ,
                                @TotalOCV2 DECIMAL(8, 2) ,
                                @Quantity2 DECIMAL(8, 2) ,
                                @DisValue2 DECIMAL(8, 2) ,
                                @FinalPMV DECIMAL(8, 2) ,
                                @FinalOCV DECIMAL(8, 2)

                            SELECT  @TotalPMV2 = SUM(ProfitMarginVal) ,
                                    @TotalOCV2 = SUM(OverheadCostVal) ,
                                    @Quantity2 = SUM(Quantity) ,
                                    @DisValue2 = SUM(DisValue)
                            FROM    dbo.RateAnalysisDetails
                            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                            DECLARE @total DECIMAL(8, 2) ,
                                @GrossTotal DECIMAL(8, 2)
                            SET @total = 0
                            SET @GrossTotal = 0
                            SELECT  @total = @total + ( ( UnitPrice * Quantity )
                                                        + ProfitMarginVal
                                                        + OverheadCostVal )
                                    - ( DisValue * Quantity )
                            FROM    dbo.RateAnalysisDetails
                            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                                    AND isDisRate = 0
                            SELECT  @total = @total + ( ( UnitPrice * Quantity )
                                                        + ProfitMarginVal
                                                        + OverheadCostVal )
                                    - ( ( ( DisValue / 100 ) * UnitPrice )
                                        * Quantity )
                            FROM    dbo.RateAnalysisDetails
                            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                                    AND isDisRate = 1  
                            SELECT  @GrossTotal = @GrossTotal + ( UnitPrice
                                                              * Quantity )
                            FROM    dbo.RateAnalysisDetails
                            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID

                            SELECT  @GrossTotal
                            SELECT  @total
                            SELECT  @TotalOCV2
                            SELECT  @TotalPMV2
                            SELECT  @Quantity2
                            SELECT  @DisValue2

							
                            UPDATE  dbo.RateAnalysisHeaders
                            SET     ProfitMarginVal = @TotalPMV2 ,
                                    OverheadCostVal = @TotalOCV2 ,
                                    TotalCost = @total ,
                                    ProfitMarginPer = ( @TotalPMV2
                                                        / @GrossTotal ) * 100 ,
                                    OverheadCostPer = ( @TotalOCV2
                                                        / @GrossTotal ) * 100
                            WHERE   Id = @RateAnalysisHeaderID
							
							select 'final test'
                        END
                END --ACTION 2 ENDS

            ELSE
                IF @Action = 2
                    BEGIN 
					 SELECT  'came to action 2' 
                        BEGIN
                            IF EXISTS ( SELECT  *
                                        FROM    dbo.BOQRateanalysisAllocationDetails
                                        WHERE   [ID] = @Id
                                                AND BOQID = @BoqID
                                                AND PackID = @PackID )
                                BEGIN
								select * from BOQRateanalysisAllocationDetails
                                    	 SELECT  'came to action 2 If exists' 

                                    SELECT  @Qty = Quantity
                                    FROM    dbo.RateAnalysisDetails
                                    WHERE   Id = @Id

                                    SELECT  @QtyAmount = @Quantity - @Qty

                                    SELECT  @WorkdetailQTY = Quantity
                                    FROM    dbo.WorkDetails
                                    WHERE   Workid = @WorkDetailID and RateAnalysisHeaderID = @RateAnalysisHeaderID

                                    SELECT  @QtyAmount = @QtyAmount
                                            * @WorkdetailQTY
									
                                    --UPDATE  dbo.MRNItemRegistries
                                    --SET     BOQQuantity = BOQQuantity
                                    --        + @QtyAmount ,
                                    --        UnitID = @UnitID ,
                                    --        BalanceQuantity = BalanceQuantity
                                    --        + @QtyAmount ,
                                    --        LastModUserID = @LastModUserID ,
                                    --        LastModDate = @LastModDate
                                    --WHERE   ItemId = @ItemHeaderID
                                    --        AND BOQId = @BoqID
                                    --        AND DepId = @DeptID
                                    --        AND ProjectID = @ProjectID
                                    UPDATE  dbo.BOQRateanalysisAllocationDetails
                                    SET     
									--        Location = @LocationID ,
                                    --        ItemType = @ItemType ,
                                    --        Unit = @UnitID ,
                                    --        UnitPrice = @UnitPrice ,
                                    --        ItemID = @ItemHeaderID ,
									        UnitPrice= @UnitPrice,
                                            Quantity = @QQTY,
											PackQty=@PackQty,
											PackBreakdownQty=@PackBreakdownQty,
											ProfitMarginVal= @ProfitMarginVal,
											OverheadCostVal = @OverheadCostVal,
											DiscountValue = @DisValue,
											IsProfitMarg = @IsProfitMarg,
											DiscountPercentage=@DiscountPercentage,
											ProfitMarginPercentage=@ProfitMarginPercentage,
											IsPercentageOrValue=@isDisRate
											-- Currency=@Currency,
											--	ExchangeRate	=@ExchangeRate


											 WHERE   BOQID = @BoqID
											 AND RateID = @RateAnalysisHeaderID
                                         --  AND SequNo = @SequNo 
											 AND ItemID=@ItemHeaderID
											
                                END
                            ELSE
                                BEGIN
								

                                    SELECT  @NextNO = MAX(SequNo)
                                    FROM    dbo.BOQRateanalysisAllocationDetails
                                    WHERE   RateID = @RateAnalysisHeaderID
                                    SELECT  @NextNO = @NextNO + 1
   								  

									IF (@NextNO IS NULL)
								    BEGIN
									SELECT @NextNO =1
									 
									END
                                    INSERT  INTO dbo.BOQRateanalysisAllocationDetails
                                            ( BOQID ,
                                              RateID ,
                                              SequNo ,
                                              Location ,
                                              ItemID ,
                                              ItemType ,
                                              Unit ,
                                              UnitPrice ,
                                              Quantity,
											  currency,
											  ExchangeRate,
											    [PackID],
									  [PackQty],
									  [PackRate],
									  [PackBreakdownQty]


		                                    )
                                    VALUES  ( @BoqID , -- BOQID - int
                                              @RateAnalysisHeaderID , -- RateID - int
                                              @NextNO , -- SequNo - int
                                              @LocationID , -- Location - nvarchar(max)
                                              @ItemHeaderID , -- ItemCode - nvarchar(max)
                                              @ItemType , -- ItemType - nvarchar(max)
                                              @UnitID , -- Unit - nvarchar(max)
                                              @UnitPrice , -- UnitPrice - float
                                              @Quantity , -- Quantity - float
											   @currency,
											  @ExchangeRate,
											   @PackID,
									  @PackQty,
									  @PackRate,
									  @PackBreakdownQty

		                                    )
									-- SELECT  'came to action 2 If Not exists after inser' ,@NextNO
                                    --IF @ItemType in ('I','P')
                                    --    BEGIN


                                    --        SELECT  @WorkdetailQTY = Quantity
                                    --        FROM    dbo.WorkDetails
                                    --        WHERE   WorkID = @WorkDetailID and RateAnalysisHeaderID=@RateAnalysisHeaderID
                                    --        SELECT  @Quantity = @Quantity
                                    --                * @WorkdetailQTY


                                    --        IF EXISTS ( SELECT
                                    --                          *
                                    --                    FROM  dbo.MRNItemRegistries
                                    --                    WHERE ItemId = @ItemHeaderID
                                    --                          AND BOQId = @BoqID
                                    --                          AND DepId = @DeptID
                                    --                          AND ProjectID = @ProjectID )
                                    --            BEGIN
                                    --                UPDATE  dbo.MRNItemRegistries
                                    --                SET     BOQQuantity = BOQQuantity
                                    --                        + ( @Quantity
                                    --                          * @WorkdetailQTY ) ,
                                    --                        BalanceQuantity = BalanceQuantity
                                    --                        + ( @Quantity
                                    --                          * @WorkdetailQTY ) ,
                                    --                        LastModUserID = @LastModUserID ,
                                    --                        LastModDate = @LastModDate
                                    --                WHERE   ItemId = @ItemHeaderID
                                    --                        AND BOQId = @BoqID
                                    --                        AND DepId = @DeptID
                                    --                        AND ProjectID = @ProjectID
                                    --            END 
	 
                                    --        ELSE
                                    --            BEGIN
	                                   --             INSERT  INTO dbo.MRNItemRegistries
                                    --                        ( ItemId ,
                                    --                          BOQId ,
                                    --                          DepId ,
                                    --                          BOQQuantity ,
                                    --                          RequestQuantity ,
                                    --                          IssueQuantity ,
                                    --                          BalanceQuantity ,
                                    --                          SuspendedQuantity ,
                                    --                          IPAddress ,
                                    --                          CreatedUserID ,
                                    --                          LastModUserID ,
                                    --                          CreatedDate ,
                                    --                          LastModDate ,
                                    --                          ProjectID ,
                                    --                          UnitID
	                                   --                     )
                                    --                VALUES  ( @ItemHeaderID , -- ItemId - int
                                    --                          @BoqID , -- BOQId - int
                                    --                          @DeptID , -- DepId - int
                                    --                          @QQTY , -- BOQQuantity - decimal
                                    --                          0 , -- RequestQuantity - decimal
                                    --                          0 , -- IssueQuantity - decimal
                                    --                          @QQTY , -- BalanceQuantity - decimal
                                    --                          0 , -- SuspendedQuantity - decimal
                                    --                          @IPAddress , -- IPAddress - nvarchar(max)
                                    --                          @CreatedUserID , -- CreatedUserID - int
                                    --                          @LastModUserID , -- LastModUserID - int
                                    --                          GETDATE() , -- CreatedDate - datetime
                                    --                          GETDATE() , -- LastModDate - datetime
                                    --                          (SELECT ProjectID FROM dbo.BOQHeaders WHERE Id=@BoqID),  -- ProjectID - int
                                    --                          @UnitID
	                                   --                     )


                                    --            END 
                                    --    END
                                END
                        END --ACTION 2 ENDS


                    END

	---Update Workdetails Total and Rate Header Total and workheader

                ELSE
                    IF @Action = 3
                        BEGIN
                            DELETE  [BOQRateanalysisallocationdetails]
                            WHERE   [ID] = @Id
                                        AND [BOQID] = @BoqID
                                        AND [ItemID] = @ItemHeaderID
                            IF @@ROWCOUNT > 0
                                BEGIN
                                    SET @statusIN = 3;
                                END
                            ELSE
                                BEGIN
                                    SET @statusIN = -3;
                                END
                        END --ACTIION -3 ENDS
            COMMIT TRAN -- Transaction Success!
            SET @status = @statusIN
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
            DECLARE @message VARCHAR(MAX)
            SET @status = -1;
            SET @message = ERROR_MESSAGE() 
            RAISERROR (15600,-1,-1, @message);
        END CATCH
    END--SP ENDS

GO

