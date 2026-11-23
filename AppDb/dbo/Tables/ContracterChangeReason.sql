CREATE TABLE [dbo].[ContracterChangeReason] (
    [ID]                           INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]                   INT             NULL,
    [LocationID]                   INT             NULL,
    [StockItemID]                  INT             NULL,
    [TransactionHeaderID]          INT             NULL,
    [TransactionType]              CHAR (5)        NULL,
    [SupplierID]                   INT             NULL,
    [SupplierPrice]                DECIMAL (18, 6) NULL,
    [ContractedSupplierID]         INT             NULL,
    [ContractSupplierPrice]        DECIMAL (18, 6) NULL,
    [ContractSupplierChangeReason] VARCHAR (MAX)   NULL,
    [CreatedUserID]                INT             NULL,
    [CreatedDate]                  DATETIME        NULL
);


GO

