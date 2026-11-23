/*  Re-queue only the failed items of a completed run.

    Safe to repeat: /users/track is an upsert, so a member sent twice is
    idempotent on Braze's side. SKIPPED items are left alone - they were skipped
    for consent or a missing id, and neither is fixed by retrying.               */
CREATE PROCEDURE dbo.LTYC_BrazeSync_Retry
    @SyncId     int,
    @PropertyId int,
    @ActionBy   int = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.LTYC_BrazeSync WHERE SyncId = @SyncId AND PropertyId = @PropertyId)
        THROW 50607, 'This sync run no longer exists.', 1;

    UPDATE dbo.LTYC_BrazeSyncItem
    SET    Status = 'PENDING', AttemptCount = 0, ErrorMessage = NULL, HttpStatus = NULL
    WHERE  SyncId = @SyncId AND Status = 'FAILED';

    DECLARE @requeued int = @@ROWCOUNT;

    IF (@requeued > 0)
        UPDATE dbo.LTYC_BrazeSync
        SET    Status = 'RUNNING', CompletedAt = NULL, ErrorSummary = NULL
        WHERE  SyncId = @SyncId;

    INSERT INTO dbo.LTYJ_AuditLog (PropertyId, EntityType, EntityId, Action, ActorUserId, AfterJson)
    VALUES (@PropertyId, 'BRAZE_SYNC', @SyncId, 'RETRY', @ActionBy,
            (SELECT @requeued AS requeued FOR JSON PATH, WITHOUT_ARRAY_WRAPPER));

    SELECT @SyncId AS SyncId, @requeued AS Requeued;
END

GO

