--SELECT * FROM dbo.BoqTaxes
--SELECT * FROM dbo.BOQRateanalysisAllocationDetails


--[dbo].[SPP_SaveBoqItemWiseTaxes]'<ArrayOfBoqTax xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><BoqTax><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>0001-01-01T00:00:00</CreatedDate><LastModDate>0001-01-01T00:00:00</LastModDate><Id>0</Id><ProjectId>3</ProjectId><BoqId>14</BoqId><ItemId>8</ItemId><ItemName>0</ItemName><TaxId>1</TaxId><TaxRate>15</TaxRate></BoqTax><BoqTax><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>0001-01-01T00:00:00</CreatedDate><LastModDate>0001-01-01T00:00:00</LastModDate><Id>0</Id><ProjectId>3</ProjectId><BoqId>14</BoqId><ItemId>17</ItemId><ItemName>0</ItemName><TaxId>1</TaxId><TaxRate>15</TaxRate></BoqTax></ArrayOfBoqTax>',-1


--[dbo].[SPP_SaveBoqItemWiseTaxes]'<ArrayOfBoqTax xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><BoqTax><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>0001-01-01T00:00:00</CreatedDate><LastModDate>0001-01-01T00:00:00</LastModDate><Id>0</Id><ProjectId>3</ProjectId><BoqId>14</BoqId><ItemId>-99</ItemId><ItemName>0</ItemName><TaxId>5</TaxId><TaxRate>2.04</TaxRate></BoqTax></ArrayOfBoqTax>',-1

--[dbo].[SPP_SaveBoqItemWiseTaxes]'<ArrayOfBoqTax><BoqTax><CreatedUserID>0</CreatedUserID><LastModUserID>0</LastModUserID><CreatedDate>0001-01-01T00:00:00</CreatedDate><LastModDate>0001-01-01T00:00:00</LastModDate><Id>0</Id><ProjectId>1</ProjectId><BoqId>5</BoqId><ItemId>5459</ItemId><ItemName>0</ItemName><TaxId>11</TaxId><TaxRate>3</TaxRate><IsBOQ>true</IsBOQ></BoqTax></ArrayOfBoqTax>',-1
CREATE PROCEDURE [dbo].[SPP_SaveBoqItemWiseTaxes_old]
(
    @XMLDetails AS XML,
    @status INT OUTPUT
)
AS
DECLARE @iDocID INT;

