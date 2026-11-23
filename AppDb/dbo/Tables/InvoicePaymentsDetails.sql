CREATE TABLE [dbo].[InvoicePaymentsDetails] (
    [ID]               INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceHeaderID]  INT             NOT NULL,
    [PaymentTypeID]    INT             NOT NULL,
    [TenderedAmount]   DECIMAL (18, 2) NOT NULL,
    [ActualAmount]     DECIMAL (18, 2) NOT NULL,
    [BalanceAmount]    DECIMAL (18, 2) NOT NULL,
    [Remarks]          NVARCHAR (MAX)  NULL,
    [ReferanceNumebrs] NVARCHAR (MAX)  NULL,
    [IPAddress]        NVARCHAR (MAX)  NULL,
    [CreatedUserID]    INT             NOT NULL,
    [LastModUserID]    INT             NOT NULL,
    [CreatedDate]      DATETIME        NOT NULL,
    [LastModDate]      DATETIME        NOT NULL,
    [CreditNumber]     NVARCHAR (MAX)  NULL,
    [CreditRequestID]  INT             NULL,
    CONSTRAINT [PK_dbo.InvoicePaymentsDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

