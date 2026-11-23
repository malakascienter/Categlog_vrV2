CREATE TABLE [dbo].[tempStockRequestItems] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [XmlData] XML      NULL,
    [logdate] DATETIME CONSTRAINT [DF_tempStockRequestItems_logdate] DEFAULT (getdate()) NOT NULL
);


GO

