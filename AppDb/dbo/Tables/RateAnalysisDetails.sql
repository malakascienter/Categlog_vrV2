CREATE TABLE [dbo].[RateAnalysisDetails] (
    [Id]                              INT             IDENTITY (1, 1) NOT NULL,
    [RateAnalysisHeaderID]            INT             NOT NULL,
    [SequNo]                          INT             NOT NULL,
    [LocationID]                      INT             NOT NULL,
    [ItemHeaderID]                    INT             NOT NULL,
    [ItemType]                        NVARCHAR (1)    NULL,
    [UnitID]                          INT             NOT NULL,
    [UnitPrice]                       DECIMAL (18, 2) NOT NULL,
    [Quantity]                        DECIMAL (18, 2) NOT NULL,
    [ProfitMarginVal]                 DECIMAL (18, 2) NOT NULL,
    [OverheadCostVal]                 DECIMAL (18, 2) NOT NULL,
    [isDisRate]                       BIT             NOT NULL,
    [DisValue]                        DECIMAL (18, 2) NOT NULL,
    [IPAddress]                       NVARCHAR (MAX)  NULL,
    [CreatedUserID]                   INT             NOT NULL,
    [LastModUserID]                   INT             NOT NULL,
    [CreatedDate]                     DATETIME        NOT NULL,
    [LastModDate]                     DATETIME        NOT NULL,
    [isAlternativeItemApplicable]     BIT             CONSTRAINT [DF__RateAnaly__isAlt__4242D080] DEFAULT ((0)) NOT NULL,
    [isProjectspecificSubstituteItem] BIT             CONSTRAINT [DF__RateAnaly__isPro__442B18F2] DEFAULT ((0)) NOT NULL,
    [Currency]                        INT             CONSTRAINT [DF__RateAnaly__Curre__430CD787] DEFAULT ((0)) NOT NULL,
    [ExchangeRate]                    DECIMAL (18, 2) CONSTRAINT [DF__RateAnaly__Excha__44F51FF9] DEFAULT ((0)) NOT NULL,
    [PackID]                          INT             CONSTRAINT [DF__RateAnaly__PackI__02F25272] DEFAULT ((0)) NOT NULL,
    [PackQty]                         DECIMAL (18, 2) CONSTRAINT [DF__RateAnaly__PackQ__03E676AB] DEFAULT ((0)) NOT NULL,
    [PackRate]                        DECIMAL (18, 2) CONSTRAINT [DF__RateAnaly__PackR__04DA9AE4] DEFAULT ((0)) NOT NULL,
    [PackBreakdownQty]                DECIMAL (18, 2) CONSTRAINT [DF__RateAnaly__PackB__05CEBF1D] DEFAULT ((0)) NOT NULL,
    [DiscountPercentage]              DECIMAL (18, 2) NULL,
    [ProfitMarginPercentage]          DECIMAL (18)    NULL,
    [IsProfitMarg]                    BIT             NULL,
    [IsOHCPercentage]                 BIT             NULL,
    [OHCPercentage]                   DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_dbo.RateAnalysisDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

