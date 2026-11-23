CREATE TABLE [dbo].[WorkHeaders] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [Description]      NVARCHAR (MAX) NULL,
    [IPAddress]        NVARCHAR (MAX) NULL,
    [CreatedUserID]    INT            NOT NULL,
    [LastModUserID]    INT            NOT NULL,
    [CreatedDate]      DATETIME       NOT NULL,
    [LastModDate]      DATETIME       NOT NULL,
    [WorkHeaderStatus] BIT            DEFAULT ((0)) NOT NULL,
    [WorkCode]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.WorkHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

