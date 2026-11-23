CREATE TABLE [dbo].[AutoStockItemCodeCombination] (
    [ID]                INT           IDENTITY (1, 1) NOT NULL,
    [PrefixCombination] VARCHAR (MAX) NULL,
    [NextNumber]        NCHAR (10)    NULL
);


GO

