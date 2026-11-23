CREATE TABLE [dbo].[ItemWisePrinters] (
    [MainMenuCode]    CHAR (4) NOT NULL,
    [PrinterCode]     CHAR (2) NOT NULL,
    [PropertyId]      INT      NULL,
    [IsUpload]        BIT      CONSTRAINT [DF_ItemWisePrinters_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]   INT      NULL,
    [CreatedDateTime] DATETIME NULL,
    [UpdatedUserId]   INT      NULL,
    [UpdatedDateTime] DATETIME NULL
);


GO

