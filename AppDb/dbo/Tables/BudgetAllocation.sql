CREATE TABLE [dbo].[BudgetAllocation] (
    [ID]            INT             IDENTITY (1, 1) NOT NULL,
    [LocationID]    INT             NULL,
    [PropertyID]    INT             NULL,
    [Budget]        DECIMAL (18, 8) NULL,
    [Balance]       DECIMAL (18, 8) NULL,
    [UtilizeAmount] DECIMAL (18, 8) NULL,
    [CreatedUserID] INT             NULL,
    [LastModUserID] INT             NULL,
    [CreatedDate]   DATETIME        NULL,
    [LastModDate]   DATETIME        NULL
);


GO

