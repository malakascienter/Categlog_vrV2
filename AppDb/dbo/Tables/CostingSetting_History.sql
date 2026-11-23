CREATE TABLE [dbo].[CostingSetting_History] (
    [SysDate]            DATETIME        CONSTRAINT [DF_CostingSetting_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Id]                 INT             NOT NULL,
    [CostingName]        VARCHAR (150)   NULL,
    [Percentage]         DECIMAL (18, 2) NULL,
    [Active]             BIT             NULL,
    [PropertyId]         INT             NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [LastEditedUserId]   INT             NULL,
    [LastEditedDateTime] DATETIME        NULL
);


GO

