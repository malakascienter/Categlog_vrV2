CREATE TABLE [dbo].[BankBranches] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [BankID]        INT            DEFAULT ((0)) NOT NULL,
    [Branch_Code]   NVARCHAR (MAX) NULL,
    [Branch_Name]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.BankBranches] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

