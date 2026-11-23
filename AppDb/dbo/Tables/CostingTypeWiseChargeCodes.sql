CREATE TABLE [dbo].[CostingTypeWiseChargeCodes] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [CostingId]          INT           NULL,
    [ChargeTypeId]       INT           NULL,
    [Description]        VARCHAR (200) NULL,
    [Active]             BIT           NULL,
    [PropertyId]         INT           NULL,
    [CreatedUserId]      INT           NULL,
    [CreatedDateTime]    DATETIME      NULL,
    [LastEditedUserId]   INT           NULL,
    [LastEditedDateTime] DATETIME      NULL,
    CONSTRAINT [PK_CostingChargeCodes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

