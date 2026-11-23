CREATE TABLE [dbo].[CostingSetting] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [CostingName]        VARCHAR (150)   NULL,
    [Percentage]         DECIMAL (18, 2) NULL,
    [Active]             BIT             NULL,
    [PropertyId]         INT             NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [LastEditedUserId]   INT             NULL,
    [LastEditedDateTime] DATETIME        NULL,
    CONSTRAINT [PK_CostingSetting] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

