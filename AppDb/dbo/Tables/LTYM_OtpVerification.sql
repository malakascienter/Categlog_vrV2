CREATE TABLE [dbo].[LTYM_OtpVerification] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [MemberId]     INT           NULL,
    [Channel]      VARCHAR (10)  NOT NULL,
    [Recipient]    VARCHAR (150) NOT NULL,
    [CodeHash]     VARCHAR (128) NOT NULL,
    [Purpose]      VARCHAR (20)  NOT NULL,
    [AttemptCount] INT           CONSTRAINT [DF_LTYM_OtpVerification_AttemptCount] DEFAULT ((0)) NOT NULL,
    [ExpiresAt]    DATETIME2 (0) NOT NULL,
    [ConsumedAt]   DATETIME2 (0) NULL,
    [CreatedAt]    DATETIME2 (0) CONSTRAINT [DF_LTYM_OtpVerification_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYM_OtpVerification] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYM_OtpVerification_Recipient_Purpose]
    ON [dbo].[LTYM_OtpVerification]([Recipient] ASC, [Purpose] ASC)
    INCLUDE([ExpiresAt], [ConsumedAt]);


GO

