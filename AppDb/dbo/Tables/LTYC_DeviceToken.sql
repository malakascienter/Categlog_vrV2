CREATE TABLE [dbo].[LTYC_DeviceToken] (
    [TokenId]       INT            IDENTITY (1, 1) NOT NULL,
    [MemberId]      INT            NOT NULL,
    [PropertyId]    INT            NOT NULL,
    [Platform]      VARCHAR (10)   NOT NULL,
    [Token]         NVARCHAR (500) NOT NULL,
    [AuthSecret]    NVARCHAR (200) NULL,
    [P256dhKey]     NVARCHAR (200) NULL,
    [DeviceName]    NVARCHAR (150) NULL,
    [AppVersion]    VARCHAR (30)   NULL,
    [IsActive]      BIT            CONSTRAINT [DF_LTYC_DeviceToken_IsActive] DEFAULT ((1)) NOT NULL,
    [FailureCount]  INT            CONSTRAINT [DF_LTYC_DeviceToken_FailureCount] DEFAULT ((0)) NOT NULL,
    [LastSeenAt]    DATETIME2 (0)  NULL,
    [DeactivatedAt] DATETIME2 (0)  NULL,
    [CreatedDate]   DATETIME2 (0)  CONSTRAINT [DF_LTYC_DeviceToken_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [TokenChecksum] AS             (checksum([Token])) PERSISTED,
    CONSTRAINT [PK_LTYC_DeviceToken] PRIMARY KEY CLUSTERED ([TokenId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_DeviceToken_Member_Active]
    ON [dbo].[LTYC_DeviceToken]([MemberId] ASC, [IsActive] ASC)
    INCLUDE([TokenId], [Platform], [Token]);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_DeviceToken_Checksum]
    ON [dbo].[LTYC_DeviceToken]([TokenChecksum] ASC)
    INCLUDE([TokenId], [MemberId], [IsActive]);


GO

