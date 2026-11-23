CREATE TABLE [dbo].[TempStockItemRequest] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [PropertyId]        INT           NULL,
    [ItemCode]          VARCHAR (200) NULL,
    [ItemDescription]   VARCHAR (500) NULL,
    [CategoryId]        INT           NULL,
    [SubCategoryId]     INT           NULL,
    [SubCategory2Id]    INT           NULL,
    [Remarks]           VARCHAR (500) NULL,
    [ItemUnit]          INT           NULL,
    [Approved]          BIT           DEFAULT ((0)) NULL,
    [CreatedDate]       DATETIME      NULL,
    [CreatedUserID]     INT           NULL,
    [LastModDate]       DATETIME      NULL,
    [LastModUserID]     INT           NULL,
    [StockItemHeaderID] BIGINT        CONSTRAINT [DF_TempStockItemRequest_StockItemHeaderID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__TempStoc__3214EC07897E578E] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

