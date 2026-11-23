CREATE TABLE [dbo].[OrderDetails] (
    [Id]                      INT             IDENTITY (1, 1) NOT NULL,
    [OrderHeaderID]           INT             NOT NULL,
    [ProductID]               INT             NOT NULL,
    [OrderQty]                DECIMAL (18, 2) NOT NULL,
    [IssueQty]                DECIMAL (18, 2) NOT NULL,
    [BalanceQty]              DECIMAL (18, 2) NOT NULL,
    [ConvertFactor]           DECIMAL (18, 2) NOT NULL,
    [UnitID]                  INT             NOT NULL,
    [SellingPrice]            DECIMAL (18, 2) NOT NULL,
    [TaxGroupID]              INT             NOT NULL,
    [TaxValue]                DECIMAL (18, 2) NOT NULL,
    [IsPercentageForDiscount] BIT             NOT NULL,
    [ItemDiscountValue]       DECIMAL (18, 2) NOT NULL,
    [ItemDiscountRate]        DECIMAL (18, 2) NOT NULL,
    [LineNo]                  INT             NOT NULL,
    [Total]                   DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [NetTotal]                DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ApprovedQuantity]        DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [TaxInclusivePrice]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.OrderDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

