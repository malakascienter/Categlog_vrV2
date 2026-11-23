CREATE TABLE [dbo].[BillTrans] (
    [PropertyId]             INT             CONSTRAINT [DF_BillTrans_PropertyId] DEFAULT ((0)) NOT NULL,
    [OrderNo]                CHAR (6)        NOT NULL,
    [OrderType]              CHAR (1)        NOT NULL,
    [OrderDate]              DATETIME        NOT NULL,
    [OrderTime]              DATETIME        NOT NULL,
    [Category]               CHAR (4)        NULL,
    [MainMenuCode]           CHAR (4)        NOT NULL,
    [Qty]                    MONEY           CONSTRAINT [DF_BillTrans_Qty] DEFAULT ((0)) NOT NULL,
    [Rate]                   MONEY           CONSTRAINT [DF_BillTrans_Rate] DEFAULT ((0)) NOT NULL,
    [DisCode]                CHAR (10)       NULL,
    [DisPerc]                MONEY           CONSTRAINT [DF_BillTrans_DisPerc] DEFAULT ((0)) NOT NULL,
    [ItWiseDiscount]         MONEY           CONSTRAINT [DF_BillTrans_ItWiseDiscount] DEFAULT ((0)) NOT NULL,
    [UserID]                 VARCHAR (10)    CONSTRAINT [DF_BillTrans_UserID] DEFAULT (' ') NOT NULL,
    [Outlet]                 CHAR (3)        CONSTRAINT [DF_BillTrans_Outlet] DEFAULT ('L1') NOT NULL,
    [UniqueNo]               NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [UploadDayEnd]           BIT             NULL,
    [ItemCost]               MONEY           CONSTRAINT [DF_BillTrans_itemcost] DEFAULT ((0)) NOT NULL,
    [CompCode]               CHAR (3)        NULL,
    [ItemSeq]                BIGINT          CONSTRAINT [DF_BillTrans_ItemSeq_1] DEFAULT ((0)) NOT NULL,
    [RefItemCode]            VARCHAR (6)     CONSTRAINT [DF_BillTrans_RefItemCode_1] DEFAULT (' ') NOT NULL,
    [SortSeq]                INT             CONSTRAINT [DF_BillTrans_SortSeq_1] DEFAULT ((0)) NOT NULL,
    [IsModifier]             BIT             CONSTRAINT [DF_BillTrans_IsModifier] DEFAULT ((0)) NOT NULL,
    [ActionID]               INT             CONSTRAINT [DF_BillTrans_ActionID] DEFAULT ((0)) NOT NULL,
    [IsCombo]                BIT             CONSTRAINT [DF_BillTrans_IsModifier1] DEFAULT ((0)) NOT NULL,
    [IsActionable]           BIT             NULL,
    [ActualPrice]            NUMERIC (18, 4) CONSTRAINT [DF_BillTrans_ActualPrice] DEFAULT ((0)) NOT NULL,
    [ResNetVal]              MONEY           CONSTRAINT [DF_BillTrans_ResNetVal] DEFAULT ((1.1734)) NOT NULL,
    [NetAmount]              AS              (([Qty]*[Rate]-(([Qty]*[Rate])*[DisPerc])/(100))-[BillDisVal]),
    [IsInstruction]          BIT             CONSTRAINT [DF_BillTrans_IsInstruction_1] DEFAULT ((0)) NOT NULL,
    [SyncDateTime]           DATETIME        CONSTRAINT [DF_BillTrans_SyncDateTime] DEFAULT (getdate()) NOT NULL,
    [VoucherNo]              BIGINT          CONSTRAINT [DF_BillTrans_VoucherNo] DEFAULT ((0)) NULL,
    [ItemDisPer]             NUMERIC (18, 8) CONSTRAINT [DF_BillTrans_ItemDisPer] DEFAULT ((0)) NULL,
    [ItemDisVal]             NUMERIC (18, 8) CONSTRAINT [DF_BillTrans_ItemDisPer1] DEFAULT ((0)) NULL,
    [BillDisPer]             NUMERIC (18, 8) CONSTRAINT [DF_BillTrans_ItemDisPer2] DEFAULT ((0)) NULL,
    [BillDisVal]             NUMERIC (18, 8) CONSTRAINT [DF_BillTrans_ItemDisPer3] DEFAULT ((0)) NULL,
    [StockLocation]          VARCHAR (10)    CONSTRAINT [DF_BillTrans_StockLocation] DEFAULT ((0)) NOT NULL,
    [IsIncludeChargeToPrice] BIT             CONSTRAINT [DF_BillTrans_IsIncludeChargeToPrice] DEFAULT ((0)) NULL,
    [ItemType]               VARCHAR (1)     CONSTRAINT [DF_BillTrans_ItemType] DEFAULT ('') NULL,
    [OpenItemDescription]    VARCHAR (200)   DEFAULT ('') NOT NULL,
    [DiscountRemark]         VARCHAR (50)    CONSTRAINT [DF_BillTrans_DiscountRemark] DEFAULT ('') NOT NULL,
    [DiscountAuthUser]       VARCHAR (50)    CONSTRAINT [DF_BillTrans_DiscountAuthUser] DEFAULT ('') NOT NULL,
    [DiscountAuthTime]       DATETIME        CONSTRAINT [DF_BillTrans_DiscountAuthTime] DEFAULT (getdate()) NOT NULL,
    [ReturnQuantity]         NUMERIC (18, 4) CONSTRAINT [DF_BillTrans_ReturnQuantity] DEFAULT ((0)) NOT NULL,
    [BrandID]                INT             DEFAULT ((0)) NOT NULL,
    [ChargeHeaderID]         INT             CONSTRAINT [DF_BillTrans_ChargeHeaderID] DEFAULT ((0)) NOT NULL,
    [ComplimentaryID]        INT             CONSTRAINT [DF_BillTrans_ComplimentaryID] DEFAULT ((0)) NOT NULL,
    [ComplimentaryRemark]    VARCHAR (100)   CONSTRAINT [DF_BillTrans_ComplimentaryRemark] DEFAULT ('') NOT NULL
);


GO

CREATE NONCLUSTERED INDEX [IDX_BillTrans_MainMenuCode_PropertyId]
    ON [dbo].[BillTrans]([MainMenuCode] ASC, [PropertyId] ASC)
    INCLUDE([Outlet], [OrderDate]);


GO

