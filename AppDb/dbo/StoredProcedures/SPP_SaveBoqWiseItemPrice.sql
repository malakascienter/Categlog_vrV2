
--[dbo].[SPP_SaveBoqWiseItemPrice] '<BoqPriceChangeLog xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><IPAddress>::1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-10-27T08:24:58.38Z</CreatedDate><LastModDate>2018-10-27T08:24:58.38Z</LastModDate><Id>-1</Id><ProjectId>3</ProjectId><BoqId>1</BoqId><SectionId>0</SectionId><WorkId>0</WorkId><RateId>7</RateId><ItemId>10</ItemId><RevisionPrice>0</RevisionPrice><NewPrice>0</NewPrice></BoqPriceChangeLog>',1
CREATE PROCEDURE [dbo].[SPP_SaveBoqWiseItemPrice]
    (
      @XMLDetails AS XML ,
      @status INT OUTPUT
    )
AS
    DECLARE @iDocID INT 

    BEGIN TRY
        BEGIN TRANSACTION
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	
        IF OBJECT_ID('tempdb.dbo.#BoqWiseItemPrice', 'U') IS NOT NULL
            DROP TABLE #BoqWiseItemPrice; 

        SELECT  [Id] ,
                [ProjectId] ,
                [BoqId] ,
                [SectionId] ,              
                [WorkId] ,
                [RateId],
				[ItemId],
				[RevisionPrice] ,
				[NewPrice],
				[IPAddress],
				[CreatedUserID],
				[LastModUserID],
				[CreatedDate],
				[LastModDate]               
        INTO    #BoqWiseItemPrice
        FROM    OPENXML(@iDocID,'BoqPriceChangeLog', 2)
		 WITH ([Id] INT,[Name] VARCHAR(max),[ProjectId] int,[BoqId] int,[SectionId] INT,[WorkId] INT,[RateId] INT,[ItemId] INT,[RevisionPrice] DECIMAL(18,2),[NewPrice] DECIMAL(18,2),[IPAddress] VARCHAR(max),[CreatedUserID] INT,[LastModUserID] INT,[CreatedDate] DATETIME,[LastModDate] DATETIME)

        DECLARE @SectionID INT ,
            @WorkID INT ,
            @RateID INT ,
            @BoqID INT ,
			@ProjectID INT,
			@ItemID INT,
			@NewPrice DECIMAL(18,2),
			@OldPrice DECIMAL(18,2) 

		INSERT INTO dbo.BoqPriceChangeLogs
		        ( ProjectId ,
		          BoqId ,
		          SectionId ,
		          WorkId ,
		          RateId ,
		          ItemId ,
		          RevisionPrice ,
		          NewPrice,
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
				[RevisionPrice] ,
				[NewPrice],
				[IPAddress],
				[CreatedUserID],
				[LastModUserID],
				GETDATE(),
				[LastModDate]     FROM #BoqWiseItemPrice
                    



        SELECT  @ProjectID =ProjectId,
                @BoqID = BoqId ,
                @SectionID = SectionId ,
                @WorkID = WorkID ,              
				@ItemID=ItemId,
				@RateID=RateID,
				@NewPrice=NewPrice,
				@OldPrice=RevisionPrice

  FROM    #BoqWiseItemPrice

  SELECT @ItemID,@RateID

  SELECT * FROM #BoqWiseItemPrice

		  UPDATE BRAD
		  SET BRAD.UnitPrice=@NewPrice
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

              
		 EXEC TotalRecalculateBOQ  @BoqID	
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

