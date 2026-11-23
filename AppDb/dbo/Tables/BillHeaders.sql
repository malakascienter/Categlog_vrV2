CREATE TABLE [dbo].[BillHeaders] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [BillNumber]      NVARCHAR (MAX)  NULL,
    [BillDate]        DATETIME        NOT NULL,
    [ProjectID]       INT             NOT NULL,
    [CustomerId]      INT             NOT NULL,
    [TotalVal]        DECIMAL (18, 2) NOT NULL,
    [LogDate]         DATETIME        NOT NULL,
    [Invoiced]        BIT             NOT NULL,
    [InvoicedDate]    DATETIME        NOT NULL,
    [Status]          NVARCHAR (MAX)  NULL,
    [Completed]       BIT             NOT NULL,
    [IsApproved]      BIT             NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    [PropertyID]      INT             NOT NULL,
    [LocationID]      INT             NOT NULL,
    [TransactionType] NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.BillHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

