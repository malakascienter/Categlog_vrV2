CREATE TABLE [dbo].[CashierHeader] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]   INT             NULL,
    [LocationID]   INT             NULL,
    [SystemDate]   DATETIME        NULL,
    [CashierValue] DECIMAL (18, 8) NULL,
    [UserID]       INT             NULL,
    [Remark]       VARCHAR (100)   NULL,
    [SystemAmount] DECIMAL (18, 8) NULL
);


GO

