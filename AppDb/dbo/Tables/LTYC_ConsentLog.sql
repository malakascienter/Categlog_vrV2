CREATE TABLE [dbo].[LTYC_ConsentLog] (
    [LogId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [MemberId]    INT            NOT NULL,
    [PropertyId]  INT            NOT NULL,
    [Channel]     VARCHAR (20)   NOT NULL,
    [OldValue]    BIT            NULL,
    [NewValue]    BIT            NOT NULL,
    [Source]      VARCHAR (30)   NOT NULL,
    [ActorUserId] INT            NULL,
    [ActorIp]     VARCHAR (45)   NULL,
    [DispatchId]  BIGINT         NULL,
    [Notes]       NVARCHAR (500) NULL,
    [CreatedDate] DATETIME2 (0)  CONSTRAINT [DF_LTYC_ConsentLog_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_ConsentLog] PRIMARY KEY CLUSTERED ([LogId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_ConsentLog_Member]
    ON [dbo].[LTYC_ConsentLog]([MemberId] ASC, [Channel] ASC, [CreatedDate] ASC)
    INCLUDE([NewValue], [Source]);


GO

