
CREATE PROCEDURE dbo.LTYC_Dispatch_Suppress
    @PropertyId      int,
    @MemberId        int,
    @Channel         varchar(20),
    @SourceType      varchar(20),
    @SourceId        int         = NULL,
    @RunId           bigint      = NULL,
    @StepExecutionId bigint      = NULL,
    @SuppressReason  varchar(40),
    @IdempotencyKey  varchar(120)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        INSERT INTO dbo.LTYC_Dispatch
              (PropertyId, MemberId, Channel, SourceType, SourceId, RunId, StepExecutionId,
               Status, SuppressReason, IdempotencyKey)
        VALUES(@PropertyId, @MemberId, @Channel, @SourceType, @SourceId, @RunId, @StepExecutionId,
               'SUPPRESSED', @SuppressReason, @IdempotencyKey);

        SELECT CAST(SCOPE_IDENTITY() AS bigint) AS DispatchId, 1 AS IsNew,
               'SUPPRESSED' AS Status, CAST(NULL AS int) AS TemplateId;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (2627, 2601) THROW;

        SELECT DispatchId, 0 AS IsNew, Status, TemplateId
        FROM   dbo.LTYC_Dispatch
        WHERE  IdempotencyKey = @IdempotencyKey;
    END CATCH
END

GO

