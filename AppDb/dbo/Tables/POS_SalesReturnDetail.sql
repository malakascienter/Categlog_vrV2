CREATE TABLE [dbo].[POS_SalesReturnDetail] (
    [ReturnDetailID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [ReturnHeaderID] BIGINT          NOT NULL,
    [CompanyID]      TINYINT         CONSTRAINT [DF_POS_SalesReturnDetail_CompanyID] DEFAULT ((0)) NOT NULL,
    [LocationID]     INT             CONSTRAINT [DF_POS_SalesReturnDetail_LocationID] DEFAULT ((0)) NOT NULL,
    [ReturnNo]       VARCHAR (20)    NOT NULL,
    [BusinessDate]   DATE            CONSTRAINT [DF_POS_SalesReturnDetail_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [InsertDateTime] DATETIME        NOT NULL,
    [ItemID]         INT             CONSTRAINT [DF_POS_SalesReturnDetail_ItemID] DEFAULT ((0)) NOT NULL,
    [ItemCode]       VARCHAR (20)    CONSTRAINT [DF_POS_SalesReturnDetail_ItemCode] DEFAULT ('') NOT NULL,
    [Quantity]       NUMERIC (18, 8) CONSTRAINT [DF_POS_SalesReturnDetail_Quantity] DEFAULT ((0)) NOT NULL,
    [ReturnPrice]    NUMERIC (18, 8) CONSTRAINT [DF_Table_1_Quantity1] DEFAULT ((0)) NOT NULL
);


GO

