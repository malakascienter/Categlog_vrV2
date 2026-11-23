CREATE TABLE [dbo].[LaborUnits] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [LaborUnitCode] NVARCHAR (MAX) NULL,
    [LaborUnitName] NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.LaborUnits] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

