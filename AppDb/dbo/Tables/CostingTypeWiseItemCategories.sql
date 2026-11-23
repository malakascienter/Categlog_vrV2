CREATE TABLE [dbo].[CostingTypeWiseItemCategories] (
    [Id]                 INT          IDENTITY (1, 1) NOT NULL,
    [CostingId]          INT          NULL,
    [CategoryId]         INT          NULL,
    [Code]               VARCHAR (4)  NULL,
    [Name]               VARCHAR (50) NULL,
    [Active]             BIT          NULL,
    [PropertyId]         INT          NULL,
    [CreatedUserId]      INT          NULL,
    [CreatedDateTime]    DATETIME     NULL,
    [LastEditedUserId]   INT          NULL,
    [LastEditedDateTime] DATETIME     NULL,
    CONSTRAINT [PK_CostingTypeWiseItemCategories] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

