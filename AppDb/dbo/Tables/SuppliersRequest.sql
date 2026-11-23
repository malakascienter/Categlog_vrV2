CREATE TABLE [dbo].[SuppliersRequest] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]         INT             NOT NULL,
    [Name]               NVARCHAR (100)  NULL,
    [Address1]           NVARCHAR (200)  NULL,
    [Email]              NVARCHAR (255)  NULL,
    [Telephone1]         NVARCHAR (15)   NULL,
    [IsApprove]          BIT             NULL,
    [CreatedUserID]      INT             NOT NULL,
    [LastModUserID]      INT             NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [LastModDate]        DATETIME        NOT NULL,
    [VatNo]              VARCHAR (150)   NULL,
    [BillingAddress]     NVARCHAR (200)  NULL,
    [FaxNo]              NVARCHAR (15)   NULL,
    [Telephone2]         NVARCHAR (15)   NULL,
    [ContactPerson]      NVARCHAR (150)  NULL,
    [NameOnCheque]       NVARCHAR (MAX)  NULL,
    [Remarks]            NVARCHAR (MAX)  NULL,
    [CreditPeriod]       REAL            NULL,
    [CreditLimit]        DECIMAL (18, 2) NULL,
    [CurrencyID]         INT             CONSTRAINT [DF_SuppliersRequest_CurrencyID] DEFAULT ((86)) NULL,
    [AccountNo]          VARCHAR (20)    NULL,
    [GracePeriod]        MONEY           NULL,
    [DefaultPaymentType] INT             NULL,
    [BankCode]           VARCHAR (5)     NULL,
    [BranchCode]         VARCHAR (5)     NULL,
    [CommissionAcc]      VARCHAR (12)    NULL,
    [DeductionControl]   BIT             NULL,
    [CreditorTypeID]     INT             CONSTRAINT [DF_SuppliersRequest_CreditorTypeID] DEFAULT ((0)) NULL,
    [Email2]             NVARCHAR (255)  NULL,
    CONSTRAINT [PK_dbo.SuppliersRequest] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

