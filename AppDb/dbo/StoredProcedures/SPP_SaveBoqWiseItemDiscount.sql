--SPP_SaveBoqWiseItemDiscount '<BoqWiseItems xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>225</Id><Name /><IsPercentageOrValue>true</IsPercentageOrValue><DiscountPercentage>10</DiscountPercentage><DiscountValue>0</DiscountValue><SectionID>23</SectionID><WorkID>0</WorkID><RateID>0</RateID><BoqID>0</BoqID><ProjectID>0</ProjectID><Quantity>0</Quantity></BoqWiseItems>',1
CREATE PROCEDURE [dbo].[SPP_SaveBoqWiseItemDiscount]
    (
      @XMLDetails AS XML ,
      @status INT OUTPUT
    )
AS
    DECLARE @iDocID INT 

    BEGIN TRY
        BEGIN TRANSACTION
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	
        IF OBJECT_ID('tempdb.dbo.#BoqWiseItemDiscounts', 'U') IS NOT NULL
            DROP TABLE #BoqWiseItemDiscounts; 

        SELECT  [Id] ,
                [Name] ,
                [IsPercentageOrValue] ,
                [DiscountPercentage] ,
                [DiscountValue] ,
                [SectionID] ,
                [WorkID] ,
                [RateID],
				[BoqID],
				[ProjectID]                
        INTO    #BoqWiseItemDiscounts
        FROM    OPENXML(@iDocID,'BoqWiseItems', 2)
		 WITH ([Id] INT,[Name] VARCHAR(max),[IsPercentageOrValue] BIT,[DiscountPercentage] DECIMAL(18,2),[DiscountValue] DECIMAL(18,2),[SectionID] INT,[WorkID] INT,[RateID] INT,[BoqID] INT,[ProjectID] INT)

        DECLARE @SectionID INT ,
            @WorkID INT ,
            @RateID INT ,
            @BoqID INT ,
            @IsPercentage BIT ,
            @Percentage DECIMAL(18,2) ,
            @Value DECIMAL(18,2) ,
			@ProjectID INT,
			@ItemID INT 
                    

SELECT * FROM #BoqWiseItemDiscounts

        SELECT  @ProjectID =ProjectID,
                @BoqID = BoqID ,
                @SectionID = SectionID ,
                @WorkID = WorkID ,
                @IsPercentage = IsPercentageOrValue ,
                @Percentage = DiscountPercentage ,
                @Value = DiscountValue,
				@ItemID=ID,
				@RateID=RateID

  FROM    #BoqWiseItemDiscounts

  SELECT @ItemID,@RateID

  select * from BOQRateanalysisAllocationDetails
  SELECT * FROM #BoqWiseItemDiscounts

		  UPDATE BRAD
		  SET BRAD.IsPercentageOrValue=@IsPercentage,			
				BRAD.DiscountPercentage=@Percentage,
				 BRAD.DiscountValue = (case when @IsPercentage =1 then (BRAD.UnitPrice+BRAD.OverheadCostVal) *(@Percentage/100) else 
				 @Value end)
        FROM    dbo.BOQMainWorkAllocations BMA
                INNER JOIN dbo.BOQSubWorkAllocations BSA ON BMA.Id = BSA.MainWorkID
                INNER JOIN dbo.WorkHeaders WH ON WH.Id = BSA.WorkID
                INNER JOIN dbo.BOQRateanalysisAllocationHeaders MBH ON MBH.BOQID = BSA.BOQID
                                                              AND MBH.WorkID = BSA.Id
                INNER JOIN dbo.BOQRateanalysisAllocationDetails BRAD ON BRAD.RateID = MBH.RateAnalysisID
                                                              AND BRAD.BOQID = MBH.BOQID
                INNER JOIN dbo.StockItemHeaders SH ON SH.Id = BRAD.ItemID
        WHERE   BRAD.ItemType = 'I'
                AND BMA.Id = ( CASE WHEN @SectionID = 0 THEN BMA.Id
                                    ELSE @SectionID
                               END )
                AND BSA.Id = ( CASE WHEN @WorkID = 0 THEN BSA.Id
                                    ELSE @WorkID
                               END )
                AND MBH.ID = ( CASE WHEN @RateID = 0 THEN MBH.ID
                                    ELSE @RateID
                               END )
							   AND BRAD.ItemID=@ItemID
	  						
      --EXEC  UpdateRateAllocationForPriceChange @BoqID,@RateID
	  EXEC TotalRecalculateBOQ @BoqID
        EXEC sp_xml_removedocument @iDocID
        IF @@TRANCOUNT > 0
            SET @status = 1
        COMMIT TRAN
     
    END TRY

    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        SET @status = -1
		raiserror('while loop error',18,2)
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN 

    END CATCH

	-- SET NOCOUNT ON added to prevent extra result sets from

GO

