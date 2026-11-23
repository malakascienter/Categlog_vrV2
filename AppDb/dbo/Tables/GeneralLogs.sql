CREATE TABLE [dbo].[GeneralLogs] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [LogTypesID] INT            NOT NULL,
    [Type]       INT            NOT NULL,
    [Message]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.GeneralLogs] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

