CREATE TABLE [dbo].[a] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [BOQID]               INT             NOT NULL,
    [Description]         NVARCHAR (150)  NULL,
    [IsPercentageOrValue] BIT             NOT NULL,
    [DiscountPercentage]  DECIMAL (18, 2) NOT NULL,
    [DiscountValue]       DECIMAL (18, 2) NOT NULL
);


GO

