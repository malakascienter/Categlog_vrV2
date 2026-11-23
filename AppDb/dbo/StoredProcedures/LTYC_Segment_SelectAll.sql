CREATE PROCEDURE dbo.LTYC_Segment_SelectAll
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT s.SegmentId,
           s.Name,
           s.Description,
           s.RootOperator,
           s.RefreshMode,
           s.RefreshCron,
           s.LastEstimatedCount,
           s.LastEstimatedAt,
           s.LastRefreshedAt,
           s.LastRefreshMs,
           s.IsActive,
           -- The materialised size, which may differ from the last estimate if
           -- the data moved since. Both are shown so a stale segment is obvious.
           (SELECT COUNT(*) FROM dbo.LTYC_SegmentMember AS sm WHERE sm.SegmentId = s.SegmentId) AS MemberCount,
           -- Where it is used, so nobody deletes a segment a live journey needs.
           (SELECT COUNT(*) FROM dbo.LTYC_BrazeSync AS bs WHERE bs.SegmentId = s.SegmentId)     AS SyncCount,
           s.CreatedDate,
           s.ModifiedDate
    FROM   dbo.LTYC_Segment AS s
    WHERE  s.PropertyId = @PropertyId
      AND  s.IsDeleted  = 0
    ORDER BY s.Name;
END

GO

