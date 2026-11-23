CREATE TABLE [dbo].[LTYC_UserRole] (
    [UserRoleId]   INT            IDENTITY (1, 1) NOT NULL,
    [UserId]       INT            NOT NULL,
    [PropertyId]   INT            NULL,
    [Role]         VARCHAR (20)   NOT NULL,
    [Notes]        NVARCHAR (300) NULL,
    [IsActive]     BIT            CONSTRAINT [DF_LTYC_UserRole_IsActive] DEFAULT ((1)) NOT NULL,
    [CreatedBy]    INT            NOT NULL,
    [CreatedDate]  DATETIME2 (0)  CONSTRAINT [DF_LTYC_UserRole_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]   INT            NULL,
    [ModifiedDate] DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYC_UserRole] PRIMARY KEY CLUSTERED ([UserRoleId] ASC),
    CONSTRAINT [CK_LTYC_UserRole_Role] CHECK ([Role]='ADMIN' OR [Role]='PUBLISHER' OR [Role]='AUTHOR' OR [Role]='VIEWER')
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYC_UserRole_User_Property]
    ON [dbo].[LTYC_UserRole]([UserId] ASC, [PropertyId] ASC) WHERE ([PropertyId] IS NOT NULL);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYC_UserRole_User_Global]
    ON [dbo].[LTYC_UserRole]([UserId] ASC) WHERE ([PropertyId] IS NULL);


GO

