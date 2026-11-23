CREATE TABLE [dbo].[tempBudgetAllocation] (
    [ID]      INT      IDENTITY (1, 1) NOT NULL,
    [XmlData] XML      NULL,
    [logdate] DATETIME CONSTRAINT [DF_tempBudgetAllocation_logdate] DEFAULT (getdate()) NOT NULL
);


GO

