CREATE TABLE [dbo].[WB_TaskUser] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [TaskTypesId]   INT            NOT NULL,
    [UserId]        INT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.WB_TaskUser] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