BEGIN TRY
    BEGIN TRANSACTION;
    EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

    IF OBJECT_ID('tempdb.dbo.#Temp1', 'U') IS NOT NULL
        DROP TABLE #Temp1;
    IF OBJECT_ID('tempdb.dbo.#Temp2', 'U') IS NOT NULL
        DROP TABLE #Temp2;

    IF OBJECT_ID('tempdb.dbo.#BoqWiseTax', 'U') IS NOT NULL
        DROP TABLE #BoqWiseTax;
    --SELECT  *
    --FROM    dbo.BoqTaxes

	--select @XMLDetails XMLDetails into AAdata
	--select * from AAdata
	--drop table AAdata

    SELECT [ProjectId],
           [BoqId],
           [TaxId],
           [TaxRate],
           [ItemId],
           [IsBOQ]
    INTO #BoqWiseTax
    FROM
        OPENXML(@iDocID, 'ArrayOfBoqTax/BoqTax', 2)
        WITH
        (
            ProjectId INT,
            BoqId INT,
            TaxId INT,
            TaxRate DECIMAL(8, 2),
            ItemId INT,
            IsBOQ BIT
        );


    DECLARE @CheckItem INT,
            @CheckTaxId INT,
            @IsBOQ BIT,
            @CheckBOQId INT;

    SELECT TOP (1)
           @CheckItem = ItemId,
           @CheckTaxId = TaxId,
           @CheckBOQId = BoqId,
           @IsBOQ = IsBOQ
    FROM #BoqWiseTax;

    IF (@CheckItem = -99)
    BEGIN

        DELETE FROM dbo.BoqTaxes
        WHERE TaxId = @CheckTaxId
              AND BoqId = @CheckBOQId
              AND IsBoq = @IsBOQ;



        CREATE TABLE #Temp2
        (
            Id INT,
            ProjectId INT,
            BOQId INT,
            ItemId INT,
            TaxId INT,
            TaxRate DECIMAL(8, 2),
            IsBoq BIT
        );

		

        IF ((SELECT COUNT(Id) FROM dbo.BoqTaxes where BoqId = @CheckBOQId) > 0)
        BEGIN
            INSERT INTO #Temp2
            (
                Id,
                ProjectId,
                BOQId,
                ItemId,
                TaxId,
                TaxRate,
                IsBoq
            )
            SELECT Id,
                   ProjectId,
                   BOQId,
                   ItemId,
                   TaxId,
                   TaxRate,
                   IsBoq
            FROM dbo.BoqTaxes Where BOQId=@CheckBOQId;

            DECLARE @Id2 INT,
                    @BOQID3 INT,
                    @ItemID3 INT,
                    @Rate3 DECIMAL(8, 2);

            UPDATE dbo.BOQRateanalysisAllocationDetails
            SET TotalTax = 0,
                UnitTax = 0
			Where BOQId= @CheckBOQId

			 UPDATE BOQRateanalysisAllocationDetails
                SET OverheadCostVal = (UnitPrice) * OHCPercentage/100
				where  ISOHCPercentage=1    AND BOQId=@CheckBOQId   


            WHILE ((SELECT COUNT(Id) FROM #Temp2) > 0)
            BEGIN

                SELECT TOP (1)
                       @Id2 = Id,
                       @BOQID3 = BOQId,
                       @ItemID3 = ItemId,
                       @Rate3 = TaxRate,
                       @IsBOQ = IsBoq
                FROM #Temp2;

                UPDATE dbo.BOQRateanalysisAllocationDetails
                SET TotalTax = CASE
                                   WHEN @IsBOQ = 0 THEN
                                       TotalTax + @Rate3 * Quantity
                                   ELSE
                                       TotalTax
                               END,
                    UnitTax = CASE
                                  WHEN @IsBOQ = 1 THEN
                                      UnitTax + @Rate3
                                  ELSE
                                      UnitTax
                              END
                WHERE BOQID = @BOQID3
                      AND ItemID = @ItemID3;
					


			    UPDATE BOQRateanalysisAllocationDetails
            SET OverheadCostVal = CASE
                                      WHEN @IsBOQ = 1 THEN
                (UnitPrice + (UnitPrice*UnitTax)/100) * OHCPercentage/100
                                      ELSE
                                          OverheadCostVal
                                  END
            WHERE BOQID = @BOQID3
                  AND ItemID = @ItemID3
                  AND ISOHCPercentage = 1;
	



                DELETE FROM #Temp2
                WHERE Id = @Id2;
            END;

        END;
        ELSE
        BEGIN
            UPDATE dbo.BOQRateanalysisAllocationDetails
            SET TotalTax = 0,
                UnitTax = 0;

			
			    UPDATE BOQRateanalysisAllocationDetails
                SET OverheadCostVal = (UnitPrice) * OHCPercentage/100
				where  ISOHCPercentage=1    AND BOQId=@CheckBOQId   
				
        END;
		EXEC TotalRecalculateBOQ @CheckBOQId

    END;

    ELSE
    BEGIN

        DECLARE @ProjectID INT,
                @BoqID INT,
                @ItemID INT,
                @TaxId INT,
                @TaxRate DECIMAL(8, 2),
                @TotalTax DECIMAL(8, 2) = 0;



        SELECT @BoqID = BoqId,
               @TaxId = TaxId
        FROM #BoqWiseTax;



        DELETE FROM dbo.BoqTaxes
        WHERE TaxId = @TaxId
              AND BoqId = @BoqID
              AND IsBOQ = @IsBOQ;

        IF ((SELECT COUNT(ItemId) FROM #BoqWiseTax) > 0)
        BEGIN



            INSERT INTO dbo.BoqTaxes
            (
                ProjectId,
                BoqId,
                ItemId,
                TaxId,
                IsBoq,
                TaxRate,
                IPAddress,
                CreatedUserID,
                LastModUserID,
                CreatedDate,
                LastModDate
            )
            SELECT ProjectId, -- ProjectId - int
                   BoqId,     -- BoqId - int -- CategoryId - int
                   ItemId,    -- ItemId - int
                   TaxId,
                   IsBOQ,     -- TaxId - int
                   TaxRate,   -- TaxRate - decimal
                   N'',       -- IPAddress - nvarchar(max)
                   0,         -- CreatedUserID - int
                   0,         -- LastModUserID - int
                   GETDATE(), -- CreatedDate - datetime
                   GETDATE()  -- LastModDate - datetime
            FROM #BoqWiseTax;


        END;

        CREATE TABLE #Temp1
        (
            Id INT,
            ProjectId INT,
            BOQId INT,
            ItemId INT,
            TaxId INT,
            TaxRate DECIMAL(8, 2),
            IsBoq BIT
        );


        INSERT INTO #Temp1
        (
            Id,
            ProjectId,
            BOQId,
            ItemId,
            TaxId,
            TaxRate,
            IsBoq
        )
        SELECT Id,
               ProjectId,
               BOQId,
               ItemId,
               TaxId,
               TaxRate,
               IsBoq
        FROM dbo.BoqTaxes;




        DECLARE @Id INT,
                @BOQID2 INT,
                @ItemID2 INT,
                @Rate2 DECIMAL(8, 2);

         UPDATE dbo.BOQRateanalysisAllocationDetails
            SET TotalTax = 0,
                UnitTax = 0
			Where BOQId= @BoqID

			 UPDATE BOQRateanalysisAllocationDetails
                SET OverheadCostVal = (UnitPrice) * OHCPercentage/100
				where  ISOHCPercentage=1    AND BOQId=@BoqID   


        WHILE ((SELECT COUNT(Id) FROM #Temp1) > 0)
        BEGIN

            SELECT TOP (1)
                   @Id = Id,
                   @BOQID2 = BOQId,
                   @ItemID2 = ItemId,
                   @Rate2 = TaxRate,
                   @IsBOQ = IsBoq
            FROM #Temp1;



            UPDATE dbo.BOQRateanalysisAllocationDetails
            SET TotalTax = CASE
                               WHEN @IsBOQ = 0 THEN
                                   TotalTax + @Rate2 * Quantity
                               ELSE
                                   TotalTax
                           END,
                UnitTax = CASE
                              WHEN @IsBOQ = 1 THEN
                                  UnitTax + @Rate2
                              ELSE
                                  UnitTax
                          END
            WHERE BOQID = @BOQID2
                  AND ItemID = @ItemID2;



            UPDATE BOQRateanalysisAllocationDetails
            SET OverheadCostVal = CASE
                                      WHEN @IsBOQ = 1 THEN
                (UnitPrice + (UnitPrice*UnitTax)/100) * OHCPercentage/100
                                      ELSE
                                          OverheadCostVal
                                  END
            WHERE BOQID = @BOQID2
                  AND ItemID = @ItemID2
                  AND ISOHCPercentage = 1;


            DELETE FROM #Temp1
            WHERE Id = @Id;
        END;

		EXEC TotalRecalculateBOQ @BoqID
    END;

	
	--select * from BOQRateanalysisAllocationDetails



    EXEC sp_xml_removedocument @iDocID;
    IF @@TRANCOUNT > 0
        SET @status = 1;
    COMMIT TRAN;

END TRY
BEGIN CATCH
    RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line '
           + CAST(ERROR_LINE() AS VARCHAR(10));
    SET @status = -1;
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

END CATCH;

GO

