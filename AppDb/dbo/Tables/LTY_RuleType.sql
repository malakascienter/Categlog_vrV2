CREATE TABLE [dbo].[LTY_RuleType] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (MAX) NOT NULL,
    [IsActive]   BIT           CONSTRAINT [DF_LTY_RuleType_IsActive] DEFAULT ((0)) NOT NULL,
    [PropertyId] INT           NULL,
    CONSTRAINT [PK_LTY_RuleType] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

