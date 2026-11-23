CREATE TABLE [dbo].[BundleItems] (
    [Id]                      INT             IDENTITY (1, 1) NOT NULL,
    [BundleStockItemHeaderId] INT             NOT NULL,
    [DetailStockItemHeaderId] INT             NOT NULL,
    [Quantity]                DECIMAL (18, 2) NOT NULL,
    [IPAddress]               NVARCHAR (MAX)  NULL,
    [CreatedUserID]           INT             DEFAULT ((0)) NOT NULL,
    [LastModUserID]           INT             DEFAULT ((0)) NOT NULL,
    [CreatedDate]             DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]             DATETIME        DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [Unit]                    INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BundleItems] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

