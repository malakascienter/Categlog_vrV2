CREATE TABLE [dbo].[CostingTypeWisePaymentTypes] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [CostingId]          INT           NULL,
    [PaymentTypeId]      INT           NULL,
    [PayCode]            VARCHAR (4)   NULL,
    [Description]        VARCHAR (150) NULL,
    [Active]             BIT           NULL,
    [PropertyId]         INT           NULL,
    [CreatedUserId]      INT           NULL,
    [CreatedDateTime]    DATETIME      NULL,
    [LastEditedUserId]   INT           NULL,
    [LastEditedDateTime] DATETIME      NULL,
    CONSTRAINT [PK_CostingTypeWisePaymentTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

