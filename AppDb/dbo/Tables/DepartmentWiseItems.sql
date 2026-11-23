CREATE TABLE [dbo].[DepartmentWiseItems] (
    [Id]           INT IDENTITY (1, 1) NOT NULL,
    [DepartmentId] INT NULL,
    [StockItemId]  INT NULL
);


GO

CREATE NONCLUSTERED INDEX [DepartmentWiseItems_DepartmentId]
    ON [dbo].[DepartmentWiseItems]([StockItemId] ASC)
    INCLUDE([DepartmentId]);


GO

