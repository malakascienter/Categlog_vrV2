CREATE TABLE [dbo].[ValidationModes] (
    [Id]           INT           IDENTITY (1, 1) NOT NULL,
    [Code]         VARCHAR (10)  NULL,
    [Description]  VARCHAR (150) NULL,
    [PropertyId]   INT           NULL,
    [DiscountType] VARCHAR (10)  DEFAULT ('') NOT NULL,
    [IsActive]     BIT           CONSTRAINT [DF_ValidationModes_IsActive] DEFAULT ((1)) NOT NULL,
    [IsValue]      BIT           CONSTRAINT [DF_ValidationModes_IsValue] DEFAULT ((0)) NOT NULL,
    [IsPercentage] BIT           CONSTRAINT [DF_ValidationModes_IsPercentage] DEFAULT ((0)) NOT NULL
);


GO

