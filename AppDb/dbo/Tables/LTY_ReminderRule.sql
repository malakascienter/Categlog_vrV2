CREATE TABLE [dbo].[LTY_ReminderRule] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (MAX) NOT NULL,
    [ReminderId] INT           NULL,
    [PropertyId] INT           NULL,
    CONSTRAINT [PK_LTY_ReminderRule] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTY_ReminderRule_Reminder]
    ON [dbo].[LTY_ReminderRule]([ReminderId] ASC, [PropertyId] ASC);


GO

