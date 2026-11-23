CREATE TABLE [dbo].[BOQRateanalysisAllocationHeaders] (
    [ID]                  INT             IDENTITY (1, 1) NOT NULL,
    [BOQID]               INT             NOT NULL,
    [WorkID]              INT             NOT NULL,
    [RateQtyInWork]       FLOAT (53)      NOT NULL,
    [RateAnalysisID]      INT             NOT NULL,
    [Description]         NVARCHAR (MAX)  NULL,
    [TotalPrice]          FLOAT (53)      NOT NULL,
    [Status]              BIT             NOT NULL,
    [CreateUserId]        INT             NOT NULL,
    [CreateDate]          DATETIME        NOT NULL,
    [AllocationUserID]    INT             NOT NULL,
    [AllocationDate]      DATETIME        NOT NULL,
    [ProfitMarginPer]     FLOAT (53)      NOT NULL,
    [ProfitMarginVal]     FLOAT (53)      NOT NULL,
    [OverheadCostPer]     FLOAT (53)      NOT NULL,
    [OverheadCostVal]     FLOAT (53)      NOT NULL,
    [SundryValue]         DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsPercentageOrValue] BIT             DEFAULT ((0)) NOT NULL,
    [DiscountPercentage]  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DiscountValue]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BOQRateanalysisAllocationHeaders] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

