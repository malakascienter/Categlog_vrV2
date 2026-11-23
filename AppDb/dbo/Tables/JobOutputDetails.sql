CREATE TABLE [dbo].[JobOutputDetails] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [JobHeaderID]       INT             NOT NULL,
    [StockItemHeaderID] INT             NOT NULL,
    [Qty]               DECIMAL (18, 2) NOT NULL,
    [OutputQty]         DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.JobOutputDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

