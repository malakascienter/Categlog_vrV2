/* =============================================================================
   Author       : Tharuka Sachintha
   Create date  : 2026-08-03
   Description  : Auto completes ageing transactions. 

   -- exec [dbo].[SP_AutoCompleteTransactions]
   ============================================================================= */

CREATE   PROCEDURE [dbo].[SP_AutoCompleteTransactions]
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @RunId         UNIQUEIDENTIFIER = NEWID(),
            @RunDate       DATE             = CAST(GETDATE() AS DATE),
            @CompletedOn   DATETIME         = GETDATE(),
            @OpenStatus    NVARCHAR(2)      = N'P',       
            @CloseStatus   NVARCHAR(2)      = N'C',      
            @UserProfileId INT              = 0,         
            @LogModule     VARCHAR(50)      = 'Auto Complete Job';

   
    DECLARE @Types TABLE (Section           VARCHAR(2)   NOT NULL,
                          TransactionTypeId INT          NOT NULL,
                          Code              NVARCHAR(20) NULL,
                          AutoCompleteDays  INT          NOT NULL,
                          PRIMARY KEY (Section, TransactionTypeId));

    INSERT INTO @Types (Section, TransactionTypeId, Code, AutoCompleteDays)
    SELECT  CASE WHEN LTRIM(RTRIM(tt.Code)) IN (N'RI', N'IR') THEN 'IR'
                 WHEN LTRIM(RTRIM(tt.Code)) = N'RP'           THEN 'PR'
                 ELSE 'PO'
            END,
            tt.Id,
            LTRIM(RTRIM(tt.Code)),
            tt.AutoCompleteDays
    FROM    dbo.TransactionTypes tt
    WHERE   LTRIM(RTRIM(tt.Code)) IN (N'RI', N'IR', N'RP', N'PO')
    AND  tt.AutoCompleteDays > 0;

    DECLARE @IRDays INT, @PRDays INT, @PODays INT;

    SELECT  @IRDays = NULLIF(MAX(CASE WHEN Section = 'IR' THEN AutoCompleteDays ELSE 0 END), 0),
            @PRDays = NULLIF(MAX(CASE WHEN Section = 'PR' THEN AutoCompleteDays ELSE 0 END), 0),
            @PODays = NULLIF(MAX(CASE WHEN Section = 'PO' THEN AutoCompleteDays ELSE 0 END), 0)
    FROM    @Types;

    IF @IRDays IS NULL AND @PRDays IS NULL AND @PODays IS NULL
    BEGIN
        PRINT N'SP_AutoCompleteTransactions: no transaction type has AutoCompleteDays > 0. Nothing to do.';
        RETURN;
    END


    DECLARE @POTypeId INT, @POTypeCode NVARCHAR(20);

    SELECT   TOP (1) @POTypeId = t.TransactionTypeId, @POTypeCode = t.Code
    FROM     @Types t
    WHERE    t.Section = 'PO'
    ORDER BY t.AutoCompleteDays DESC, t.TransactionTypeId;


    CREATE TABLE #Eligible
    (
        DocumentType        VARCHAR(2)   NOT NULL,
        SourceTable         VARCHAR(30)  NOT NULL,
        ReferenceID         INT          NOT NULL,
        TransactionTypeId   INT          NULL,
        TransactionTypeCode NVARCHAR(20) NULL,
        RequestType         NVARCHAR(10) NULL,
        DocumentDate        DATETIME     NULL,
        PropertyID          INT          NULL,
        PRIMARY KEY CLUSTERED (SourceTable, ReferenceID)
    );


    IF @IRDays IS NOT NULL
    BEGIN
        INSERT INTO #Eligible (DocumentType, SourceTable, ReferenceID, TransactionTypeId,
                               TransactionTypeCode, RequestType, DocumentDate, PropertyID)
        SELECT  'IR', 'RequestHeaders', rh.Id, t.TransactionTypeId, t.Code,
                rh.RequestType, rh.RequestDate, rh.PropertyID
        FROM    dbo.RequestHeaders rh
                INNER JOIN @Types t
                    ON  t.Section = 'IR'
                    AND t.TransactionTypeId = TRY_CONVERT(INT, LTRIM(RTRIM(rh.TransactionTypeCode)))
        WHERE   rh.DocumentStatus = @OpenStatus
                AND  rh.IsApproved = 1
                AND DATEDIFF(DAY, CAST(rh.RequestDate AS DATE), @RunDate) >= @IRDays;
    END


    IF @PRDays IS NOT NULL
    BEGIN
        INSERT INTO #Eligible (DocumentType, SourceTable, ReferenceID, TransactionTypeId,
                               TransactionTypeCode, RequestType, DocumentDate, PropertyID)
        SELECT  'PR', 'RequestHeaders', rh.Id, t.TransactionTypeId, t.Code,
                rh.RequestType, rh.RequestDate, rh.PropertyID
        FROM    dbo.RequestHeaders rh
                INNER JOIN @Types t
                    ON  t.Section = 'PR'
                    AND t.TransactionTypeId = TRY_CONVERT(INT, LTRIM(RTRIM(rh.TransactionTypeCode)))
        WHERE   rh.IsApproved = 1
                AND rh.DocumentStatus = @OpenStatus
                AND DATEDIFF(DAY, CAST(rh.RequestDate AS DATE), @RunDate) >= @PRDays
                AND NOT EXISTS (SELECT 1 FROM #Eligible e
                                WHERE e.SourceTable = 'RequestHeaders' AND e.ReferenceID = rh.Id);
    END


    IF @PODays IS NOT NULL
    BEGIN
        INSERT INTO #Eligible (DocumentType, SourceTable, ReferenceID, TransactionTypeId,
                               TransactionTypeCode, RequestType, DocumentDate, PropertyID)
        SELECT  'PO', 'PoHeaders', ph.Id, @POTypeId, @POTypeCode,
                N'PO', ph.DocumentDate, ph.PropertyID
        FROM    dbo.PoHeaders ph
        WHERE   ph.IsApproved = 1
                AND ph.DocumentStatus = @OpenStatus
                AND DATEDIFF(DAY, CAST(ph.DocumentDate AS DATE), @RunDate) >= @PODays;
    END


    BEGIN TRY

        BEGIN TRANSACTION;

   
            UPDATE  rh
            SET     rh.DocumentStatus = @CloseStatus
            FROM    dbo.RequestHeaders rh
                    INNER JOIN #Eligible e
                        ON  e.ReferenceID = rh.Id
                        AND e.SourceTable = 'RequestHeaders';

            UPDATE  ph
            SET     ph.DocumentStatus = @CloseStatus
            FROM    dbo.PoHeaders ph
                    INNER JOIN #Eligible e
                        ON  e.ReferenceID = ph.Id
                        AND e.SourceTable = 'PoHeaders';


            INSERT INTO dbo.AutoCompleteTransactionLog
                    (RunId, RunDate, TransactionTypeId, TransactionTypeCode,
                     SourceTable, ReferenceID, DocumentDate,
                     CompletedOn, CompletedDate, CompletedTime)
            SELECT  @RunId, @RunDate, e.TransactionTypeId, e.TransactionTypeCode,
                    e.SourceTable, e.ReferenceID, e.DocumentDate,
                    @CompletedOn, CAST(@CompletedOn AS DATE), CAST(@CompletedOn AS TIME(0))
            FROM    #Eligible e;


            INSERT INTO dbo.TransactionStatus_Log
                    (HeaderID, TransactionType, SysDate, Status, UserID, Module)
            SELECT  e.ReferenceID, e.RequestType, @CompletedOn, 'Complete', @UserProfileId, @LogModule
            FROM    #Eligible e
            WHERE   e.SourceTable = 'RequestHeaders';

            INSERT INTO dbo.POStatusUpdate_Log
                    (PropertyID, PoHeaderID, Status, Module, SysDate, UserID)
            SELECT  e.PropertyID, e.ReferenceID, 'Complete', @LogModule, @CompletedOn, @UserProfileId
            FROM    #Eligible e
            WHERE   e.SourceTable = 'PoHeaders';

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        DROP TABLE #Eligible;
        THROW;

    END CATCH


    DECLARE @IRCount INT, @PRCount INT, @POCount INT;

    SELECT  @IRCount = SUM(CASE WHEN DocumentType = 'IR' THEN 1 ELSE 0 END),
            @PRCount = SUM(CASE WHEN DocumentType = 'PR' THEN 1 ELSE 0 END),
            @POCount = SUM(CASE WHEN DocumentType = 'PO' THEN 1 ELSE 0 END)
    FROM    #Eligible;

    PRINT N'SP_AutoCompleteTransactions run ' + CONVERT(VARCHAR(36), @RunId)
        + N' for ' + CONVERT(VARCHAR(10), @RunDate, 120) + N': '
        + N'IR closed = ' + CONVERT(VARCHAR(10), ISNULL(@IRCount, 0)) + N', '
        + N'PR closed = ' + CONVERT(VARCHAR(10), ISNULL(@PRCount, 0)) + N', '
        + N'PO closed = ' + CONVERT(VARCHAR(10), ISNULL(@POCount, 0)) + N'.';

    DROP TABLE #Eligible;
END

GO

