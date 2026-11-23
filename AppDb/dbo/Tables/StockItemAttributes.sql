CREATE TABLE [dbo].[StockItemAttributes] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [Code]                NVARCHAR (MAX) NULL,
    [Name]                NVARCHAR (MAX) NULL,
    [IsRemarksApplicable] BIT            NOT NULL,
    [IPAddress]           NVARCHAR (MAX) NULL,
    [CreatedUserID]       INT            NOT NULL,
    [LastModUserID]       INT            NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [LastModDate]         DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.StockItemAttributes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

