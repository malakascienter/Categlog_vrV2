CREATE TABLE [dbo].[EvaluationCriteria] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [EvaluationTemplateID] INT           NULL,
    [Criteria]             VARCHAR (MAX) NULL,
    [MaxMarks]             INT           NULL,
    [BenchMarks]           INT           NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [CK_EvaluationCriteria_BenchMarks] CHECK ([BenchMarks] IS NULL OR [BenchMarks]>=(0) AND [BenchMarks]<=[MaxMarks])
);


GO

