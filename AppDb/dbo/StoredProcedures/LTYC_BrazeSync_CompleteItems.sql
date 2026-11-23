/*  Record the outcome for a batch, as a JSON array so one round trip closes 75
    members rather than 75 round trips.

        [{"itemId":1,"status":"SENT"},
         {"itemId":2,"status":"FAILED","httpStatus":400,"error":"invalid email"}]

    A FAILED item under the attempt limit goes back to PENDING, so a retry picks
    it up without re-enqueuing the whole run.                                    */
CREATE PROCEDURE dbo.LTYC_BrazeSync_CompleteItems
    @SyncId      int,
    @ItemsJson   nvarchar(max),
    @MaxAttempts int = 3
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF (ISJSON(@ItemsJson) = 0)
        THROW 50606, 'The batch result could not be read.', 1;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();

    UPDATE i
    SET    i.Status = CASE
                          WHEN r.status = 'SENT' THEN 'SENT'
                          WHEN r.status = 'FAILED' AND i.AttemptCount < @MaxAttempts THEN 'PENDING'
                          ELSE 'FAILED'
                      END,
           i.HttpStatus   = r.httpStatus,
           i.ErrorMessage = LEFT(r.error, 1000),
           i.SentAt       = CASE WHEN r.status = 'SENT' THEN @now ELSE i.SentAt END
    FROM   dbo.LTYC_BrazeSyncItem AS i
    INNER JOIN OPENJSON(@ItemsJson)
    WITH (
        itemId     bigint         '$.itemId',
        status     varchar(20)    '$.status',
        httpStatus int            '$.httpStatus',
        error      nvarchar(1000) '$.error'
    ) AS r ON r.itemId = i.ItemId
    WHERE  i.SyncId = @SyncId;

    SELECT @@ROWCOUNT AS RowsAffected,
           (SELECT COUNT(*) FROM dbo.LTYC_BrazeSyncItem WHERE SyncId = @SyncId AND Status = 'PENDING') AS StillPending;
END

GO

