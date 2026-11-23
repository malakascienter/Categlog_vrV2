CREATE TABLE [dbo].[CostProvisionSnapShot] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [RateHeaderId] INT             NOT NULL,
    [Cost]         DECIMAL (18, 2) NOT NULL,
    [CategoryId]   INT             NOT NULL,
    [Percentage]   DECIMAL (18, 2) NOT NULL,
    [BoqId]        INT             NOT NULL,
    [ItemId]       INT             NOT NULL,
    [OHPercentage] DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_CostProvisionSnapShot] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

