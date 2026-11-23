/*  Enrol members whose birthday month starts today.

    @DayOfMonth 1 is "first day of the birthday month", which is what the brief
    asks for. It is a parameter rather than a constant so a journey can trigger on
    the birthday itself (@MatchDay = 1) or mid-month, without a new procedure.

    Leap years: a 29 February birthday is treated as 28 February in a non-leap
    year, so those members are not skipped every fourth year. The abandoned
    LYT_SP_GenerateBirthdayRewards in LoyaltyDB handles this the same way, which
    is good evidence it is a real case rather than a theoretical one.

    Re-entry: ONCE_PER_PERIOD with 365 days is the sensible birthday setting, and
    is enforced by the NOT EXISTS on prior runs rather than by the daily
    watermark - a member must not be enrolled twice in one year even if the
    journey is republished.                                                       */
CREATE PROCEDURE dbo.LTYJ_Enrollment_Birthday
    @JourneyId        int,
    @VersionId        int,
    @PropertyId       int,
    @StartNodeKey     varchar(50),
    @BusinessDate     date        = NULL,
    -- 1 = first of the birth month. NULL = the birthday itself.
    @DayOfMonth       int         = 1,
    @ReEntryPolicy    varchar(20) = 'ONCE_PER_PERIOD',
    @ReEntryPeriodDays int        = 365
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @BusinessDate = ISNULL(@BusinessDate, CAST(SYSUTCDATETIME() AS date));

    DECLARE @now      datetime2(3) = SYSUTCDATETIME();
    DECLARE @todayDay int = DAY(@BusinessDate);
    DECLARE @todayMon int = MONTH(@BusinessDate);
    DECLARE @cutoff   date = DATEADD(day, -ISNULL(@ReEntryPeriodDays, 365), @BusinessDate);

    INSERT INTO dbo.LTYJ_Run
          (JourneyId, VersionId, MemberId, PropertyId, Status, CurrentNodeKey, NextRunAt, EnteredDate, ContextJson)
    SELECT @JourneyId, @VersionId, m.MemberId, m.PropertyId, 'ACTIVE', @StartNodeKey, @now, @BusinessDate, N'{}'
    FROM   dbo.LTY_Member AS m
    WHERE  m.PropertyId = @PropertyId
      AND  m.IsActive   = 1
      AND  m.BirthDay IS NOT NULL
      AND  MONTH(m.BirthDay) = @todayMon
      AND  (
             -- first day of the birth month
             (@DayOfMonth IS NOT NULL AND @todayDay = @DayOfMonth)
             -- or the birthday itself, with 29 Feb folded onto the 28th in a
             -- non-leap year so those members are not skipped
          OR (@DayOfMonth IS NULL
              AND @todayDay = CASE
                                  WHEN MONTH(m.BirthDay) = 2 AND DAY(m.BirthDay) = 29
                                       AND ISDATE(CONCAT(YEAR(@BusinessDate), '-02-29')) = 0
                                  THEN 28
                                  ELSE DAY(m.BirthDay)
                              END)
           )
      AND  NOT EXISTS (
             SELECT 1 FROM dbo.LTYJ_Run AS r
             WHERE  r.JourneyId = @JourneyId
               AND  r.MemberId  = m.MemberId
               AND  (
                      @ReEntryPolicy = 'ONCE_EVER'
                   OR (@ReEntryPolicy = 'ONCE_PER_PERIOD' AND r.EnteredDate > @cutoff)
                   OR (@ReEntryPolicy = 'ALWAYS'          AND r.EnteredDate = @BusinessDate)
                    )
           );

    SELECT @@ROWCOUNT AS Enrolled;
END

GO

