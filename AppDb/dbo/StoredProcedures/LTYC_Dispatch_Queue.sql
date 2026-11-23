
CREATE PROCEDURE dbo.LTYC_Dispatch_Queue
    @PropertyId      int,
    @MemberId        int,
    @Channel         varchar(20),
    @SourceType      varchar(20),
    @SourceId        int            = NULL,
    @RunId           bigint         = NULL,
    @StepExecutionId bigint         = NULL,
    @TemplateId      int            = NULL,
    @TemplateCode    varchar(60)    = NULL,
    @VariantKey      varchar(20)    = NULL,
    @ScheduledFor    datetime2(3)   = NULL,
    @IdempotencyKey  varchar(120)
AS
BEGIN
    SET NOCOUNT ON;

    /* Resolve a template by code when the caller named one. A journey node
       stores a stable code rather than an id, so a template can be re-versioned
       without editing every journey that references it. */
    IF (@TemplateId IS NULL AND NULLIF(LTRIM(RTRIM(ISNULL(@TemplateCode, ''))), '') IS NOT NULL)
    BEGIN
        SELECT TOP (1) @TemplateId = TemplateId
        FROM   dbo.LTYC_Template
        WHERE  PropertyId = @PropertyId
          AND  Code       = @TemplateCode
          AND  Channel    = @Channel
          AND  Status     = 'PUBLISHED'
          AND  IsDeleted  = 0
        ORDER BY VersionNo DESC;
    END

    BEGIN TRY
        INSERT INTO dbo.LTYC_Dispatch
              (PropertyId, MemberId, Channel, SourceType, SourceId, RunId, StepExecutionId,
               TemplateId, VariantKey, Status, ScheduledFor, IdempotencyKey)
        VALUES(@PropertyId, @MemberId, @Channel, @SourceType, @SourceId, @RunId, @StepExecutionId,
               @TemplateId, @VariantKey, 'QUEUED', @ScheduledFor, @IdempotencyKey);

        SELECT CAST(SCOPE_IDENTITY() AS bigint) AS DispatchId,
               1          AS IsNew,
               'QUEUED'   AS Status,
               @TemplateId AS TemplateId;
    END TRY
    BEGIN CATCH
        -- 2627 unique constraint, 2601 unique index: this message is already
        -- queued. Expected traffic on a replay, not an error.
        IF ERROR_NUMBER() NOT IN (2627, 2601) THROW;

        SELECT DispatchId, 0 AS IsNew, Status, TemplateId
        FROM   dbo.LTYC_Dispatch
        WHERE  IdempotencyKey = @IdempotencyKey;
    END CATCH
END

GO

