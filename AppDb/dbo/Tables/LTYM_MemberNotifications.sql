CREATE TABLE [dbo].[LTYM_MemberNotifications] (
    [Id]        BIGINT         IDENTITY (1, 1) NOT NULL,
    [MemberId]  INT            NOT NULL,
    [Title]     NVARCHAR (200) NOT NULL,
    [Body]      NVARCHAR (MAX) NULL,
    [Type]      VARCHAR (20)   NOT NULL,
    [IsRead]    BIT            CONSTRAINT [DF_LTYM_MemberNotifications_IsRead] DEFAULT ((0)) NOT NULL,
    [IsDeleted] BIT            CONSTRAINT [DF_LTYM_MemberNotifications_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedAt] DATETIME2 (0)  CONSTRAINT [DF_LTYM_MemberNotifications_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYM_MemberNotifications] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYM_MemberNotifications_Member]
    ON [dbo].[LTYM_MemberNotifications]([MemberId] ASC, [IsDeleted] ASC, [IsRead] ASC)
    INCLUDE([CreatedAt]);


GO

