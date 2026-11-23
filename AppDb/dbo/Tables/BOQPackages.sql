CREATE TABLE [dbo].[BOQPackages] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [Description] NVARCHAR (MAX)  NULL,
    [length]      DECIMAL (18, 2) NOT NULL,
    [ProjectID]   INT             DEFAULT ((0)) NOT NULL,
    [LocationId]  INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BOQPackages] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

