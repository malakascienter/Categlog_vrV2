CREATE TABLE [dbo].[BoqTaxes] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [ProjectId]     INT             NOT NULL,
    [BoqId]         INT             NOT NULL,
    [ItemId]        INT             NOT NULL,
    [TaxId]         INT             NOT NULL,
    [TaxRate]       DECIMAL (18, 2) NOT NULL,
    [IsBoq]         BIT             CONSTRAINT [DF_BoqTaxes_IsBoq] DEFAULT ((0)) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             CONSTRAINT [DF__BoqTaxes__Create__25B17ECA] DEFAULT ((0)) NOT NULL,
    [LastModUserID] INT             CONSTRAINT [DF__BoqTaxes__LastMo__26A5A303] DEFAULT ((0)) NOT NULL,
    [CreatedDate]   DATETIME        CONSTRAINT [DF__BoqTaxes__Create__2799C73C] DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]   DATETIME        CONSTRAINT [DF__BoqTaxes__LastMo__288DEB75] DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [ItemName]      INT             CONSTRAINT [DF__BoqTaxes__ItemNa__3A779186] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BoqTaxes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

