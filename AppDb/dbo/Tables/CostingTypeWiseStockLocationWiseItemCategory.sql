CREATE TABLE [dbo].[CostingTypeWiseStockLocationWiseItemCategory] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [CostingId]          INT           NULL,
    [Code]               VARCHAR (MAX) NULL,
    [Name]               VARCHAR (50)  NULL,
    [Active]             BIT           NULL,
    [PropertyId]         INT           NULL,
    [ItemCategoryId]     INT           NULL,
    [CreatedUserId]      INT           NULL,
    [CreatedDateTime]    DATETIME      NULL,
    [LastEditedUserId]   INT           NULL,
    [LastEditedDateTime] DATETIME      NULL,
    CONSTRAINT [PK_CostingTypeWiseStockLocation] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

