--select * from WorkDoneRegistries
--[dbo].[SP_Save_WorkDoneRegistries] '<ArrayOfWorkDoneRegistry xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><WorkDoneRegistry><IPAddress>192.168.0.1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-12-18T08:34:57.461Z</CreatedDate><LastModDate>2018-12-18T08:34:57.461Z</LastModDate><Id>0</Id><ProjectID>3</ProjectID><LocationID>0</LocationID><BOQID>2</BOQID><MainWorkID>2</MainWorkID><WorkID>4</WorkID><txnDate>2018-12-19T00:00:00</txnDate><AssessedByPrcentage>false</AssessedByPrcentage><AssessedPrcentage>0</AssessedPrcentage><AssessedValue>2000</AssessedValue><BilledValue>0</BilledValue><Completed>false</Completed><Value>12801.4744</Value><CompletedValue>0</CompletedValue><Status>c</Status><ApprovedByClient>false</ApprovedByClient><IsApproved>false</IsApproved><PropertyID>1</PropertyID><WorkValue>116377.04</WorkValue><DepartmentID>0</DepartmentID></WorkDoneRegistry><WorkDoneRegistry><IPAddress>192.168.0.1</IPAddress><CreatedUserID>1</CreatedUserID><LastModUserID>1</LastModUserID><CreatedDate>2018-12-18T08:35:14.467Z</CreatedDate><LastModDate>2018-12-18T08:35:14.467Z</LastModDate><Id>0</Id><ProjectID>3</ProjectID><LocationID>0</LocationID><BOQID>2</BOQID><MainWorkID>2</MainWorkID><WorkID>9</WorkID><txnDate>2018-12-19T00:00:00</txnDate><AssessedByPrcentage>false</AssessedByPrcentage><AssessedPrcentage>0</AssessedPrcentage><AssessedValue>2000</AssessedValue><BilledValue>0</BilledValue><Completed>false</Completed><Value>12801.4744</Value><CompletedValue>0</CompletedValue><Status>c</Status><ApprovedByClient>false</ApprovedByClient><IsApproved>false</IsApproved><PropertyID>1</PropertyID><WorkValue>116377.04</WorkValue><DepartmentID>0</DepartmentID></WorkDoneRegistry></ArrayOfWorkDoneRegistry>','',3
CREATE PROCEDURE [dbo].[SP_Save_WorkDoneRegistries]
    @XMLDetails AS XML,
    @docID VARCHAR(MAX) OUTPUT,
    @headerid INT OUTPUT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @iDocID INT;


        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;


        --INSERT INTO [dbo].[WorkDoneRegistries]
        --           ([ProjectID],[DocumentNo],[BOQID],[MainWorkID],[WorkID],[txnDate]
        --           ,[AssessedByPrcentage],[AssessedPrcentage],[AssessedValue],[BilledValue],[Completed]
        --           ,[PendingValue],[CompletedValue],[Status],[ApprovedByClient],[IsApproved],[IPAddress]
        --           ,[CreatedUserID],[LastModUserID],[CreatedDate],[LastModDate])

        IF (OBJECT_ID('tempdb..#temp')) IS NOT NULL
        BEGIN
            DROP TABLE #temp;
        END;


        CREATE TABLE #tempKeyValue
        (
            Docno VARCHAR(20),
            Headerid INT
        );

        CREATE TABLE #temp
        (
            ID INT IDENTITY(1, 1),
            [PropertyID] [INT] NOT NULL,
            [DepartmentID] [INT] NOT NULL,
            [ProjectID] [INT] NOT NULL,
            [DocumentNo] [NVARCHAR](MAX) NULL,
            [BOQID] [INT] NOT NULL,
            [MainWorkID] [INT] NOT NULL,
            [WorkID] [INT] NOT NULL,
            [txnDate] [DATETIME] NOT NULL,
            [AssessedByPrcentage] [BIT] NOT NULL,
            [AssessedPrcentage] [DECIMAL](18, 2) NOT NULL,
            [AssessedValue] [DECIMAL](18, 2) NOT NULL,
            [BilledValue] [DECIMAL](18, 2) NOT NULL,
            [Completed] [BIT] NOT NULL,
            [CompletedValue] [DECIMAL](18, 2) NOT NULL,
            [Value] [DECIMAL](18, 2) NOT NULL,
            [WorkValue] [DECIMAL](18, 2) NOT NULL,
            [Status] [NVARCHAR](MAX) NULL,
            [ApprovedByClient] [BIT] NOT NULL,
            [IsApproved] [BIT] NOT NULL,
            [IPAddress] [NVARCHAR](MAX) NULL,
            [CreatedUserID] [INT] NOT NULL,
            [LastModUserID] [INT] NOT NULL,
            [CreatedDate] [DATETIME] NOT NULL,
            [LastModDate] [DATETIME] NOT NULL,
            [TransactionType] [NVARCHAR](MAX),
            [LocationID] INT
        );



        EXEC sp_xml_preparedocument @iDocID OUTPUT, @XMLDetails;
        INSERT INTO #temp
        (
            [PropertyID],
            [DepartmentID],
            [ProjectID],
            [DocumentNo],
            [BOQID],
            [MainWorkID],
            [WorkID],
            [txnDate],
            [AssessedByPrcentage],
            [AssessedPrcentage],
            [AssessedValue],
            [BilledValue],
            [Completed],
            [Value],
            [WorkValue],
            [CompletedValue],
            [Status],
            [ApprovedByClient],
            [IsApproved],
            [IPAddress],
            [CreatedUserID],
            [LastModUserID],
            [CreatedDate],
            [LastModDate],
            [TransactionType],
            LocationID
        )
        SELECT *
        FROM
            OPENXML(@iDocID, '/ArrayOfWorkDoneRegistry/WorkDoneRegistry', 2)
            WITH
            (
                [PropertyID] [INT],
                [DepartmentID] [INT],
                [ProjectID] [INT],
                [DocumentNo] [NVARCHAR](MAX),
                [BOQID] [INT],
                [MainWorkID] [INT],
                [WorkID] [INT],
                [txnDate] [DATETIME],
                [AssessedByPrcentage] [BIT],
                [AssessedPrcentage] [DECIMAL](18, 2),
                [AssessedValue] [DECIMAL](18, 2),
                [BilledValue] [DECIMAL](18, 2),
                [Completed] [BIT],
                [Value] [DECIMAL](18, 2),
                [WorkValue] [DECIMAL](18, 2),
                [CompletedValue] [DECIMAL](18, 2),
                [Status] [NVARCHAR](MAX),
                [ApprovedByClient] [BIT],
                [IsApproved] [BIT],
                [IPAddress] [NVARCHAR](MAX),
                [CreatedUserID] [INT],
                [LastModUserID] [INT],
                [CreatedDate] [DATETIME],
                [LastModDate] [DATETIME],
                [TransactionType] [NVARCHAR](MAX),
                LocationID INT
            );
        EXEC sp_xml_removedocument @iDocID;

        UPDATE #temp
        SET TransactionType = 'WD';

        DECLARE @counter INT = 0;
        DECLARE @Totalcounter INT = 0;
        SELECT @Totalcounter = COUNT(*)
        FROM #temp;



        SELECT *
        FROM #temp;

        WHILE @counter < @Totalcounter
        BEGIN

            SELECT 'Counter',
                   @counter;

            DECLARE @WorkDoneRegID INT,
                    @LocationID INT,
                    @PropertyID INT,
                    @DocumentNo VARCHAR(MAX),
                    @RequestType VARCHAR(3),
                    @TransactionTypeID INT;

            SELECT @RequestType = TransactionType,
                   @PropertyID = PropertyID,
                   @LocationID = LocationID
            FROM #temp
            WHERE ID = @counter + 1;

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

            INSERT INTO [dbo].[WorkDoneRegistries]
            (
                [ProjectID],
                [DepartmentID],
                [DocumentNo],
                [BOQID],
                [MainWorkID],
                [WorkID],
                [txnDate],
                [AssessedByPrcentage],
                [AssessedPrcentage],
                [AssessedValue],
                [BilledValue],
                [Completed],
                [Value],
                [WorkValue],
                [CompletedValue],
                [Status],
                [ApprovedByClient],
                [IsApproved],
                [IPAddress],
                [CreatedUserID],
                [LastModUserID],
                [CreatedDate],
                [LastModDate],
                [TransactionType],
                [LocationID]
            ) --25

            SELECT [ProjectID],
                   [DepartmentID],
                   @DocumentNo,
                   [BOQID],
                   [MainWorkID],
                   [WorkID],
                   [txnDate],
                   [AssessedByPrcentage],
                   [AssessedPrcentage],
                   [AssessedValue],
                   [BilledValue],
                   [Completed],
                   [Value],
                   [WorkValue],
                   [CompletedValue],
                   [Status],
                   [ApprovedByClient],
                   [IsApproved],
                   [IPAddress],
                   [CreatedUserID],
                   [LastModUserID],
                   [CreatedDate],
                   [LastModDate],
                   [TransactionType],
                   [LocationID]
            FROM #temp
            WHERE ID = @counter + 1;

            SET @WorkDoneRegID = SCOPE_IDENTITY();
            --Assiugn Header and Doc No
            SET @docID = @DocumentNo;
            SET @headerid = @WorkDoneRegID;

            INSERT INTO #tempKeyValue
            VALUES
            (@DocumentNo, @WorkDoneRegID);
            EXEC dbo.SP_InsertApprovalLevelForRequest @PropertyID,
                                                      @LocationID,
                                                      @TransactionTypeID,
                                                      @WorkDoneRegID;

            -- Loop end
            SET @counter = @counter + 1;
        END;

        SELECT *
        FROM #tempKeyValue;



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

