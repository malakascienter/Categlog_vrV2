CREATE TABLE [dbo].[BOQAmedmentDetails] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [ItemID]         INT          NOT NULL,
    [BalanceQTY]     DECIMAL (18) NOT NULL,
    [BOQAMDheaderID] INT          NOT NULL,
    CONSTRAINT [PK_BOQAmedmentDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

