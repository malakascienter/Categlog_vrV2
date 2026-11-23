CREATE TABLE [dbo].[SellingPrice_ChangeLog] (
    [ID]           INT      IDENTITY (1, 1) NOT NULL,
    [StockItemID]  INT      NOT NULL,
    [LocationID]   INT      NOT NULL,
    [PropertyID]   INT      NOT NULL,
    [SellingPrice] INT      NOT NULL,
    [UserID]       INT      NOT NULL,
    [BusinessDate] DATE     CONSTRAINT [DF_SellingPrice_ChangeLog_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [CreatedDate]  DATETIME CONSTRAINT [DF_SellingPrice_ChangeLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [IsActive]     BIT      CONSTRAINT [DF_SellingPrice_ChangeLog_IsActive] DEFAULT ((1)) NULL,
    [IsUpload]     BIT      CONSTRAINT [DF_SellingPrice_ChangeLog_IsUpload] DEFAULT ((0)) NOT NULL
);


GO

