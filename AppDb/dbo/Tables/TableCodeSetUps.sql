CREATE TABLE [dbo].[TableCodeSetUps] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [TableName]          NVARCHAR (50)  NULL,
    [IsCodeAutoGenerate] BIT            NOT NULL,
    [Description]        NVARCHAR (100) NULL,
    [Prifix]             NVARCHAR (3)   NULL,
    [NextNo]             INT            NOT NULL,
    [FeildLegnth]        INT            NOT NULL,
    CONSTRAINT [PK_dbo.TableCodeSetUps] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

