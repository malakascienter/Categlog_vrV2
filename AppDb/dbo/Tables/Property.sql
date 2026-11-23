CREATE TABLE [dbo].[Property] (
    [Id]               INT            NOT NULL,
    [Name]             NVARCHAR (50)  NOT NULL,
    [Image]            NVARCHAR (50)  NULL,
    [LogoURL]          NVARCHAR (50)  NULL,
    [Address]          NVARCHAR (100) NULL,
    [Email]            NVARCHAR (50)  NULL,
    [ContactNo]        NVARCHAR (50)  NULL,
    [IsActive]         BIT            NOT NULL,
    [PropertyServer]   VARCHAR (100)  CONSTRAINT [DF_Property_PropertyServer] DEFAULT ('') NOT NULL,
    [PropertyDatabase] VARCHAR (100)  CONSTRAINT [DF_Property_PropertyDatabase] DEFAULT ('') NOT NULL,
    [GLCOMPCODE]       CHAR (3)       NULL,
    CONSTRAINT [PK_HProperties] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

