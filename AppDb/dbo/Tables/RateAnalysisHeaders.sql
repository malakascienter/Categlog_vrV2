CREATE TABLE [dbo].[RateAnalysisHeaders] (
    [Id]                       INT             IDENTITY (1, 1) NOT NULL,
    [Description]              NVARCHAR (50)   NULL,
    [ProfitMarginPer]          DECIMAL (18, 2) NOT NULL,
    [ProfitMarginVal]          DECIMAL (18, 2) NOT NULL,
    [OverheadCostPer]          DECIMAL (18, 2) NOT NULL,
    [OverheadCostVal]          DECIMAL (18, 2) NOT NULL,
    [TotalCost]                DECIMAL (18, 2) NOT NULL,
    [IPAddress]                NVARCHAR (MAX)  NULL,
    [CreatedUserID]            INT             NOT NULL,
    [LastModUserID]            INT             NOT NULL,
    [CreatedDate]              DATETIME        NOT NULL,
    [LastModDate]              DATETIME        NOT NULL,
    [RateAnalysisHeaderStatus] BIT             NOT NULL,
    [RateCode]                 NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.RateAnalysisHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

