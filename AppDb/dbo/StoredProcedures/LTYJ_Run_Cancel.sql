/*  Remove one member from a journey, from the admin screen. Audited by the
    caller; irreversible by design.                                               */
CREATE PROCEDURE dbo.LTYJ_Run_Cancel
    @RunId      bigint,
    @PropertyId int,
    @ExitReason varchar(50) = 'CANCELLED_BY_USER'
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYJ_Run
    SET    Status      = 'CANCELLED',
           ExitReason  = @ExitReason,
           EndedAt     = SYSUTCDATETIME(),
           NextRunAt   = NULL,
           LockedBy    = NULL,
           LockedUntil = NULL
    WHERE  RunId      = @RunId
      AND  PropertyId = @PropertyId
      AND  Status IN ('ACTIVE','WAITING');

    SELECT @@ROWCOUNT AS RowsAffected;
END

GO

