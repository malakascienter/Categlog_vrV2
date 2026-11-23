/*  Record a step failure and either schedule a retry or give up.

    Backoff is exponential on AttemptCount, capped, and the caller supplies the
    base so a transient provider error and a database timeout can back off
    differently. Past @MaxAttempts the run goes to FAILED and stops consuming
    ticks - it stays visible on the journey detail screen rather than
    disappearing, because a silently dropped member is worse than a visible
    failure.                                                                      */
CREATE PROCEDURE dbo.LTYJ_Run_Fail
    @RunId              bigint,
    @WorkerId           varchar(100),
    @Error              nvarchar(2000),
    @MaxAttempts        int = 5,
    @BackoffBaseSeconds int = 60,
    @BackoffCapSeconds  int = 3600
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now      datetime2(3) = SYSUTCDATETIME();
    DECLARE @attempts int = (SELECT AttemptCount FROM dbo.LTYJ_Run WHERE RunId = @RunId);

    -- POWER overflows quickly; clamp the exponent before it is evaluated.
    DECLARE @exp   int = CASE WHEN @attempts > 10 THEN 10 ELSE @attempts END;
    DECLARE @delay int = CASE
                             WHEN @BackoffBaseSeconds * POWER(2, @exp) > @BackoffCapSeconds
                             THEN @BackoffCapSeconds
                             ELSE @BackoffBaseSeconds * POWER(2, @exp)
                         END;

    UPDATE dbo.LTYJ_Run
    SET    Status      = CASE WHEN @attempts >= @MaxAttempts THEN 'FAILED' ELSE Status END,
           NextRunAt   = CASE WHEN @attempts >= @MaxAttempts THEN NULL
                              ELSE DATEADD(second, @delay, @now) END,
           EndedAt     = CASE WHEN @attempts >= @MaxAttempts THEN @now ELSE NULL END,
           ExitReason  = CASE WHEN @attempts >= @MaxAttempts THEN 'FAILED' ELSE ExitReason END,
           LastError   = @Error,
           LockedBy    = NULL,
           LockedUntil = NULL
    WHERE  RunId    = @RunId
      AND  LockedBy = @WorkerId;

    SELECT @@ROWCOUNT                                            AS RowsAffected,
           CASE WHEN @attempts >= @MaxAttempts THEN 1 ELSE 0 END AS GaveUp,
           @delay                                                AS RetryInSeconds;
END

GO

