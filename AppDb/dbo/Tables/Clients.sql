CREATE TABLE [dbo].[Clients] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (50)  NULL,
    [Address]       NVARCHAR (120) NULL,
    [Tel]           NVARCHAR (15)  NULL,
    [Email]         NVARCHAR (30)  NULL,
    [ConPer]        NVARCHAR (30)  NULL,
    [Fax]           NVARCHAR (15)  NULL,
    [TaxGroupID]    INT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.Clients] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

