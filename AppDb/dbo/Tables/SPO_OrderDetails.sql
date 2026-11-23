CREATE TABLE [dbo].[SPO_OrderDetails] (
    [OrderDetailId]     INT             IDENTITY (1, 1) NOT NULL,
    [OrderId]           INT             NOT NULL,
    [ItemCode]          VARCHAR (50)    NOT NULL,
    [ItemName]          VARCHAR (255)   NOT NULL,
    [Price]             DECIMAL (18, 2) NOT NULL,
    [Qty]               INT             NOT NULL,
    [Discount]          DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [TotalAmount]       DECIMAL (18, 2) NOT NULL,
    [ItemRemark]        VARCHAR (500)   NULL,
    [CreatedDate]       DATETIME        DEFAULT (getdate()) NULL,
    [DiscountType]      VARCHAR (100)   NULL,
    [IsDiscount]        BIT             CONSTRAINT [DF_SPO_OrderDetails_IsDiscount] DEFAULT ((0)) NOT NULL,
    [IsDiscountApprove] BIT             CONSTRAINT [DF_SPO_OrderDetails_IsDiscountApprove] DEFAULT ((0)) NOT NULL,
    [DiscountStatus]    CHAR (1)        CONSTRAINT [DF_SPO_OrderDetails_DiscountStatus] DEFAULT ('P') NOT NULL,
    [ItemSeq]           INT             NULL,
    [SortSeq]           INT             NULL,
    [RefItemCode]       VARCHAR (MAX)   NULL,
    PRIMARY KEY CLUSTERED ([OrderDetailId] ASC)
);


GO

