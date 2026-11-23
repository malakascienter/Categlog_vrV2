CREATE TABLE [dbo].[CostingTypeWiseOutletWiseItemCategory] (
    [Id]                 INT         IDENTITY (1, 1) NOT NULL,
    [CostingId]          INT         NULL,
    [Code]               VARCHAR (4) NULL,
    [Active]             BIT         NULL,
    [PropertyId]         INT         NULL,
    [ItemCategoryId]     INT         NULL,
    [CreatedUserId]      INT         NULL,
    [CreatedDateTime]    DATETIME    NULL,
    [LastEditedUserId]   INT         NULL,
    [LastEditedDateTime] DATETIME    NULL,
    CONSTRAINT [PK_CostingTypeWiseOutletWiseItemCategory] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

