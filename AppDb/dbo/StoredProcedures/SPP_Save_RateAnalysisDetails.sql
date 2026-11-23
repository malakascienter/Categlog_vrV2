/*** ***************************************************************************************************** ****/
-- This procedure was Auto Genarated By A tool created by S.G. Asanga Chandrakumara
-- ON3/29/2018 10:58:33 AM
/*** ***************************************************************************************************** ****/

/*
-----------------------------------------------------
INPUTS
-----------------------------------------------------
- WHEN SAVE ADD ALL OTHER COLUMNS AS DEFAULT
- PASS @Action =1 TO INSERT OR UPDATE
- PASS @Action =2 TO DELETE
-----------------------------------------------------
OUTPUTS 
-----------------------------------------------------
@status RETURNS 1 WHEN RECORD INSERTED AND NO ERRORS
@status RETURNS 2 WHEN RECORD UPDATED AND NO ERRORS
@status RETURNS 3 WHEN MORE THAN ONE RECORD DELETED AND NO ERRORS
@status RETURNS -3 WHEN DELETED SUCCESS BUT NO EFFECTED NO OF RECORDS
@status RETURNS -1 WHEN ANY KIND OF ERROR OCCURED
TO INSERT A RECORD PASS A NEGATIVE)VALUE TO @ID
*/
--SPP_Save_RateAnalysisDetails -1,
CREATE PROCEDURE [dbo].[SPP_Save_RateAnalysisDetails]
    --DECLARE PARAMETERS 27
    @Id INT,
    @RateAnalysisHeaderID INT,
    @BoqID INT,
    @SequNo INT,
    @LocationID INT,
    @ItemHeaderID INT,
    @ItemType NVARCHAR(1),
    @UnitID INT,
    @UnitPrice DECIMAL(18, 2),
    @Quantity DECIMAL(18, 2),
    @ProfitMarginVal DECIMAL(18, 2),
    @OverheadCostVal DECIMAL(18, 2),
    @isDisRate BIT,
    @isProjectspecificSubstituteItem BIT,
    @DisValue DECIMAL(18, 2),
    @IPAddress NVARCHAR(MAX),
    @CreatedUserID INT,
    @LastModUserID INT,
    @CreatedDate DATETIME,
    @LastModDate DATETIME,
    @Action [INT],
    @status [INT] OUTPUT,
    @ProjectID INT,
    @DeptID INT,
    @PropertyID INT,
    @WorkDetailID INT,
    @Currency INT,
    @ExchangeRate DECIMAL(18, 2),
    @DiscountPercentage DECIMAL(18, 2),
    @ProfitMarginPercentage DECIMAL(18, 2),
    @IsProfitMarg BIT,
    @IsOHCPercentage BIT,
    @OHCPercentage DECIMAL(18, 2),
    @CostPercentage DECIMAL(18, 2)
