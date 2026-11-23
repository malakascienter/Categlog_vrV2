CREATE TABLE [dbo].[SubContratctorWorkDoneRegistories] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PWSID]              INT             NOT NULL,
    [PWSDetailsID]       INT             NOT NULL,
    [DoneQty]            DECIMAL (18, 2) NOT NULL,
    [Rate]               DECIMAL (18, 2) NOT NULL,
    [TxnDate]            DATETIME        NOT NULL,
    [LogDate]            DATETIME        NOT NULL,
    [StatusID]           DECIMAL (18, 2) NOT NULL,
    [PaymentRequestSent] BIT             NOT NULL,
    [PaymentRequestID]   INT             NOT NULL,
    [IPAddress]          NVARCHAR (MAX)  NULL,
    [CreatedUserID]      INT             NOT NULL,
    [LastModUserID]      INT             NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [LastModDate]        DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.SubContratctorWorkDoneRegistories] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

