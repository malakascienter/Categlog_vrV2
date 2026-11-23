/*  Record that a journey has been evaluated for a business date.                 */
CREATE PROCEDURE dbo.LTYJ_Watermark_Set
    @JourneyId      int,
    @PropertyId     int,
    @BusinessDate   date,
    @EnrolledCount  int = 0
AS
BEGIN
    SET NOCOUNT ON;

    MERGE dbo.LTYJ_EnrollmentWatermark AS t
    USING (SELECT @JourneyId AS JourneyId, @PropertyId AS PropertyId) AS s
       ON t.JourneyId = s.JourneyId AND t.PropertyId = s.PropertyId
     WHEN MATCHED THEN
          UPDATE SET LastEvaluatedDate = @BusinessDate,
                     LastRunAt         = SYSUTCDATETIME(),
                     LastEnrolledCount = @EnrolledCount
     WHEN NOT MATCHED BY TARGET THEN
          INSERT (JourneyId, PropertyId, LastEvaluatedDate, LastRunAt, LastEnrolledCount)
          VALUES (@JourneyId, @PropertyId, @BusinessDate, SYSUTCDATETIME(), @EnrolledCount);
END

GO

