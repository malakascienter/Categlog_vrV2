CREATE TABLE [dbo].[POS_OrderReturnDetail] (
    [ReturnDetailID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [ReturnHeaderID] BIGINT          NOT NULL,
    [PropertyId]     TINYINT         CONSTRAINT [DF_POS_OrderReturnDetail_PropertyId] DEFAULT ((0)) NOT NULL,
    [Outlet]         VARCHAR (5)     CONSTRAINT [DF_POS_OrderReturnDetail_Outlet] DEFAULT ('') NOT NULL,
    [ReturnNo]       VARCHAR (20)    NOT NULL,
    [BusinessDate]   DATE            CONSTRAINT [DF_POS_OrderReturnDetail_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [InsertDateTime] DATETIME        NOT NULL,
    [MainMenuCode]   VARCHAR (20)    CONSTRAINT [DF_POS_OrderReturnDetail_MainMenuCode] DEFAULT ('') NOT NULL,
    [Quantity]       NUMERIC (18, 8) CONSTRAINT [DF_POS_OrderReturnDetail_Quantity] DEFAULT ((0)) NOT NULL,
    [ReturnPrice]    NUMERIC (18, 8) CONSTRAINT [DF_POS_OrderReturnDetail_ReturnPrice] DEFAULT ((0)) NOT NULL
);


GO

