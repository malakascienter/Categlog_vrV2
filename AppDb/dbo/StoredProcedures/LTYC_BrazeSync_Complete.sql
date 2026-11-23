/*  Close a run and roll up its counts from the item rows.

    Counts are derived, never incremented as the run goes: a counter updated per
    batch drifts the moment a batch is retried, and the item rows are the record
    anyway.

    A run that finished with failures is COMPLETED_WITH_ERRORS rather than
    COMPLETED, so a partially successful export is not reported as a clean one.  */
CREATE PROCEDURE dbo.LTYC_BrazeSync_Complete
    @SyncId       int,
    @ErrorSummary nvarchar(2000) = NULL,
    @Failed       bit            = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Named *Count to avoid colliding with the @Failed parameter: T-SQL
    -- identifiers are case-insensitive, so @failed and @Failed are one name.
    DECLARE @sentCount    int = (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem WHERE SyncId = @SyncId AND Status = 'SENT');
    DECLARE @failedCount  int = (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem WHERE SyncId = @SyncId AND Status = 'FAILED');
    DECLARE @skippedCount int = (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem WHERE SyncId = @SyncId AND Status = 'SKIPPED');

    UPDATE dbo.LTYC_BrazeSync
    SET    Status = CASE
                        WHEN @Failed = 1 THEN 'FAILED'
                        WHEN @failedCount > 0 THEN 'COMPLETED_WITH_ERRORS'
                        ELSE 'COMPLETED'
                    END,
           SuccessCount = @sentCount,
           FailedCount  = @failedCount,
           SkippedCount = @skippedCount,
           CompletedAt  = SYSUTCDATETIME(),
           ErrorSummary = @ErrorSummary
    WHERE  SyncId = @SyncId;

    SELECT SyncId, Status, TotalCount, SuccessCount, FailedCount, SkippedCount, Mode, ExternalIdAttribute
    FROM   dbo.LTYC_BrazeSync
    WHERE  SyncId = @SyncId;
END

GO

