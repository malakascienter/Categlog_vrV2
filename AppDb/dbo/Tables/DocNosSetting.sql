CREATE TABLE [dbo].[DocNosSetting] (
    [SettingID]      SMALLINT      IDENTITY (1, 1) NOT NULL,
    [Code]           VARCHAR (6)   NULL,
    [Description]    VARCHAR (250) NULL,
    [Value]          VARCHAR (200) NULL,
    [NextNo]         BIGINT        NULL,
    [PossibleValues] VARCHAR (40)  NULL,
    [Prefix]         VARCHAR (5)   NULL,
    [SerialLength]   INT           NULL,
    CONSTRAINT [PK_Setting] PRIMARY KEY CLUSTERED ([SettingID] ASC)
);


GO

