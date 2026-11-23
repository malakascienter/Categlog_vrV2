CREATE TABLE [dbo].[BOQMainWorkAllocations] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [BOQID]               INT             NOT NULL,
    [Description]         NVARCHAR (MAX)  NULL,
    [IsPercentageOrValue] BIT             DEFAULT ((0)) NOT NULL,
    [DiscountPercentage]  DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DiscountValue]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BOQMainWorkAllocations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

