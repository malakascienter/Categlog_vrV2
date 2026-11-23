/*  Move a run to its next node and release the lease.

    @NextNodeKey NULL with @Status 'COMPLETED' or 'EXITED' ends the run.
    @NextRunAt   NULL on a live run means "immediately" - a WAIT node passes a
                 real time, every other node passes NULL and the run is picked up
                 on the next tick rather than spinning inside one.

    The lease is only released if this worker still holds it. If the lease expired
    and another worker took over, this update matches nothing and the caller is
    told so - which is the correct outcome, because the other worker is now the
    owner and a blind write would duplicate work.                                 */
CREATE PROCEDURE dbo.LTYJ_Run_Advance
    @RunId          bigint,
    @WorkerId       varchar(100),
    @NextNodeKey    varchar(50)   = NULL,
    @NextRunAt      datetime2(3)  = NULL,
    @Status         varchar(20)   = 'ACTIVE',
    @ContextJson    nvarchar(max) = NULL,
    @ExitReason     varchar(50)   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();
    DECLARE @terminal bit = CASE WHEN @Status IN ('COMPLETED','EXITED','FAILED','CANCELLED') THEN 1 ELSE 0 END;

    UPDATE dbo.LTYJ_Run
    SET    CurrentNodeKey = CASE WHEN @terminal = 1 THEN CurrentNodeKey ELSE @NextNodeKey END,
           Status         = @Status,
           NextRunAt      = CASE WHEN @terminal = 1 THEN NULL
                                 ELSE ISNULL(@NextRunAt, @now) END,
           ContextJson    = ISNULL(@ContextJson, ContextJson),
           ExitReason     = CASE WHEN @terminal = 1 THEN ISNULL(@ExitReason, ExitReason) ELSE ExitReason END,
           EndedAt        = CASE WHEN @terminal = 1 THEN @now ELSE NULL END,
           LockedBy       = NULL,
           LockedUntil    = NULL,
           LastError      = NULL
    WHERE  RunId    = @RunId
      AND  LockedBy = @WorkerId;

    SELECT @@ROWCOUNT AS RowsAffected;
END

GO

