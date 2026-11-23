CREATE TABLE [dbo].[App_AuditLogDetail] (
    [Id]         BIGINT         IDENTITY (1, 1) NOT NULL,
    [AuditLogId] BIGINT         NOT NULL,
    [FieldName]  VARCHAR (100)  NOT NULL,
    [OldValue]   NVARCHAR (MAX) NULL,
    [NewValue]   NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_App_AuditLogDetail] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_App_AuditLogDetail_App_AuditLog] FOREIGN KEY ([AuditLogId]) REFERENCES [dbo].[App_AuditLog] ([Id]) ON DELETE CASCADE
);


GO

CREATE NONCLUSTERED INDEX [IX_App_AuditLogDetail_AuditLogId]
    ON [dbo].[App_AuditLogDetail]([AuditLogId] ASC);


GO

