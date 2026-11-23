-- SPP_SaveBoqWiseDiscount'<BoqWiseDiscounts><Id>0</Id><ProjectID>2</ProjectID><SectionID>0</SectionID><WorkID>0</WorkID><BoqDiscount>true</BoqDiscount><SectionDiscount>false</SectionDiscount><WorkDiscount>false</WorkDiscount><DiscountPercentage>0</DiscountPercentage><DiscountValue>10</DiscountValue><IsPercentageForDiscount>false</IsPercentageForDiscount><BoqID>79</BoqID><RateID>0</RateID><RateDiscount>false</RateDiscount><ALLItems>true</ALLItems></BoqWiseDiscounts>',-1
CREATE PROCEDURE [dbo].[SPP_SaveBoqWiseDiscount]
    (
      @XMLDetails AS XML ,
      @status INT OUTPUT
    )
AS
    DECLARE @iDocID INT 

    BEGIN TRY
        BEGIN TRANSACTION
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

	
        IF OBJECT_ID('tempdb.dbo.#BoqWiseDiscounts', 'U') IS NOT NULL
            DROP TABLE #BoqWiseDiscounts; 

        SELECT  [ProjectID] ,
                [SectionID] ,
                [WorkID] ,
                [BoqDiscount] ,
                [SectionDiscount] ,
                [WorkDiscount] ,
                [DiscountPercentage] ,
                [DiscountValue] ,
                [IsPercentageForDiscount] ,
                [BoqID],
				[RateID],
				[RateDiscount],
				[ALLItems],
				[ItemType]
        INTO    #BoqWiseDiscounts
        FROM    OPENXML(@iDocID,'BoqWiseDiscounts', 2)
		 WITH BoqWiseDiscounts

        DECLARE @ProjectID INT ,
            @SectionID INT ,
            @WorkID INT ,
            @BoqID INT ,
            @IsPercentage BIT ,
            @Percentage DECIMAL(18,2) ,
            @Value DECIMAL(18,2) ,
            @ISBoq BIT ,
            @ISSection BIT ,
            @ISWork BIT,
			@ISRate BIT,
			@RateID int,
			@ALLItems BIT,
			@RateHeaderID INT,
			@ItemType Varchar(max)        



        SELECT  @ProjectID = ProjectID ,
                @BoqID = BoqID ,
                @SectionID = SectionID ,
                @WorkID = WorkID ,
                @IsPercentage = IsPercentageForDiscount ,
                @Percentage = DiscountPercentage ,
                @Value = DiscountValue ,
                @ISBoq = BoqDiscount ,
                @ISSection = SectionDiscount ,
                @ISWork = WorkDiscount,
				@ISRate = RateDiscount,
				@RateID = RateID,
				@ALLItems= ALLItems,
				@ItemType =ItemType 
        FROM    #BoqWiseDiscounts

		IF(@ISBoq=1)
		BEGIN
		SET @SectionID=0
		SET @WorkID=0
		SET @RateID=0

		END
        
		IF(@ISSection=1)
		BEGIN
		SET @WorkID=0
		SET @RateID=0
		END
        

		IF(@ISWork=1)
		BEGIN
		SET @RateID=0

		END


        IF EXISTS ( SELECT  *
                    FROM    dbo.BoqWiseDiscounts
                    WHERE   ProjectID = @ProjectID
                            AND BoqID = @BoqID
                            AND SectionDiscount=@ISSection
                            AND WorkDiscount=@ISWork
							AND RateDiscount=@ISRate AND SectionID=@SectionID AND WorkID=@WorkID AND RateID=@RateID AND ItemType= @ItemType) --AND BoqDiscount=@ISBoq AND WorkDiscount=@ISWork AND SectionDiscount=@ISSection )
            BEGIN

                UPDATE  dbo.BoqWiseDiscounts
                SET     IsPercentageForDiscount = @IsPercentage ,
                        DiscountPercentage = @Percentage ,
                        DiscountValue = @Value ,
                        BoqDiscount = @ISBoq ,
                        SectionDiscount = @ISSection ,
                        SectionID = @SectionID ,
                        WorkID = @WorkID ,
                        WorkDiscount = @ISWork
                WHERE   ProjectID = @ProjectID
                        AND BoqID = @BoqID 
						AND SectionID=@SectionID
						AND WorkID=@WorkID
						AND RateID=@RateID
						AND ItemType= @ItemType
						--AND SectionID=(CASE WHEN @SectionID=0 THEN SectionID ELSE @SectionID END) AND WorkID=(CASE WHEN @WorkID=0 THEN WorkID ELSE @WorkID END) 
						--AND RateID=(CASE WHEN @RateID=0 THEN RateID ELSE @RateID END)


                IF ( @ISBoq = 1 )
                    BEGIN

					IF(@ALLItems =1)
						BEGIN
						
						
						update BOQRateanalysisAllocationDetails set 
						DiscountValue = case when @IsPercentage=1 and @Percentage<>0  then  (UnitPrice+OverheadCostVal)*@Percentage/100 else @Value end,
						IsPercentageOrValue=@IsPercentage,
						DiscountPercentage = @Percentage
						Where BOQID=@BoqID AND ItemType=@ItemType


						 

						--select * from BOQRateanalysisAllocationDetails where BOQID =67

						--select * from BOQMainWorkAllocations

						--select * from BOQSubWorkAllocations

						--select * from WorkDetails
						--select * from BOQRateanalysisAllocationHeaders

						--select * from boqheaders as BH
						--inner join BOQMainWorkAllocations as BMA on BH.Id=BMA.BOQID
						--inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BH.Id
						--inner join WorkDetails as WD on WD.WorkID =BSA.Id
						--inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BH.Id
						--inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BH.Id=67

						--select * from BOQRateanalysisAllocationDetails where BOQID =67

						END

						ELSE
						BEGIN
                        UPDATE  dbo.BOQHeaders
                        SET     IsPercentageOrValue = @IsPercentage ,
                                DiscountPercentage = @Percentage ,
                                DiscountValue = @Value
                        WHERE   ProjectID = @ProjectID
                                AND Id = @BoqID
						
						END
                        --UPDATE  dbo.BOQMainWorkAllocations
                        --SET     IsPercentageOrValue = 0 ,
                        --        DiscountPercentage = 0 
                        --   --     DiscountValue = 0
                        --WHERE   Id = @SectionID
                        --        AND BOQID = @BoqID
                        --UPDATE  dbo.BOQSubWorkAllocations
                        --SET     IsPercentageOrValue = 0 ,
                        --        DiscountPercentage = 0 
                        --   --     DiscountValue = 0
                        --WHERE   Id = @WorkID
                        --        AND BOQID = @BoqID
                        --        AND MainWorkID = @SectionID

                        --UPDATE  BRD
                        --SET     BRD.IsPercentageOrValue = @IsPercentage ,
                        --        BRD.DiscountPercentage = @Percentage
                        --FROM    dbo.BOQRateanalysisAllocationHeaders BRH
                        --        INNER JOIN dbo.BOQRateanalysisAllocationDetails BRD ON BRH.RateAnalysisID = BRD.RateID
                        --WHERE   BRH.BOQID = @BoqID

				
                    END
                ELSE
                    IF ( @ISSection = 1 )
                        BEGIN


						IF(@ALLItems =1)
						BEGIN
							
						update BRD  SET BRD.DiscountValue = case when @IsPercentage=1 and @Percentage<>0 then  (BRD.UnitPrice+BRD.OverheadCostVal)*@Percentage/100 else @Value end,
						BRD.IsPercentageOrValue=@IsPercentage,
						BRD.DiscountPercentage = @Percentage 
						from BOQMainWorkAllocations as BMA 
						inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BMA.BOQID
						inner join WorkDetails as WD on WD.WorkID =BSA.Id
						inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BMA.BOQID
						inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BMA.BOQID=@BoqID and BMA.Id=@SectionID AND BRD.ItemType=@ItemType
						

						END

						ELSE
						BEGIN

                            UPDATE  dbo.BOQMainWorkAllocations
                            SET     IsPercentageOrValue = @IsPercentage ,
                                    DiscountPercentage = @Percentage ,
                                    DiscountValue = @Value
                            WHERE   Id = @SectionID
                                    AND BOQID = @BoqID
                            --UPDATE  dbo.BOQHeaders
                            --SET     IsPercentageOrValue = 0 ,
                            --        DiscountPercentage = 0 
                            --    --    DiscountValue = 0
                            --WHERE   ProjectID = @ProjectID
                            --        AND Id = @BoqID
                            --UPDATE  dbo.BOQSubWorkAllocations
                            --SET     IsPercentageOrValue = 0 ,
                            --        DiscountPercentage = 0 
                            --     --   DiscountValue = 0
                            --WHERE   Id = @WorkID
                            --        AND BOQID = @BoqID
                            --        AND MainWorkID = @SectionID


									
                            --UPDATE  BRD
                            --SET     BRD.IsPercentageOrValue = @IsPercentage ,
                            --        BRD.DiscountPercentage = @Percentage
                            --FROM    dbo.BOQRateanalysisAllocationHeaders BRH
                            --        INNER JOIN dbo.BOQRateanalysisAllocationDetails BRD ON BRH.RateAnalysisID = BRD.RateID
                            --        INNER JOIN dbo.BOQMainWorkAllocations BSW ON BSW.BOQID = BRD.BOQID
                                                              
                            --WHERE   BRH.BOQID = @BoqID
                            --        AND BSW.BOQID = @BoqID
                            --        AND BSW.Id = @SectionID
							END
                        END
                    ELSE
                        IF ( @ISWork = 1 )
                            BEGIN

								IF(@ALLItems =1)
								BEGIN

								update BRD  SET BRD.DiscountValue = case when @IsPercentage=1 and @Percentage<>0 then  (BRD.UnitPrice+BRD.OverheadCostVal)*@Percentage/100 else @Value end,
								BRD.IsPercentageOrValue=@IsPercentage,
								BRD.DiscountPercentage = @Percentage
								from
								BOQMainWorkAllocations as BMA 
								inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BMA.BOQID
								inner join WorkDetails as WD on WD.WorkID =BSA.Id
								inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BMA.BOQID
								inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BMA.BOQID=@BoqID and BMA.Id=@SectionID and BSA.Id=@WorkID AND BRD.ItemType=@ItemType
		

								END

								ELSE
								BEGIN

								UPDATE  dbo.BOQSubWorkAllocations
                                SET     IsPercentageOrValue = @IsPercentage ,
                                        DiscountPercentage = @Percentage, 
                                        DiscountValue = @Value
                                WHERE   Id = @WorkID
                                        AND BOQID = @BoqID
                                        AND MainWorkID = @SectionID
								END


                                
                                --UPDATE  dbo.BOQHeaders
                                --SET     IsPercentageOrValue = 0 ,
                                --        DiscountPercentage = 0 
                                -- --       DiscountValue = 0
                                --WHERE   ProjectID = @ProjectID
                                --        AND Id = @BoqID
                                --UPDATE  dbo.BOQMainWorkAllocations
                                --SET     IsPercentageOrValue = 0 ,
                                --        DiscountPercentage = 0 
                                --  --      DiscountValue = 0
                                --WHERE   Id = @SectionID
                                --        AND BOQID = @BoqID


                                --UPDATE  BRD
                                --SET     BRD.IsPercentageOrValue = @IsPercentage ,
                                --        BRD.DiscountPercentage = @Percentage
                                --FROM    dbo.BOQRateanalysisAllocationHeaders BRH
                                --        INNER JOIN dbo.BOQRateanalysisAllocationDetails BRD ON BRH.RateAnalysisID = BRD.RateID
                                --WHERE   BRD.BOQID = @BoqID
                                --        AND BRH.WorkID = @WorkID 
                            END 

							ELSE IF (@ISRate=1)
							BEGIN


							If(@ALLItems =1)
							BEGIN


							select @RateHeaderID=RateAnalysisID from BOQRateanalysisAllocationHeaders where Id= @RateID


							update BRD  SET BRD.DiscountValue = case when @IsPercentage=1 and @Percentage<>0 then  (BRD.UnitPrice+BRD.OverheadCostVal)*@Percentage/100 else @Value end,
								BRD.IsPercentageOrValue=@IsPercentage,
								BRD.DiscountPercentage = @Percentage
								from
								BOQMainWorkAllocations as BMA 
								inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BMA.BOQID
								inner join WorkDetails as WD on WD.WorkID =BSA.Id
								inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BMA.BOQID
								inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BMA.BOQID=@BoqID and BMA.Id=@SectionID and BSA.Id=@WorkID and BRA.RateAnalysisID=@RateHeaderID AND BRD.ItemType=@ItemType


							END
							ELSE
							BEGIN
							
							UPDATE dbo.BOQRateanalysisAllocationHeaders SET IsPercentageOrValue=@IsPercentage,
							DiscountPercentage=@Percentage,DiscountValue=@Value WHERE ID=@RateID AND BOQID=@BoqID AND WorkID=@WorkID  

							END
                        

							END 

		 
            END  

        ELSE
            
                BEGIN

                    INSERT  INTO dbo.BoqWiseDiscounts
                            ( ProjectID ,
                              SectionID ,
                              WorkID ,
                              BoqDiscount ,
                              SectionDiscount ,
                              WorkDiscount ,
                              DiscountPercentage ,
                              DiscountValue ,
                              IsPercentageForDiscount ,
                              BoqID,
							  RateID,
							  RateDiscount,
							  ALLItems,
							  ItemType
		                    )
                            SELECT  *
                            FROM    #BoqWiseDiscounts
                    IF ( @ISBoq = 1 )
                        BEGIN


						IF(@ALLItems =1)
						BEGIN

						update BOQRateanalysisAllocationDetails set 
						DiscountValue = case when @IsPercentage=1 and @Percentage<>0 then  (UnitPrice+OverheadCostVal)*@Percentage/100 else @Value end,
						IsPercentageOrValue=@IsPercentage,
						DiscountPercentage = @Percentage
						Where BOQID=@BoqID AND ItemType=@ItemType

						END
						BEGIN
						
                            UPDATE  dbo.BOQHeaders
                            SET     IsPercentageOrValue = @IsPercentage ,
                                    DiscountPercentage = @Percentage ,
                                    DiscountValue = @Value
                            WHERE   ProjectID = @ProjectID
                                    AND Id = @BoqID
						END


                        END
                    ELSE
                        IF ( @ISSection = 1 )
                            BEGIN

							IF(@ALLItems =1)
						BEGIN
							
						update BRD  SET BRD.DiscountValue =case when @IsPercentage=1 and @Percentage<>0 then (BRD.UnitPrice+BRD.OverheadCostVal)*@Percentage/100 else @Value end,
						BRD.IsPercentageOrValue=@IsPercentage,
						BRD.DiscountPercentage = @Percentage 
						from BOQMainWorkAllocations as BMA 
						inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BMA.BOQID
						inner join WorkDetails as WD on WD.WorkID =BSA.Id
						inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BMA.BOQID
						inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BMA.BOQID=@BoqID and BMA.Id=@SectionID AND BRD.ItemType=@ItemType
						

						END
						ELSE
						BEGIN
						

                                UPDATE  dbo.BOQMainWorkAllocations
                                SET     IsPercentageOrValue = @IsPercentage ,
                                        DiscountPercentage = @Percentage ,
                                        DiscountValue = @Value
                                WHERE   Id = @SectionID
                                        AND BOQID = @BoqID

						END


                            END
                        ELSE
                            IF ( @ISWork = 1 )
                                BEGIN

								
								IF(@ALLItems =1)
								BEGIN

								update BRD  SET BRD.DiscountValue = case when @IsPercentage=1 and @Percentage<>0 then  (BRD.UnitPrice+BRD.OverheadCostVal)*@Percentage/100 else @Value end,
								BRD.IsPercentageOrValue=@IsPercentage,
								BRD.DiscountPercentage = @Percentage
								from
								BOQMainWorkAllocations as BMA 
								inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BMA.BOQID
								inner join WorkDetails as WD on WD.WorkID =BSA.Id
								inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BMA.BOQID
								inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BMA.BOQID=@BoqID and BMA.Id=@SectionID and BSA.Id=@WorkID AND BRD.ItemType=@ItemType
		

								END
								ELSE
								BEGIN
								  UPDATE  dbo.BOQSubWorkAllocations
                                    SET     IsPercentageOrValue = @IsPercentage ,
                                            DiscountPercentage = @Percentage ,
                                            DiscountValue = @Value
                                    WHERE   Id = @WorkID
                                            AND BOQID = @BoqID
                                            AND MainWorkID = @SectionID
								END


                                  

                                END 

						ELSE IF (@ISRate=1)
							BEGIN

							If(@ALLItems =1)
							BEGIN


							select @RateHeaderID=RateAnalysisID from BOQRateanalysisAllocationHeaders where Id= @RateID

							update BRD  SET BRD.DiscountValue = case when @IsPercentage=1 and @Percentage<>0 then (BRD.UnitPrice+BRD.OverheadCostVal)*@Percentage/100 else @Value end,
								BRD.IsPercentageOrValue=@IsPercentage,
								BRD.DiscountPercentage = @Percentage
								from
								BOQMainWorkAllocations as BMA 
								inner join BOQSubWorkAllocations as BSA on BSA.MainWorkID=BMA.Id and BSA.BOQID=BMA.BOQID
								inner join WorkDetails as WD on WD.WorkID =BSA.Id
								inner join BOQRateanalysisAllocationHeaders as BRA on WD.RateAnalysisHeaderID=BRA.RateAnalysisID and BRA.BOQID=BMA.BOQID
								inner join BOQRateanalysisAllocationDetails as BRD on BRA.RateAnalysisID=BRD.RateID and BRA.BOQID=BRD.BOQID where BMA.BOQID=@BoqID and BMA.Id=@SectionID and BSA.Id=@WorkID and BRA.RateAnalysisID=@RateHeaderID AND BRD.ItemType=@ItemType
		


							END
							ELSE
							BEGIN
							
							UPDATE dbo.BOQRateanalysisAllocationHeaders SET IsPercentageOrValue=@IsPercentage,
							DiscountPercentage=@Percentage,DiscountValue=@Value WHERE ID=@RateID AND BOQID=@BoqID AND WorkID=@WorkID                          

							END



							END 


                END

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

