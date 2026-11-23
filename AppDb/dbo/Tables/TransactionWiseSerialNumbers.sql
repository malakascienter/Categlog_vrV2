CREATE TABLE [dbo].[TransactionWiseSerialNumbers] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [LocationID]        INT           NOT NULL,
    [StockItemHeaderID] INT           NOT NULL,
    [TxnID]             INT           NOT NULL,
    [TxnType]           CHAR (2)      NOT NULL,
    [TxnDate]           DATE          NOT NULL,
    [SerialNumber]      VARCHAR (MAX) NOT NULL,
    [OutTxnID]          INT           NULL,
    [OutTxnType]        CHAR (2)      NULL,
    [Out]               BIT           NULL,
    [OutTxnDate]        DATE          NULL
);


GO

