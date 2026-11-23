CREATE TABLE [dbo].[SPO_CommonTransactionColumnConfiguration] (
    [Id]               INT            NULL,
    [TransactionID]    INT            NULL,
    [ColumnHeaderData] NVARCHAR (MAX) NULL,
    [ColumnDetailData] NVARCHAR (MAX) NULL,
    [reportName]       NVARCHAR (300) NULL,
    [Action]           CHAR (3)       NULL,
    [ActionTitle]      VARCHAR (200)  NULL,
    [IsActive]         BIT            CONSTRAINT [DF_SPO_CommonTransactionColumnConfiguration_IsActive] DEFAULT ((0)) NOT NULL,
    [DropdownData]     NVARCHAR (MAX) NULL,
    [EnableAction]     NVARCHAR (MAX) NULL
);


GO

