CREATE TABLE [dbo].[LTYM_RefreshTokens] (
    [Id]                  BIGINT        IDENTITY (1, 1) NOT NULL,
    [MemberId]            INT           NOT NULL,
    [TokenHash]           VARCHAR (128) NOT NULL,
    [ExpiresAt]           DATETIME2 (0) NOT NULL,
    [CreatedAt]           DATETIME2 (0) CONSTRAINT [DF_LTYM_RefreshTokens_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [CreatedByIp]         VARCHAR (45)  NULL,
    [RevokedAt]           DATETIME2 (0) NULL,
    [ReplacedByTokenHash] VARCHAR (128) NULL,
    CONSTRAINT [PK_LTYM_RefreshTokens] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYM_RefreshTokens_TokenHash]
    ON [dbo].[LTYM_RefreshTokens]([TokenHash] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_LTYM_RefreshTokens_MemberId]
    ON [dbo].[LTYM_RefreshTokens]([MemberId] ASC)
    INCLUDE([ExpiresAt], [RevokedAt]);


GO

