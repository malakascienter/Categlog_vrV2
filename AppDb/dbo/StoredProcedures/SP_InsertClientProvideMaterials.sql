-- SP_InsertClientProvideMaterials '<CustomerSuppliedStockHeader xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><Id>-1</Id><PropertyID>1</PropertyID><LocationID>2</LocationID><TransactionType>CP</TransactionType><TxnNumber /><TxnDate>2018-05-14T05:39:48.432Z</TxnDate><ProjectID>3</ProjectID><CustID>3</CustID><BOQID>2</BOQID><deptID>5</deptID><TotalValue>0</TotalValue><Status /><Completed>false</Completed><Billed>false</Billed><BillNumber /><invoiced>false</invoiced><invoiceNo /><CustomerSuppliedStockDetails><CustomerSuppliedStockDetail><Id>0</Id><HeaderID>0</HeaderID><ItemID>8</ItemID><unitID>3</unitID><UnitPrice>0</UnitPrice><Qunatity>23</Qunatity><TotalValue>0</TotalValue></CustomerSuppliedStockDetail><CustomerSuppliedStockDetail><Id>0</Id><HeaderID>0</HeaderID><ItemID>10</ItemID><unitID>4</unitID><UnitPrice>0</UnitPrice><Qunatity>10</Qunatity><TotalValue>0</TotalValue></CustomerSuppliedStockDetail><CustomerSuppliedStockDetail><Id>0</Id><HeaderID>0</HeaderID><ItemID>11</ItemID><unitID>1</unitID><UnitPrice>0</UnitPrice><Qunatity>188</Qunatity><TotalValue>0</TotalValue></CustomerSuppliedStockDetail><CustomerSuppliedStockDetail><Id>0</Id><HeaderID>0</HeaderID><ItemID>72</ItemID><unitID>4</unitID><UnitPrice>0</UnitPrice><Qunatity>10</Qunatity><TotalValue>0</TotalValue></CustomerSuppliedStockDetail></CustomerSuppliedStockDetails></CustomerSuppliedStockHeader>','',0
CREATE PROCEDURE [dbo].[SP_InsertClientProvideMaterials]
    @XMLDetails AS XML,
    @docID VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @iDocID INT;
        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;

        CREATE TABLE #CustomerSuppliedStockHeaders
        (
            [Id] [INT] IDENTITY(1, 1) NOT NULL,
            [TxnNumber] [NVARCHAR](MAX) NULL,
            [TxnDate] [DATETIME] NOT NULL,
            [ProjectID] [INT] NOT NULL,
            [CustID] [INT] NOT NULL,
            [BOQID] [INT] NOT NULL,
            [deptID] [INT] NOT NULL,
            [TotalValue] [DECIMAL](18, 2) NOT NULL,
            [Status] [NVARCHAR](MAX) NULL,
            [Completed] [BIT] NOT NULL,
            [Billed] [BIT] NOT NULL,
            [BillNumber] [NVARCHAR](MAX) NULL,
            [invoiced] [BIT] NOT NULL,
            [invoiceNo] [NVARCHAR](MAX) NULL,
            [PropertyID] [INT] NOT NULL,
            [LocationID] [INT] NOT NULL,
            [TransactionType] [NVARCHAR](MAX) NULL
        );

        INSERT INTO #CustomerSuppliedStockHeaders
        SELECT '',
               [TxnDate],
               [ProjectID],
               [CustID],
               [BOQID],
               [deptID],
               [TotalValue],
               [Status],
               [Completed],
               [Billed],
               [BillNumber],
               [invoiced],
               [invoiceNo],
               [PropertyID],
               [LocationID],
               [TransactionType]
        FROM
            OPENXML(@iDocID, '/CustomerSuppliedStockHeader', 2)
            WITH CustomerSuppliedStockHeaders;


        CREATE TABLE #CustomerSuppliedStockDetails
        (
            [Id] [INT] IDENTITY(1, 1) NOT NULL,
            [HeaderID] [INT] NOT NULL,
            [ItemID] [INT] NOT NULL,
            [unitID] [INT] NOT NULL,
            [UnitPrice] [DECIMAL](18, 2) NOT NULL,
            [Qunatity] [DECIMAL](18, 2) NOT NULL,
            [TotalValue] [DECIMAL](18, 2) NOT NULL,
        );

        INSERT INTO #CustomerSuppliedStockDetails
        SELECT 1,
               [ItemID],
               [unitID],
               [UnitPrice],
               [Qunatity],
               [TotalValue]
        FROM
            OPENXML(@iDocID, '/CustomerSuppliedStockHeader/CustomerSuppliedStockDetails/CustomerSuppliedStockDetail', 2)
            WITH CustomerSuppliedStockDetails;

        DECLARE @BillID INT,
                @LocationID INT,
                @PropertyID INT,
                @DocumentNo VARCHAR(MAX),
                @RequestType VARCHAR(3),
                @TransactionTypeID INT;

        SELECT @RequestType = TransactionType,
               @LocationID = LocationID,
               @PropertyID = PropertyID
        FROM #CustomerSuppliedStockHeaders; --OPENXML(@iDocID, '/CustomerSuppliedStockHeader', 2) WITH(TransactionType VARCHAR(3), LocationID INT, PropertyID INT);


		PRINT  @LocationID
        --handling Document numbers *************************************************************************
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
            SELECT @DocumentNo = dbo.FN_GetNextDocumentNumber(@PropertyID, @LocationID, @RequestType);
        END;
        UPDATE TransactionTypeWiseNextNumbers
        SET NextNumber = NextNumber + 1
        WHERE LocationID = @LocationID
              AND TransactionType = @RequestType;

        SELECT @TransactionTypeID = Id
        FROM TransactionTypes
        WHERE Code = @RequestType;
        INSERT INTO CustomerSuppliedStockHeaders
        (
            [TxnNumber],
            [TxnDate],
            [ProjectID],
            [CustID],
            [BOQID],
            [deptID],
            [TotalValue],
            [Status],
            [Completed],
            [Billed],
            [BillNumber],
            [invoiced],
            [invoiceNo],
            [PropertyID],
            [LocationID],
            [TransactionType]
        )
        SELECT @DocumentNo,
               [TxnDate],
               [ProjectID],
               [CustID],
               [BOQID],
               [deptID],
               [TotalValue],
               [Status],
               [Completed],
               [Billed],
               [BillNumber],
               [invoiced],
               [invoiceNo],
               [PropertyID],
               [LocationID],
               [TransactionType]
        FROM #CustomerSuppliedStockHeaders; -- OPENXML(@iDocID, '/CustomerSuppliedStockHeader', 2) WITH CustomerSuppliedStockHeaders;



			SELECT * FROM #CustomerSuppliedStockDetails
		
			 SELECT #CustomerSuppliedStockDetails.ItemID, SD.LocationID,'asa', @BillID,
               [ItemID],
               unitID,
               SD.SellingPrice,
               [Qunatity],
               SD.SellingPrice * [Qunatity]
        FROM #CustomerSuppliedStockDetails
            LEFT JOIN dbo.StockItemDetails SD
                ON SD.StockItemHeaderID = #CustomerSuppliedStockDetails.ItemID
       -- WHERE SD.LocationID = @LocationID; --OPENXML(




        SELECT @BillID = SCOPE_IDENTITY();

        INSERT INTO CustomerSuppliedStockDetails
        (
            [HeaderID],
            [ItemID],
            [unitID],
            [UnitPrice],
            [Qunatity],
            [TotalValue]
        )
        SELECT @BillID,
               [ItemID],
               unitID,
               SD.SellingPrice,
               [Qunatity],
               SD.SellingPrice * [Qunatity]
        FROM #CustomerSuppliedStockDetails
            LEFT JOIN dbo.StockItemDetails SD
                ON SD.StockItemHeaderID = #CustomerSuppliedStockDetails.ItemID
        WHERE SD.LocationID = @LocationID; --OPENXML(@iDocID, '/CustomerSuppliedStockHeader/CustomerSuppliedStockDetails', 2) WITH CustomerSuppliedStockDetails;

		

	



		DECLARE @Total DECIMAL;

        SELECT @Total = ISNULL(SUM(TotalValue), 0)
        FROM dbo.CustomerSuppliedStockDetails
        WHERE HeaderID = @BillID;

        UPDATE dbo.CustomerSuppliedStockHeaders
        SET TotalValue = @Total
        WHERE Id = @BillID;

        --Assiugn Header and Doc No

        --SET @docID = @DocumentNo;
        --SET @headerid = @BillID;
        --EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID,
        --                                          @LocationID,
        --                                          @TransactionTypeID,
        --                                          @BillID;

        DELETE #CustomerSuppliedStockDetails;
        DELETE #CustomerSuppliedStockHeaders;

        COMMIT TRAN; -- Transaction Success!
    END TRY
    BEGIN CATCH
        RETURN CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line '
               + CAST(ERROR_LINE() AS VARCHAR(10));
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN; --RollBack in case of Error
    END CATCH;
END;

GO

