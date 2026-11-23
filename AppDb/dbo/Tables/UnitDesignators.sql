CREATE TABLE [dbo].[UnitDesignators] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [CompanyID]     INT             NOT NULL,
    [UnitID]        INT             NOT NULL,
    [Name]          NVARCHAR (MAX)  NULL,
    [Rate]          DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.UnitDesignators] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

