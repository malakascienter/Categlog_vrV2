CREATE TABLE [dbo].[SPO_OrderDetailsHistory] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [OrderDetailId]     INT             NULL,
    [OrderId]           INT             NULL,
    [ItemCode]          VARCHAR (50)    NULL,
    [ItemName]          VARCHAR (255)   NULL,
    [Price]             DECIMAL (18, 2) NULL,
    [Qty]               INT             NULL,
    [Discount]          DECIMAL (18, 2) NULL,
    [TotalAmount]       DECIMAL (18, 2) NULL,
    [ItemRemark]        VARCHAR (500)   NULL,
    [CreatedDate]       DATETIME        NULL,
    [DiscountType]      VARCHAR (100)   NULL,
    [IsDiscount]        BIT             NULL,
    [IsDiscountApprove] BIT             NULL,
    [DiscountStatus]    CHAR (1)        NULL,
    [ItemSeq]           INT             NULL,
    [SortSeq]           INT             NULL,
    [RefItemCode]       VARCHAR (MAX)   NULL,
    CONSTRAINT [PK_SPO_OrderDetailsHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

