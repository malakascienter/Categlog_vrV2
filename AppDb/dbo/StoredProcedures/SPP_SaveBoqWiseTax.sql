CREATE PROCEDURE [dbo].[SPP_SaveBoqWiseTax]
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
                [Rate] ,
                [SectionID] ,
                [WorkID] 
				[BoqID],
				[ProjectID],
				  [RateID]                
        INTO    #BoqWiseItemDiscounts
        FROM    OPENXML(@iDocID,'BoqTax', 2)
		 WITH ([Id] INT,[Name] VARCHAR(max),[Rate] DECIMAL(18,2),[SectionID] INT,[WorkID] INT,[BoqID] INT,[ProjectID] INT,[RateID] INT)

        DECLARE @SectionID INT ,
            @WorkID INT ,
            @BoqID INT ,
            @Rate DECIMAL(18,2),
			@ProjectID INT,
			@RateID INT 

                    

SELECT * FROM #BoqWiseItemDiscounts

        SELECT  @ProjectID =ProjectID,
                @BoqID = BoqID ,
                @SectionID = SectionID ,
                @WorkID = WorkID ,
                @Rate = Rate
		
  FROM    #BoqWiseItemDiscounts


 
  SELECT * FROM #BoqWiseItemDiscounts

		  UPDATE BRAD
		  SET   TotalTax = CASE WHEN BRAD.IsPercentageOrValue=0 THEN (BRAD.UnitPrice- BRAD.DiscountValue)*BRAD.Quantity*@Rate ELSE (UnitPrice-BRAD.UnitPrice*BRAD.DiscountPercentage)*BRAD.Quantity*@Rate  END
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
							  

              

        EXEC sp_xml_removedocument @iDocID
        IF @@TRANCOUNT > 0
            SET @status = 1
        COMMIT TRAN
     
    END TRY

    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        SET @status = -1
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN 

    END CATCH

	-- SET NOCOUNT ON added to prevent extra result sets from

GO

