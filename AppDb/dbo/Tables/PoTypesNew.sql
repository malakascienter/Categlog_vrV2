CREATE TABLE [dbo].[PoTypesNew] (
    [Id]       INT            IDENTITY (1, 1) NOT NULL,
    [Name]     NVARCHAR (500) NULL,
    [IsActive] BIT            CONSTRAINT [DF_PoTypesNew_IsActive] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_PoTypesNew] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

