CREATE TABLE [dbo].[LTYM_MemberSettings] (
    [MemberId]           INT           NOT NULL,
    [Language]           VARCHAR (10)  CONSTRAINT [DF_LTYM_MemberSettings_Language] DEFAULT ('en') NOT NULL,
    [EmailNotifications] BIT           CONSTRAINT [DF_LTYM_MemberSettings_EmailNotif] DEFAULT ((1)) NOT NULL,
    [SmsNotifications]   BIT           CONSTRAINT [DF_LTYM_MemberSettings_SmsNotif] DEFAULT ((1)) NOT NULL,
    [PromoMessages]      BIT           CONSTRAINT [DF_LTYM_MemberSettings_Promo] DEFAULT ((1)) NOT NULL,
    [UpdatedAt]          DATETIME2 (0) CONSTRAINT [DF_LTYM_MemberSettings_UpdatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYM_MemberSettings] PRIMARY KEY CLUSTERED ([MemberId] ASC)
);


GO

