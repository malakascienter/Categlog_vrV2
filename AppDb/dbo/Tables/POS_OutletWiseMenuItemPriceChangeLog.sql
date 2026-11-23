CREATE TABLE [dbo].[POS_OutletWiseMenuItemPriceChangeLog] (
    [OutLetWiseMenuItemID] INT             IDENTITY (1, 1) NOT NULL,
    [MenuItemCode]         NVARCHAR (10)   NULL,
    [OutletCode]           NVARCHAR (10)   NULL,
    [PriceTypeID]          INT             NULL,
    [NewPrice]             DECIMAL (18, 5) NULL,
    [OldPrice]             DECIMAL (18, 5) NULL,
    [IsActive]             BIT             NULL,
    [CreatedUser]          INT             NULL,
    [CreatedDate]          DATETIME        NULL,
    [ModifiedUser]         INT             NULL,
    [ModifiedDate]         DATETIME        NULL,
    [PropertyId]           INT             DEFAULT ((0)) NOT NULL,
    [EffectiveDate]        DATE            DEFAULT (getdate()) NOT NULL,
    [Id]                   AS              ([OutLetWiseMenuItemID]),
    CONSTRAINT [PK_POS_OutletWiseMenuItemPriceChangeLog] PRIMARY KEY CLUSTERED ([OutLetWiseMenuItemID] ASC)
);


GO

