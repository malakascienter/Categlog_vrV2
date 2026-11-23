/*  Take a batch of unprocessed events off the outbox.

    Same shape as the run claim: one statement, OUTPUT hands back what was taken,
    READPAST lets several drainers share the table. ProcessedAt is stamped up
    front so a crashed drainer does not leave events invisible - the attempt
    counter and LastError record what happened if handling fails afterwards.      */
CREATE PROCEDURE dbo.LTYJ_Outbox_Claim
    @BatchSize int = 200
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Claimed TABLE
    (
        EventId    bigint,
        EventType  varchar(40),
        MemberId   int,
        PropertyId int,
        EntityId   int,
        PayloadJson nvarchar(max),
        OccurredAt datetime2(0)
    );

    UPDATE TOP (@BatchSize) o WITH (READPAST, ROWLOCK)
    SET    o.ProcessedAt     = SYSUTCDATETIME(),
           o.ProcessAttempts = o.ProcessAttempts + 1
    OUTPUT inserted.EventId, inserted.EventType, inserted.MemberId, inserted.PropertyId,
           inserted.EntityId, inserted.PayloadJson, inserted.OccurredAt
      INTO @Claimed
    FROM   dbo.LTYJ_EventOutbox AS o
    WHERE  o.ProcessedAt IS NULL;

    SELECT EventId, EventType, MemberId, PropertyId, EntityId, PayloadJson, OccurredAt
    FROM   @Claimed
    ORDER BY EventId;
END

GO

