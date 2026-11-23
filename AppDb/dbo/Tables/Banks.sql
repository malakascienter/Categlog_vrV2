CREATE TABLE [dbo].[Banks] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Bank_Code]     NVARCHAR (MAX) NULL,
    [Bank_Name]     NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Banks] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

