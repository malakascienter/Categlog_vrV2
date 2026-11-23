--[dbo].[DeleteUpdateRateAllocation] 6,17,7
CREATE PROCEDURE [dbo].[DeleteUpdateRateAllocation]
    @BOQID INT ,
    @WorkID INT ,
    @RateHeaderID INT
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION
			 DECLARE @MainTotal DECIMAL(18, 2) ,
                @UnitPrice DECIMAL(18, 2) ,
                @TotalPMV DECIMAL(18, 2) ,
                @TotalOCV DECIMAL(18, 2) ,
                @Quantity DECIMAL(18, 2) ,
                @DisValue DECIMAL(18, 2) ,
                @FinalPMV DECIMAL(18, 2) ,
                @FinalOCV DECIMAL(18, 2)

				SELECT  @TotalPMV = SUM(ProfitMarginVal) ,
                    @TotalOCV = SUM(OverheadCostVal) ,
                    @Quantity = SUM(Quantity) ,
                    @DisValue = SUM(DiscountValue)
            FROM    dbo.BOQRateanalysisAllocationDetails
            WHERE   RateID = @RateHeaderID AND BOQID = @BOQID
            DECLARE @total DECIMAL(18, 2) ,
                @GrossTotal DECIMAL(18, 2)
            SET @total = 0
            SET @GrossTotal = 0
            SELECT  @total = @total + ( ( UnitPrice * Quantity )
                                        + ProfitMarginVal + OverheadCostVal )
                    - ( DiscountValue * Quantity )
            FROM    dbo.BOQRateanalysisAllocationDetails
            WHERE   RateID = @RateHeaderID
                    AND IsPercentageOrValue = 0
            SELECT  @total = @total + ( ( UnitPrice * Quantity )
                                        + ProfitMarginVal + OverheadCostVal )
                    - ( ( ( DiscountValue / 100 ) * UnitPrice ) * Quantity )
            FROM    dbo.BOQRateanalysisAllocationDetails
            WHERE   RateID = @RateHeaderID
                    AND  IsPercentageOrValue = 1  
            SELECT  @GrossTotal = @GrossTotal + ( UnitPrice * Quantity )
            FROM    dbo.RateAnalysisDetails
            WHERE   RateAnalysisHeaderID = @RateHeaderID

            SELECT  @GrossTotal AS 'gross'
            SELECT  @total AS 'Total'
            SELECT  @TotalOCV 
            SELECT  @TotalPMV
            SELECT  @Quantity 'QTY'
            SELECT  @DisValue


            --UPDATE  dbo.BOQRateanalysisAllocationHeaders
            --SET     ProfitMarginVal = @TotalPMV ,
            --        OverheadCostVal = @TotalOCV ,
            --        TotalPrice = @total ,
            --        ProfitMarginPer = ( @TotalPMV / @GrossTotal ) * 100 ,
            --        OverheadCostPer = ( @TotalOCV / @GrossTotal ) * 100
            --WHERE   RateAnalysisID = @RateHeaderID AND BOQID = @BOQID
          
		       DECLARE @totalQT DECIMAL(18, 2) ,
                @totalRate DECIMAL(18, 2) ,
                @calculatedRate DECIMAL(18, 2)
		  
            SELECT  @totalQT = SUM(Quantity) ,
                    @totalRate = SUM(Rate) ,
                    @calculatedRate = SUM(Quantity * Rate)
            FROM    dbo.WorkDetails
            WHERE   WorkID = @WorkID  AND RateAnalysisHeaderID=@RateHeaderID

            UPDATE  dbo.WorkDetails
            SET     Rate =Rate-@total
            WHERE   WorkID = @WorkID and RateAnalysisHeaderID = @RateHeaderID



            SELECT  @totalQT ,
                    @totalRate,
					@calculatedRate AS 'calrate'

            UPDATE  dbo.BOQSubWorkAllocations
            --SET   Quantity = @totalQT ,

            SET        Rate = Rate-@calculatedRate
            WHERE   BOQID = @BOQID
                    AND id = @WorkID

