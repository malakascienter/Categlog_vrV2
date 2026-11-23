CREATE TABLE [dbo].[TransactionWiseApprovalTypes] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [TransactionApprovalID] INT            NOT NULL,
    [TransactionID]         INT            NOT NULL,
    [PropertyID]            INT            NOT NULL,
    [LocationID]            INT            NOT NULL,
    [ApprovalTypeID]        INT            NOT NULL,
    [SeqID]                 INT            NOT NULL,
    [IPAddress]             NVARCHAR (MAX) NULL,
    [CreatedUserID]         INT            NOT NULL,
    [LastModUserID]         INT            NOT NULL,
    [CreatedDate]           DATETIME       NOT NULL,
    [LastModDate]           DATETIME       NOT NULL,
    [MinValue]              INT            NULL,
    CONSTRAINT [PK_dbo.TransactionWiseApprovalTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

