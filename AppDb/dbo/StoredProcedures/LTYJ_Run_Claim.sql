/*  Claim a bounded batch of due runs and return them.

    One statement: the UPDATE takes the lease and OUTPUT hands back the rows, so
    there is no window between selecting and locking in which another worker
    could take the same run.

    READPAST skips rows another worker holds rather than queueing behind them,
    which is what lets N workers share the queue with no coordinator.

    Runs on a paused or archived journey are excluded here rather than after the
    fact, so pausing takes effect on the next tick without touching run rows.     */
CREATE PROCEDURE dbo.LTYJ_Run_Claim
    @WorkerId       varchar(100),
    @BatchSize      int = 100,
    @LeaseSeconds   int = 300,
    @PropertyId     int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();
    DECLARE @leaseUntil datetime2(3) = DATEADD(second, @LeaseSeconds, @now);

    DECLARE @Claimed TABLE
    (
        RunId           bigint,
        JourneyId       int,
        VersionId       int,
        MemberId        int,
        PropertyId      int,
        Status          varchar(20),
        CurrentNodeKey  varchar(50),
        ContextJson     nvarchar(max),
        AttemptCount    int,
        EnteredAt       datetime2(0)
    );

    UPDATE TOP (@BatchSize) r WITH (READPAST, ROWLOCK)
    SET    r.LockedBy    = @WorkerId,
           r.LockedUntil = @leaseUntil,
           r.AttemptCount = r.AttemptCount + 1
    OUTPUT inserted.RunId, inserted.JourneyId, inserted.VersionId, inserted.MemberId,
           inserted.PropertyId, inserted.Status, inserted.CurrentNodeKey,
           inserted.ContextJson, inserted.AttemptCount, inserted.EnteredAt
      INTO @Claimed
    FROM   dbo.LTYJ_Run AS r
    INNER JOIN dbo.LTYJ_Journey AS j
            ON j.JourneyId = r.JourneyId
           AND j.Status    = 'ACTIVE'
           AND j.IsDeleted = 0
    WHERE  r.Status IN ('ACTIVE','WAITING')
      AND  r.NextRunAt IS NOT NULL
      AND  r.NextRunAt <= @now
      AND  (r.LockedUntil IS NULL OR r.LockedUntil < @now)
      AND  (@PropertyId IS NULL OR r.PropertyId = @PropertyId);

    SELECT RunId, JourneyId, VersionId, MemberId, PropertyId, Status,
           CurrentNodeKey, ContextJson, AttemptCount, EnteredAt
    FROM   @Claimed
    ORDER BY RunId;
END

GO

