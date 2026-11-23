CREATE TABLE [dbo].[UserMasters] (
    [Id]                       INT            NOT NULL,
    [CompanyID]                INT            NOT NULL,
    [LocationID]               INT            NOT NULL,
    [UserName]                 NVARCHAR (MAX) NULL,
    [UserDescription]          NVARCHAR (MAX) NULL,
    [Email]                    NVARCHAR (MAX) NULL,
    [Password]                 NVARCHAR (MAX) NULL,
    [UserGroupID]              INT            NOT NULL,
    [IsActive]                 BIT            NOT NULL,
    [IsUserCantChangePassword] BIT            NOT NULL,
    [IsUserMustChangePassword] BIT            NOT NULL,
    [IsDelete]                 BIT            NOT NULL,
    [EmployeeId]               INT            NOT NULL,
    [IPAddress]                NVARCHAR (MAX) NULL,
    [CreatedUserID]            INT            NOT NULL,
    [LastModUserID]            INT            NOT NULL,
    [CreatedDate]              DATETIME       NOT NULL,
    [LastModDate]              DATETIME       NOT NULL,
    [FirstName]                NVARCHAR (MAX) NULL,
    [LastName]                 NVARCHAR (MAX) NULL,
    [IsPOSUser]                BIT            CONSTRAINT [DF_UserMasters_IsPOSUser] DEFAULT ((0)) NULL,
    [AccessCard]               VARCHAR (50)   NULL
);


GO

