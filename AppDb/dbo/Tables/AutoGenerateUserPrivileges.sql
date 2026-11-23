CREATE TABLE [dbo].[AutoGenerateUserPrivileges] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [UserMasterId]   INT            NOT NULL,
    [AutoGenerateID] INT            NOT NULL,
    [HasBrekdown]    BIT            NOT NULL,
    [FormID]         INT            NOT NULL,
    [ModuleID]       INT            NOT NULL,
    [IsViewAccess]   BIT            NOT NULL,
    [IsInsertAccess] BIT            NOT NULL,
    [IsModifyAccess] BIT            NOT NULL,
    [IsDeleteAccess] BIT            NOT NULL,
    [IsPrintAccess]  BIT            NOT NULL,
    [IPAddress]      NVARCHAR (MAX) NULL,
    [CreatedUserID]  INT            NOT NULL,
    [LastModUserID]  INT            NOT NULL,
    [CreatedDate]    DATETIME       NOT NULL,
    [LastModDate]    DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.AutoGenerateUserPrivileges] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

