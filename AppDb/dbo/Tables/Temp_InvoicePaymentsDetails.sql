CREATE TABLE [dbo].[Temp_InvoicePaymentsDetails] (
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
    [ChequeNumber]     NVARCHAR (MAX)  NULL,
    [BankId]           INT             DEFAULT ((0)) NOT NULL,
    [BranchId]         INT             DEFAULT ((0)) NOT NULL,
    [RealizedDate]     DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [CreditNumber]     NVARCHAR (MAX)  NULL,
    [CnId]             INT             NULL,
    CONSTRAINT [PK_dbo.Temp_InvoicePaymentsDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

