CREATE TABLE [dbo].[ProcurementEvaluation] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [ProcurementID]        INT           NULL,
    [SupplierID]           INT           NULL,
    [EvaluationCriteriaID] INT           NULL,
    [AssignedScore]        INT           NULL,
    [Criteria]             VARCHAR (MAX) NULL,
    [MaxMarks]             INT           NULL,
    [UserID]               INT           NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

