CREATE TABLE [dbo].[NotificationPanelDetails] (
    [Id]                INT           IDENTITY (1, 1) NOT NULL,
    [HeadingName]       VARCHAR (255) NOT NULL,
    [Type]              VARCHAR (10)  NOT NULL,
    [Color]             VARCHAR (255) NOT NULL,
    [Hint]              VARCHAR (MAX) NOT NULL,
    [TransactionTypeId] INT           NOT NULL,
    [RoutePath]         VARCHAR (255) NULL,
    [FormID]            INT           NULL,
    CONSTRAINT [PK_NotificationPanelDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

