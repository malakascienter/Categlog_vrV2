CREATE TABLE [dbo].[AutoGenerateRights] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [AutoGenerateID]      INT            NOT NULL,
    [HasBrekdown]         BIT            NOT NULL,
    [Userid]              INT            NOT NULL,
    [FormID]              INT            NOT NULL,
    [ModuleID]            INT            NOT NULL,
    [DefaultViewAccess]   BIT            NOT NULL,
    [DefaultInsertAccess] BIT            NOT NULL,
    [DefaultModifyAccess] BIT            NOT NULL,
    [DefaultDeleteAccess] BIT            NOT NULL,
    [DefaultPrintAccess]  BIT            NOT NULL,
    [TemplateId]          INT            DEFAULT ((0)) NOT NULL,
    [IPAddress]           NVARCHAR (MAX) NULL,
    [CreatedUserID]       INT            DEFAULT ((0)) NOT NULL,
    [LastModUserID]       INT            DEFAULT ((0)) NOT NULL,
    [CreatedDate]         DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [LastModDate]         DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    CONSTRAINT [PK_dbo.AutoGenerateRights] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

