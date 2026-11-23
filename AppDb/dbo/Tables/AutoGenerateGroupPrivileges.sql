CREATE TABLE [dbo].[AutoGenerateGroupPrivileges] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [UserGroupID]         INT            NOT NULL,
    [AutoGenerateID]      INT            NOT NULL,
    [HasBrekdown]         BIT            NOT NULL,
    [FormID]              INT            NOT NULL,
    [ModuleID]            INT            NOT NULL,
    [DefaultViewAccess]   BIT            NOT NULL,
    [DefaultInsertAccess] BIT            NOT NULL,
    [DefaultModifyAccess] BIT            NOT NULL,
    [DefaultDeleteAccess] BIT            NOT NULL,
    [DefaultPrintAccess]  BIT            NOT NULL,
    [IPAddress]           NVARCHAR (MAX) NULL,
    [CreatedUserID]       INT            NOT NULL,
    [LastModUserID]       INT            NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [LastModDate]         DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.AutoGenerateGroupPrivileges] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

