CREATE TABLE [dbo].[AuditTrail_Log] (
    [Id]                BIGINT         IDENTITY (1, 1) NOT NULL,
    [DateTimeUtc]       DATETIME       CONSTRAINT [DF_AuditTrail_Log_DateTimeUtc] DEFAULT (getutcdate()) NOT NULL,
    [Code]              NVARCHAR (50)  NOT NULL,
    [UserId]            INT            NOT NULL,
    [TableId]           INT            NULL,
    [UniqueColumnName]  NVARCHAR (100) NULL,
    [UniqueColumnValue] NVARCHAR (250) NULL,
    [PageId]            INT            NULL,
    [ActionType]        CHAR (1)       NOT NULL,
    [Remark]            NVARCHAR (250) CONSTRAINT [DF_AuditTrail_Log_Remark] DEFAULT ('') NULL,
    [Changes]           VARCHAR (MAX)  NULL,
    [PropertyId]        INT            NULL
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Insert (I), Delete (D), Update (U), Select(S)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AuditTrail_Log', @level2type = N'COLUMN', @level2name = N'ActionType';


GO

