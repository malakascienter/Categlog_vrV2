/*  Take a batch of messages that are due to go out.

    Same claim shape as LTYJ_Run_Claim: one statement, OUTPUT returns what was
    taken, READPAST lets several dispatchers share the queue. A DEFERRED message
    becomes due again when its ScheduledFor passes, which is how a quiet-hours
    hold resumes without any separate sweep.

    Status moves to SENDING up front so a crashed dispatcher leaves evidence
    rather than a row that silently re-sends.                                    */
CREATE PROCEDURE dbo.LTYC_Dispatch_Claim
    @BatchSize  int = 100,
    @PropertyId int = NULL,
    @Channel    varchar(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();

    DECLARE @Claimed TABLE
    (
        DispatchId  bigint,
        PropertyId  int,
        MemberId    int,
        Channel     varchar(20),
        SourceType  varchar(20),
        SourceId    int,
        RunId       bigint,
        TemplateId  int,
        VariantKey  varchar(20),
        AttemptCount int
    );

    UPDATE TOP (@BatchSize) d WITH (READPAST, ROWLOCK)
    SET    d.Status       = 'SENDING',
           d.AttemptCount = d.AttemptCount + 1
    OUTPUT inserted.DispatchId, inserted.PropertyId, inserted.MemberId, inserted.Channel,
           inserted.SourceType, inserted.SourceId, inserted.RunId, inserted.TemplateId,
           inserted.VariantKey, inserted.AttemptCount
      INTO @Claimed
    FROM   dbo.LTYC_Dispatch AS d
    WHERE  d.Status IN ('QUEUED','DEFERRED')
      AND  (d.ScheduledFor IS NULL OR d.ScheduledFor <= @now)
      AND  (@PropertyId IS NULL OR d.PropertyId = @PropertyId)
      AND  (@Channel    IS NULL OR d.Channel    = @Channel);

    SELECT DispatchId, PropertyId, MemberId, Channel, SourceType, SourceId,
           RunId, TemplateId, VariantKey, AttemptCount
    FROM   @Claimed
    ORDER BY DispatchId;
END

GO

