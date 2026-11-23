CREATE TABLE [dbo].[JobInputDetails] (
    [Id]                      INT             IDENTITY (1, 1) NOT NULL,
    [JobHeaderID]             INT             NOT NULL,
    [OutPutStockItemHeaderID] INT             NOT NULL,
    [StockItemHeaderID]       INT             NOT NULL,
    [Qty]                     DECIMAL (18, 2) NOT NULL,
    [UnitID]                  INT             NOT NULL,
    [RequestQty]              DECIMAL (18, 2) NOT NULL,
    [IssueQty]                DECIMAL (18, 2) NOT NULL,
    [JobOutPutHeadId]         INT             NULL,
    [Type]                    INT             NULL,
    CONSTRAINT [PK_dbo.JobInputDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

