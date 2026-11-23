CREATE TABLE [dbo].[LTY_PromotionWisePoint] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]     INT             NOT NULL,
    [PromotionId]    INT             NOT NULL,
    [Rate]           DECIMAL (18, 4) NULL,
    [BaseValueId]    INT             NULL,
    [Multiplier]     DECIMAL (18, 4) NULL,
    [ExpireDate]     DATE            NULL,
    [ExpireDayCount] INT             NULL,
    CONSTRAINT [PK_LTY_PromotionWisePoint] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

