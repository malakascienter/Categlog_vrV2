CREATE TABLE [dbo].[GL_POST_TRANSACTION_LOG] (
    [Id]              BIGINT   IDENTITY (1, 1) NOT NULL,
    [TransactionId]   BIGINT   NOT NULL,
    [TransactionDate] DATE     NOT NULL,
    [PropertyId]      INT      NOT NULL,
    [SysDate]         DATETIME CONSTRAINT [DF_GL_POST_TRANSACTION_LOG_SysDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_GL_POST_TRANSACTION_LOG] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

