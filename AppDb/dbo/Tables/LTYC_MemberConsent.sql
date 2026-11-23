CREATE TABLE [dbo].[LTYC_MemberConsent] (
    [ConsentId]            INT           IDENTITY (1, 1) NOT NULL,
    [MemberId]             INT           NOT NULL,
    [PropertyId]           INT           NOT NULL,
    [Channel]              VARCHAR (20)  NOT NULL,
    [IsOptedIn]            BIT           NOT NULL,
    [Source]               VARCHAR (30)  NOT NULL,
    [UnsubscribeTokenHash] VARCHAR (200) NULL,
    [ChangedAt]            DATETIME2 (0) CONSTRAINT [DF_LTYC_MemberConsent_ChangedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [ChangedBy]            INT           NULL,
    CONSTRAINT [PK_LTYC_MemberConsent] PRIMARY KEY CLUSTERED ([ConsentId] ASC),
    CONSTRAINT [UQ_LTYC_MemberConsent_Member_Channel] UNIQUE NONCLUSTERED ([MemberId] ASC, [Channel] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_MemberConsent_TokenHash]
    ON [dbo].[LTYC_MemberConsent]([UnsubscribeTokenHash] ASC)
    INCLUDE([MemberId], [Channel]) WHERE ([UnsubscribeTokenHash] IS NOT NULL);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_MemberConsent_Channel_OptedIn]
    ON [dbo].[LTYC_MemberConsent]([Channel] ASC, [IsOptedIn] ASC)
    INCLUDE([MemberId], [PropertyId]);


GO

