CREATE TABLE [dbo].[CostTypes] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]    INT            NOT NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.CostTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

