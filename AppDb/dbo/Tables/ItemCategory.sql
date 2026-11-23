CREATE TABLE [dbo].[ItemCategory] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [Code]            VARCHAR (3)  NOT NULL,
    [Name]            VARCHAR (50) NOT NULL,
    [IsActive]        BIT          CONSTRAINT [DF_ItemCategory_IsActive] DEFAULT ((0)) NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_ItemCategory_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdatedUserId]   INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    CONSTRAINT [PK_ItemCategory] PRIMARY KEY CLUSTERED ([Id] ASC, [Code] ASC)
);


GO

