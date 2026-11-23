/*  Close out one message: sent, suppressed, deferred or failed.

    @MaxAttempts applies only to FAILED. A transient provider error puts the row
    back to QUEUED with a backoff; past the limit it stays FAILED and is visible
    on the delivery log rather than retrying forever.                            */
CREATE PROCEDURE dbo.LTYC_Dispatch_Complete
    @DispatchId        bigint,
    -- SENT | SUPPRESSED | DEFERRED | FAILED
    @Status            varchar(20),
    @SuppressReason    varchar(40)    = NULL,
    @ProviderMessageId varchar(200)   = NULL,
    @ProviderName      varchar(50)    = NULL,
    @Recipient         nvarchar(300)  = NULL,
    @ScheduledFor      datetime2(3)   = NULL,
    @Error             nvarchar(2000) = NULL,
    @MaxAttempts       int            = 5,
    @BackoffSeconds    int            = 300
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @now      datetime2(3) = SYSUTCDATETIME();
    DECLARE @attempts int = (SELECT AttemptCount FROM dbo.LTYC_Dispatch WHERE DispatchId = @DispatchId);

    -- A retryable failure goes back on the queue; an exhausted one stays failed.
    DECLARE @finalStatus varchar(20) =
        CASE WHEN @Status = 'FAILED' AND @attempts < @MaxAttempts THEN 'QUEUED' ELSE @Status END;

    UPDATE dbo.LTYC_Dispatch
    SET    Status            = @finalStatus,
           SuppressReason    = ISNULL(@SuppressReason, SuppressReason),
           ProviderMessageId = ISNULL(@ProviderMessageId, ProviderMessageId),
           ProviderName      = ISNULL(@ProviderName, ProviderName),
           Recipient         = ISNULL(@Recipient, Recipient),
           SentAt            = CASE WHEN @Status = 'SENT' THEN @now ELSE SentAt END,
           ScheduledFor      = CASE
                                   WHEN @Status = 'DEFERRED' THEN @ScheduledFor
                                   WHEN @finalStatus = 'QUEUED' THEN DATEADD(second, @BackoffSeconds, @now)
                                   ELSE ScheduledFor
                               END,
           LastError         = @Error
    WHERE  DispatchId = @DispatchId;

    SELECT @finalStatus AS FinalStatus,
           CASE WHEN @Status = 'FAILED' AND @attempts >= @MaxAttempts THEN 1 ELSE 0 END AS GaveUp;
END

GO

