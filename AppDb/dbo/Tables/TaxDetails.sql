CREATE TABLE [dbo].[TaxDetails] (
    [TaxTypeId]         INT             IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (MAX)  NULL,
    [Rate]              DECIMAL (18, 2) NOT NULL,
    [TransactionCodeId] INT             NOT NULL,
    [AccountId]         BIGINT          NOT NULL,
    [IsActive]          BIT             NOT NULL,
    [IPAddress]         NVARCHAR (MAX)  NULL,
    [CreatedUserID]     INT             NOT NULL,
    [LastModUserID]     INT             NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [LastModDate]       DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.TaxDetails] PRIMARY KEY CLUSTERED ([TaxTypeId] ASC)
);


GO

