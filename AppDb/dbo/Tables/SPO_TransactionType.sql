CREATE TABLE [dbo].[SPO_TransactionType] (
    [Id]                 INT            IDENTITY (1, 1) NOT NULL,
    [Code]               CHAR (5)       NULL,
    [Transaction]        VARCHAR (300)  NULL,
    [IsCutOffValue]      BIT            CONSTRAINT [DF_SPO_TransactionType_IsCutOffValue] DEFAULT ((0)) NOT NULL,
    [DropdownData]       NVARCHAR (MAX) NULL,
    [IsDropdown]         BIT            CONSTRAINT [DF_SPO_TransactionType_IsDropdown] DEFAULT ((0)) NOT NULL,
    [IsApprovalRequired] BIT            CONSTRAINT [DF_SPO_TransactionType_IsApprovalRequired] DEFAULT ((0)) NOT NULL
);


GO

