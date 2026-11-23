CREATE TABLE [dbo].[InvoiceHeaders] (
    [ID]                      INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]               NVARCHAR (MAX)  NULL,
    [CustomerID]              INT             NOT NULL,
    [InvoiceDate]             DATETIME        NOT NULL,
    [InvoiceMode]             INT             CONSTRAINT [DF_InvoiceHeaders_InvoiceMode] DEFAULT ((1)) NOT NULL,
    [DepartmentID]            INT             NOT NULL,
    [Location]                INT             NOT NULL,
    [TotalDiscount]           DECIMAL (18, 2) NOT NULL,
    [ItemDiscountTotal]       DECIMAL (18, 2) NOT NULL,
    [TaxTotal]                DECIMAL (18, 2) NOT NULL,
    [OtherCharges]            DECIMAL (18, 2) NOT NULL,
    [sysDate]                 DATETIME        NOT NULL,
    [UserID]                  INT             NOT NULL,
    [IPAddress]               NVARCHAR (MAX)  NULL,
    [CreatedUserID]           INT             NOT NULL,
    [LastModUserID]           INT             NOT NULL,
    [CreatedDate]             DATETIME        NOT NULL,
    [LastModDate]             DATETIME        NOT NULL,
    [CustomerName]            NVARCHAR (MAX)  NULL,
    [PropertyID]              INT             CONSTRAINT [DF__InvoiceHe__Prope__28D80438] DEFAULT ((0)) NOT NULL,
    [VATNo]                   INT             CONSTRAINT [DF__InvoiceHe__VATNo__2E90DD8E] DEFAULT ((0)) NOT NULL,
    [SalesPersonID]           INT             NULL,
    [TotalPrintDiscount]      DECIMAL (18, 2) NULL,
    [SubTotal]                DECIMAL (18, 2) NULL,
    [IsSerialUpdated]         BIT             CONSTRAINT [DF__InvoiceHe__IsSer__4A8DFDBE] DEFAULT ((0)) NOT NULL,
    [IsPercentageForDiscount] BIT             CONSTRAINT [DF__InvoiceHe__IsPer__0E44098D] DEFAULT ((0)) NOT NULL,
    [ToatlDiscountRate]       DECIMAL (18, 2) CONSTRAINT [DF__InvoiceHe__Toatl__1B9E04AB] DEFAULT ((0)) NOT NULL,
    [GrossTotal]              DECIMAL (18, 2) CONSTRAINT [DF__InvoiceHe__Gross__2062B9C8] DEFAULT ((0)) NOT NULL,
    [NetTotal]                DECIMAL (18, 2) CONSTRAINT [DF__InvoiceHe__NetTo__2156DE01] DEFAULT ((0)) NOT NULL,
    [ItemDiscountType]        INT             CONSTRAINT [DF__InvoiceHe__ItemD__4B4D17CD] DEFAULT ((0)) NOT NULL,
    [Isprint]                 BIT             CONSTRAINT [DF__InvoiceHe__Ispri__0A3E6E7F] DEFAULT ((0)) NOT NULL,
    [ReferenceNo]             NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.InvoiceHeaders] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

