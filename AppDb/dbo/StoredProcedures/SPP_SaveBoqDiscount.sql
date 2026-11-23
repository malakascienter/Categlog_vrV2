--SPP_SaveBoqDiscount 10,2,''
--SPP_SaveBoqWiseItemDiscount '<BoqWiseItems xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>8</Id><Name /><IsPercentageOrValue>false</IsPercentageOrValue><DiscountPercentage>0</DiscountPercentage><DiscountValue>120</DiscountValue><SectionID>0</SectionID><WorkID>0</WorkID><RateID>72</RateID><BoqID>0</BoqID><ProjectID>0</ProjectID></BoqWiseItems>',1
CREATE PROCEDURE [dbo].[SPP_SaveBoqDiscount]
    (
	  @Workid1 INT,
	  @BOQid INT,
      @status INT OUTPUT
    )
AS
    DECLARE @iDocID INT 

    BEGIN TRY
        BEGIN TRAN
      
	
        IF OBJECT_ID('tempdb.dbo.#BoqsubworkAllocation', 'U') IS NOT NULL
            DROP TABLE #BoqsubworkAllocation; 

        SELECT  [Id] ,
               [BOQID],
			   [WorkID]
			  
        INTO    #BoqsubworkAllocation
		 from BOQSubWorkAllocations where WorkID=@Workid1



		 IF OBJECT_ID('tempdb.dbo.#WorkDetails', 'U') IS NOT NULL
         DROP TABLE #WorkDetails; 

        SELECT  [Id] ,
               [RateAnalysisHeaderID],
			   [WorkID]
			  
        INTO    #WorkDetails 
		 from WorkDetails 



	IF OBJECT_ID('tempdb.dbo.#BOQRateanalysisAllocationHeaders', 'U') IS NOT NULL
         DROP TABLE #BOQRateanalysisAllocationHeaders; 

        SELECT  [ID] ,
               [BOQID],
			   [WorkID],
			   [RateQtyInWork],
			   [RateAnalysisID]
			   
			  
        INTO    #BOQRateanalysisAllocationHeaders
		 from BOQRateanalysisAllocationHeaders 
  

        DECLARE @SectionID INT ,
				@WorkID INT ,
				@NoOfBoqsubworkAllocationRows INT,
				@NoOfWorkDetailsRows INT,
				@NoOfBOQRateanalysisAllocationHeaders INT,
				@RateAnalysisHeaderID INT


	SELECT @NoOfBoqsubworkAllocationRows=Count(Id) FROM #BoqsubworkAllocation where WorkID=@Workid1
	SELECT @NoOfWorkDetailsRows=Count(Id) FROM #WorkDetails where WorkID=@Workid1
	SELECT @NoOfBOQRateanalysisAllocationHeaders=Count(ID) FROM #BOQRateanalysisAllocationHeaders where WorkID=@Workid1
    --SELECT Count(ID) FROM BOQRateanalysisAllocationHeaders where WorkID=4      
                    
while @NoOfBoqsubworkAllocationRows>0
BEGIN
	--SELECT TOP(1) * FROM #BoqsubworkAllocation

			SELECT TOP(1)
					@WorkID = WorkID 
              

	  FROM    #BoqsubworkAllocation
	  WHILE @NoOfWorkDetailsRows>0
	  BEGIN
	  	--SELECT TOP(1) * FROM #BoqsubworkAllocation

			SELECT TOP(1)
					@WorkID = WorkID ,
					@RateAnalysisHeaderID=RateAnalysisHeaderID

	  FROM    #WorkDetails where WorkID=@workid1 
	   WHILE @NoOfBOQRateanalysisAllocationHeaders>0
	  BEGIN
	  	--SELECT TOP(1) * FROM #BOQRateanalysisAllocationHeaders

			SELECT TOP(1)
					@WorkID = WorkID 
              

	  FROM    #BOQRateanalysisAllocationHeaders where RateAnalysisID=@RateAnalysisHeaderID and WorkID=@Workid1
	  
	  EXEC UpdateRateAllocation @BOQid,@Workid1,@RateAnalysisHeaderID

	  SELECT @NoOfBOQRateanalysisAllocationHeaders=Count(ID) FROM #BOQRateanalysisAllocationHeaders where WorkID=@Workid1
	  DELETE TOP(1) FROM #BOQRateanalysisAllocationHeaders
	  
	  END
	  
	  SELECT @NoOfWorkDetailsRows=Count(Id) FROM #WorkDetails where WorkID=@Workid1
	  DELETE TOP(1) FROM #WorkDetails
	  
	  END

	SELECT @NoOfBoqsubworkAllocationRows=Count(Id) FROM #BoqsubworkAllocation where WorkID=@Workid1
	DELETE TOP(1) FROM #BoqsubworkAllocation
	
END


              
  COMMIT TRAN
     
    END TRY

    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
        raiserror('while loop error',18,2)
		SET @status = -1
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN 

    END CATCH

	-- SET NOCOUNT ON added to prevent extra result sets from

GO

