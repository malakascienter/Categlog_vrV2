CREATE TABLE [dbo].[AutoGenerateTemplates] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (MAX) NULL,
    [IPAddress]           NVARCHAR (MAX) NULL,
    [CreatedUserID]       INT            NOT NULL,
    [LastModUserID]       INT            NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [LastModDate]         DATETIME       NOT NULL,
    [AutoGenerateID]      INT            DEFAULT ((0)) NOT NULL,
    [FormID]              INT            DEFAULT ((0)) NOT NULL,
    [ModuleID]            INT            DEFAULT ((0)) NOT NULL,
    [DefaultViewAccess]   BIT            DEFAULT ((0)) NOT NULL,
    [DefaultInsertAccess] BIT            DEFAULT ((0)) NOT NULL,
    [DefaultModifyAccess] BIT            DEFAULT ((0)) NOT NULL,
    [DefaultDeleteAccess] BIT            DEFAULT ((0)) NOT NULL,
    [DefaultPrintAccess]  BIT            DEFAULT ((0)) NOT NULL,
    [TemplateBaseId]      INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.AutoGenerateTemplates] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

