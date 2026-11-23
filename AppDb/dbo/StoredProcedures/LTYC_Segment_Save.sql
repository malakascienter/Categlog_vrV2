/*  Create or update a segment and replace its rule tree.

    @RulesJson is a FLAT array carrying a client-side key and parent key, not a
    nested document. Nesting would need recursive OPENJSON, which T-SQL does not
    do; flattening is what the client already has and shreds in one statement.

        [{"key":"r1","parentKey":null,"nodeKind":"GROUP","logicalOp":"OR", ...},
         {"key":"r2","parentKey":"r1","nodeKind":"CONDITION", ...}]

    Client keys are mapped to real RuleIds after insert, so parents resolve
    regardless of the order they arrive in.                                      */
CREATE PROCEDURE dbo.LTYC_Segment_Save
    @SegmentId    int = NULL,
    @PropertyId   int,
    @Name         nvarchar(150),
    @Description  nvarchar(1000) = NULL,
    @RootOperator varchar(3)     = 'AND',
    @RefreshMode  varchar(20)    = 'SCHEDULED',
    @RefreshCron  varchar(100)   = NULL,
    @RulesJson    nvarchar(max)  = N'[]',
    @ActionBy     int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF (NULLIF(LTRIM(RTRIM(@Name)), '') IS NULL)
            THROW 50502, 'A segment name is required.', 1;

        IF (@RootOperator NOT IN ('AND','OR'))
            THROW 50503, 'The match type must be AND or OR.', 1;

        IF (@RefreshMode NOT IN ('SCHEDULED','MANUAL','STATIC'))
            THROW 50504, 'The refresh mode must be SCHEDULED, MANUAL or STATIC.', 1;

        IF (ISJSON(@RulesJson) = 0)
            THROW 50505, 'The rules could not be read.', 1;

        IF (@SegmentId IS NULL OR @SegmentId = 0)
        BEGIN
            IF EXISTS (SELECT 1 FROM dbo.LTYC_Segment
                       WHERE PropertyId = @PropertyId AND Name = @Name AND IsDeleted = 0)
                THROW 50506, 'A segment with this name already exists.', 1;

            INSERT INTO dbo.LTYC_Segment
                  (PropertyId, Name, Description, RootOperator, RefreshMode, RefreshCron, CreatedBy)
            VALUES(@PropertyId, @Name, @Description, @RootOperator, @RefreshMode, @RefreshCron, @ActionBy);

            SET @SegmentId = SCOPE_IDENTITY();
        END
        ELSE
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_Segment
                           WHERE SegmentId = @SegmentId AND PropertyId = @PropertyId AND IsDeleted = 0)
                THROW 50501, 'This segment no longer exists.', 1;

            IF EXISTS (SELECT 1 FROM dbo.LTYC_Segment
                       WHERE PropertyId = @PropertyId AND Name = @Name
                         AND SegmentId <> @SegmentId AND IsDeleted = 0)
                THROW 50506, 'A segment with this name already exists.', 1;

            UPDATE dbo.LTYC_Segment
            SET    Name = @Name, Description = @Description, RootOperator = @RootOperator,
                   RefreshMode = @RefreshMode, RefreshCron = @RefreshCron,
                   ModifiedBy = @ActionBy, ModifiedDate = SYSUTCDATETIME()
            WHERE  SegmentId = @SegmentId;
        END

        ---- rules ------------------------------------------------------------
        DELETE FROM dbo.LTYC_SegmentRule WHERE SegmentId = @SegmentId;

        DECLARE @Incoming TABLE
        (
            ClientKey     varchar(50)   NOT NULL PRIMARY KEY,
            ParentKey     varchar(50)       NULL,
            NodeKind      varchar(10)   NOT NULL,
            LogicalOp     varchar(3)        NULL,
            AttributeCode varchar(60)       NULL,
            Operator      varchar(30)       NULL,
            ValueJson     nvarchar(max)     NULL,
            SortOrder     int           NOT NULL,
            RuleId        int               NULL
        );

        INSERT INTO @Incoming (ClientKey, ParentKey, NodeKind, LogicalOp, AttributeCode, Operator, ValueJson, SortOrder)
        SELECT r.[key], r.parentKey, r.nodeKind, r.logicalOp, r.attributeCode,
               r.[operator], r.valueJson, ISNULL(r.sortOrder, 0)
        FROM   OPENJSON(@RulesJson)
        WITH (
            [key]         varchar(50)   '$.key',
            parentKey     varchar(50)   '$.parentKey',
            nodeKind      varchar(10)   '$.nodeKind',
            logicalOp     varchar(3)    '$.logicalOp',
            attributeCode varchar(60)   '$.attributeCode',
            [operator]    varchar(30)   '$.operator',
            valueJson     nvarchar(max) '$.valueJson',
            sortOrder     int           '$.sortOrder'
        ) AS r
        WHERE  NULLIF(LTRIM(RTRIM(r.[key])), '') IS NOT NULL;

        -- Insert first without parents, then resolve them. One pass cannot work:
        -- a child may arrive before its parent has an id.
        DECLARE @Mapped TABLE (ClientKey varchar(50) NOT NULL, RuleId int NOT NULL);

        DECLARE @key varchar(50);

        DECLARE rule_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT ClientKey FROM @Incoming ORDER BY SortOrder, ClientKey;

        OPEN rule_cursor;
        FETCH NEXT FROM rule_cursor INTO @key;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO dbo.LTYC_SegmentRule
                  (SegmentId, ParentRuleId, NodeKind, LogicalOp, AttributeCode, Operator, ValueJson, SortOrder)
            SELECT @SegmentId, NULL, i.NodeKind, i.LogicalOp, i.AttributeCode, i.Operator, i.ValueJson, i.SortOrder
            FROM   @Incoming AS i
            WHERE  i.ClientKey = @key;

            INSERT INTO @Mapped (ClientKey, RuleId) VALUES (@key, SCOPE_IDENTITY());

            FETCH NEXT FROM rule_cursor INTO @key;
        END

        CLOSE rule_cursor;
        DEALLOCATE rule_cursor;

        UPDATE r
        SET    r.ParentRuleId = pm.RuleId
        FROM   dbo.LTYC_SegmentRule AS r
        INNER JOIN @Mapped   AS m  ON m.RuleId = r.RuleId
        INNER JOIN @Incoming AS i  ON i.ClientKey = m.ClientKey
        INNER JOIN @Mapped   AS pm ON pm.ClientKey = i.ParentKey
        WHERE  r.SegmentId = @SegmentId;

        -- The definition changed, so any stored estimate is now a lie.
        UPDATE dbo.LTYC_Segment
        SET    LastEstimatedCount = NULL, LastEstimatedAt = NULL
        WHERE  SegmentId = @SegmentId;

        COMMIT TRANSACTION;

        SELECT @SegmentId AS SegmentId,
               (SELECT COUNT(*) FROM dbo.LTYC_SegmentRule WHERE SegmentId = @SegmentId) AS RuleCount;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

