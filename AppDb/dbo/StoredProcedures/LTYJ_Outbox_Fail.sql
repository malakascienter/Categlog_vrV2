/*  Hand an event back for another attempt, up to a limit. Past the limit it stays
    processed and carries its error, so a poison event cannot spin forever.       */
CREATE PROCEDURE dbo.LTYJ_Outbox_Fail
    @EventId     bigint,
    @Error       nvarchar(2000),
    @MaxAttempts int = 5
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYJ_EventOutbox
    SET    ProcessedAt = CASE WHEN ProcessAttempts >= @MaxAttempts THEN ProcessedAt ELSE NULL END,
           LastError   = @Error
    WHERE  EventId = @EventId;

    SELECT CASE WHEN (SELECT ProcessAttempts FROM dbo.LTYJ_EventOutbox WHERE EventId = @EventId) >= @MaxAttempts
                THEN 1 ELSE 0 END AS GaveUp;
END

GO

