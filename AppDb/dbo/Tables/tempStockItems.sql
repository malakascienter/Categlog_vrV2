CREATE TABLE [dbo].[tempStockItems] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [XmlData] XML      NULL,
    [logdate] DATETIME CONSTRAINT [DF_tempStockItems_logdate] DEFAULT (getdate()) NOT NULL
);


GO

