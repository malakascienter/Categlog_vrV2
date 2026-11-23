CREATE TABLE [dbo].[SupplierQuotationHeader] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [SupplierId]           INT           NULL,
    [QuotationNo]          VARCHAR (150) NULL,
    [ReferenceNo]          VARCHAR (150) NULL,
    [ValidFrom]            DATE          NULL,
    [ValidTo]              DATE          NULL,
    [IsActive]             BIT           NULL,
    [Status]               VARCHAR (20)  NULL,
    [Remarks]              VARCHAR (200) NULL,
    [LeadTimeExpireDays]   INT           NULL,
    [ExpdateChangeRemarks] VARCHAR (500) NULL,
    [IsDefaultSupplier]    BIT           CONSTRAINT [DF_SupplierQuotationHeader_IsDefaultSupplier] DEFAULT ((0)) NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_SupplierQuotationHeader_CreatedDate] DEFAULT (getdate()) NULL,
    [CreatedUserId]        INT           NULL,
    [ApprovedDate]         DATETIME      NULL,
    [ApprovedUserId]       INT           NULL,
    CONSTRAINT [PK__Supplier__3214EC076F9A227F] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

