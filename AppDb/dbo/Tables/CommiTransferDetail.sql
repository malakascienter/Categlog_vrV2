CREATE TABLE [dbo].[CommiTransferDetail] (
    [ID]             INT         IDENTITY (1, 1) NOT NULL,
    [CTHeaderID]     INT         NULL,
    [ItemID]         INT         NULL,
    [UnitID]         INT         NULL,
    [ApprovedQTY]    MONEY       CONSTRAINT [DF_CommiTransferDetail_ApprovedQTY] DEFAULT ((0)) NOT NULL,
    [TransferredQTY] MONEY       CONSTRAINT [DF_CommiTransferDetail_TransferdQTY] DEFAULT ((0)) NOT NULL,
    [BalanceQTY]     MONEY       CONSTRAINT [DF_CommiTransferDetail_BalaneQTY] DEFAULT ((0)) NOT NULL,
    [Status]         VARCHAR (5) NULL,
    [LogDate]        DATETIME    CONSTRAINT [DF__CommiTran__LogDa__12A439B7] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CommiTransferDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

