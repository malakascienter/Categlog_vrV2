CREATE TABLE [dbo].[LaborMasters] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [price]         DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    [LaborTypeId]   INT             DEFAULT ((0)) NOT NULL,
    [LaborUnitId]   INT             DEFAULT ((0)) NOT NULL,
    [SupplierId]    INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.LaborMasters] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

