CREATE TABLE [dbo].[DiscountOutlet] (
    [PropertyId] INT          NULL,
    [Code]       VARCHAR (10) CONSTRAINT [DF_DiscountOutlet_Code] DEFAULT ('') NOT NULL,
    [Outlet]     VARCHAR (10) CONSTRAINT [DF_DiscountOutlet_Outlet] DEFAULT ('') NOT NULL
);


GO

