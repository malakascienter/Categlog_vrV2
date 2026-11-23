/*  Cache the last live estimate, so the grid can show a number without
    re-running every segment's query on page load.                               */
CREATE PROCEDURE dbo.LTYC_Segment_SetEstimate
    @SegmentId int,
    @Count     int
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYC_Segment
    SET    LastEstimatedCount = @Count, LastEstimatedAt = SYSUTCDATETIME()
    WHERE  SegmentId = @SegmentId;

    SELECT @@ROWCOUNT AS RowsAffected;
END

GO

