CREATE TABLE [dbo].[TableInfo] (
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [IDColumnName]          NVARCHAR (500) NULL,
    [FrindlyName]           NVARCHAR (500) NULL,
    [DescriptiveColumnName] NVARCHAR (500) NULL,
    [TableName]             NVARCHAR (500) NULL,
    CONSTRAINT [PK_TableInfo] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