--added 9/4/2018
            DECLARE @Labor DECIMAL = 0 ,
                @Material DECIMAL = 0

            DECLARE @totPMV DECIMAL ,
                @totOCV DECIMAL ,
                @totDis DECIMAL= 0 ,
                @totDisp DECIMAL= 0

            DECLARE @TEMPtotal TABLE
                (
                  WorkID INT ,
                  RateHead INT ,
                  BoqID INT ,
                  RateSelecteHead INT ,
                  PMV DECIMAL ,
                  OCV DECIMAL ,
                  DISValue DECIMAL ,
                  Qty DECIMAL ,
                  UnitPrice DECIMAL ,
                  ItemType NVARCHAR(MAX) ,
                  isDisRate BIT
                )
            INSERT  INTO @TEMPtotal
                    ( WorkID ,
                      RateHead ,
                      BoqID ,
                      RateSelecteHead ,
                      PMV ,
                      OCV ,
                      DISValue ,
                      Qty ,
                      UnitPrice ,
                      ItemType ,
                      isDisRate
                    )
                    SELECT  dbo.BOQSubWorkAllocations.WorkID ,
                            dbo.WorkDetails.RateAnalysisHeaderID ,
                            dbo.BOQHeaders.Id AS BoqID ,
                            dbo.RateAnalysisHeaders.Id AS HeaderID ,
                          dbo.BOQRateanalysisAllocationDetails.ProfitMarginVal ,
                           dbo.BOQRateanalysisAllocationDetails.OverheadCostVal ,
                           dbo.BOQRateanalysisAllocationDetails.DiscountValue ,
                           dbo.BOQRateanalysisAllocationDetails.Quantity ,
                           dbo.BOQRateanalysisAllocationDetails.UnitPrice ,
                           dbo.BOQRateanalysisAllocationDetails.ItemType ,
                           dbo.BOQRateanalysisAllocationDetails.IsPercentageOrValue
                    FROM    dbo.BOQHeaders
                            INNER JOIN dbo.BOQSubWorkAllocations ON dbo.BOQHeaders.Id = dbo.BOQSubWorkAllocations.BOQID
                            INNER JOIN dbo.WorkDetails ON dbo.BOQSubWorkAllocations.WorkID = dbo.WorkDetails.WorkID
                            INNER JOIN dbo.RateAnalysisHeaders ON dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisHeaders.Id
                            INNER JOIN dbo.BOQRateanalysisAllocationDetails ON dbo.RateAnalysisHeaders.Id = dbo.BOQRateanalysisAllocationDetails.RateID
                    WHERE   ( dbo.BOQHeaders.Id = @BOQID ) --AND (dbo.BOQSubWorkAllocations.WorkID = @WorkID) AND (dbo.WorkDetails.RateAnalysisHeaderID = @RateAnalysisHeaderID)




            SELECT  @totPMV
            SELECT  *
            FROM    @TEMPtotal

            SELECT  @totPMV = SUM(PMV) ,
                    @totOCV = SUM(OCV) ,
                    @totDis = SUM(DISValue)
            FROM    @TEMPtotal

            SELECT  @totDis = SUM(ISNULL(DISValue, 0) * Qty)
            FROM    @TEMPtotal
            WHERE   isDisRate = 0
            SELECT  @totDisp = SUM(( ( UnitPrice / 100 ) * DISValue ) * Qty)
            FROM    @TEMPtotal
            WHERE   isDisRate = 1



            SELECT  @totPMV ,
                    @totOCV ,
                    @totDis

            SELECT  @Material = SUM(( ( UnitPrice * Qty ) + PMV + OCV )
                                    - DISValue)
            FROM    @TEMPtotal
            WHERE   ItemType = 'I'
            SELECT  @Material

            SELECT  @Labor = SUM(( ( UnitPrice * Qty ) + PMV + OCV )
                                 - DISValue)
            FROM    @TEMPtotal
            WHERE   ItemType = 'L'
            SELECT  @Labor

            UPDATE  dbo.BOQHeaders
            SET     DisValue = ISNULL(@totDis, 0) + ISNULL(@totDisp, 0)
            WHERE   Id = @BOQID

-----










             COMMIT TRAN 
        END TRY
        BEGIN CATCH


            IF @@TRANCOUNT > 0
                ROLLBACK TRAN 
				DECLARE @message VARCHAR(max)
				SELECT @message=ERROR_MESSAGE()
				RAISERROR(@message,18,2)
				--RollBack in case of Error
        END CATCH






    END

GO

