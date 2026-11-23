CREATE TABLE [dbo].[StockSpotCheckDetail] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [StockSpotHeaderID] INT             NULL,
    [StockItemID]       INT             NULL,
    [QuantityInHand]    DECIMAL (18, 8) NULL,
    [PhysicalQty]       DECIMAL (18, 8) NULL,
    [UserID]            INT             NULL,
    [CreatedDate]       DATETIME        CONSTRAINT [DF_StockSpotCheckDetail_CreatedDate] DEFAULT (getdate()) NULL,
    [Remark]            NVARCHAR (MAX)  NULL,
    [AveragePrice]      DECIMAL (18, 8) CONSTRAINT [DF_StockSpotCheckDetail_AveragePrice] DEFAULT ((0)) NULL,
    [FirstLevelRemark]  NVARCHAR (MAX)  NULL,
    [SecondLevelRemark] NVARCHAR (MAX)  NULL
);


GO

