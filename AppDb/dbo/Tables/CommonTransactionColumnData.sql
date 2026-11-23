CREATE TABLE [dbo].[CommonTransactionColumnData] (
    [Id]               INT            NULL,
    [TransactionID]    INT            NULL,
    [ColumnData]       NVARCHAR (MAX) NULL,
    [ColumnDetailData] NVARCHAR (MAX) NULL,
    [reportName]       NVARCHAR (300) NULL,
    [Action]           CHAR (1)       NULL,
    [ActionTitle]      VARCHAR (100)  NULL,
    [IsActive]         BIT            CONSTRAINT [DF_CommonTransactionColumnData_IsActive] DEFAULT ((0)) NOT NULL
);


GO

