CREATE PROCEDURE dbo.LTYC_BrazeSync_History
    @PropertyId int,
    @SegmentId  int = NULL,
    @Top        int = 50
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@Top)
           b.SyncId, b.SegmentId, s.Name AS SegmentName, b.Status, b.Mode,
           b.ExternalIdAttribute, b.SnapshotVersion,
           b.TotalCount, b.SuccessCount, b.FailedCount, b.SkippedCount,
           b.StartedAt, b.CompletedAt, b.ErrorSummary, b.TriggeredBy
    FROM   dbo.LTYC_BrazeSync AS b
    LEFT JOIN dbo.LTYC_Segment AS s ON s.SegmentId = b.SegmentId
    WHERE  b.PropertyId = @PropertyId
      AND  (@SegmentId IS NULL OR b.SegmentId = @SegmentId)
    ORDER BY b.SyncId DESC;
END

GO

