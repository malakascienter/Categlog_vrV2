/*  One journey with the graph the builder should open.

    @VersionId null opens the draft when there is one, otherwise the published
    version - which is what a marketer means by "open this journey".

    Returns the whole thing as a single JSON document, following LTY_GetPromotion
    and LTY_GetDashboard. The canvas wants one nested object, and shaping it here
    avoids three result sets and a mapping layer.                                */
CREATE PROCEDURE dbo.LTYJ_Journey_Select
    @JourneyId  int,
    @PropertyId int,
    @VersionId  int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTYJ_Journey
                   WHERE JourneyId = @JourneyId AND PropertyId = @PropertyId AND IsDeleted = 0)
        THROW 50401, 'This journey no longer exists.', 1;

    IF (@VersionId IS NULL)
        SELECT TOP (1) @VersionId = v.VersionId
        FROM   dbo.LTYJ_JourneyVersion AS v
        WHERE  v.JourneyId = @JourneyId
        ORDER BY CASE WHEN v.Status = 'DRAFT' THEN 0 ELSE 1 END, v.VersionNo DESC;

    DECLARE @Json nvarchar(max) =
    (
        SELECT j.JourneyId,
               j.PropertyId,
               j.Name,
               j.Description,
               j.Status,
               j.CurrentVersionId,
               JSON_QUERY((
                   SELECT v.VersionId, v.VersionNo, v.Status, v.TriggerJson, v.ExitRulesJson,
                          v.ReEntryPolicy, v.ReEntryPeriodDays, v.PublishedDate,
                          /*  JSON_QUERY is not decoration. A nested FOR JSON subquery is
                              embedded as an escaped STRING unless it is wrapped, which would
                              force the client to parse the document twice and would make the
                              graph unreadable to the engine.                                  */
                          JSON_QUERY((
                              SELECT n.NodeKey    AS nodeKey,
                                     n.NodeType   AS nodeType,
                                     n.Label      AS label,
                                     n.ConfigJson AS configJson,
                                     n.PosX       AS posX,
                                     n.PosY       AS posY
                              FROM   dbo.LTYJ_Node AS n
                              WHERE  n.VersionId = v.VersionId
                              ORDER BY n.NodeId
                              FOR JSON PATH
                          )) AS nodes,
                          JSON_QUERY((
                              SELECT e.FromNodeKey AS fromNodeKey,
                                     e.ToNodeKey   AS toNodeKey,
                                     e.BranchKey   AS branchKey,
                                     e.SortOrder   AS sortOrder
                              FROM   dbo.LTYJ_Edge AS e
                              WHERE  e.VersionId = v.VersionId
                              ORDER BY e.SortOrder, e.EdgeId
                              FOR JSON PATH
                          )) AS edges
                   FROM   dbo.LTYJ_JourneyVersion AS v
                   WHERE  v.VersionId = @VersionId
                   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
               )) AS version
        FROM   dbo.LTYJ_Journey AS j
        WHERE  j.JourneyId = @JourneyId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @Json AS JourneyJson;
END

GO