AS
DECLARE @statusIN [INT];
SET @statusIN = 0;
BEGIN
    BEGIN TRY

        SELECT 'action is',
               @Action;


        INSERT INTO testXml
        (
            val
        )
        VALUES
        (@Quantity);
        INSERT INTO testXml
        (
            val
        )
        VALUES
        (@UnitID);
        BEGIN TRANSACTION;


        IF (@ItemType = 'I')
        BEGIN

            DECLARE @MasterUnit INT,
                    @value DECIMAL(18, 2);
            SELECT @MasterUnit = MasterUnitID
            FROM dbo.StockItemDetails
            WHERE PropertyID = @ProjectID
                  AND LocationID = @LocationID
                  AND StockItemHeaderID = @ItemHeaderID;


            IF @MasterUnit <> @UnitID
            BEGIN

                SELECT TOP (1)
                       @value = Value
                FROM dbo.UnitConversions
                WHERE FromUnitID = @UnitID
                      AND ToUnitID = @MasterUnit
                      AND CompanyId = @ProjectID;

                SELECT @UnitID = @MasterUnit;
                SELECT @Quantity = @Quantity * @value;

            END;


        END;

        DECLARE @NextNO INT;

        --costProvision snap unit price
        DECLARE @UnitPriceCostSnap DECIMAL(18, 2);
        --costprovision unit price
        DECLARE @UnitPriceCost DECIMAL(18, 2);

        SELECT @NextNO = COUNT(SequNo)
        FROM dbo.RateAnalysisDetails
        WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID;
        SELECT @NextNO;
        BEGIN
            IF @NextNO = 0
            BEGIN

                SELECT @NextNO = @NextNO + 1;

            END;

            ELSE
            BEGIN
                SELECT @NextNO = MAX(SequNo)
                FROM dbo.RateAnalysisDetails
                WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID;
                SELECT @NextNO = @NextNO + 1;
            END;
        END;
        SELECT @NextNO;

        IF @Action = 1
        BEGIN

            SELECT 'came to action 1',
                   @Action;
            IF EXISTS
            (
                SELECT *
                FROM BOQRateanalysisAllocationDetails
                WHERE [ID] = @Id
                      AND [BOQID] = @BoqID
                      AND [ItemID] = @ItemHeaderID
            )
            BEGIN
                --UPDATE THE RECORD 

                SELECT 'If True Part',
                       @Id AS id,
                       @BoqID AS boqid,
                       @ItemHeaderID AS Itemheadeid;
                DECLARE @Qty DECIMAL(18, 2),
                        @QtyAmount DECIMAL(18, 2),
                        @WorkdetailQTY DECIMAL(18, 2);

                SELECT @Qty = Quantity
                FROM dbo.BOQRateanalysisAllocationDetails
                WHERE ID = @Id;
                SELECT @QtyAmount = @Quantity - @Qty;

                DECLARE @PreviousQunatity DECIMAL,
                        @PriviousPrice DECIMAL;
                SELECT @PreviousQunatity = Quantity,
                       @PriviousPrice = UnitPrice
                FROM dbo.BOQRateanalysisAllocationDetails
                WHERE [ID] = @Id
                      AND BOQID = @BoqID
                      AND ItemID = @ItemHeaderID;
                DECLARE @CatId3 INT;

                SELECT @CatId3 = CategoryID
                FROM stockitemheaders
                WHERE Id = @ItemHeaderID;


                UPDATE costprovisionsnapshot
                SET cost = cost - @PreviousQunatity * @PriviousPrice * (Percentage / 100)
                WHERE boqid = @BoqID
                      AND RateHeaderId = @RateAnalysisHeaderID
                      AND CategoryID = @CatId3
                      AND ItemId = @ItemHeaderID;



                UPDATE BOQRateanalysisAllocationDetails
                SET [RateID] = @RateAnalysisHeaderID,
                    [SequNo] = @SequNo,
                    [Location] = @LocationID,
                    [ItemID] = @ItemHeaderID,
                    [ItemType] = @ItemType,
                    [Unit] = @UnitID,
                    [UnitPrice] = @UnitPrice,
                    [Quantity] = @Quantity,
                    [ProfitMarginVal] = @ProfitMarginVal,
                    [OverheadCostVal] = @OverheadCostVal,
                    [IsPercentageOrValue] = @isDisRate,
                    [isProjectspecificSubstituteItem] = @isProjectspecificSubstituteItem,
                    [DiscountValue] = @DisValue,
                    [IPAddress] = @IPAddress,
                    [CreatedUserID] = @CreatedUserID,
                    [LastModUserID] = @LastModUserID,
                    [CreatedDate] = @CreatedDate,
                    [LastModDate] = @LastModDate,
                    [Currency] = @Currency,
                    [ExchangeRate] = @ExchangeRate,
                    [ProfitMarginPercentage] = @ProfitMarginPercentage,
                    [IsProfitMarg] = @IsProfitMarg,
                    [DiscountPercentage] = @DiscountPercentage,
                    [IsOHCPercentage] = @IsOHCPercentage,
                    [OHCPercentage] = @OHCPercentage
                WHERE [ID] = @Id;
                DECLARE @RateQuantitiyInWork DECIMAL(18, 2) = 0;
                DECLARE @QtyAmountNew DECIMAL(18, 2) = 0;
                DECLARE @cnt INT = 0;
                DECLARE @totalcount INT = 0;

                SELECT @totalcount = COUNT(ID)
                FROM dbo.BOQRateanalysisAllocationHeaders;

                SELECT 'cnt',
                       @cnt;
                SELECT 'Tt',
                       @totalcount;



                WHILE @totalcount + 1 > @cnt
                BEGIN
                    SELECT 'cnt',
                           @cnt;


                    IF EXISTS
                    (
                        SELECT *
                        FROM dbo.BOQRateanalysisAllocationHeaders
                        WHERE ID = @cnt
                              AND RateAnalysisID = @RateAnalysisHeaderID
                    )
                    BEGIN

                        SELECT @RateQuantitiyInWork = RateQtyInWork
                        FROM dbo.BOQRateanalysisAllocationHeaders
                        WHERE ID = @cnt
                              AND RateAnalysisID = @RateAnalysisHeaderID;

                        SELECT @QtyAmountNew = @QtyAmountNew + @QtyAmount * @RateQuantitiyInWork;

                    END;
                    SET @cnt = @cnt + 1;
                END;

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



                IF EXISTS
                (
                    SELECT *
                    FROM costprovisionsnapshot
                    WHERE boqid = @BoqID
                          AND RateHeaderId = @RateAnalysisHeaderID
                          AND CategoryID = @CatId3
                          AND ItemId = @ItemHeaderID
                )
                BEGIN

                    IF (@CostPercentage = 0)
                    BEGIN

                        DELETE FROM costprovisionsnapshot
                        WHERE boqid = @BoqID
                              AND RateHeaderId = @RateAnalysisHeaderID
                              AND CategoryID = @CatId3
                              AND ItemId = @ItemHeaderID;

                    END;
                    ELSE
                    BEGIN
                        --


                        --Set @UnitPriceCostSnap = Case When @isDisRate=1 then @UnitPrice* (100-@DiscountPercentage)/100 else @UnitPrice-@DisValue end	




                        UPDATE costprovisionsnapshot
                        SET cost = (@Quantity * @UnitPrice * @CostPercentage) / 100,
                            Percentage = @CostPercentage,
                            OHPercentage = @OHCPercentage
                        WHERE boqid = @BoqID
                              AND RateHeaderId = @RateAnalysisHeaderID
                              AND CategoryID = @CatId3
                              AND ItemId = @ItemHeaderID;
                    END;
                END;
                ELSE
                BEGIN
                    IF (@CostPercentage <> 0)
                    BEGIN




                        SET @UnitPriceCostSnap = CASE
                                                     WHEN @isDisRate = 1 THEN
                                                         @UnitPrice * (100 - @DiscountPercentage) / 100
                                                     ELSE
                                                         @UnitPrice - @DisValue
                                                 END;


                        INSERT INTO [dbo].[CostProvisionSnapShot]
                        (
                            [RateHeaderId],
                            [Cost],
                            [CategoryId],
                            [Percentage],
                            [BoqId],
                            [ItemId],
                            [OHPercentage]
                        )
                        VALUES
                        (@RateAnalysisHeaderID, @Quantity * @UnitPrice * @CostPercentage / 100, @CatId3,
                         @CostPercentage, @BoqID, @ItemHeaderID, @OHCPercentage);
                    END;
                END;

				
				

                SELECT @ItemHeaderID,
                       @BoqID,
                       @DeptID,
                       @ProjectID;
                SELECT @QtyAmountNew;
                SET @statusIN = 2;

            END;
            ELSE
            BEGIN
                --INSERT THE RECORD		
                DECLARE @CatId INT;

                SELECT @CatId = CategoryID
                FROM stockitemheaders
                WHERE Id = @ItemHeaderID;

                --If EXISTS(select * from costprovisions where categoryId=@CatId and RateHeaderId=@RateAnalysisHeaderID)
                --Begin
				
                --update costprovisions set Cost = Cost +  @Quantity * @UnitPrice where RateHeaderId= @RateAnalysisHeaderID and categoryId=@CatId

                --end
                --else
                --begin
                IF (@ItemType = 'I')
                BEGIN


                    SET @UnitPriceCost = CASE
                                             WHEN @isDisRate = 1 THEN
                                                 @UnitPrice * (100 - @DiscountPercentage) / 100
                                             ELSE
                                                 @UnitPrice - @DisValue
                                         END;


                    IF (@CostPercentage <> 0)
                    BEGIN
                        INSERT INTO [dbo].[CostProvisions]
                        (
                            [CategoryId],
                            [RateHeaderId],
                            [Cost],
                            [Percentage],
                            [ItemId],
                            [OHPercentage]
                        )
                        VALUES
                        (@CatId, @RateAnalysisHeaderID, @Quantity * @UnitPrice * @CostPercentage / 100,
                         @CostPercentage, @ItemHeaderID, @OHCPercentage);
                    END;
                END;

				

                SELECT 'If False Part';
                INSERT INTO RateAnalysisDetails
                (
                    [RateAnalysisHeaderID],
                    [SequNo],
                    [LocationID],
                    [ItemHeaderID],
                    [ItemType],
                    [UnitID],
                    [UnitPrice],
                    [Quantity],
                    [ProfitMarginVal],
                    [OverheadCostVal],
                    [isDisRate],
                    [isProjectspecificSubstituteItem],
                    [DisValue],
                    [IPAddress],
                    [CreatedUserID],
                    [LastModUserID],
                    [CreatedDate],
                    [LastModDate],
                    [Currency],
                    [ExchangeRate],
                    [DiscountPercentage],
                    [ProfitMarginPercentage],
                    [IsProfitMarg],
                    [IsOHCPercentage],
                    [OHCPercentage]
                )
                VALUES
                (@RateAnalysisHeaderID, @NextNO, @LocationID, @ItemHeaderID, @ItemType, @UnitID, @UnitPrice, @Quantity,
                 @ProfitMarginVal, @OverheadCostVal, @isDisRate, @isProjectspecificSubstituteItem, @DisValue,
                 @IPAddress, @CreatedUserID, @LastModUserID, @CreatedDate, @LastModDate, @Currency, @ExchangeRate,
                 @DiscountPercentage, @ProfitMarginPercentage, @IsProfitMarg, @IsOHCPercentage, @OHCPercentage);
                SELECT SCOPE_IDENTITY() AS ID;
                SELECT 'came to action 1',
                       'Else PArt',
                       @RateAnalysisHeaderID,
                       @ItemHeaderID,
                       SCOPE_IDENTITY() AS ' SCOPE_IDENTITY';
                SET @statusIN = 1;
                DECLARE @TotalPMV2 DECIMAL(18, 2),
                        @TotalOCV2 DECIMAL(18, 2),
                        @Quantity2 DECIMAL(18, 2),
                        @DisValue2 DECIMAL(18, 2),
                        @FinalPMV DECIMAL(18, 2),
                        @FinalOCV DECIMAL(18, 2);

                SELECT @TotalPMV2 = SUM(ProfitMarginVal),
                       @TotalOCV2 = SUM(OverheadCostVal),
                       @Quantity2 = SUM(Quantity),
                       @DisValue2 = SUM(DisValue)
                FROM dbo.RateAnalysisDetails
                WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID;
                DECLARE @total DECIMAL(18, 2),
                        @GrossTotal DECIMAL(18, 2);
                SET @total = 0;
                SET @GrossTotal = 0;
                SELECT @total
                    = @total + ((UnitPrice * Quantity) + ProfitMarginVal + OverheadCostVal) - (DisValue * Quantity)
                FROM dbo.RateAnalysisDetails
                WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID
                      AND isDisRate = 0;
                SELECT @total
                    = @total + ((UnitPrice * Quantity) + ProfitMarginVal + OverheadCostVal)
                      - (((DisValue / 100) * UnitPrice) * Quantity)
                FROM dbo.RateAnalysisDetails
                WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID
                      AND isDisRate = 1;
                SELECT @GrossTotal = @GrossTotal + (UnitPrice * Quantity)
                FROM dbo.RateAnalysisDetails
                WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID;

                SELECT @GrossTotal;
                SELECT @total;
                SELECT @TotalOCV2;
                SELECT @TotalPMV2;
                SELECT @Quantity2;
                SELECT @DisValue2;


                UPDATE dbo.RateAnalysisHeaders
                SET ProfitMarginVal = @TotalPMV2,
                    OverheadCostVal = @TotalOCV2,
                    TotalCost = @total,
                    ProfitMarginPer = (@TotalPMV2 / @GrossTotal) * 100,
                    OverheadCostPer = (@TotalOCV2 / @GrossTotal) * 100
                WHERE Id = @RateAnalysisHeaderID;

            END;
			
        END; --ACTION 2 ENDS

        ELSE IF @Action = 2
        BEGIN
            SELECT 'came to action 2';
            BEGIN
                IF EXISTS
                (
                    SELECT *
                    FROM dbo.BOQRateanalysisAllocationDetails
                    WHERE [ID] = @Id
                          AND BOQID = @BoqID
                          AND ItemID = @ItemHeaderID
                )
                BEGIN

                    SELECT 'came to action 2 If exists';

                    SELECT @Qty = Quantity
                    FROM dbo.RateAnalysisDetails
                    WHERE Id = @Id;

                    SELECT @QtyAmount = @Quantity - @Qty;

                    SELECT @WorkdetailQTY = Quantity
                    FROM dbo.WorkDetails
                    WHERE Workid = @WorkDetailID
                          AND RateAnalysisHeaderID = @RateAnalysisHeaderID;

                    SELECT @QtyAmount = @QtyAmount * @WorkdetailQTY;



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
                    UPDATE dbo.BOQRateanalysisAllocationDetails
                    SET Location = @LocationID,
                        ItemType = @ItemType,
                        Unit = @UnitID,
                        UnitPrice = @UnitPrice,
                        ItemID = @ItemHeaderID,
                        Quantity = @Quantity,
                        Currency = @Currency,
                        ExchangeRate = @ExchangeRate
                    WHERE BOQID = @BoqID
                          AND RateID = @RateAnalysisHeaderID
                          AND SequNo = @SequNo;



                END;
                ELSE
                BEGIN


                    SELECT @NextNO = MAX(SequNo)
                    FROM dbo.BOQRateanalysisAllocationDetails
                    WHERE RateID = @RateAnalysisHeaderID;
                    SELECT @NextNO = @NextNO + 1;


                    IF (@NextNO IS NULL)
                    BEGIN
                        SELECT @NextNO = 1;

                    END;
                    INSERT INTO dbo.BOQRateanalysisAllocationDetails
                    (
                        BOQID,
                        RateID,
                        SequNo,
                        Location,
                        ItemID,
                        ItemType,
                        Unit,
                        UnitPrice,
                        Quantity,
                        currency,
                        ExchangeRate,
                        DiscountValue,
                        DiscountPercentage,
                        ProfitMarginVal,
                        OverheadCostVal,
                        IsPercentageOrValue,
                        IsProfitMarg,
                        ISOHCPercentage,
                        OHCPercentage,
						ProfitMarginPercentage
                    )
                    VALUES
                    (   @BoqID,                -- BOQID - int
                        @RateAnalysisHeaderID, -- RateID - int
                        @NextNO,               -- SequNo - int
                        @LocationID,           -- Location - nvarchar(max)
                        @ItemHeaderID,         -- ItemCode - nvarchar(max)
                        @ItemType,             -- ItemType - nvarchar(max)
                        @UnitID,               -- Unit - nvarchar(max)
                        @UnitPrice,            -- UnitPrice - float
                        @Quantity,             -- Quantity - float
                        @currency, @ExchangeRate, @DisValue, @DiscountPercentage, @ProfitMarginVal, @OverheadCostVal,
                        @isDisRate, @IsProfitMarg, @IsOHCPercentage, @OHCPercentage,@ProfitMarginPercentage);

                    DECLARE @CatId2 INT;

                    SELECT @CatId2 = CategoryID
                    FROM stockitemheaders
                    WHERE Id = @ItemHeaderID;

                    IF EXISTS
                    (
                        SELECT *
                        FROM costprovisionsnapshot
                        WHERE boqid = @BoqID
                              AND RateHeaderId = @RateAnalysisHeaderID
                              AND CategoryID = @CatId2
                              AND ItemID = @ItemHeaderID
                    )
                    BEGIN


                        --Set @UnitPriceCostSnap = Case When @isDisRate=1 then @UnitPrice* (100-@DiscountPercentage)/100 else @UnitPrice-@DisValue end	


                        UPDATE costprovisionsnapshot
                        SET cost = (@Quantity * @UnitPrice * @CostPercentage) / 100,
                            Percentage = @CostPercentage,
                            OHPercentage = @OHCPercentage
                        WHERE boqid = @BoqID
                              AND RateHeaderId = @RateAnalysisHeaderID
                              AND CategoryID = @CatId2
                              AND ItemID = @ItemHeaderID;
                    END;
                    ELSE
                    BEGIN

                        IF (@ItemType = 'I' AND @CostPercentage <> 0)
                        BEGIN


                            --Set @UnitPriceCostSnap = Case When @isDisRate=1 then @UnitPrice* (100-@DiscountPercentage)/100 else @UnitPrice-@DisValue end	



                            INSERT INTO [dbo].[CostProvisionSnapShot]
                            (
                                [RateHeaderId],
                                [Cost],
                                [CategoryId],
                                [Percentage],
                                [BoqId],
                                [ItemId],
                                [OHPercentage]
                            )
                            VALUES
                            (@RateAnalysisHeaderID, @Quantity * @UnitPrice * (@CostPercentage / 100), @CatId2,
                             @CostPercentage, @BoqID, @ItemHeaderID, @OHCPercentage);
                        END;
                    END;
                -- SELECT  'came to action 2 If Not exists after inser' ,@NextNO
                --IF @ItemType = 'I'


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
                --                          @Quantity , -- BOQQuantity - decimal
                --                          0 , -- RequestQuantity - decimal
                --                          0 , -- IssueQuantity - decimal
                --                          @Quantity , -- BalanceQuantity - decimal
                --                          0 , -- SuspendedQuantity - decimal
                --                          @IPAddress , -- IPAddress - nvarchar(max)
                --                          @CreatedUserID , -- CreatedUserID - int
                --                          @LastModUserID , -- LastModUserID - int
                --                          @CreatedDate , -- CreatedDate - datetime
                --                          @LastModDate , -- LastModDate - datetime
                --                          @ProjectID ,  -- ProjectID - int
                --                          @UnitID
                --                     )


                --            END 
                --    END
                END;
            END; --ACTION 2 ENDS


        END;

        ---Update Workdetails Total and Rate Header Total and workheader

        ELSE IF @Action = 3
        BEGIN

            DECLARE @PreviousQunatityDel DECIMAL,
                    @PriviousPriceDel DECIMAL;
            SELECT @PreviousQunatityDel = Quantity,
                   @PriviousPriceDel = UnitPrice
            FROM dbo.BOQRateanalysisAllocationDetails
            WHERE [ID] = @Id
                  AND BOQID = @BoqID
                  AND ItemID = @ItemHeaderID;
            DECLARE @CatId3del INT;

            SELECT @CatId3del = CategoryID
            FROM stockitemheaders
            WHERE Id = @ItemHeaderID;



            --      UPDATE costprovisionsnapshot
            --      SET cost = cost - @PreviousQunatityDel * @PriviousPriceDel
            --      WHERE boqid = @BoqID
            --            AND RateHeaderId = @RateAnalysisHeaderID
            --            AND CategoryID = @CatId3del;
            --AND 
            DELETE FROM costprovisionsnapshot
            WHERE BOQID = @BoqID
                  AND ItemID = @ItemHeaderID
                  AND RateHeaderId = @RateAnalysisHeaderID;

            DELETE [BOQRateanalysisallocationdetails]
            WHERE [ID] = @Id
                  AND [BOQID] = @BoqID
                  AND [ItemID] = @ItemHeaderID;
            DECLARE @WorkID INT;
            SELECT TOP (1)
                   @WorkID = WorkID
            FROM dbo.WorkDetails
            WHERE Id = @WorkDetailID
                  AND RateAnalysisHeaderID = @RateAnalysisHeaderID;
            EXEC [dbo].[DeleteUpdateRateAllocation] @BOQID,
                                                    @WorkID,
                                                    @RateAnalysisHeaderID;




            IF @@ROWCOUNT > 0
            BEGIN
                SET @statusIN = 3;
            END;
            ELSE
            BEGIN
                SET @statusIN = -3;
            END;
        END; --ACTIION -3 ENDS



        ELSE IF @Action = 4
        BEGIN
            DELETE FROM RateAnalysisDetails
            WHERE RateAnalysisHeaderID = @RateAnalysisHeaderID
                  AND ItemHeaderID = @ItemHeaderID;
            DELETE FROM CostProvisions
            WHERE RateHeaderId = @RateAnalysisHeaderID
                  AND ItemId = @ItemHeaderID;

        END;



        EXEC [dbo].[TotalRecalculateBOQ] @BOQID;

		

        COMMIT TRAN; -- Transaction Success!
        SET @status = @statusIN;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
        DECLARE @message VARCHAR(MAX);
        SET @status = -1;
        SET @message = ERROR_MESSAGE();
        RAISERROR(15600, -1, -1, @message);
    END CATCH;
END; --SP ENDS

GO

