CREATE TABLE [dbo].[DocumentWiseRptFileName] (
    [TxnTypeId]   INT           NULL,
    [RptFilename] VARCHAR (100) NULL,
    [PropertyID]  INT           CONSTRAINT [DF_DocumentWiseRptFileName_PropertyID] DEFAULT ((0)) NULL
);


GO

