CREATE TABLE [dbo].[SPO_TransactionApprovalLog] (
    [Id]                  INT            IDENTITY (1, 1) NOT NULL,
    [TransactionTypeID]   INT            NULL,
    [TransactionHeaderID] INT            NULL,
    [UserProfileID]       INT            NULL,
    [IsApproved]          BIT            NULL,
    [TransactionStatus]   CHAR (1)       NULL,
    [CreatedUserID]       INT            NULL,
    [LastModifiedUserID]  INT            NULL,
    [CreatedDate]         DATETIME       NULL,
    [LastModifiedDate]    DATETIME       NULL,
    [LocationID]          CHAR (5)       NULL,
    [OldData]             NVARCHAR (MAX) NULL,
    [NewData]             NVARCHAR (MAX) NULL
);


GO

