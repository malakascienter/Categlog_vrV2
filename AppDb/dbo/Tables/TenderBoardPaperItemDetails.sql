CREATE TABLE [dbo].[TenderBoardPaperItemDetails] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [TBPHeaderID]       INT             NOT NULL,
    [StockItemHeaderID] INT             NOT NULL,
    [Qunatity]          DECIMAL (18, 2) NOT NULL,
    [ProfitMargin]      DECIMAL (18, 2) NOT NULL,
    [SellingPrice]      DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.TenderBoardPaperItemDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

