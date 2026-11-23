CREATE TABLE [dbo].[Logins] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [UserName]      NVARCHAR (MAX) NULL,
    [Password]      NVARCHAR (MAX) NULL,
    [Tocken]        NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Logins] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

