CREATE TABLE [dbo].[BoqWiseOHP] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [ProjectID]          INT             NOT NULL,
    [SectionID]          INT             NOT NULL,
    [WorkID]             INT             NOT NULL,
    [BoqDiscount]        BIT             NOT NULL,
    [SectionDiscount]    BIT             NOT NULL,
    [WorkDiscount]       BIT             NOT NULL,
    [OHPPercentage]      DECIMAL (18, 2) NOT NULL,
    [OHPValue]           DECIMAL (18, 2) NOT NULL,
    [IsPercentageForOHP] BIT             NOT NULL,
    [BoqID]              INT             DEFAULT ((0)) NOT NULL,
    [RateID]             INT             DEFAULT ((0)) NOT NULL,
    [RateDiscount]       BIT             DEFAULT ((0)) NOT NULL,
    [ALLItems]           BIT             NULL,
    [ItemType]           NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.BoqWiseOHP] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

