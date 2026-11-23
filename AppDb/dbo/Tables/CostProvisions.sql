CREATE TABLE [dbo].[CostProvisions] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [CategoryId]   INT             NOT NULL,
    [RateHeaderId] INT             NOT NULL,
    [Cost]         DECIMAL (18)    NOT NULL,
    [Percentage]   DECIMAL (18)    NOT NULL,
    [ItemId]       INT             NOT NULL,
    [OHPercentage] DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_CostProvisions] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

