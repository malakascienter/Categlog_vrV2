CREATE TABLE [dbo].[CustomerSignatures] (
    [Id]                INT            IDENTITY (1, 1) NOT NULL,
    [CustomerId]        INT            NOT NULL,
    [CustomerPerson]    NVARCHAR (MAX) NULL,
    [IsFromBasePath]    BIT            NOT NULL,
    [ImageFileName]     NVARCHAR (MAX) NULL,
    [ImageFileFullPath] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.CustomerSignatures] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

