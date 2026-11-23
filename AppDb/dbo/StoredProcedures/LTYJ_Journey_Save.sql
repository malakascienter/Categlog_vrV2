/*  Create or update a journey and its DRAFT graph in one call.

    The whole graph is replaced rather than diffed: the canvas always posts the
    complete picture, and reconciling adds, moves and deletes would be a lot of
    machinery to reproduce what the client already knows.

    A PUBLISHED version is never edited. Saving against a journey whose newest
    version is published creates the next DRAFT, so publishing is what makes a
    change take effect and a member in flight is never moved onto a graph they
    did not enter on.                                                            */
CREATE PROCEDURE dbo.LTYJ_Journey_Save
    @JourneyId         int = NULL,
    @PropertyId        int,
    @Name              nvarchar(150),
    @Description       nvarchar(1000) = NULL,
    @TriggerJson       nvarchar(max)  = NULL,
    @ExitRulesJson     nvarchar(max)  = NULL,
    @ReEntryPolicy     varchar(20)    = 'ONCE_EVER',
    @ReEntryPeriodDays int            = NULL,
    -- [{"nodeKey":"n1","nodeType":"TRIGGER","label":"..","configJson":"..","posX":0,"posY":0}]
    @NodesJson         nvarchar(max)  = N'[]',
    -- [{"fromNodeKey":"n1","toNodeKey":"n2","branchKey":"DEFAULT","sortOrder":1}]
    @EdgesJson         nvarchar(max)  = N'[]',
    @ActionBy          int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL)
            THROW 50402, 'A journey name is required.', 1;

        IF (@ReEntryPolicy NOT IN ('ONCE_EVER','ONCE_PER_PERIOD','ALWAYS'))
            THROW 50403, 'The re-entry policy is not one of ONCE_EVER, ONCE_PER_PERIOD or ALWAYS.', 1;

        IF (@TriggerJson IS NOT NULL AND ISJSON(@TriggerJson) = 0)
            THROW 50404, 'The trigger configuration is not valid JSON.', 1;

        IF (@ExitRulesJson IS NOT NULL AND ISJSON(@ExitRulesJson) = 0)
            THROW 50405, 'The exit rules are not valid JSON.', 1;

        ---- journey header ---------------------------------------------------
        IF (@JourneyId IS NULL OR @JourneyId = 0)
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                       WHERE PropertyId = @PropertyId AND Name = @Name AND IsDeleted = 0)
                THROW 50406, 'A journey with this name already exists.', 1;

            INSERT INTO dbo.LTYJ_Journey (PropertyId, Name, Description, Status, CreatedBy)
            VALUES (@PropertyId, @Name, @Description, 'DRAFT', @ActionBy);

            SET @JourneyId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                           WHERE JourneyId = @JourneyId AND PropertyId = @PropertyId AND IsDeleted = 0)
                THROW 50401, 'This journey no longer exists.', 1;

            IF EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                       WHERE PropertyId = @PropertyId AND Name = @Name
                         AND JourneyId <> @JourneyId AND IsDeleted = 0)
                THROW 50406, 'A journey with this name already exists.', 1;

            UPDATE dbo.LTYJ_Journey
            SET    Name = @Name, Description = @Description,
                   ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
            WHERE  JourneyId = @JourneyId;
        END

        ---- the draft version to write into ----------------------------------
        DECLARE @VersionId int;

        SELECT TOP (1) @VersionId = VersionId
        FROM   dbo.LTYJ_JourneyVersion
        WHERE  JourneyId = @JourneyId AND Status = 'DRAFT'
        ORDER BY VersionNo DESC;

        IF (@VersionId IS NULL)
        BEGIN
            DECLARE @NextNo int =
                ISNULL((SELECT MAX(VersionNo) FROM dbo.LTYJ_JourneyVersion WHERE JourneyId = @JourneyId), 0) + 1;

            INSERT INTO dbo.LTYJ_JourneyVersion
                  (JourneyId, PropertyId, VersionNo, Status, TriggerJson, ExitRulesJson,
                   ReEntryPolicy, ReEntryPeriodDays, CreatedBy)
            VALUES(@JourneyId, @PropertyId, @NextNo, 'DRAFT', @TriggerJson, @ExitRulesJson,
                   @ReEntryPolicy, @ReEntryPeriodDays, @ActionBy);

            SET @VersionId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            UPDATE dbo.LTYJ_JourneyVersion
            SET    TriggerJson = @TriggerJson, ExitRulesJson = @ExitRulesJson,
                   ReEntryPolicy = @ReEntryPolicy, ReEntryPeriodDays = @ReEntryPeriodDays,
                   ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
            WHERE  VersionId = @VersionId;
        END

        ---- graph ------------------------------------------------------------
        DELETE FROM dbo.LTYJ_Edge WHERE VersionId = @VersionId;
        DELETE FROM dbo.LTYJ_Node WHERE VersionId = @VersionId;

        INSERT INTO dbo.LTYJ_Node (VersionId, NodeKey, NodeType, Label, ConfigJson, PosX, PosY)
        SELECT @VersionId, n.nodeKey, n.nodeType, n.label, n.configJson,
               ISNULL(n.posX, 0), ISNULL(n.posY, 0)
        FROM   OPENJSON(@NodesJson)
        WITH (
            nodeKey    varchar(50)   '$.nodeKey',
            nodeType   varchar(30)   '$.nodeType',
            label      nvarchar(150) '$.label',
            configJson nvarchar(max) '$.configJson',
            posX       decimal(9,2)  '$.posX',
            posY       decimal(9,2)  '$.posY'
        ) AS n
        WHERE  NULLIF(LTRIM(RTRIM(n.nodeKey)), '') IS NOT NULL;

        INSERT INTO dbo.LTYJ_Edge (VersionId, FromNodeKey, ToNodeKey, BranchKey, SortOrder)
        SELECT @VersionId, e.fromNodeKey, e.toNodeKey,
               ISNULL(NULLIF(LTRIM(RTRIM(e.branchKey)), ''), 'DEFAULT'), ISNULL(e.sortOrder, 0)
        FROM   OPENJSON(@EdgesJson)
        WITH (
            fromNodeKey varchar(50) '$.fromNodeKey',
            toNodeKey   varchar(50) '$.toNodeKey',
            branchKey   varchar(20) '$.branchKey',
            sortOrder   int         '$.sortOrder'
        ) AS e
        WHERE  NULLIF(LTRIM(RTRIM(e.fromNodeKey)), '') IS NOT NULL
          AND  NULLIF(LTRIM(RTRIM(e.toNodeKey)), '') IS NOT NULL;

        COMMIT TRANSACTION;

        SELECT @JourneyId AS JourneyId, @VersionId AS VersionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

