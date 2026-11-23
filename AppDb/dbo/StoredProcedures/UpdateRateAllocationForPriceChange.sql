

--[dbo].[UpdateRateAllocationForPriceChange] 11,72
CREATE PROCEDURE [dbo].[UpdateRateAllocationForPriceChange]
    @BOQID INT,
    @RateHeaderID INT
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
                    @DisValue = SUM(DiscountValue)
            FROM    dbo.BOQRateanalysisAllocationDetails
            WHERE   RateID = @RateHeaderID AND BOQID = @BOQID
            DECLARE @total DECIMAL(8, 2) ,
                @GrossTotal DECIMAL(8, 2)
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

            SELECT  @GrossTotal
            SELECT  @total
            SELECT  @TotalOCV
            SELECT  @TotalPMV
            SELECT  @Quantity
            SELECT  @DisValue


            UPDATE  dbo.BOQRateanalysisAllocationHeaders
            SET     ProfitMarginVal = @TotalPMV ,
                    OverheadCostVal = @TotalOCV ,
                    TotalPrice = @total ,
                    ProfitMarginPer = ( @TotalPMV / @GrossTotal ) * 100 ,
                    OverheadCostPer = ( @TotalOCV / @GrossTotal ) * 100
            WHERE   RateAnalysisID = @RateHeaderID AND BOQID = @BOQID
          

            UPDATE  dbo.WorkDetails
            SET     Rate = @total
            WHERE   RateAnalysisHeaderID = @RateHeaderID


			Select *  into  #TempSub from BOQSubWorkAllocations
		
			
			DECLARE @totalQT DECIMAL,
                @totalRate DECIMAL,
                @calculatedRate DECIMAL,
				@WorkId INT

			While((select Count(Id) from #TempSub)>0)
			Begin

			set  @totalQT=0;
			set  @totalRate=0;
			set @calculatedRate=0;
			set @WorkId=0;
			
				select top(1) @WorkId = #TempSub.Id from #TempSub

			if EXISTS(select * from WorkDetails where workid=@workid)
			begin
            SELECT  @totalQT = SUM(Quantity) ,
                    @totalRate = SUM(Rate) ,
                    @calculatedRate = SUM(Quantity * Rate)
            FROM    dbo.WorkDetails
            WHERE   WorkID = @WorkID

			UPDATE  dbo.BOQSubWorkAllocations
            --SET   Quantity = @totalQT ,

            SET     Rate = @calculatedRate
            WHERE   BOQID = @BOQID
                    AND Id = @WorkID
			
		
			End

			delete from #TempSub  where #TempSub.Id = @WorkId
			

			end

                  

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
                ROLLBACK TRAN --RollBack in case of Error
        END CATCH






    END

GO

