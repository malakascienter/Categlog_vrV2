CREATE TABLE [dbo].[DiscountWiseDates] (
    [Id]         INT          IDENTITY (1, 1) NOT NULL,
    [DiscountId] INT          NULL,
    [DayName]    VARCHAR (15) NULL,
    [Date]       DATETIME     NULL,
    [DayId]      INT          NULL,
    CONSTRAINT [PK_DiscountWiseDates] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

