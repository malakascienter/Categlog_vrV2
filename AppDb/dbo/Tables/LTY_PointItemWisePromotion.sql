CREATE TABLE [dbo].[LTY_PointItemWisePromotion] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]     INT             NOT NULL,
    [PromotionId]    INT             NOT NULL,
    [ItemCode]       VARCHAR (20)    NOT NULL,
    [PointCount]     DECIMAL (18, 4) NULL,
    [ExpireDate]     DATE            NULL,
    [Quantity]       INT             CONSTRAINT [DF_LTY_PointItemWisePromotion_Quantity] DEFAULT ((0)) NOT NULL,
    [ExpireDayCount] INT             NULL,
    CONSTRAINT [PK_LTY_PointItemWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

