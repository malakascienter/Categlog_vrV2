/*  Allow one more attempt at a step that failed.

    The idempotency key embeds an attempt group, so a genuine retry uses a NEW
    key rather than reusing the failed one. This procedure exists for the case
    where a step failed BEFORE its side effect ran - the executor knows that and
    can safely reopen. It never reopens a SUCCESS row.                           */
CREATE PROCEDURE dbo.LTYJ_Step_Reopen
    @StepExecutionId bigint
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYJ_StepExecution
    SET    Status      = 'PENDING',
           AttemptNo   = AttemptNo + 1,
           CompletedAt = NULL
    WHERE  StepExecutionId = @StepExecutionId
      AND  Status = 'FAILED';

    SELECT @@ROWCOUNT AS RowsAffected;
END

GO

