/*  Scheduled segments whose membership is older than the configured interval.

    STATIC segments are never refreshed - their membership is frozen at the
    moment they were saved, which is the point of them. MANUAL ones wait for
    someone to press the button.                                                 */
CREATE PROCEDURE dbo.LTYC_Segment_SelectDueForRefresh
    @PropertyId      int = NULL,
    @StaleAfterHours int = 24,
    @MaxSegments     int = 20
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP (@MaxSegments)
           s.SegmentId, s.PropertyId, s.Name, s.RootOperator, s.LastRefreshedAt
    FROM   dbo.LTYC_Segment AS s
    WHERE  s.IsDeleted   = 0
      AND  s.IsActive    = 1
      AND  s.RefreshMode = 'SCHEDULED'
      AND  (@PropertyId IS NULL OR s.PropertyId = @PropertyId)
      AND  (s.LastRefreshedAt IS NULL
            OR s.LastRefreshedAt < DATEADD(hour, -@StaleAfterHours, SYSUTCDATETIME()))
    ORDER BY ISNULL(s.LastRefreshedAt, '1900-01-01'), s.SegmentId;
END

GO

