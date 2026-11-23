CREATE PROCEDURE [dbo].[SPP_SaveBoqItemWiseTaxes]
    (
      @XMLDetails AS XML ,
      @status INT OUTPUT
    )
AS
    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @iDocID INT;
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

        IF OBJECT_ID('tempdb.dbo.#BoqWiseTax', 'U') IS NOT NULL
            DROP TABLE #BoqWiseTax;

        IF OBJECT_ID('tempdb.dbo.#Temp1', 'U') IS NOT NULL
            DROP TABLE #Temp1;

--SELECT @XMLDetails xmll INTO AAdata
--SELECT * FROM AAdata
--DROP TABLE AAdata

        SELECT  [ProjectId] ,
                [BoqId] ,
                [TaxId] ,
                [TaxRate] ,
                [ItemId] ,
                [IsBOQ]
        INTO    #BoqWiseTax
        FROM    OPENXML(@iDocID, 'ArrayOfBoqTax/BoqTax', 2)
        WITH
        (
            ProjectId INT,
            BoqId INT,
            TaxId INT,
            TaxRate DECIMAL(8, 2),
            ItemId INT,
            IsBOQ BIT
        );

        DECLARE @CheckItem INT ,
            @CheckTaxId INT ,
            @IsBOQ BIT ,
            @CheckBOQId INT;

        SELECT TOP ( 1 )
                @CheckItem = ItemId ,
                @CheckTaxId = TaxId ,
                @CheckBOQId = BoqId ,
                @IsBOQ = IsBOQ
        FROM    #BoqWiseTax;

        DELETE  FROM dbo.BoqTaxes
        WHERE   TaxId = @CheckTaxId
                AND BoqId = @CheckBOQId
              --AND IsBoq = @IsBOQ;

        INSERT  INTO dbo.BoqTaxes
                ( ProjectId ,
                  BoqId ,
                  ItemId ,
                  TaxId ,
                  IsBoq ,
                  TaxRate ,
                  IPAddress ,
                  CreatedUserID ,
                  LastModUserID ,
                  CreatedDate ,
                  LastModDate
                )
                SELECT  ProjectId , -- ProjectId - int
                        BoqId ,     -- BoqId - int -- CategoryId - int
                        ItemId ,    -- ItemId - int
                        TaxId ,
                        IsBoq ,     -- TaxId - int
                        TaxRate ,   -- TaxRate - decimal
                        N'' ,       -- IPAddress - nvarchar(max)
                        0 ,         -- CreatedUserID - int
                        0 ,         -- LastModUserID - int
                        GETDATE() , -- CreatedDate - datetime
                        GETDATE()  -- LastModDate - datetime
                FROM    #BoqWiseTax
				WHERE TaxRate > 0

        UPDATE  dbo.BOQRateanalysisAllocationDetails
        SET     TotalTax = 0 ,
                UnitTax = 0
        WHERE   BOQID = @CheckBOQId

        UPDATE  BOQRateanalysisAllocationDetails
        SET     OverheadCostVal = ( UnitPrice ) * OHCPercentage / 100
        WHERE   ISOHCPercentage = 1
                AND BOQID = @CheckBOQId 

        CREATE TABLE #Temp1
            (
              Id INT ,
              ProjectId INT ,
              BOQId INT ,
              ItemId INT ,
              TaxId INT ,
              TaxRate DECIMAL(8, 2) ,
              IsBoq BIT
            );

        INSERT  INTO #Temp1
                ( Id ,
                --ProjectId,
                  BOQId ,
                  ItemId
                --TaxId,
                --TaxRate,
                --IsBoq
                )
                SELECT  Id ,
                   --ProjectId,
                        BoqId ,
                        ItemId
                   --TaxId,
                   --TaxRate,
                   --IsBoq
                FROM    dbo.BoqTaxes
                WHERE   BoqId = @CheckBOQId;

        DECLARE @id INT
        DECLARE @selectedBOQ INT
        DECLARE @itemID INT
        DECLARE @BOQTax DECIMAL (8,2)

        SELECT  @BOQTax = SUM(TaxRate)
        FROM    dbo.BoqTaxes
        WHERE   BoqId = @CheckBOQId

        WHILE ( ( SELECT    COUNT(Id)
                  FROM      #Temp1
                ) > 0 )
            BEGIN
                SELECT TOP ( 1 )
                        @id = Id ,
                        @selectedBOQ = BOQId ,
                        @itemID = ItemId
                FROM    #Temp1;

                UPDATE  dbo.BOQRateanalysisAllocationDetails
                SET     UnitTax = @BOQTax ,
                        TotalTax = ( UnitPrice * Quantity ) * @BOQTax / 100
                WHERE   BOQID = @selectedBOQ
                        AND ItemID = @itemID;

                UPDATE  BOQRateanalysisAllocationDetails
                SET     OverheadCostVal = ( UnitPrice + ( UnitPrice * UnitTax )
                                            / 100 ) * OHCPercentage / 100
                WHERE   BOQID = @selectedBOQ
                        AND ItemID = @itemID
                        AND ISOHCPercentage = 1;

                DELETE  FROM #Temp1
                WHERE   Id = @id
            END
        EXEC TotalRecalculateBOQ @CheckBOQId

--COMMIT TRANSACTION
        EXEC sp_xml_removedocument @iDocID;

        IF @@TRANCOUNT > 0
            SET @status = 1;
        COMMIT TRAN;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION

        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT;  

        SELECT  @ErrorMessage = ERROR_MESSAGE() ,
                @ErrorSeverity = ERROR_SEVERITY() ,
                @ErrorState = ERROR_STATE();  

     
        RAISERROR (@ErrorMessage,  @ErrorSeverity, @ErrorState );  

    END CATCH

GO

