CREATE TABLE [dbo].[LTY_Reminder] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Name]       VARCHAR (MAX) NOT NULL,
    [IsActive]   BIT           CONSTRAINT [DF_LTY_Reminder_IsActive] DEFAULT ((1)) NOT NULL,
    [PropertyId] INT           NULL,
    CONSTRAINT [PK_LTY_Reminder] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

