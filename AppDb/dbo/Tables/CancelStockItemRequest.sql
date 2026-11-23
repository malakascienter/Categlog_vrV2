CREATE TABLE [dbo].[CancelStockItemRequest] (
    [Id]              INT           NOT NULL,
    [PropertyId]      INT           NULL,
    [ItemCode]        VARCHAR (200) NULL,
    [ItemDescription] VARCHAR (500) NULL,
    [CategoryId]      INT           NULL,
    [SubCategoryId]   INT           NULL,
    [SubCategory2Id]  INT           NULL,
    [Remarks]         VARCHAR (500) NULL,
    [ItemUnit]        INT           NULL,
    [Approved]        BIT           NULL,
    [CanceledUserID]  INT           NULL,
    [LogDate]         DATE          DEFAULT (getdate()) NOT NULL
);


GO

