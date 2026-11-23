CREATE TABLE [dbo].[DepartmentWiseCostProvisions] (
    [ID]           INT             IDENTITY (1, 1) NOT NULL,
    [BOQID]        INT             NOT NULL,
    [CategoryId]   INT             NOT NULL,
    [DepartmentId] INT             NOT NULL,
    [TotalCost]    DECIMAL (18, 2) NOT NULL,
    [BalanceCost]  DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_DepartmentWiseCostProvisions] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

