CREATE TABLE [dbo].[KIOSK_SmsLog] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [OrderNo]    VARCHAR (MAX)  NOT NULL,
    [Outlet]     VARCHAR (50)   NOT NULL,
    [JsonData]   NVARCHAR (MAX) NOT NULL,
    [SystemDate] DATETIME       NOT NULL,
    [IsSMSSend]  BIT            CONSTRAINT [DF_KIOSK_SmsLog_IsSMSSend] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_KIOSK_SmsLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

