CREATE TABLE [dbo].[EvaluationCriteriaRange] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [EvaluationTemplateID] INT           NULL,
    [MaxMarks]             INT           NULL,
    [MarksFrom]            INT           NULL,
    [MarksTo]              INT           NULL,
    [Grade]                NVARCHAR (50) NULL,
    [SysDateTime]          DATETIME      NULL,
    [UpdateDateTime]       DATETIME      NULL
);


GO

