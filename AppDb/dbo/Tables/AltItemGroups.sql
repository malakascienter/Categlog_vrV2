CREATE TABLE [dbo].[AltItemGroups] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [GropCOde]      NVARCHAR (MAX) NULL,
    [GropName]      NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [PropertyID]    INT            DEFAULT ((0)) NOT NULL,
    [LocationID]    INT            DEFAULT ((0)) NOT NULL,
    [DepartmentID]  INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.AltItemGroups] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

