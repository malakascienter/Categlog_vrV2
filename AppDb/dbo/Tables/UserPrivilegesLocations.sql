CREATE TABLE [dbo].[UserPrivilegesLocations] (
    [Id]                        INT            IDENTITY (1, 1) NOT NULL,
    [UserPrivilegesLocationsID] INT            NOT NULL,
    [UserMasterID]              INT            NOT NULL,
    [UserGroupID]               INT            NOT NULL,
    [LocationID]                INT            NOT NULL,
    [IsSelect]                  BIT            NOT NULL,
    [IPAddress]                 NVARCHAR (MAX) NULL,
    [CreatedUserID]             INT            NOT NULL,
    [LastModUserID]             INT            NOT NULL,
    [CreatedDate]               DATETIME       NOT NULL,
    [LastModDate]               DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.UserPrivilegesLocations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

