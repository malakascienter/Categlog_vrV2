CREATE TABLE [dbo].[UserGroups] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [UserGroupName] NVARCHAR (50)  NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [PropertyID]    INT            NULL,
    CONSTRAINT [PK_dbo.UserGroups] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

