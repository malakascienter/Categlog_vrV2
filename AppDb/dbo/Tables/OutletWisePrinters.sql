CREATE TABLE [dbo].[OutletWisePrinters] (
    [OutLet]   CHAR (6)     NOT NULL,
    [Printer]  VARCHAR (50) NOT NULL,
    [CompName] VARCHAR (50) CONSTRAINT [DF_OutletWisePrinters_CompName] DEFAULT ('') NOT NULL
);


GO

