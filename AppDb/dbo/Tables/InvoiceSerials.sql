CREATE TABLE [dbo].[InvoiceSerials] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceNumber]   NVARCHAR (100)  NULL,
    [InoviceDetailId] INT             NOT NULL,
    [stockItemId]     INT             NOT NULL,
    [RequestQuantity] DECIMAL (18, 2) NOT NULL,
    [LocationId]      INT             NOT NULL,
    [PropertyId]      INT             NOT NULL,
    [InventoryDate]   DATETIME        NOT NULL,
    [SerialNumber]    NVARCHAR (MAX)  NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    [InvoiceHeaderId] INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.InvoiceSerials] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

