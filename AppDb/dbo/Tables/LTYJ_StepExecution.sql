CREATE TABLE [dbo].[LTYJ_StepExecution] (
    [StepExecutionId] BIGINT          IDENTITY (1, 1) NOT NULL,
    [RunId]           BIGINT          NOT NULL,
    [JourneyId]       INT             NOT NULL,
    [VersionId]       INT             NOT NULL,
    [MemberId]        INT             NOT NULL,
    [PropertyId]      INT             NOT NULL,
    [NodeKey]         VARCHAR (50)    NOT NULL,
    [NodeType]        VARCHAR (30)    NOT NULL,
    [Status]          VARCHAR (20)    CONSTRAINT [DF_LTYJ_StepExecution_Status] DEFAULT ('PENDING') NOT NULL,
    [IdempotencyKey]  VARCHAR (120)   NOT NULL,
    [ResultJson]      NVARCHAR (MAX)  NULL,
    [BranchTaken]     VARCHAR (20)    NULL,
    [ErrorMessage]    NVARCHAR (2000) NULL,
    [AttemptNo]       INT             CONSTRAINT [DF_LTYJ_StepExecution_AttemptNo] DEFAULT ((1)) NOT NULL,
    [StartedAt]       DATETIME2 (0)   CONSTRAINT [DF_LTYJ_StepExecution_StartedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [CompletedAt]     DATETIME2 (0)   NULL,
    CONSTRAINT [PK_LTYJ_StepExecution] PRIMARY KEY CLUSTERED ([StepExecutionId] ASC),
    CONSTRAINT [UQ_LTYJ_StepExecution_Idempotency] UNIQUE NONCLUSTERED ([IdempotencyKey] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_StepExecution_Journey_Node]
    ON [dbo].[LTYJ_StepExecution]([JourneyId] ASC, [VersionId] ASC, [NodeKey] ASC, [Status] ASC)
    INCLUDE([StartedAt], [CompletedAt], [BranchTaken]);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_StepExecution_Run]
    ON [dbo].[LTYJ_StepExecution]([RunId] ASC, [NodeKey] ASC)
    INCLUDE([Status], [BranchTaken], [CompletedAt]);


GO

