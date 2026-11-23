CREATE TABLE [dbo].[ConsigmentItemsSalesDetails] (
    [ID]              INT             IDENTITY (1, 1) NOT NULL,
    [DocumentNo]      VARCHAR (MAX)   NULL,
    [SupplierID]      INT             NULL,
    [LocationID]      INT             NULL,
    [TransactionDate] DATE            NULL,
    [UnitPrice]       DECIMAL (18, 8) NULL,
    [GRNQty]          DECIMAL (18, 8) NULL,
    [SalesQty]        DECIMAL (18, 8) NULL,
    [BusinessDate]    DATE            NULL,
    [SysDateTime]     DATETIME        NULL
);


GO

