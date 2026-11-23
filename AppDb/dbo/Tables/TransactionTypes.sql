CREATE TABLE [dbo].[TransactionTypes] (
    [Id]                      INT            NOT NULL,
    [Code]                    NVARCHAR (MAX) NULL,
    [Name]                    NVARCHAR (MAX) NULL,
    [GLNarration]             NVARCHAR (MAX) NULL,
    [IsActive]                BIT            NOT NULL,
    [tempDocumentNo]          NVARCHAR (20)  NULL,
    [DocumentNo]              NVARCHAR (20)  NULL,
    [DocumentID]              INT            NOT NULL,
    [CompanyId]               INT            NOT NULL,
    [LocationId]              INT            NOT NULL,
    [IPAddress]               NVARCHAR (MAX) NULL,
    [CreatedUserID]           INT            NOT NULL,
    [LastModUserID]           INT            NOT NULL,
    [CreatedDate]             DATETIME       NOT NULL,
    [LastModDate]             DATETIME       NOT NULL,
    [DocumentTitle]           NVARCHAR (MAX) NULL,
    [PostGLAtDayend]          BIT            DEFAULT ((0)) NOT NULL,
    [GLBLOCKID]               INT            NULL,
    [IsMailNotification]      BIT            CONSTRAINT [DF_TransactionTypes_IsMailNotification] DEFAULT ((0)) NULL,
    [IsWhatsAppNotification]  BIT            CONSTRAINT [DF_TransactionTypes_IsMailNotification1] DEFAULT ((0)) NULL,
    [RejectedReportName]      NVARCHAR (MAX) NULL,
    [SortID]                  INT            CONSTRAINT [DF_TransactionTypes_SortID] DEFAULT ((0)) NULL,
    [AutoCompleteDays]        INT            CONSTRAINT [DF_TransactionTypes_AutoCompleteDays] DEFAULT ((0)) NOT NULL,
    [IsHeaderRemarkMandatory] BIT            CONSTRAINT [DF_TransactionTypes_IsHeaderRemarkMandatory] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.TransactionTypes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

