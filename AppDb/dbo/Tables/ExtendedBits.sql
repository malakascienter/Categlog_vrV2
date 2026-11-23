CREATE TABLE [dbo].[ExtendedBits] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [DefaultValue]  BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.ExtendedBits] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

