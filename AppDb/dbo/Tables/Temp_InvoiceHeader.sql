CREATE TABLE [dbo].[Temp_InvoiceHeader] (
    [ID]                      INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceNo]               NVARCHAR (MAX)  NULL,
    [CustomerID]              INT             NOT NULL,
    [InvoiceDate]             DATETIME        NOT NULL,
    [DepartmentID]            INT             NOT NULL,
    [Location]                INT             NOT NULL,
    [TotalDiscount]           DECIMAL (18, 2) NOT NULL,
    [ToatlDiscountRate]       DECIMAL (18, 2) NOT NULL,
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
    [PropertyID]              INT             CONSTRAINT [DF__Temp_Invo__Prope__27E3DFFF] DEFAULT ((0)) NOT NULL,
    [VATNo]                   INT             CONSTRAINT [DF__Temp_Invo__VATNo__2F8501C7] DEFAULT ((0)) NOT NULL,
    [SalesPersonID]           INT             NULL,
    [TotalPrintDiscount]      DECIMAL (18, 2) NULL,
    [SubTotal]                DECIMAL (18, 2) NULL,
    [IsSerialUpdated]         BIT             CONSTRAINT [DF__Temp_Invo__IsSer__4999D985] DEFAULT ((0)) NOT NULL,
    [IsPercentageForDiscount] BIT             CONSTRAINT [DF__Temp_Invo__IsPer__0F382DC6] DEFAULT ((0)) NOT NULL,
    [GrossTotal]              DECIMAL (18, 2) CONSTRAINT [DF__Temp_Invo__Gross__224B023A] DEFAULT ((0)) NOT NULL,
    [NetTotal]                DECIMAL (18, 2) CONSTRAINT [DF__Temp_Invo__NetTo__233F2673] DEFAULT ((0)) NOT NULL,
    [ItemDiscountType]        INT             CONSTRAINT [DF__Temp_Invo__ItemD__4C413C06] DEFAULT ((0)) NOT NULL,
    [ReferenceNo]             NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.Temp_InvoiceHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

