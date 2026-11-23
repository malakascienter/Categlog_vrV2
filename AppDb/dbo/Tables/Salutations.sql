CREATE TABLE [dbo].[Salutations] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [Name]       NVARCHAR (100) NULL,
    [IsActive]   BIT            NULL,
    [PropertyId] INT            NULL,
    CONSTRAINT [PK_Salutations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

