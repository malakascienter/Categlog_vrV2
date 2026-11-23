CREATE TABLE [dbo].[TransactionWiseEmails] (
    [ID]              INT      IDENTITY (1, 1) NOT NULL,
    [PropertyID]      INT      NULL,
    [LocationID]      INT      NULL,
    [TransactionType] CHAR (5) NULL,
    [UserID]          INT      NULL,
    [IsActive]        BIT      NULL
);


GO

