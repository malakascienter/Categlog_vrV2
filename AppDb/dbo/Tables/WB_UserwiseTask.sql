CREATE TABLE [dbo].[WB_UserwiseTask] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [TaskTypesId]    INT            NOT NULL,
    [UserId]         INT            NOT NULL,
    [AutoGenId]      INT            NOT NULL,
    [Form]           NVARCHAR (MAX) NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [Completed]      BIT            NOT NULL,
    [DatePlaned]     DATETIME       NOT NULL,
    [DateCompleted]  DATETIME       NOT NULL,
    [IsDisposable]   BIT            NOT NULL,
    [NeedEscalation] BIT            NOT NULL,
    CONSTRAINT [PK_dbo.WB_UserwiseTask] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

