CREATE TABLE [dbo].[OpenPrices] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [ItemId]       INT             NOT NULL,
    [UserId]       INT             NOT NULL,
    [LocationId]   INT             NOT NULL,
    [SellingPrice] DECIMAL (18, 2) NOT NULL,
    [Date]         DATETIME        NOT NULL,
    [Used]         BIT             NOT NULL,
    CONSTRAINT [PK_dbo.OpenPrices] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

