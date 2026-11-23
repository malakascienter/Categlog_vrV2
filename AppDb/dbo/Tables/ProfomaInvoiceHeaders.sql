CREATE TABLE [dbo].[ProfomaInvoiceHeaders] (
    [Id]                 BIGINT         IDENTITY (1, 1) NOT NULL,
    [AmmendmentNo]       INT            NOT NULL,
    [PropertyId]         INT            NOT NULL,
    [LocationId]         INT            NOT NULL,
    [PoHeaderId]         BIGINT         NOT NULL,
    [PoNo]               NVARCHAR (MAX) NULL,
    [SupplierId]         INT            NOT NULL,
    [DocumentDate]       DATETIME       NOT NULL,
    [Remarks]            NVARCHAR (MAX) NULL,
    [DocumentStatus]     NVARCHAR (MAX) NULL,
    [UserProfileId]      INT            NOT NULL,
    [IsApproved]         BIT            NOT NULL,
    [DeliverDate]        DATETIME       NOT NULL,
    [DeliveryAddressId]  INT            NOT NULL,
    [PaymentAgreementID] INT            NOT NULL,
    [DocumentNo]         NVARCHAR (MAX) NULL,
    [IPAddress]          NVARCHAR (MAX) NULL,
    [CreatedUserID]      INT            NOT NULL,
    [LastModUserID]      INT            NOT NULL,
    [CreatedDate]        DATETIME       NOT NULL,
    [LastModDate]        DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.ProfomaInvoiceHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

