CREATE TABLE [dbo].[Urls] (
    [Id]          NVARCHAR (128) NOT NULL,
    [ServiceName] NVARCHAR (MAX) NULL,
    [Url]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.Urls] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

