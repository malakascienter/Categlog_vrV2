/*  One segment with its rule tree, as a single JSON document.

    The tree is nested with a recursive CTE and emitted parent-first, so the
    application can rebuild the hierarchy from ParentRuleId without a second
    pass. JSON_QUERY on the nested array - a nested FOR JSON is otherwise
    embedded as an escaped string.                                               */
CREATE PROCEDURE dbo.LTYC_Segment_Select
    @SegmentId  int,
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_Segment
                   WHERE SegmentId = @SegmentId AND PropertyId = @PropertyId AND IsDeleted = 0)
        THROW 50501, 'This segment no longer exists.', 1;

    DECLARE @Json nvarchar(max) =
    (
        SELECT s.SegmentId,
               s.PropertyId,
               s.Name,
               s.Description,
               s.RootOperator,
               s.RefreshMode,
               s.RefreshCron,
               s.LastEstimatedCount,
               s.LastRefreshedAt,
               s.IsActive,
               JSON_QUERY((
                   SELECT r.RuleId        AS ruleId,
                          r.ParentRuleId  AS parentRuleId,
                          r.NodeKind      AS nodeKind,
                          r.LogicalOp     AS logicalOp,
                          r.AttributeCode AS attributeCode,
                          r.Operator      AS [operator],
                          r.ValueJson     AS valueJson,
                          r.SortOrder     AS sortOrder
                   FROM   dbo.LTYC_SegmentRule AS r
                   WHERE  r.SegmentId = s.SegmentId
                   ORDER BY r.RuleId
                   FOR JSON PATH
               )) AS rules
        FROM   dbo.LTYC_Segment AS s
        WHERE  s.SegmentId = @SegmentId
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    );

    SELECT @Json AS SegmentJson;
END

GO

