CREATE TABLE [dbo].[OrderHeaders] (
    [Id]                    INT             IDENTITY (1, 1) NOT NULL,
    [CompanyID]             INT             NOT NULL,
    [LocationID]            INT             NOT NULL,
    [DocumentNo]            NVARCHAR (MAX)  NULL,
    [TransType]             NVARCHAR (MAX)  NULL,
    [CustomerID]            INT             NOT NULL,
    [SalesPersonID]         INT             NOT NULL,
    [DocumentDate]          DATETIME        NOT NULL,
    [PaymentMethodID]       INT             NOT NULL,
    [GrossAmount]           DECIMAL (18, 2) NOT NULL,
    [SubDiscountAmount]     DECIMAL (18, 2) NOT NULL,
    [SubDiscountPercentage] DECIMAL (18, 2) NOT NULL,
    [LineDiscountTotal]     DECIMAL (18, 2) NOT NULL,
    [TotalDiscount]         DECIMAL (18, 2) NOT NULL,
    [TotalOtherCharges]     DECIMAL (18, 2) NOT NULL,
    [TotalTax]              DECIMAL (18, 2) NOT NULL,
    [NetAmount]             DECIMAL (18, 2) NOT NULL,
    [Remark]                NVARCHAR (MAX)  NULL,
    [ReferenceNo]           NVARCHAR (MAX)  NULL,
    [DocumentStatus]        NVARCHAR (MAX)  NULL,
    [IsCancel]              BIT             DEFAULT ((0)) NOT NULL,
    [CancelDate]            DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [CanceledUser]          INT             DEFAULT ((0)) NOT NULL,
    [IsInvoiceCreated]      BIT             DEFAULT ((0)) NOT NULL,
    [InvoiceId]             INT             DEFAULT ((0)) NOT NULL,
    [IsApproved]            BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.OrderHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

