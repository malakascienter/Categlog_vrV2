CREATE TABLE [dbo].[SubContractors] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]        INT             NOT NULL,
    [Code]              NVARCHAR (10)   NULL,
    [Name]              NVARCHAR (100)  NULL,
    [Address1]          NVARCHAR (100)  NULL,
    [BillingAddress]    NVARCHAR (100)  NULL,
    [Email]             NVARCHAR (255)  NULL,
    [Telephone1]        NVARCHAR (15)   NULL,
    [Telephone2]        NVARCHAR (15)   NULL,
    [FaxNo]             NVARCHAR (15)   NULL,
    [ContactPerson]     NVARCHAR (50)   NULL,
    [CountryID]         INT             NOT NULL,
    [Remarks]           NVARCHAR (MAX)  NULL,
    [CreditLimit]       DECIMAL (18, 2) NOT NULL,
    [CreditPeriod]      REAL            NOT NULL,
    [PaymentTermID]     INT             NOT NULL,
    [CurrencyID]        INT             NOT NULL,
    [NameOnCheque]      NVARCHAR (MAX)  NULL,
    [SupplierGradingID] INT             NOT NULL,
    [IsDefaultSupplier] BIT             NOT NULL,
    [IsActive]          BIT             NOT NULL,
    [IsLabor]           BIT             NOT NULL,
    [IPAddress]         NVARCHAR (MAX)  NULL,
    [CreatedUserID]     INT             NOT NULL,
    [LastModUserID]     INT             NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [LastModDate]       DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.SubContractors] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

