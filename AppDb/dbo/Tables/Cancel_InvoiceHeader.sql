CREATE TABLE [dbo].[Cancel_InvoiceHeader] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]         NVARCHAR (MAX)  NULL,
    [CustomerID]        INT             NOT NULL,
    [CustomerName]      NVARCHAR (MAX)  NULL,
    [InvoiceDate]       DATETIME        NOT NULL,
    [DepartmentID]      INT             NOT NULL,
    [Location]          INT             NOT NULL,
    [TotalValue]        DECIMAL (18, 2) NOT NULL,
    [TotalDiscount]     DECIMAL (18, 2) NOT NULL,
    [ToatlDiscountType] INT             NOT NULL,
    [ToatlDiscountRate] DECIMAL (18, 2) NOT NULL,
    [ItemDiscountTotal] DECIMAL (18, 2) NOT NULL,
    [TaxTotal]          DECIMAL (18, 2) NOT NULL,
    [OtherCharges]      DECIMAL (18, 2) NOT NULL,
    [sysDate]           DATETIME        NOT NULL,
    [UserID]            INT             NOT NULL,
    [PropertyID]        INT             NOT NULL,
    [VATNo]             INT             NOT NULL,
    [InvoiceMode]       NVARCHAR (MAX)  NULL,
    [IPAddress]         NVARCHAR (MAX)  NULL,
    [CreatedUserID]     INT             NOT NULL,
    [LastModUserID]     INT             NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [LastModDate]       DATETIME        NOT NULL,
    [ReferenceNo]       NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.Cancel_InvoiceHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

