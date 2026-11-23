
--[dbo].[SPP_SaveBoqWiseItemOHC] '<BOQHOCChange xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>::1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-27T08:24:58.38Z</CreatedDate><LastModDate>2018-10-27T08:24:58.38Z</LastModDate><Id>-1</Id><ProjectId>3</ProjectId><BoqId>1</BoqId><SectionId>0</SectionId><WorkId>0</WorkId><RateId>7</RateId><ItemId>10</ItemId><OhcpRate>0</OhcpRate><OhcpValue>0</OhcpValue></BOQHOCChange>',1
CREATE PROCEDURE [dbo].[SPP_SaveBoqWiseItemOHC]
    (
      @XMLDetails AS XML ,
      @status INT OUTPUT
    )
AS
    DECLARE @iDocID INT 

    BEGIN TRY
        BEGIN TRANSACTION
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	
        IF OBJECT_ID('tempdb.dbo.#BoqWiseItemOHC', 'U') IS NOT NULL
            DROP TABLE #BoqWiseItemOHC; 

        SELECT  [Id] ,
                [ProjectId] ,
                [BoqId] ,
                [SectionId] ,              
                [WorkId] ,
                [RateId],
				[ItemId],
				[OhcpRate] ,
				[OhcpValue],
				[IPAddress],
				[CreatedUserID],
				[LastModUserID],
				[CreatedDate],
				[LastModDate]               
        INTO    #BoqWiseItemOHC
        FROM    OPENXML(@iDocID,'BOQHOCChange', 2)
		 WITH ([Id] INT,[Name] VARCHAR(max),[ProjectId] int,[BoqId] int,[SectionId] INT,[WorkId] INT,[RateId] INT,[ItemId] INT,[OhcpRate] DECIMAL(18,2),[OhcpValue] DECIMAL(18,2),[IPAddress] VARCHAR(max),[CreatedUserID] INT,[LastModUserID] INT,[CreatedDate] DATETIME,[LastModDate] DATETIME)

        DECLARE @SectionID INT ,
            @WorkID INT ,
            @RateID INT ,
            @BoqID INT ,
			@ProjectID INT,
			@ItemID INT,
			@NewVal DECIMAL(18,2),
			@OldVal DECIMAL(18,2) 

		INSERT INTO dbo.BoqOHCVCharges
		        ( ProjectId ,
		          BoqId ,
		          SectionId ,
		          WorkId ,
		          RateId ,
		          ItemId ,
		          OhcpRate ,
		          OhcpValue,
				  IPAddress,
				CreatedUserID,
				LastModUserID,
				CreatedDate,
				LastModDate    
		        )
SELECT [ProjectId] ,
                [BoqId] ,
                [SectionId] ,              
                [WorkId] ,
                [RateId],
				[ItemId],
				[OhcpRate] ,
				[OhcpValue],
				[IPAddress],
				[CreatedUserID],
				[LastModUserID],
				GETDATE(),
				[LastModDate]     FROM #BoqWiseItemOHC
                    



        SELECT  @ProjectID =ProjectId,
                @BoqID = BoqId ,
                @SectionID = SectionId ,
                @WorkID = WorkID ,              
				@ItemID=ItemId,
				@RateID=RateID,
				@NewVal=OhcpValue,
				@OldVal=OhcpRate  

  FROM    #BoqWiseItemOHC

  select * from BOQRateanalysisAllocationDetails

  SELECT @ItemID,@RateID

  SELECT * FROM #BoqWiseItemOHC

		  UPDATE BRAD 
		  SET BRAD.ISOHCPercentage = case when @OldVal=0 then 0 else 1 end,
		  BRAD.OverheadCostVal= case when @OldVal=0 then @NewVal else  BRAD.UnitPrice*(@OldVal/100) end,
				BRAD.OHCPercentage=@OldVal
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


			



			 UPDATE MBH 
		  SET MBH.OverheadCostVal=@NewVal 
		  
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

		
		UPDATE BRAD
		  
				 SET BRAD.DiscountValue = (BRAD.UnitPrice+BRAD.OverheadCostVal)*BRAD.DiscountPercentage
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
							   AND BRAD.ItemID=@ItemID AND BRAD.IsPercentageOrValue=1




              
		 EXEC TotalRecalculateBOQ @BoqID	
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

