CREATE TABLE [dbo].[TempApproval] (
    [Id]      INT  IDENTITY (1, 1) NOT NULL,
    [TxnType] INT  NULL,
    [XMLData] XML  NULL,
    [TxnDate] DATE NULL
);


GO

