CREATE TABLE [dbo].[LabourTypes] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [LabourCode]    NVARCHAR (MAX) NULL,
    [LabourName]    NVARCHAR (MAX) NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.LabourTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

