CREATE TABLE [dbo].[LaborTypeMasterFiles] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [LabourCode]    NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [PropertyID]    INT            DEFAULT ((0)) NOT NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [price]         FLOAT (53)     DEFAULT ((0)) NOT NULL,
    [CostTypeID]    INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.LaborTypeMasterFiles] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

