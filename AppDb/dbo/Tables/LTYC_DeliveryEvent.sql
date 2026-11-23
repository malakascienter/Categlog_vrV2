CREATE TABLE [dbo].[LTYC_DeliveryEvent] (
    [EventId]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [DispatchId]      BIGINT         NOT NULL,
    [EventType]       VARCHAR (30)   NOT NULL,
    [EventAt]         DATETIME2 (0)  NOT NULL,
    [PayloadJson]     NVARCHAR (MAX) NULL,
    [ProviderEventId] VARCHAR (200)  NULL,
    [ReceivedAt]      DATETIME2 (0)  CONSTRAINT [DF_LTYC_DeliveryEvent_ReceivedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_DeliveryEvent] PRIMARY KEY CLUSTERED ([EventId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_DeliveryEvent_Dispatch]
    ON [dbo].[LTYC_DeliveryEvent]([DispatchId] ASC, [EventType] ASC)
    INCLUDE([EventAt]);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYC_DeliveryEvent_ProviderEventId]
    ON [dbo].[LTYC_DeliveryEvent]([ProviderEventId] ASC) WHERE ([ProviderEventId] IS NOT NULL);


GO

