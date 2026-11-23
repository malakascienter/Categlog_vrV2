CREATE TABLE [dbo].[PoHeaders] (
    [Id]                     INT             IDENTITY (1, 1) NOT NULL,
    [PoHeaderID]             INT             NOT NULL,
    [PropertyID]             INT             NOT NULL,
    [LocationID]             INT             NOT NULL,
    [PoNo]                   NVARCHAR (50)   NULL,
    [SupplierID]             INT             NOT NULL,
    [DocumentDate]           DATETIME        NOT NULL,
    [Remarks]                NVARCHAR (500)  NULL,
    [DocumentStatus]         NVARCHAR (1)    NULL,
    [UserProfileID]          INT             NOT NULL,
    [IsDirectPo]             BIT             NOT NULL,
    [IsApproved]             BIT             NOT NULL,
    [IPAddress]              NVARCHAR (MAX)  NULL,
    [CreatedUserID]          INT             NOT NULL,
    [LastModUserID]          INT             NOT NULL,
    [CreatedDate]            DATETIME        NOT NULL,
    [LastModDate]            DATETIME        NOT NULL,
    [DeliveryDate]           DATETIME        NULL,
    [DeliveryAddressID]      NVARCHAR (MAX)  NULL,
    [PaymentTermsDetailID]   INT             DEFAULT ((0)) NOT NULL,
    [CurrencyId]             INT             DEFAULT ((0)) NOT NULL,
    [POTypeId]               INT             DEFAULT ((0)) NOT NULL,
    [Isprint]                BIT             DEFAULT ((0)) NOT NULL,
    [NetTotal]               DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [GrossTotal]             DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [TotalDiscount]          DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [TaxTotal]               DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [POType]                 INT             NULL,
    [SupplierReferenceNo]    VARCHAR (50)    NULL,
    [isModificationComplete] BIT             NULL,
    [IsDepartmentWise]       BIT             CONSTRAINT [DF_PoHeaders_IsDepartmentWise] DEFAULT ((0)) NOT NULL,
    [DepartmentID]           INT             CONSTRAINT [DF_PoHeaders_DepartmentID] DEFAULT ((0)) NOT NULL,
    [InvoiceID]              INT             CONSTRAINT [DF_PoHeaders_BackEndInvoiceID] DEFAULT ((0)) NULL,
    [IsInvoicebased]         BIT             CONSTRAINT [DF_PoHeaders_IsInvoicebased] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.PoHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [PoHeaders_3]
    ON [dbo].[PoHeaders]([LocationID] ASC, [IsApproved] ASC)
    INCLUDE([PropertyID], [PoNo], [SupplierID], [DocumentDate]);


GO

CREATE NONCLUSTERED INDEX [PoHeaders_2]
    ON [dbo].[PoHeaders]([IsApproved] ASC)
    INCLUDE([PropertyID], [LocationID], [PoNo], [SupplierID], [DocumentDate]);


GO

CREATE NONCLUSTERED INDEX [PoHeaders_PropertyID]
    ON [dbo].[PoHeaders]([PropertyID] ASC)
    INCLUDE([LocationID], [PoNo], [UserProfileID]);


GO

