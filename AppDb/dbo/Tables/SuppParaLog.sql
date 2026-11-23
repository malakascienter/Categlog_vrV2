CREATE TABLE [dbo].[SuppParaLog] (
    [ID]                INT             NULL,
    [PropertyID]        INT             NULL,
    [Code]              NVARCHAR (10)   NULL,
    [Name]              NVARCHAR (100)  NULL,
    [Address1]          NVARCHAR (100)  NULL,
    [BillingAddress]    NVARCHAR (100)  NULL,
    [Email]             NVARCHAR (255)  NULL,
    [Telephone1]        NVARCHAR (15)   NULL,
    [Telephone2]        NVARCHAR (15)   NULL,
    [FaxNo]             NVARCHAR (15)   NULL,
    [ContactPerson]     NVARCHAR (50)   NULL,
    [CountryID]         INT             NULL,
    [Remarks]           NVARCHAR (MAX)  NULL,
    [CreditLimit]       DECIMAL (18, 2) NULL,
    [CreditPeriod]      REAL            NULL,
    [PaymentTermID]     INT             NULL,
    [CurrencyID]        INT             NULL,
    [NameOnCheque]      NVARCHAR (MAX)  NULL,
    [SupplierGradingID] INT             NULL,
    [IsDefaultSupplier] BIT             NULL,
    [IsActive]          BIT             NULL,
    [IsLabor]           BIT             NULL,
    [IPAddress]         NVARCHAR (MAX)  NULL,
    [CreatedUserID]     INT             NULL,
    [LastModUserID]     INT             NULL,
    [CreatedDate]       DATETIME        NULL,
    [LastModDate]       DATETIME        NULL,
    [Action]            INT             NULL,
    [TempSupplierId]    INT             NULL,
    [status]            INT             NULL,
    [NewId]             INT             NULL,
    [VatNo]             NVARCHAR (MAX)  NULL,
    [message]           NVARCHAR (MAX)  NULL
);


GO

