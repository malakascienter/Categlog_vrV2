CREATE TABLE [dbo].[KIOSK_ItemType] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [KioskItemType] VARCHAR (255) NOT NULL,
    [SortOrder]     INT           NOT NULL,
    [IsActive]      BIT           CONSTRAINT [DF_KIOSK_ItemType_IsActive] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_KIOSK_ItemType] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

