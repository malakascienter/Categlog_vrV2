CREATE TABLE [dbo].[POS_ItemBarcode] (
    [ID]        BIGINT        IDENTITY (1, 1) NOT NULL,
    [CompanyID] TINYINT       CONSTRAINT [DF_POS_ItemBarcodes_CompanyID] DEFAULT ((0)) NOT NULL,
    [ItemID]    INT           CONSTRAINT [DF_POS_ItemBarcodes_ItemID] DEFAULT ((0)) NOT NULL,
    [Barcode]   VARCHAR (200) NOT NULL,
    [UserID]    INT           NULL,
    [SysDate]   DATETIME      CONSTRAINT [DF_POS_ItemBarcode_SysDate] DEFAULT (getdate()) NULL,
    [IsUpload]  BIT           CONSTRAINT [DF_POS_ItemBarcode_IsUpload] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_POS_ItemBarcode] PRIMARY KEY CLUSTERED ([Barcode] ASC)
);


GO

