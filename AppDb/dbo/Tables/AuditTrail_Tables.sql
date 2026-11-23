CREATE TABLE [dbo].[AuditTrail_Tables] (
    [Id]               INT            IDENTITY (1, 1) NOT NULL,
    [TableName]        NVARCHAR (250) NOT NULL,
    [HistoryTableName] NVARCHAR (250) NOT NULL,
    [UniqueColumnName] NVARCHAR (50)  CONSTRAINT [DF_AuditTrail_Tables_UniqueColumnName] DEFAULT ('') NOT NULL,
    [DisplayName]      NVARCHAR (250) NOT NULL,
    [DateTime]         DATETIME       CONSTRAINT [DF_AuditTrail_Tables_DateTime] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_AuditTrail_Tables_1] PRIMARY KEY CLUSTERED ([TableName] ASC)
);


GO

