CREATE TABLE [dbo].[CopyStockItem_XMLLog] (
    [ID]          INT      IDENTITY (1, 1) NOT NULL,
    [XMLDetails]  XML      NULL,
    [SysDateTime] DATETIME CONSTRAINT [DF_CopyStockItem_XMLLog_SysDateTime] DEFAULT (getdate()) NULL
);


GO

