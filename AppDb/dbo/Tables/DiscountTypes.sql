CREATE TABLE [dbo].[DiscountTypes] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [Code]        VARCHAR (2)   NULL,
    [Description] VARCHAR (150) NULL,
    [PropertyId]  INT           NULL
);


GO

