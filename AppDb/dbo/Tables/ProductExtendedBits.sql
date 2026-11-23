CREATE TABLE [dbo].[ProductExtendedBits] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [StockHeaderId] INT            NOT NULL,
    [ExtendedId]    INT            NOT NULL,
    [Value]         BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.ProductExtendedBits] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

