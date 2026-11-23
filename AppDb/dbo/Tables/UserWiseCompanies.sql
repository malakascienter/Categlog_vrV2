CREATE TABLE [dbo].[UserWiseCompanies] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [UserId]        INT            NOT NULL,
    [CompnayId]     INT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.UserWiseCompanies] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

