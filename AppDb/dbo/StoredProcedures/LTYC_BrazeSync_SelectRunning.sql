/*  Runs the worker should still be draining. A run left RUNNING by a crashed
    worker is picked up again here rather than stalling forever.                 */
CREATE PROCEDURE dbo.LTYC_BrazeSync_SelectRunning
    @PropertyId int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT b.SyncId, b.PropertyId, b.SegmentId, b.Mode, b.ExternalIdAttribute,
           b.TotalCount, b.StartedAt,
           (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem AS i
            WHERE i.SyncId = b.SyncId AND i.Status IN ('PENDING','SENDING')) AS Remaining
    FROM   dbo.LTYC_BrazeSync AS b
    WHERE  b.Status IN ('QUEUED','RUNNING')
      AND  (@PropertyId IS NULL OR b.PropertyId = @PropertyId)
    ORDER BY b.SyncId;
END

GO

