CREATE TABLE [dbo].[MRNPOBalances] (
    [ID]     INT             IDENTITY (1, 1) NOT NULL,
    [POID]   INT             NOT NULL,
    [MRNID]  INT             NOT NULL,
    [ItemID] INT             NOT NULL,
    [Qty]    DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.MRNPOBalances] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

