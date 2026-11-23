CREATE TABLE [dbo].[CostingTypeWiseDepartmentsWiseItemCategory] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [CostingId]          INT           NULL,
    [Code]               VARCHAR (4)   NULL,
    [Name]               VARCHAR (200) NULL,
    [Active]             BIT           NULL,
    [PropertyId]         INT           NULL,
    [ItemCategoryId]     INT           NULL,
    [CreatedUserId]      INT           NULL,
    [CreatedDateTime]    DATETIME      NULL,
    [LastEditedUserId]   INT           NULL,
    [LastEditedDateTime] DATETIME      NULL,
    CONSTRAINT [PK_CostingTypeWiseDepartments] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

