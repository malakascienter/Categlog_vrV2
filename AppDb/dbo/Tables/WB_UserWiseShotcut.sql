CREATE TABLE [dbo].[WB_UserWiseShotcut] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [UserId]        INT            NOT NULL,
    [IconsName]     NVARCHAR (MAX) NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [Path]          NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.WB_UserWiseShotcut] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

