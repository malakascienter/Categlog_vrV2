CREATE TABLE [dbo].[GRNApprovalLog] (
    [Id]                       INT           IDENTITY (1, 1) NOT NULL,
    [SupplierId]               INT           NULL,
    [LocationId]               INT           NULL,
    [ReferenceId]              INT           NULL,
    [XMLDetails]               VARCHAR (MAX) NULL,
    [ApprovedUserId]           INT           NULL,
    [Remarks]                  VARCHAR (250) NULL,
    [Status]                   CHAR (2)      NULL,
    [TransactionType]          CHAR (2)      NULL,
    [CompanyId]                INT           NULL,
    [CreatedUserId]            INT           NULL,
    [CreatedDate]              DATETIME      NULL,
    [DepartmentId]             INT           NULL,
    [ApprovalDocNo]            VARCHAR (MAX) NULL,
    [ReferenceNo]              VARCHAR (MAX) NULL,
    [ApprovedDateTime]         DATETIME      NULL,
    [TransactionHeaderId]      INT           NULL,
    [StockTransactionHeaderID] INT           DEFAULT ((0)) NULL,
    [SeqID]                    INT           CONSTRAINT [DF_GRNApprovalLog_SeqID] DEFAULT ((0)) NULL,
    [ApprovalLevelID]          INT           CONSTRAINT [DF_GRNApprovalLog_ApprovalLevelID] DEFAULT ((0)) NULL,
    [IsComplete]               BIT           CONSTRAINT [DF_GRNApprovalLog_IsComplete] DEFAULT ((0)) NULL,
    [UserProfileId]            INT           CONSTRAINT [DF_GRNApprovalLog_UserProfileId] DEFAULT ((0)) NULL,
    [SendMail]                 BIT           CONSTRAINT [DF_GRNApprovalLog_SendMail] DEFAULT ((0)) NULL,
    [ToLocationID]             INT           CONSTRAINT [DF_GRNApprovalLog_ToLocationID] DEFAULT ((0)) NULL
);


GO

CREATE NONCLUSTERED INDEX [IX_GRNApprovalLog_Supplier_Type]
    ON [dbo].[GRNApprovalLog]([SupplierId] ASC, [TransactionType] ASC)
    INCLUDE([ReferenceNo]);


GO

CREATE NONCLUSTERED INDEX [GRNApprovalLog_1]
    ON [dbo].[GRNApprovalLog]([StockTransactionHeaderID] ASC)
    INCLUDE([ApprovalDocNo]);


GO

CREATE NONCLUSTERED INDEX [IX_GRNApprovalLog_Reference_Type]
    ON [dbo].[GRNApprovalLog]([ReferenceId] ASC, [TransactionType] ASC)
    INCLUDE([ReferenceNo], [StockTransactionHeaderID]);


GO

CREATE NONCLUSTERED INDEX [IX_GRNApprovalLog_Company]
    ON [dbo].[GRNApprovalLog]([CompanyId] ASC)
    INCLUDE([ApprovalDocNo], [Status], [SeqID], [IsComplete]);


GO

CREATE NONCLUSTERED INDEX [IX_GRNApprovalLog_Status_Type_Company]
    ON [dbo].[GRNApprovalLog]([Status] ASC, [TransactionType] ASC, [CompanyId] ASC)
    INCLUDE([CreatedUserId], [LocationId], [SupplierId], [ReferenceId], [SeqID], [UserProfileId], [ApprovalLevelID], [StockTransactionHeaderID], [CreatedDate], [ApprovalDocNo]);


GO

