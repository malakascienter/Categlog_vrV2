CREATE TABLE [dbo].[tempIssueNote] (
    [ID]                       INT      IDENTITY (1, 1) NOT NULL,
    [logate]                   DATETIME DEFAULT (getdate()) NOT NULL,
    [XmlDATA]                  XML      NULL,
    [StockTransactionHeaderID] INT      NULL
);


GO

