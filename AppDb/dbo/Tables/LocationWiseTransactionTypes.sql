CREATE TABLE [dbo].[LocationWiseTransactionTypes] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]    INT            NOT NULL,
    [LocationID]    INT            NOT NULL,
    [TransactionID] INT            NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.LocationWiseTransactionTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

