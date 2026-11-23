CREATE TABLE [dbo].[LTYM_MemberCredentials] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [MemberId]       INT            NOT NULL,
    [Email]          VARCHAR (150)  NOT NULL,
    [PasswordHash]   NVARCHAR (200) NOT NULL,
    [IsVerified]     BIT            CONSTRAINT [DF_LTYM_MemberCredentials_IsVerified] DEFAULT ((0)) NOT NULL,
    [FailedAttempts] INT            CONSTRAINT [DF_LTYM_MemberCredentials_FailedAttempts] DEFAULT ((0)) NOT NULL,
    [LockoutEnd]     DATETIME2 (0)  NULL,
    [CreatedAt]      DATETIME2 (0)  CONSTRAINT [DF_LTYM_MemberCredentials_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UpdatedAt]      DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYM_MemberCredentials] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_LTYM_MemberCredentials_MemberId] UNIQUE NONCLUSTERED ([MemberId] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYM_MemberCredentials_Email]
    ON [dbo].[LTYM_MemberCredentials]([Email] ASC);


GO

