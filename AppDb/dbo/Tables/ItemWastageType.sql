CREATE TABLE [dbo].[ItemWastageType] (
    [Id]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (50) CONSTRAINT [DF_ItemWastageType_Name] DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_ItemWastageType] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

