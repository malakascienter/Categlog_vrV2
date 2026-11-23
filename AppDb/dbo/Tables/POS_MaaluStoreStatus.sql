CREATE TABLE [dbo].[POS_MaaluStoreStatus] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [PropertyId]    INT           NOT NULL,
    [OutletCode]    VARCHAR (5)   NOT NULL,
    [Maalu_StoreId] VARCHAR (200) NULL,
    [Status]        VARCHAR (20)  NOT NULL,
    [OfflineReason] VARCHAR (255) NULL,
    [PausedUntil]   DATETIME      NULL,
    [Reason]        VARCHAR (255) NULL,
    [LastSyncedOn]  DATETIME      NULL,
    [UpdatedBy]     VARCHAR (100) NULL,
    [UpdatedOn]     DATETIME      CONSTRAINT [DF_POS_MaaluStoreStatus_UpdatedOn] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_POS_MaaluStoreStatus] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UX_POS_MaaluStoreStatus_Outlet] UNIQUE NONCLUSTERED ([PropertyId] ASC, [OutletCode] ASC)
);


GO

