CREATE TABLE [dbo].[ESMSLog] (
    [ID]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [OrderNo]       VARCHAR (12)  NOT NULL,
    [OrderDate]     DATE          NOT NULL,
    [Outlet]        VARCHAR (5)   NOT NULL,
    [PropertyId]    INT           NOT NULL,
    [Token]         VARCHAR (MAX) NOT NULL,
    [Request]       VARCHAR (MAX) NOT NULL,
    [Response]      VARCHAR (MAX) NOT NULL,
    [IsSent]        BIT           NOT NULL,
    [IsFail]        BIT           NOT NULL,
    [TransactionId] BIGINT        NOT NULL,
    [UniqueId]      VARCHAR (MAX) NOT NULL,
    [SysDate]       DATETIME      CONSTRAINT [DF_ESMSLog_SysDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ESMSLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

