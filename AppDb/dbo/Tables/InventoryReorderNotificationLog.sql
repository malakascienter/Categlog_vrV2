CREATE TABLE [dbo].[InventoryReorderNotificationLog] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [StockItemID]        INT             NULL,
    [LocationID]         INT             NULL,
    [UnitID]             INT             NULL,
    [CompanyID]          INT             NULL,
    [QuantityInHand]     DECIMAL (18, 4) NULL,
    [ReOrderLevel]       DECIMAL (18, 4) NULL,
    [ReOrderQuantity]    DECIMAL (18, 4) NULL,
    [NotificationID]     INT             NULL,
    [NotificationType]   VARCHAR (100)   NULL,
    [NotificationStatus] CHAR (2)        NULL,
    [StartDate]          DATETIME        NULL,
    [EndDate]            DATETIME        NULL,
    [SendRequestDate]    DATETIME        CONSTRAINT [DF_InventoryReorderNotificationLog_SendRequestDate] DEFAULT (getdate()) NOT NULL,
    [SentDate]           DATETIME        NULL,
    [IsSent]             BIT             CONSTRAINT [DF_InventoryReorderNotificationLog_IsSent] DEFAULT ((0)) NOT NULL,
    [DocNo]              NVARCHAR (600)  NULL
);


GO

