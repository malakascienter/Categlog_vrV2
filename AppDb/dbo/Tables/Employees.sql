CREATE TABLE [dbo].[Employees] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [CompanyID]       INT             NOT NULL,
    [LocationID]      INT             NOT NULL,
    [DepartmentID]    INT             NOT NULL,
    [Code]            NVARCHAR (MAX)  NULL,
    [Title]           NVARCHAR (MAX)  NULL,
    [Name]            NVARCHAR (MAX)  NULL,
    [Designation]     NVARCHAR (MAX)  NULL,
    [Gender]          NVARCHAR (MAX)  NULL,
    [Remark]          NVARCHAR (MAX)  NULL,
    [Address1]        NVARCHAR (MAX)  NULL,
    [Address2]        NVARCHAR (MAX)  NULL,
    [Address3]        NVARCHAR (MAX)  NULL,
    [Email]           NVARCHAR (MAX)  NULL,
    [Telephone]       NVARCHAR (MAX)  NULL,
    [Mobile]          NVARCHAR (MAX)  NULL,
    [Image]           VARBINARY (MAX) NULL,
    [IsActive]        BIT             NOT NULL,
    [MinimumDiscount] DECIMAL (18, 2) NOT NULL,
    [CrLimit]         DECIMAL (18, 2) NOT NULL,
    [PchLimit]        DECIMAL (18, 2) NOT NULL,
    [AccCredit]       DECIMAL (18, 2) NOT NULL,
    [AccPch]          DECIMAL (18, 2) NOT NULL,
    [IsDelete]        BIT             NOT NULL,
    [CostCenterID]    INT             NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.Employees] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

