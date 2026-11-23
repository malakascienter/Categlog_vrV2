CREATE TABLE [dbo].[CompanySettings] (
    [Id]                               INT             IDENTITY (1, 1) NOT NULL,
    [CompanyId]                        INT             NOT NULL,
    [ThresholdPercentage]              DECIMAL (18, 2) NOT NULL,
    [IsSupplierCodeAutoGenerate]       BIT             NULL,
    [NextSupplierNumber]               INT             NULL,
    [DailyMarketItemAttributeId]       INT             NULL,
    [ThresholdValueAttributeId]        INT             NULL,
    [TemperatureApplicableAttributeId] INT             NULL,
    [ProductionItemAttributeId]        INT             CONSTRAINT [DF_CompanySettings_ProductionItemAttributeId] DEFAULT ((22)) NULL,
    [IsQuotationAttributeId]           INT             NULL,
    CONSTRAINT [PK_CompanySettings] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

