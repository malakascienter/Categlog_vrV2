CREATE TABLE [dbo].[StockSpotCheckHeader] (
    [ID]                  INT           IDENTITY (1, 1) NOT NULL,
    [PropertyID]          INT           NULL,
    [LocationID]          INT           NULL,
    [DocNo]               NCHAR (20)    NULL,
    [SpotCheckDate]       DATETIME      NULL,
    [UserID]              INT           NULL,
    [CreatedDate]         DATETIME      CONSTRAINT [DF_StockSpotCheckHeader_CreatedDate] DEFAULT (getdate()) NULL,
    [Remark]              VARCHAR (MAX) NULL,
    [IsApprove]           BIT           CONSTRAINT [DF_StockSpotCheckHeader_IsApprove] DEFAULT ((0)) NULL,
    [FirstLevel]          BIT           CONSTRAINT [DF_StockSpotCheckHeader_FirstLevel] DEFAULT ((0)) NULL,
    [SecondLevel]         BIT           CONSTRAINT [DF_StockSpotCheckHeader_SecondLevel] DEFAULT ((0)) NULL,
    [TransactionHeaderID] INT           CONSTRAINT [DF_StockSpotCheckHeader_TransactionHeaderID] DEFAULT ((0)) NULL
);


GO

