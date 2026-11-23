CREATE TABLE [dbo].[tempBudgetReEmbrece] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [XmlData] XML      NULL,
    [logdate] DATETIME CONSTRAINT [DF_tempBudgetReEmbrece_logdate] DEFAULT (getdate()) NOT NULL
);


GO

