

--SaveProjectPrice '<ArrayOfProjectWiseItemDataModel ><ProjectWiseItemDataModel><Id>1</Id><name>13A 250V 2 GANG 3 PIN COMBINATION S/S S/O</name><DefaultSupplier>2</DefaultSupplier></ProjectWiseItemDataModel><ProjectWiseItemDataModel><Id>314</Id><name>BATTARY 90A</name><DefaultSupplier>1</DefaultSupplier></ProjectWiseItemDataModel><ProjectWiseItemDataModel><Id>765</Id><name>BATTARY 12V FOR FIRE ALARM PANEL</name><DefaultSupplier>1</DefaultSupplier></ProjectWiseItemDataModel></ArrayOfProjectWiseItemDataModel>',2
CREATE PROCEDURE [dbo].[SaveProjectPrice]
    @XMLDetails AS XML,
    @ProjectId INT,
    @PropertyID INT,
    @LocationID INT,
	@DocId varchar(50) output
AS
DECLARE @iDocID INT;
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

        DECLARE @DocNumber VARCHAR(50),
                @TransactionId INT,
                @RequestType CHAR(2),
                @DocumentNo VARCHAR(50),
                @TransactionTypeID INT;

        SELECT *
        INTO #TEMP1
        FROM
            OPENXML(@iDocID, 'ArrayOfProjectWiseItemDataModel/ProjectWiseItemDataModel', 2)
            WITH
            (
                Id INT,
                name VARCHAR(100),
                DefaultSupplier INT
            );

        SET @RequestType = 'SP';
        SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @RequestType);

        IF @DocumentNo IS NULL
        BEGIN
            INSERT INTO TransactionTypeWiseNextNumbers
            (
                PropertyID,
                LocationID,
                TransactionType,
                NextNumber,
                LengthOfFormatting
            )
            VALUES
            (@PropertyID, @LocationID, @RequestType, 1, 6);
        END;

        SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @RequestType);
        SELECT @DocumentNo = 'SP' + @DocumentNo;

        UPDATE TransactionTypeWiseNextNumbers
        SET NextNumber = NextNumber + 1
        WHERE locationid = @LocationID
              AND transactionType = @RequestType;


	    SET @DocId=@DocumentNo

        INSERT INTO [dbo].[ProjectWisePricesLogHeader]
        (
            [ProjectId],
            [Status],
            [CreatedUserID],
            [CreatedDate],
            [IPAddress],
            [DocumentNo],
            [Approve]
        )
        VALUES
        (@ProjectId, 'P', 1, GETDATE(), '192.168.1.1', @DocumentNo, 0);

        SET @TransactionId = SCOPE_IDENTITY();


        UPDATE [dbo].[ProjectWiseSupplierPrices]
        SET Status = 'P',
            TransactionId = @TransactionId
        WHERE ProjectId = @ProjectId;


        SELECT *
        INTO #TempSP
        FROM ProjectWiseSupplierPrices AS p
        WHERE p.ProjectID = @ProjectId;

		Update PT3 SET PT3.DefaultSupplier =T4.DefaultSupplier
		FROM #TEMP1 AS T4
            INNER JOIN ProjectWiseSupplierPrices AS PT3
                ON T4.Id = PT3.StockItemId
                   AND PT3.ProjectId = @ProjectId;

        UPDATE T2
        SET T2.DefaultSupplier = T1.DefaultSupplier
        FROM #TEMP1 AS T1
            INNER JOIN #TempSP AS T2
                ON T1.Id = T2.StockItemId
                   AND T2.ProjectId = @ProjectId;


        INSERT INTO [dbo].[ProjectWisePriceLogDetails]
        (
            [HeaderId],
            [ProjectID],
            [SupplierID],
            [StockItemID],
            [Price],
            [DiscountValue],
            [NetPrice],
            [IPAddress],
            [CreatedUserID],
            [LastModUserID],
            [CreatedDate],
            [LastModDate],
            [DefaultSupplier]
        )
        SELECT @TransactionId,
               ProjectId,
               SupplierID,
               StockItemID,
               Price,
               DiscountValue,
               NetPrice,
               IPAddress,
               CreatedUserID,
               LastModUserID,
               CreatedDate,
               LastModDate,
               DefaultSupplier
        FROM [dbo].[#TempSP]
        WHERE ProjectId = @ProjectId AND SupplierID =DefaultSupplier;


        SELECT @TransactionTypeID = Id
        FROM TransactionTypes
        WHERE Code = 'SP';

        EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID,
                                                  @LocationID,
                                                  @TransactionTypeID,
                                                  @TransactionId;

		SELECT 1

        COMMIT TRANSACTION;


    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
    END CATCH;

END;

GO

