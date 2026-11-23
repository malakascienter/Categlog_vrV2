CREATE TABLE [dbo].[PoWisePRs] (
    [PoWisePRID]      INT             IDENTITY (1, 1) NOT NULL,
    [PoHeaderID]      INT             NOT NULL,
    [RequestHeaderID] INT             NOT NULL,
    [StockItemID]     INT             NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    [RequestionQty]   DECIMAL (18, 2) CONSTRAINT [DF__PoWisePRs__Reque__6576FE24] DEFAULT ((0)) NOT NULL,
    [ApprovedQty]     DECIMAL (18, 2) CONSTRAINT [DF__PoWisePRs__Appro__666B225D] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.PoWisePRs] PRIMARY KEY CLUSTERED ([PoWisePRID] ASC)
);


GO

