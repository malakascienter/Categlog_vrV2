CREATE TABLE [dbo].[WB_UserwiseMessage] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [TaskTypesId]   INT            NOT NULL,
    [UserId]        INT            NOT NULL,
    [ShortName]     NVARCHAR (MAX) NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [Done]          BIT            NOT NULL,
    [DateCompleted] DATETIME       NOT NULL,
    [IsDisposable]  BIT            NOT NULL,
    CONSTRAINT [PK_dbo.WB_UserwiseMessage] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

