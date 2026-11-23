/*  Close a step. @BranchTaken is set by CONDITION nodes and drives branch
    analytics; @ResultJson carries whatever the node produced (a CouponId, a
    DispatchId) so a replay can reuse it instead of repeating the side effect.    */
CREATE PROCEDURE dbo.LTYJ_Step_Complete
    @StepExecutionId bigint,
    @Status          varchar(20),
    @ResultJson      nvarchar(max)  = NULL,
    @BranchTaken     varchar(20)    = NULL,
    @ErrorMessage    nvarchar(2000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.LTYJ_StepExecution
    SET    Status       = @Status,
           ResultJson   = ISNULL(@ResultJson, ResultJson),
           BranchTaken  = ISNULL(@BranchTaken, BranchTaken),
           ErrorMessage = @ErrorMessage,
           CompletedAt  = SYSUTCDATETIME()
    WHERE  StepExecutionId = @StepExecutionId;

    SELECT @@ROWCOUNT AS RowsAffected;
END

GO

