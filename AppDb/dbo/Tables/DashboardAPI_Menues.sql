CREATE TABLE [dbo].[DashboardAPI_Menues] (
    [Id]       INT            NOT NULL,
    [ParentId] INT            NULL,
    [Name]     NVARCHAR (MAX) NOT NULL,
    [Link]     NVARCHAR (MAX) NOT NULL,
    [Icon]     NVARCHAR (MAX) NULL,
    [RowId]    INT            IDENTITY (1, 1) NOT NULL,
    [IsActive] BIT            CONSTRAINT [DF_DashboardAPI_Menues_IsActive] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_DashboardAPI_Menues] PRIMARY KEY CLUSTERED ([RowId] ASC)
);


GO

