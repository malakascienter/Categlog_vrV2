/*  Drop the lease without advancing. Used when the worker is shutting down mid
    batch: the run becomes claimable immediately instead of waiting out the lease. */
CREATE PROCEDURE dbo.LTYJ_Run_Release
    @RunId    bigint,
    @WorkerId varchar(100)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYJ_Run
    SET    LockedBy = NULL, LockedUntil = NULL
    WHERE  RunId = @RunId AND LockedBy = @WorkerId;

    SELECT @@ROWCOUNT AS RowsAffected;
END

GO

