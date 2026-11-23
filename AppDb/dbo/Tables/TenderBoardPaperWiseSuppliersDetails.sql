CREATE TABLE [dbo].[TenderBoardPaperWiseSuppliersDetails] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [TBPHeaderID]       INT             NOT NULL,
    [SupplierID]        INT             NOT NULL,
    [StockItemHeaderID] INT             NOT NULL,
    [MaxQty]            DECIMAL (18, 2) NULL,
    [MinQty]            DECIMAL (18, 2) NULL,
    [Price]             DECIMAL (18, 2) NOT NULL,
    [Qunatity]          DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsSuggested]       BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.TenderBoardPaperWiseSuppliersDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

