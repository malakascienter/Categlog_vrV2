CREATE PROCEDURE [dbo].[UpdateRateAllocation]
    @BOQID INT,
    @WorkID INT,
    @RateHeaderID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @MainTotal DECIMAL(18, 2),
                @UnitPrice DECIMAL(18, 2),
                @TotalPMV DECIMAL(18, 2),
                @TotalOCV DECIMAL(18, 2),
                @Quantity DECIMAL(18, 2),
                @DisValue DECIMAL(18, 2),
                @FinalPMV DECIMAL(18, 2),
                @FinalOCV DECIMAL(18, 2);

        SELECT @TotalPMV = SUM(Quantity*ProfitMarginVal),
               @TotalOCV = SUM(Quantity*OverheadCostVal),
               @Quantity = SUM(Quantity),
               @DisValue = SUM(Quantity*DiscountValue)
        FROM dbo.BOQRateanalysisAllocationDetails
        WHERE RateID = @RateHeaderID
              AND BOQID = @BOQID;


        --IF EXISTS
        --(
        --    SELECT *
        --    FROM dbo.BOQRateanalysisAllocationDetails
        --    WHERE RateID = @RateHeaderID
        --          AND BOQID = @BOQID
        --          AND IsProfitMarg = 1
        --)
        --BEGIN
        --    SELECT @TotalPMV = @TotalPMV + SUM(UnitPrice * ProfitMarginPercentage / 100)
        --    FROM dbo.BOQRateanalysisAllocationDetails
        --    WHERE RateID = @RateHeaderID
        --          AND BOQID = @BOQID
        --          AND IsProfitMarg = 1;

        --END;

	


        DECLARE @total DECIMAL(18, 2),
                @GrossTotal DECIMAL(18, 2);
        SET @total = 0;
        SET @GrossTotal = 0;
        SELECT @total
            = @total + ((UnitPrice * Quantity) + ProfitMarginVal * Quantity + OverheadCostVal * Quantity)
              - ((DiscountValue) * Quantity)
        FROM dbo.BOQRateanalysisAllocationDetails
        WHERE RateID = @RateHeaderID
              AND BOQID = @BOQID
              AND IsPercentageOrValue = 0;



        SELECT @total = @total + ((UnitPrice * Quantity) + ProfitMarginVal * Quantity + OverheadCostVal * Quantity)
                        --- ( ( ( DiscountValue / 100 ) * UnitPrice ) * Quantity )
                        - ((DiscountValue) * Quantity)
        FROM dbo.BOQRateanalysisAllocationDetails
        WHERE RateID = @RateHeaderID
              AND BOQID = @BOQID
              AND IsPercentageOrValue = 1;

        SELECT @total = @total + (Cost) + (Cost * (ISNULL(OHPercentage, 0)) / 100)
        FROM [dbo].[CostProvisionSnapShot]
        WHERE RateHeaderId = @RateHeaderID
              AND boqId = @BOQID;

        SELECT @GrossTotal = @GrossTotal + (UnitPrice * Quantity)
        FROM dbo.RateAnalysisDetails
        WHERE RateAnalysisHeaderID = @RateHeaderID;

        SELECT @GrossTotal;
        SELECT @total;
        SELECT @TotalOCV;
        SELECT @TotalPMV;
        SELECT @Quantity;
        SELECT @DisValue;


        UPDATE dbo.BOQRateanalysisAllocationHeaders
        SET ProfitMarginVal = @TotalPMV,
            OverheadCostVal = @TotalOCV,
            TotalPrice = @total,
            ProfitMarginPer = (@TotalPMV / @GrossTotal) * 100,
            OverheadCostPer = (@TotalOCV / @GrossTotal) * 100
        WHERE RateAnalysisID = @RateHeaderID
              AND BOQID = @BOQID;




        UPDATE dbo.WorkDetails
        SET Rate = @total
        WHERE RateAnalysisHeaderID = @RateHeaderID
              AND WorkID = @WorkID;

        DECLARE @totalQT DECIMAL(18, 2),
                @totalRate DECIMAL(18, 2),
                @calculatedRate DECIMAL(18, 2);

        SELECT @totalQT = SUM(Quantity),
               @totalRate = SUM(Rate),
               @calculatedRate = SUM(Quantity * Rate)
        FROM dbo.WorkDetails
        WHERE WorkID = @WorkID;

        SELECT @totalQT,
               @totalRate;

        UPDATE dbo.BOQSubWorkAllocations
        --SET   Quantity = @totalQT ,

        SET Rate = @calculatedRate
        WHERE BOQID = @BOQID
              AND Id = @WorkID;

        --added 9/4/2018
        DECLARE @Labor DECIMAL = 0,
                @Material DECIMAL = 0;

        DECLARE @totPMV DECIMAL,
                @totOCV DECIMAL,
                @totDis DECIMAL = 0,
                @totDisp DECIMAL = 0;

        DECLARE @TEMPtotal TABLE
        (
            WorkID INT,
            RateHead INT,
            BoqID INT,
            RateSelecteHead INT,
            PMV DECIMAL,
            OCV DECIMAL,
            DISValue DECIMAL,
            Qty DECIMAL,
            UnitPrice DECIMAL,
            ItemType NVARCHAR(MAX),
            isDisRate BIT
        );
        INSERT INTO @TEMPtotal
        (
            WorkID,
            RateHead,
            BoqID,
            RateSelecteHead,
            PMV,
            OCV,
            DISValue,
            Qty,
            UnitPrice,
            ItemType,
            isDisRate
        )
        SELECT dbo.BOQSubWorkAllocations.WorkID,
               dbo.WorkDetails.RateAnalysisHeaderID,
               dbo.BOQHeaders.Id AS BoqID,
               dbo.RateAnalysisHeaders.Id AS HeaderID,
               dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal,
               dbo.BOQRateanalysisAllocationDetails.OverheadCostVal,
               dbo.BOQRateanalysisAllocationDetails.DiscountValue,
               dbo.BOQRateanalysisAllocationDetails.Quantity,
               dbo.BOQRateanalysisAllocationDetails.UnitPrice,
               dbo.BOQRateanalysisAllocationDetails.ItemType,
               dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue
        FROM dbo.BOQHeaders
            INNER JOIN dbo.BOQSubWorkAllocations
                ON dbo.BOQHeaders.Id = dbo.BOQSubWorkAllocations.BoqID
            INNER JOIN dbo.WorkDetails
                ON dbo.BOQSubWorkAllocations.WorkID = dbo.WorkDetails.WorkID
            INNER JOIN dbo.RateAnalysisHeaders
                ON dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisHeaders.Id
            INNER JOIN dbo.BOQRateanalysisAllocationDetails
                ON dbo.RateAnalysisHeaders.Id = dbo.BOQRateanalysisAllocationDetails.RateID
        WHERE (dbo.BOQHeaders.Id = @BOQID); --AND (dbo.BOQSubWorkAllocations.WorkID = @WorkID) AND (dbo.WorkDetails.RateAnalysisHeaderID = @RateAnalysisHeaderID)




        SELECT @totPMV;
        SELECT *
        FROM @TEMPtotal;

        SELECT @totPMV = SUM(PMV),
               @totOCV = SUM(OCV),
               @totDis = SUM(DISValue)
        FROM @TEMPtotal;

        SELECT @totDis = SUM(ISNULL(DISValue, 0) * Qty)
        FROM @TEMPtotal
        WHERE isDisRate = 0;
        --SELECT  @totDisp = SUM(( ( UnitPrice / 100 ) * DISValue ) * Qty)
        SELECT @totDisp = SUM((DISValue) * Qty)
        FROM @TEMPtotal
        WHERE isDisRate = 1;



        SELECT @totPMV,
               @totOCV,
               @totDis;

        SELECT @Material = SUM(((UnitPrice * Qty) + PMV + OCV) - DISValue)
        FROM @TEMPtotal
        WHERE ItemType = 'I';
        SELECT @Material;

        SELECT @Labor = SUM(((UnitPrice * Qty) + PMV + OCV) - DISValue)
        FROM @TEMPtotal
        WHERE ItemType = 'L';
        SELECT @Labor;

        UPDATE dbo.BOQHeaders
        SET DisValue = ISNULL(@totDis, 0) + ISNULL(@totDisp, 0)
        WHERE Id = @BOQID;

        -----










        COMMIT TRAN;
    END TRY
    BEGIN CATCH


        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
    END CATCH;






END;

GO

