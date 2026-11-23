CREATE TABLE [dbo].[DayEnd_ValidationChecks] (
    [Id]               INT           NOT NULL,
    [Code]             VARCHAR (10)  NOT NULL,
    [Name]             VARCHAR (100) NOT NULL,
    [TransactionTypes] VARCHAR (50)  NULL,
    [ConfigType]       VARCHAR (10)  NOT NULL,
    [Description]      VARCHAR (500) NULL,
    [SortOrder]        INT           CONSTRAINT [DF_DayEnd_ValidationChecks_SortOrder] DEFAULT ((0)) NOT NULL,
    [IsActive]         BIT           CONSTRAINT [DF_DayEnd_ValidationChecks_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_DayEnd_ValidationChecks] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_DayEnd_ValidationChecks_ConfigType] CHECK ([ConfigType]='TEMPLATE' OR [ConfigType]='DESC'),
    CONSTRAINT [UQ_DayEnd_ValidationChecks_Code] UNIQUE NONCLUSTERED ([Code] ASC)
);


GO

