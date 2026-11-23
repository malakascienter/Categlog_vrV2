CREATE TABLE [dbo].[InvoiceWiseChequeDetails] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [InvoiceHeaderID] INT            NOT NULL,
    [PaymentTypeID]   INT            NOT NULL,
    [ChequeNumber]    NVARCHAR (MAX) NULL,
    [BankId]          INT            NOT NULL,
    [BranchId]        INT            NOT NULL,
    [RealizedDate]    DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.InvoiceWiseChequeDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

