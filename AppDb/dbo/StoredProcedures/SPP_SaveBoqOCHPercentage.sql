CREATE PROCEDURE [dbo].[SPP_SaveBoqOCHPercentage]
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
            DROP TABLE  #BoqOHCP; 
        SELECT  *
        FROM    dbo.BoqTaxes
        SELECT  [ProjectID] ,
                [BoqID] ,
                [OHCP] ,
                [ItemID]
        INTO    #BoqOHCP
        FROM    OPENXML(@iDocID,'Arrayofboqtax', 2)
		 WITH (ProjectID INT ,
		    BoqID INT,
			OHCP DECIMAL,   
			ItemID INT
           
			)

        DECLARE @ProjectID INT ,
            @BoqID INT ,
            @ItemID INT ,
            @OHCP INT ,
            @TotalTax DECIMAL = 0
            
			


        WHILE ( ( SELECT    COUNT(ItemID)
                  FROM      #BoqOHCP
                ) > 0 )
            BEGIN



                SELECT TOP ( 1 )
                        @ProjectID = ProjectID ,
                        @BoqID = BoqID ,
                        @ItemID = ItemID ,
                        @OHCP = OHCP
                FROM    #BoqOHCP


                IF EXISTS ( SELECT  *
                            FROM    dbo.BoqOHCVCharges
                            WHERE   ProjectId = @ProjectID
                                    AND BoqId = @BoqID
                                    AND ItemId = @ItemID
                                    AND OhcpRate = @OHCP )
                    BEGIN
                             

                        DELETE  FROM BoqOHCVCharges
                        WHERE   ProjectId = @ProjectID
                                AND BoqId = @BoqID
                                AND ItemId = @ItemID
                            

                        INSERT  INTO dbo.BoqOHCVCharges
                                ( ProjectId ,
                                  BoqId ,
                                  SectionId ,
                                  WorkId ,
                                  RateId ,
                                  ItemId ,
                                  OhcpRate ,
                                  OhcpValue ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate
                                )
                        VALUES  ( @ProjectID , -- ProjectId - int
                                  @BoqID , -- BoqId - int
                                  0 , -- SectionId - int
                                  0 , -- WorkId - int
                                  0 , -- RateId - int
                                  0 , -- ItemId - int
                                  NULL , -- OhcpRate - decimal
                                  @OHCP , -- OhcpValue - decimal
                                  N'' , -- IPAddress - nvarchar(max)
                                  0 , -- CreatedUserID - int
                                  0 , -- LastModUserID - int
                                  GETDATE() , -- CreatedDate - datetime
                                  GETDATE()  -- LastModDate - datetime
                                )


                       
                                 

                        UPDATE  dbo.BOQRateanalysisAllocationDetails
                        SET     OverheadCostVal = UnitPrice * @OHCP / 100
                        WHERE   BOQID = @BoqID
                                AND ItemID = @ItemID



									
                    
                      


							
                    END

                ELSE
                    BEGIN

                        INSERT  INTO dbo.BoqOHCVCharges
                                ( ProjectId ,
                                  BoqId ,
                                  SectionId ,
                                  WorkId ,
                                  RateId ,
                                  ItemId ,
                                  OhcpRate ,
                                  OhcpValue ,
                                  IPAddress ,
                                  CreatedUserID ,
                                  LastModUserID ,
                                  CreatedDate ,
                                  LastModDate
                                )
                        VALUES  ( @ProjectID , -- ProjectId - int
                                  @BoqID , -- BoqId - int
                                  0 , -- SectionId - int
                                  0 , -- WorkId - int
                                  0 , -- RateId - int
                                  0 , -- ItemId - int
                                  NULL , -- OhcpRate - decimal
                                  @OHCP , -- OhcpValue - decimal
                                  N'' , -- IPAddress - nvarchar(max)
                                  0 , -- CreatedUserID - int
                                  0 , -- LastModUserID - int
                                  GETDATE() , -- CreatedDate - datetime
                                  GETDATE()  -- LastModDate - datetime
                                )


                       
                                 

                        UPDATE  dbo.BOQRateanalysisAllocationDetails
                        SET     OverheadCostVal = UnitPrice * @OHCP / 100
                        WHERE   BOQID = @BoqID
                                AND ItemID = @ItemID



                    END


                DELETE  FROM #BoqOHCP
                WHERE   ProjectId = @ProjectID
                        AND BoqId = @BoqID
                        AND ItemId = @ItemID
                        

            END
		
		
		 
      
				

               

   

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

GO

