/*  Claim the right to execute one node, exactly once.

    This is the idempotency gate. The unique index on IdempotencyKey means only
    one caller can insert a given key; a second caller collides and is told the
    step already exists, along with what it produced.

    The collision is expected traffic, not an error - a worker whose lease expired
    mid-send comes back through here - so it is caught and returned as data.
    IsNew = 0 tells the executor to skip the side effect and reuse ResultJson,
    which is what stops a retry issuing a second voucher.                         */
CREATE PROCEDURE dbo.LTYJ_Step_Begin
    @RunId          bigint,
    @JourneyId      int,
    @VersionId      int,
    @MemberId       int,
    @PropertyId     int,
    @NodeKey        varchar(50),
    @NodeType       varchar(30),
    -- Defaulted rather than required: the key is derivable from the run, the node
    -- and the attempt group, and a caller who forgets it must not be able to
    -- bypass the guard. Pass an explicit key only to open a NEW attempt group.
    @IdempotencyKey varchar(120) = NULL,
    @AttemptGroup   int          = 1
AS
BEGIN
    SET NOCOUNT ON;

    SET @IdempotencyKey = ISNULL(@IdempotencyKey,
                                 CONCAT(@RunId, ':', @NodeKey, ':', ISNULL(@AttemptGroup, 1)));

    BEGIN TRY
        INSERT INTO dbo.LTYJ_StepExecution
              (RunId, JourneyId, VersionId, MemberId, PropertyId, NodeKey, NodeType, Status, IdempotencyKey)
        VALUES(@RunId, @JourneyId, @VersionId, @MemberId, @PropertyId, @NodeKey, @NodeType, 'PENDING', @IdempotencyKey);

        SELECT CAST(SCOPE_IDENTITY() AS bigint) AS StepExecutionId,
               1                                AS IsNew,
               'PENDING'                        AS Status,
               CAST(NULL AS nvarchar(max))      AS ResultJson,
               CAST(NULL AS varchar(20))        AS BranchTaken;
    END TRY
    BEGIN CATCH
        -- 2627 unique constraint, 2601 unique index. Anything else is real.
        IF ERROR_NUMBER() NOT IN (2627, 2601) THROW;

        SELECT StepExecutionId,
               0            AS IsNew,
               Status,
               ResultJson,
               BranchTaken
        FROM   dbo.LTYJ_StepExecution
        WHERE  IdempotencyKey = @IdempotencyKey;
    END CATCH
END

GO

