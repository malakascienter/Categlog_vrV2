/*  Active journeys whose scheduled trigger has not yet been evaluated for today.

    The watermark is what makes daily evaluation exactly-once across restarts. A
    journey published today is evaluated today; one already evaluated is skipped
    until tomorrow.                                                               */
CREATE PROCEDURE dbo.LTYJ_Journey_SelectDue
    @BusinessDate date = NULL,
    @PropertyId   int  = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SET @BusinessDate = ISNULL(@BusinessDate, CAST(SYSUTCDATETIME() AS date));

    SELECT j.JourneyId,
           j.PropertyId,
           j.Name,
           v.VersionId,
           v.TriggerJson,
           v.ExitRulesJson,
           v.ReEntryPolicy,
           v.ReEntryPeriodDays,
           w.LastEvaluatedDate
    FROM   dbo.LTYJ_Journey        AS j
    INNER JOIN dbo.LTYJ_JourneyVersion AS v
            ON v.VersionId = j.CurrentVersionId
           AND v.Status    = 'PUBLISHED'
    LEFT  JOIN dbo.LTYJ_EnrollmentWatermark AS w
            ON w.JourneyId = j.JourneyId AND w.PropertyId = j.PropertyId
    WHERE  j.Status    = 'ACTIVE'
      AND  j.IsDeleted = 0
      AND  (@PropertyId IS NULL OR j.PropertyId = @PropertyId)
      AND  (w.LastEvaluatedDate IS NULL OR w.LastEvaluatedDate < @BusinessDate)
      AND  v.TriggerJson IS NOT NULL
    ORDER BY j.JourneyId;
END

GO

