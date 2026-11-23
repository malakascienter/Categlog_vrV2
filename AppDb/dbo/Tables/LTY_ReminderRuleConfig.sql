CREATE TABLE [dbo].[LTY_ReminderRuleConfig] (
    [Id]             INT IDENTITY (1, 1) NOT NULL,
    [ReminderId]     INT NOT NULL,
    [ReminderRuleId] INT NOT NULL,
    [SendTypeId]     INT NULL,
    [TemplateId]     INT NULL,
    [PropertyId]     INT NULL,
    CONSTRAINT [PK_LTY_ReminderRuleConfig] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTY_ReminderRuleConfig_Reminder]
    ON [dbo].[LTY_ReminderRuleConfig]([ReminderId] ASC, [PropertyId] ASC);


GO

