--SPP_UpdateBoqDetails 1,6,9
CREATE PROCEDURE [dbo].[SPP_UpdateBoqDetails]
    @BOQID INT ,
    @WorkID INT ,
    @RateAnalysisHeaderID INT
AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION

            DECLARE @MainTotal DECIMAL(8, 2) ,
                @UnitPrice DECIMAL(8, 2) ,
                @TotalPMV DECIMAL(8, 2) ,
                @TotalOCV DECIMAL(8, 2) ,
                @Quantity DECIMAL(8, 2) ,
                @DisValue DECIMAL(8, 2) ,
                @FinalPMV DECIMAL(8, 2) ,
                @FinalOCV DECIMAL(8, 2)

            SELECT  @TotalPMV = SUM(ProfitMarginVal) ,
                    @TotalOCV = SUM(OverheadCostVal) ,
                    @Quantity = SUM(Quantity) ,
                    @DisValue = SUM(DisValue)
            FROM    dbo.RateAnalysisDetails
            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
            DECLARE @total DECIMAL(8, 2) ,
                @GrossTotal DECIMAL(8, 2)
            SET @total = 0
            SET @GrossTotal = 0.0
            SELECT  @total = @total + ( ( UnitPrice * Quantity )
                                        + ProfitMarginVal + OverheadCostVal )
                    - ( DisValue * Quantity )
            FROM    dbo.RateAnalysisDetails
            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                    AND isDisRate = 0
            SELECT  @total = @total + ( ( UnitPrice * Quantity )
                                        + ProfitMarginVal + OverheadCostVal )
                    - ( ( ( DisValue / 100 ) * UnitPrice ) * Quantity )
            FROM    dbo.RateAnalysisDetails
            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                    AND isDisRate = 1  
--added
            SELECT  @total AS added
            SELECT  @GrossTotal = @GrossTotal + ( UnitPrice * Quantity )
            FROM    dbo.RateAnalysisDetails
            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID

            SELECT  @GrossTotal
            SELECT  @total
            SELECT  @TotalOCV
            SELECT  @TotalPMV
            SELECT  @Quantity
            SELECT  @DisValue
--added
            SELECT  @total AS added2 ,
                    @TotalPMV ,
                    @TotalOCV ,
                    @GrossTotal

	--added		
            SELECT  *
            FROM    dbo.RateAnalysisHeaders
            WHERE   Id = @RateAnalysisHeaderID
            UPDATE  dbo.RateAnalysisHeaders
            SET     ProfitMarginVal = @TotalPMV ,
                    OverheadCostVal = @TotalOCV ,
                    TotalCost = @total ,
                    ProfitMarginPer = ( @TotalPMV / @GrossTotal ) * 100 ,
                    OverheadCostPer = ( @TotalOCV / @GrossTotal ) * 100
            WHERE   Id = @RateAnalysisHeaderID
            UPDATE  dbo.BOQRateanalysisAllocationHeaders
            SET     ProfitMarginVal = @TotalPMV ,
                    OverheadCostVal = @TotalOCV ,
                    TotalPrice = @total ,
                    ProfitMarginPer = ( @TotalPMV / @GrossTotal ) * 100 ,
                    OverheadCostPer = ( @TotalOCV / @GrossTotal ) * 100
            WHERE   RateAnalysisID = @RateAnalysisHeaderID
                    AND BOQID = @BOQID
                    AND WorkID = @WorkID

            UPDATE  dbo.WorkDetails
            SET     Rate = @total
            WHERE   RateAnalysisHeaderID = @RateAnalysisHeaderID
                    AND WorkID = @WorkID
--removed Quantity=@Quantity,
            DECLARE @totalQT DECIMAL(8, 2) ,
                @totalRate DECIMAL(8, 2) ,
                @calculatedRate DECIMAL(8, 2)

            SELECT  @totalQT = SUM(Quantity) ,
                    @totalRate = SUM(Rate) ,
                    @calculatedRate = SUM(Quantity * Rate)
            FROM    dbo.WorkDetails
            WHERE   WorkID = @WorkID

            SELECT  @totalQT ,
                    @totalRate

            UPDATE  dbo.BOQSubWorkAllocations
            SET     Quantity = @totalQT ,
                    Rate = @calculatedRate
            WHERE   BOQID = @BOQID
                    AND Id = @WorkID

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
                            dbo.RateAnalysisDetails.ProfitMarginVal ,
                            dbo.RateAnalysisDetails.OverheadCostVal ,
                            dbo.RateAnalysisDetails.DisValue ,
                            dbo.RateAnalysisDetails.Quantity ,
                            dbo.RateAnalysisDetails.UnitPrice ,
                            dbo.RateAnalysisDetails.ItemType ,
                            dbo.RateAnalysisDetails.isDisRate
                    FROM    dbo.BOQHeaders
                            INNER JOIN dbo.BOQSubWorkAllocations ON dbo.BOQHeaders.Id = dbo.BOQSubWorkAllocations.BOQID
                            INNER JOIN dbo.WorkDetails ON dbo.BOQSubWorkAllocations.WorkID = dbo.WorkDetails.WorkID
                            INNER JOIN dbo.RateAnalysisHeaders ON dbo.WorkDetails.RateAnalysisHeaderID = dbo.RateAnalysisHeaders.Id
                            INNER JOIN dbo.RateAnalysisDetails ON dbo.RateAnalysisHeaders.Id = dbo.RateAnalysisDetails.RateAnalysisHeaderID
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
            RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
            IF @@TRANCOUNT > 0
                ROLLBACK TRAN --RollBack in case of Error
		

	
        END CATCH


	
    END

GO

