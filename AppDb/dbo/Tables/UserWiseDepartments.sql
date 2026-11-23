CREATE TABLE [dbo].[UserWiseDepartments] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [userId]        INT            NOT NULL,
    [deptid]        INT            NOT NULL,
    [companyId]     INT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.UserWiseDepartments] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

