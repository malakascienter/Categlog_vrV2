CREATE TABLE [dbo].[Countries] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [CountryName] NVARCHAR (150) NOT NULL,
    [ISO2]        CHAR (2)       NOT NULL,
    [ISO3]        CHAR (3)       NOT NULL,
    [IsActive]    BIT            CONSTRAINT [DF_Countries_IsActive] DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [UQ_Countries_ISO2] UNIQUE NONCLUSTERED ([ISO2] ASC),
    CONSTRAINT [UQ_Countries_ISO3] UNIQUE NONCLUSTERED ([ISO3] ASC)
);


GO

