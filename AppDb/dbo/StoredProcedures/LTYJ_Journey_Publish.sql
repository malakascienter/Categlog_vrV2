/*  Freeze the draft and make it live.

    GraphJson is built here from the node and edge rows, in exactly the shape the
    engine's JourneyGraph model deserialises. From this moment the version is
    immutable and the worker may cache it forever.

    Structural validation (one trigger, every path terminates, no orphans, no
    cycles) happens in the API before this is called - it is graph traversal, and
    T-SQL is the wrong tool for it. What is checked here is what SQL is good at:
    that the pieces exist at all.                                                */
CREATE PROCEDURE dbo.LTYJ_Journey_Publish
    @JourneyId  int,
    @PropertyId int,
    @ActionBy   int
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @VersionId int;

        SELECT TOP (1) @VersionId = v.VersionId
        FROM   dbo.LTYJ_JourneyVersion AS v
        INNER JOIN dbo.LTYJ_Journey    AS j ON j.JourneyId = v.JourneyId
        WHERE  v.JourneyId = @JourneyId AND j.PropertyId = @PropertyId
          AND  j.IsDeleted = 0 AND v.Status = 'DRAFT'
        ORDER BY v.VersionNo DESC;

        IF (@VersionId IS NULL)
            THROW 50407, 'There is no draft to publish. Edit the journey first.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Node WHERE VersionId = @VersionId AND NodeType = 'TRIGGER')
            THROW 50408, 'A journey needs a trigger before it can be published.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Node WHERE VersionId = @VersionId AND NodeType = 'EXIT')
            THROW 50409, 'A journey needs at least one exit before it can be published.', 1;

        IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_JourneyVersion
                       WHERE VersionId = @VersionId AND TriggerJson IS NOT NULL)
            THROW 50410, 'The trigger has not been configured.', 1;

        ---- freeze -----------------------------------------------------------
        UPDATE dbo.LTYJ_JourneyVersion
        /*  JSON_QUERY on both arrays, and this is the one place it is critical.
            Without it SQL Server embeds each nested FOR JSON result as an ESCAPED
            STRING, so GraphJson comes out as {"nodes":"[{...}]"} instead of
            {"nodes":[{...}]}. The engine deserialises this into JourneyGraph and
            would fail on every published journey -- a defect that only shows at
            run time, on the one document the whole engine depends on.            */
        SET    GraphJson = (
                   SELECT JSON_QUERY((
                       SELECT n.NodeKey AS nodeKey, n.NodeType AS nodeType,
                              n.Label AS label, n.ConfigJson AS configJson
                       FROM   dbo.LTYJ_Node AS n
                       WHERE  n.VersionId = @VersionId
                       ORDER BY n.NodeId
                       FOR JSON PATH
                   )) AS nodes,
                   JSON_QUERY((
                       SELECT e.FromNodeKey AS fromNodeKey, e.ToNodeKey AS toNodeKey,
                              e.BranchKey AS branchKey
                       FROM   dbo.LTYJ_Edge AS e
                       WHERE  e.VersionId = @VersionId
                       ORDER BY e.SortOrder, e.EdgeId
                       FOR JSON PATH
                   )) AS edges
                   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
               ),
               Status        = 'PUBLISHED',
               PublishedBy   = @ActionBy,
               PublishedDate = SYSUTCDATETIME()
        WHERE  VersionId = @VersionId;

        -- The previous live version is retired, but not deleted: runs already
        -- pinned to it keep executing against it until they finish.
        UPDATE dbo.LTYJ_JourneyVersion
        SET    Status = 'RETIRED', RetiredDate = SYSUTCDATETIME()
        WHERE  JourneyId = @JourneyId AND VersionId <> @VersionId AND Status = 'PUBLISHED';

        UPDATE dbo.LTYJ_Journey
        SET    CurrentVersionId = @VersionId,
               Status           = 'ACTIVE',
               ModifiedBy       = @ActionBy,
               ModifiedDate     = SYSUTCDATETIME()
        WHERE  JourneyId = @JourneyId;

        INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId, AfterJson)
        VALUES (@PropertyId, 'JOURNEY_VERSION', @VersionId, 'PUBLISH', @ActionBy,
                (SELECT @JourneyId AS journeyId, @VersionId AS versionId FOR JSON PATH, WITHOUT_ARRAY_WRAPPER));

        COMMIT TRANSACTION;

        SELECT @JourneyId AS JourneyId, @VersionId AS VersionId;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END

GO

