CREATE TABLE [dbo].[LTY_Settings] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [SettingName] VARCHAR (MAX)  NOT NULL,
    [Value]       NVARCHAR (MAX) NOT NULL,
    [Description] VARCHAR (MAX)  NULL,
    [PropertyId]  INT            NOT NULL,
    CONSTRAINT [PK_LTY_Settings] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

