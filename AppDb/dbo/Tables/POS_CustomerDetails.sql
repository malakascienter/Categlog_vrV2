CREATE TABLE [dbo].[POS_CustomerDetails] (
    [OrderNo]             VARCHAR (6)     CONSTRAINT [DF_POS_CustomerDetails_OrderNo_1] DEFAULT ('') NOT NULL,
    [TempOrderNo]         CHAR (6)        CONSTRAINT [DF_POS_CustomerDetails_TempOrderNo_1] DEFAULT ('') NOT NULL,
    [OrderDate]           DATETIME        CONSTRAINT [DF_POS_CustomerDetails_OrderDate] DEFAULT (getdate()) NOT NULL,
    [Outlet]              VARCHAR (5)     CONSTRAINT [DF_POS_CustomerDetails_Outlet_1] DEFAULT ('') NOT NULL,
    [CustomerName]        VARCHAR (250)   CONSTRAINT [DF_POS_CustomerDetails_CustomerName_1] DEFAULT ('') NOT NULL,
    [ContactNo]           VARCHAR (250)   CONSTRAINT [DF_POS_CustomerDetails_ContactNo] DEFAULT ('') NOT NULL,
    [SysDate]             DATETIME        CONSTRAINT [DF_POS_CustomerDetails_SysDate_1] DEFAULT (getdate()) NOT NULL,
    [IsUpload]            BIT             CONSTRAINT [DF_POS_CustomerDetails_IsUpload] DEFAULT ((0)) NOT NULL,
    [CustomerID]          VARCHAR (50)    CONSTRAINT [DF_POS_CustomerDetails_CustomerID_1] DEFAULT ('') NOT NULL,
    [LoyaltyCusID]        VARCHAR (50)    CONSTRAINT [DF_POS_CustomerDetails_LoyaltyCusID] DEFAULT ('') NOT NULL,
    [AccountIdAward]      VARCHAR (50)    CONSTRAINT [DF_POS_CustomerDetails_AccountIdAward] DEFAULT ('') NOT NULL,
    [AccountIdLoyalty]    VARCHAR (50)    CONSTRAINT [DF_POS_CustomerDetails_AccountIdLoyalty] DEFAULT ('') NOT NULL,
    [AvailablePoints]     NUMERIC (18, 2) CONSTRAINT [DF_POS_CustomerDetails_AvailablePoints_1] DEFAULT ((0)) NOT NULL,
    [IssuedLoyaltyPoints] DECIMAL (18, 2) CONSTRAINT [DF_POS_CustomerDetails_IssuedLoyaltyPoints_1] DEFAULT ((0)) NOT NULL,
    [PropertyId]          BIT             CONSTRAINT [DF_POS_CustomerDetails_PropertyId] DEFAULT ((0)) NOT NULL
);


GO

