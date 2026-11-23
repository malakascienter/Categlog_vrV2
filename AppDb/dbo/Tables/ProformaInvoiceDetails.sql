CREATE TABLE [dbo].[ProformaInvoiceDetails] (
    [Id]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [PIID]               BIGINT          NOT NULL,
    [StockItemID]        BIGINT          NOT NULL,
    [UnitID]             INT             NOT NULL,
    [UnitPrice]          DECIMAL (18, 2) NOT NULL,
    [RequestedQuantity]  REAL            NOT NULL,
    [ApprovedQuantity]   REAL            NOT NULL,
    [ReceivedQuantity]   REAL            NOT NULL,
    [Remarks]            NVARCHAR (MAX)  NULL,
    [DiscountValue]      REAL            NOT NULL,
    [DiscountPercentage] REAL            NOT NULL,
    [IPAddress]          NVARCHAR (MAX)  NULL,
    [CreatedUserID]      INT             NOT NULL,
    [LastModUserID]      INT             NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [LastModDate]        DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.ProformaInvoiceDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

