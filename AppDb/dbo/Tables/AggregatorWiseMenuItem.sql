CREATE TABLE [dbo].[AggregatorWiseMenuItem] (
    [Id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    [MenuCode]         VARCHAR (10) NOT NULL,
    [AggregatorId]     INT          NOT NULL,
    [CreatedUserId]    INT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [ModifiedUserId]   INT          NULL,
    [ModifiedDateTime] DATETIME     NULL,
    [PropertyId]       INT          DEFAULT ((0)) NOT NULL,
    [Outlet]           VARCHAR (5)  NOT NULL,
    [BrandID]          INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_AggregatorWiseMenuItem] PRIMARY KEY CLUSTERED ([MenuCode] ASC, [AggregatorId] ASC, [Outlet] ASC)
);


GO

